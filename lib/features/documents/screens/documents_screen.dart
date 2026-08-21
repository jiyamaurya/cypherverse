import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:pdfx/pdfx.dart';

import '../../../core/logic/scheme_loader.dart';
import '../../../core/logic/scheme_matcher.dart';
import '../../../core/state/profile_store.dart';
import '../../../core/state/document_store.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  COLOR TOKENS  (shared across the whole app)
// ─────────────────────────────────────────────────────────────────────────────
const kDarkGreen = Color(0xFF1B5E20);
const kMedGreen = Color(0xFF2E7D32);
const kLightGreen = Color(0xFF43A047);
const kOrange = Color(0xFFEF6C00);
const kBg = Color(0xFFF7F6F0);

// A document your app actually needs — computed from the real schemes you're
// eligible/possibly-eligible for, not a fixed hardcoded list.
class _RequiredDoc {
  final String name;
  final List<String> neededFor; // scheme names that require this document
  _RequiredDoc({required this.name, required this.neededFor});
}

String _typeFor(String name) {
  final n = name.toLowerCase();
  if (n.contains('aadhaar') || n.contains('आधार') || n.contains('pan') || n.contains('पैन') ||
      n.contains('voter') || n.contains('ration') || n.contains('राशन') || n.contains('caste') ||
      n.contains('जाति') || n.contains('domicile') || n.contains('birth') || n.contains('age proof') ||
      n.contains('आयु प्रमाण') || n.contains('id')) {
    return 'identity';
  }
  if (n.contains('bank') || n.contains('बैंक') || n.contains('passbook') || n.contains('पासबुक') || n.contains('account')) {
    return 'bank';
  }
  if (n.contains('land') || n.contains('भूमि') || n.contains('khasra') || n.contains('khatauni') ||
      n.contains('7/12') || n.contains('patta')) {
    return 'land';
  }
  if (n.contains('income') || n.contains('आय')) return 'income';
  return 'other';
}

IconData _iconFor(String name) {
  final n = name.toLowerCase();
  if (n.contains('aadhaar') || n.contains('आधार')) return Icons.shield_outlined;
  if (n.contains('pan') || n.contains('पैन')) return Icons.credit_card_outlined;
  if (n.contains('bank') || n.contains('passbook') || n.contains('बैंक') || n.contains('पासबुक')) {
    return Icons.account_balance_outlined;
  }
  if (n.contains('land') || n.contains('khasra') || n.contains('khatauni') || n.contains('भूमि')) {
    return Icons.landscape_outlined;
  }
  if (n.contains('income') || n.contains('आय')) return Icons.receipt_long_outlined;
  if (n.contains('caste') || n.contains('जाति')) return Icons.groups_outlined;
  if (n.contains('ration') || n.contains('राशन')) return Icons.food_bank_outlined;
  if (n.contains('photo')) return Icons.photo_camera_outlined;
  if (n.contains('certificate') || n.contains('प्रमाण')) return Icons.description_outlined;
  return Icons.insert_drive_file_outlined;
}

// ─────────────────────────────────────────────────────────────────────────────
//  DOCUMENTS SCREEN
// ─────────────────────────────────────────────────────────────────────────────
class DocumentsScreen extends StatefulWidget {
  const DocumentsScreen({super.key});

  @override
  State<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends State<DocumentsScreen> {
  int _selectedNavIndex = 3;
  int _selectedCategory = 0;
  String _searchQuery = '';
  bool _sortMissingFirst = false;

  late Future<List<_RequiredDoc>> _docsFuture;

  @override
  void initState() {
    super.initState();
    _docsFuture = _loadRequiredDocs();
  }

  // Pulls the REAL list of required documents from the schemes the farmer
  // is actually eligible / possibly-eligible for (via the same matcher used
  // on the Schemes screen) — not a hardcoded fake list.
  Future<List<_RequiredDoc>> _loadRequiredDocs() async {
    final schemes = await loadSchemes();
    await DocumentStore.instance.load();

    final Map<String, _RequiredDoc> byName = {};
    if (ProfileStore.instance.hasProfile) {
      final profile = ProfileStore.instance.profile;
      final results = matchSchemes(profile, schemes);
      for (final r in results) {
        if (r.status == EligibilityStatus.notEligible) continue;
        for (final docName in r.scheme.documentsNeeded) {
          final clean = docName.trim();
          if (clean.isEmpty || clean.toLowerCase() == 'none mentioned') continue;
          final key = clean.toLowerCase();
          byName.putIfAbsent(key, () => _RequiredDoc(name: clean, neededFor: []));
          byName[key]!.neededFor.add(r.scheme.schemeName);
        }
      }
    }
    final list = byName.values.toList()..sort((a, b) => a.name.compareTo(b.name));
    return list;
  }

  // ── Navigation routing ────────────────────────────────────────────────────
  void _onNavTap(int index) {
    if (index == _selectedNavIndex) return;
    setState(() => _selectedNavIndex = index);

    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/home');
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/schemes');
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/chat');
        break;
      case 3:
        // Already here
        break;
      case 4:
        Navigator.pushReplacementNamed(context, '/profile');
        break;
    }
  }

  // ── Data ──────────────────────────────────────────────────────────────────
  final List<Map<String, dynamic>> _categories = [
    {'icon': Icons.grid_view_rounded, 'label': 'सभी दस्तावेज'},
    {'icon': Icons.badge_outlined, 'label': 'पहचान पत्र'},
    {'icon': Icons.account_balance_outlined, 'label': 'बैंक दस्तावेज'},
    {'icon': Icons.landscape_outlined, 'label': 'भूमि रिकॉर्ड'},
    {'icon': Icons.receipt_long_outlined, 'label': 'आय प्रमाण'},
    {'icon': Icons.more_horiz, 'label': 'अन्य'},
  ];

  // Renders the first page of a PDF (given as raw bytes) to a PNG thumbnail
  // for preview — same visual treatment images already get. Returns null if
  // rendering fails for any reason (corrupt file, unsupported PDF, etc.),
  // in which case the dialog falls back to an honest "no preview" icon
  // instead of crashing the upload.
  Future<Uint8List?> _renderPdfThumbnail(Uint8List pdfBytes) async {
    // pdfx's web renderer can throw at the JS/promise layer in ways that
    // escape Dart's try/catch entirely, destabilizing the whole app.
    // Skip PDF thumbnail rendering on web and just show the file icon.
    if (kIsWeb) return null;
    try {
      final doc = await PdfDocument.openData(pdfBytes);
      final page = await doc.getPage(1);
      final rendered = await page.render(
        width: page.width * 1.5,
        height: page.height * 1.5,
        format: PdfPageImageFormat.png,
      );
      await page.close();
      await doc.close();
      return rendered?.bytes;
    } catch (_) {
      return null;
    }
  }

  // ── Real upload flow — opens the device/browser file picker ────────────────
  Future<void> _uploadFor(_RequiredDoc doc) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
        // Always load bytes — this is what lets us show a real preview of
        // what you uploaded (image thumbnail, or a rendered PDF page) for
        // the current session, on every platform, not just web.
        withData: true,
      );
      if (result == null || result.files.isEmpty) return; // user cancelled
      final file = result.files.first;
      final ext = file.extension?.toLowerCase() ?? '';
      final isImage = ['jpg', 'jpeg', 'png'].contains(ext);
      final isPdf = ext == 'pdf';

      Uint8List? previewBytes;
      if (isImage) {
        previewBytes = file.bytes;
      } else if (isPdf && file.bytes != null) {
        previewBytes = await _renderPdfThumbnail(file.bytes!);
      }

      await DocumentStore.instance.save(
        UploadedDoc(
          docName: doc.name,
          fileName: file.name,
          filePath: kIsWeb ? null : file.path,
          sizeBytes: file.size,
          uploadedAt: DateTime.now(),
        ),
        previewBytes: previewBytes,
      );
      if (!mounted) return;
      setState(() {}); // upload state is read synchronously from DocumentStore
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${file.name} अपलोड हो गया / uploaded successfully',
              style: const TextStyle(fontWeight: FontWeight.w600)),
          backgroundColor: kDarkGreen,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('अपलोड विफल / Upload failed: $e',
              style: const TextStyle(fontWeight: FontWeight.w600)),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  Future<void> _removeDoc(_RequiredDoc doc) async {
    await DocumentStore.instance.remove(doc.name);
    if (!mounted) return;
    setState(() {});
  }

  void _showDocDialog(_RequiredDoc doc) {
    final uploaded = DocumentStore.instance.get(doc.name);
    final previewBytes = DocumentStore.instance.getPreviewBytes(doc.name);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(doc.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
        content: uploaded == null
            ? const Text('यह दस्तावेज अभी अपलोड नहीं हुआ है। / This document has not been uploaded yet.')
            : Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
                if (previewBytes != null) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.memory(
                      previewBytes,
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: 180,
                        width: double.infinity,
                        decoration: BoxDecoration(color: kBg, borderRadius: BorderRadius.circular(10)),
                        alignment: Alignment.center,
                        child: Column(mainAxisSize: MainAxisSize.min, children: [
                          const Icon(Icons.picture_as_pdf_outlined, color: kDarkGreen, size: 28),
                          const SizedBox(height: 4),
                          Text(
                            'पूर्वावलोकन लोड नहीं हो सका / Preview could not be loaded',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 10.5, color: Colors.grey.shade600),
                          ),
                        ]),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                ] else
                  Container(
                    height: 90,
                    width: double.infinity,
                    decoration: BoxDecoration(color: kBg, borderRadius: BorderRadius.circular(10)),
                    alignment: Alignment.center,
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      const Icon(Icons.picture_as_pdf_outlined, color: kDarkGreen, size: 28),
                      const SizedBox(height: 4),
                      Text(
                        'सत्र फिर से खुलने पर पूर्वावलोकन उपलब्ध नहीं होगा / Preview couldn\'t be generated for this file',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 10.5, color: Colors.grey.shade600),
                      ),
                    ]),
                  ),
                Row(children: [
                  const Icon(Icons.insert_drive_file, color: kDarkGreen, size: 20),
                  const SizedBox(width: 8),
                  Expanded(child: Text(uploaded.fileName, overflow: TextOverflow.ellipsis)),
                ]),
                const SizedBox(height: 8),
                Text('Size: ${uploaded.prettySize}', style: TextStyle(color: Colors.grey.shade600, fontSize: 12.5)),
                const SizedBox(height: 4),
                Text(
                  'Uploaded: ${uploaded.uploadedAt.day}/${uploaded.uploadedAt.month}/${uploaded.uploadedAt.year} '
                  '${uploaded.uploadedAt.hour.toString().padLeft(2, '0')}:${uploaded.uploadedAt.minute.toString().padLeft(2, '0')}',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12.5),
                ),
                if (doc.neededFor.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text('Needed for: ${doc.neededFor.join(', ')}',
                      style: TextStyle(color: Colors.grey.shade700, fontSize: 12.5, fontStyle: FontStyle.italic)),
                ],
              ]),
        actions: [
          if (uploaded != null)
            TextButton(
              onPressed: () { Navigator.pop(ctx); _removeDoc(doc); },
              child: Text('Remove', style: TextStyle(color: Colors.red.shade600, fontWeight: FontWeight.w700)),
            ),
          TextButton(
            onPressed: () { Navigator.pop(ctx); _uploadFor(doc); },
            child: Text(uploaded == null ? 'Upload' : 'Replace',
                style: const TextStyle(color: kDarkGreen, fontWeight: FontWeight.w700)),
          ),
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
        ],
      ),
    );
  }

  // ── Filter documents by category + search ───────────────────────────────
  List<_RequiredDoc> _filtered(List<_RequiredDoc> all) {
    var list = all;
    if (_selectedCategory != 0) {
      final typeMap = {1: 'identity', 2: 'bank', 3: 'land', 4: 'income'};
      final type = typeMap[_selectedCategory];
      if (type != null) list = list.where((d) => _typeFor(d.name) == type).toList();
      if (_selectedCategory == 5) list = all.where((d) => _typeFor(d.name) == 'other').toList();
    }
    if (_searchQuery.trim().isNotEmpty) {
      final q = _searchQuery.trim().toLowerCase();
      list = list.where((d) => d.name.toLowerCase().contains(q)).toList();
    }
    list = List.of(list);
    if (_sortMissingFirst) {
      list.sort((a, b) {
        final aUp = DocumentStore.instance.isUploaded(a.name);
        final bUp = DocumentStore.instance.isUploaded(b.name);
        if (aUp == bUp) return a.name.compareTo(b.name);
        return aUp ? 1 : -1; // missing (not uploaded) first
      });
    }
    return list;
  }

  // ─────────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);

    return Scaffold(
      backgroundColor: kBg,
      bottomNavigationBar: _BottomNavBar(
        selectedIndex: _selectedNavIndex,
        onTap: _onNavTap,
      ),
      body: FutureBuilder<List<_RequiredDoc>>(
        future: _docsFuture,
        builder: (context, snapshot) {
          final loading = snapshot.connectionState == ConnectionState.waiting;
          final allDocs = snapshot.data ?? const <_RequiredDoc>[];
          final filteredDocs = _filtered(allDocs);
          final uploadedCount = allDocs.where((d) => DocumentStore.instance.isUploaded(d.name)).length;
          final missingCount = allDocs.length - uploadedCount;

          return Column(
            children: [
              // ── STICKY HEADER ZONE ─────────────────────────────────────
              _StickyHeader(
                selectedCategory: _selectedCategory,
                categories: _categories,
                onCategoryChanged: (i) => setState(() => _selectedCategory = i),
                onSearchChanged: (q) => setState(() => _searchQuery = q),
              ),

              // ── SCROLLABLE CONTENT ZONE ────────────────────────────────
              Expanded(
                child: Container(
                  color: kBg,
                  child: loading
                      ? const Center(child: CircularProgressIndicator(color: kDarkGreen))
                      : !ProfileStore.instance.hasProfile
                          ? _NoProfileState(onFillProfile: () =>
                              Navigator.pushReplacementNamed(context, '/profile-setup'))
                          : allDocs.isEmpty
                              ? const _NoDocsNeededState()
                              : ListView(
                                  padding: EdgeInsets.zero,
                                  physics: const BouncingScrollPhysics(),
                                  children: [
                                    // Status summary — real Uploaded/Missing counts
                                    Container(
                                      decoration: const BoxDecoration(
                                        color: kBg,
                                        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                                      ),
                                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                                      child: _StatusSummary(
                                        uploaded: uploadedCount,
                                        missing: missingCount,
                                        total: allDocs.length,
                                      ),
                                    ),
                                    const SizedBox(height: 12),

                                    // Section header
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                                      child: _SectionHeader(
                                        count: filteredDocs.length,
                                        sortMissingFirst: _sortMissingFirst,
                                        onToggleSort: () => setState(() => _sortMissingFirst = !_sortMissingFirst),
                                      ),
                                    ),

                                    if (filteredDocs.isEmpty)
                                      const Padding(
                                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                                        child: Text(
                                          'इस श्रेणी में कोई दस्तावेज नहीं मिला / No documents found in this category',
                                          style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w600),
                                        ),
                                      ),

                                    // Document list — built from real eligible-scheme requirements
                                    ...filteredDocs.map(
                                      (doc) => Padding(
                                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                                        child: _DocumentCard(
                                          doc: doc,
                                          uploaded: DocumentStore.instance.get(doc.name),
                                          onUpload: () => _uploadFor(doc),
                                          onTap: () => _showDocDialog(doc),
                                        ),
                                      ),
                                    ),

                                    // Upload button — opens a picker for the first missing doc,
                                    // or a chooser if several are still missing.
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 14),
                                      child: _UploadButton(
                                        onTap: () async {
                                          final missing = allDocs
                                              .where((d) => !DocumentStore.instance.isUploaded(d.name))
                                              .toList();
                                          if (missing.isEmpty) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(
                                                content: Text('सभी दस्तावेज पहले से अपलोड हैं / All documents already uploaded'),
                                                backgroundColor: kDarkGreen,
                                              ),
                                            );
                                            return;
                                          }
                                          if (missing.length == 1) {
                                            _uploadFor(missing.first);
                                            return;
                                          }
                                          final chosen = await showModalBottomSheet<_RequiredDoc>(
                                            context: context,
                                            isScrollControlled: true,
                                            shape: const RoundedRectangleBorder(
                                              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                                            ),
                                            builder: (ctx) => DraggableScrollableSheet(
                                              expand: false,
                                              initialChildSize: 0.55,
                                              minChildSize: 0.3,
                                              maxChildSize: 0.9,
                                              builder: (ctx, scrollController) => SafeArea(
                                                child: Column(children: [
                                                  Container(
                                                    margin: const EdgeInsets.only(top: 10),
                                                    width: 40, height: 4,
                                                    decoration: BoxDecoration(
                                                      color: Colors.grey.shade300,
                                                      borderRadius: BorderRadius.circular(4),
                                                    ),
                                                  ),
                                                  const Padding(
                                                    padding: EdgeInsets.all(16),
                                                    child: Text('किस दस्तावेज के लिए अपलोड करें? / Upload for which document?',
                                                        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                                                  ),
                                                  Expanded(
                                                    child: ListView(
                                                      controller: scrollController,
                                                      padding: const EdgeInsets.only(bottom: 16),
                                                      children: missing.map((d) => ListTile(
                                                            leading: Icon(_iconFor(d.name), color: kDarkGreen),
                                                            title: Text(d.name),
                                                            onTap: () => Navigator.pop(ctx, d),
                                                          )).toList(),
                                                    ),
                                                  ),
                                                ]),
                                              ),
                                            ),
                                          );
                                          if (chosen != null) _uploadFor(chosen);
                                        },
                                      ),
                                    ),

                                    // Help banner
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                                      child: _HelpBanner(onAskTap: () => Navigator.pushReplacementNamed(context, '/chat')),
                                    ),
                                  ],
                                ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  EMPTY STATES — honest messaging instead of a fake-looking blank screen
// ─────────────────────────────────────────────────────────────────────────────
class _NoProfileState extends StatelessWidget {
  final VoidCallback onFillProfile;
  const _NoProfileState({required this.onFillProfile});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.person_search_outlined, size: 56, color: kMedGreen),
          const SizedBox(height: 16),
          const Text('पहले अपनी प्रोफ़ाइल भरें', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: kDarkGreen)),
          const SizedBox(height: 6),
          Text('Fill your profile so we know which documents you actually need',
              textAlign: TextAlign.center, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: onFillProfile,
            style: ElevatedButton.styleFrom(
              backgroundColor: kDarkGreen,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('प्रोफ़ाइल भरें / Fill Profile', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
          ),
        ]),
      ),
    );
  }
}

class _NoDocsNeededState extends StatelessWidget {
  const _NoDocsNeededState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.info_outline, size: 56, color: kMedGreen),
          const SizedBox(height: 16),
          const Text('अभी कोई दस्तावेज आवश्यक नहीं', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: kDarkGreen)),
          const SizedBox(height: 6),
          Text('No documents are required yet — check "My Eligibility" first',
              textAlign: TextAlign.center, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
        ]),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  STICKY HEADER — identical background treatment to HomeScreen
// ─────────────────────────────────────────────────────────────────────────────
class _StickyHeader extends StatelessWidget {
  final int selectedCategory;
  final List<Map<String, dynamic>> categories;
  final ValueChanged<int> onCategoryChanged;

  final ValueChanged<String> onSearchChanged;

  const _StickyHeader({
    required this.selectedCategory,
    required this.categories,
    required this.onCategoryChanged,
    required this.onSearchChanged,
  });

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Container(
      decoration: const BoxDecoration(color: kBg),
      child: Stack(
        children: [
          // ── Hero image — IDENTICAL to HomeScreen ─────────────────────
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            bottom: 0,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  'assets/images/home_bg.png',
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                  errorBuilder: (_, _, _) => Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0xFFE8F5E9), Color(0xFFC8E6C9)],
                      ),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.transparent,
                          kBg.withValues(alpha: 0.8),
                          kBg,
                        ],
                        stops: const [0.0, 0.6, 0.85, 1.0],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── UI content over image ────────────────────────────────────
          Padding(
            padding: EdgeInsets.only(
              top: topPadding + 10,
              left: 16,
              right: 16,
              bottom: 14,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Title row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Back button
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_new,
                          size: 19,
                          color: kDarkGreen,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'दस्तावेज',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                            color: kDarkGreen,
                            letterSpacing: -0.5,
                            shadows: [
                              Shadow(color: Colors.white60, blurRadius: 8),
                            ],
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'अपने सभी दस्तावेज एक जगह',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: kMedGreen,
                            shadows: [
                              Shadow(color: Colors.white54, blurRadius: 6),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    // Language pill
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: const Row(
                        children: [
                          Text(
                            'हिंदी',
                            style: TextStyle(
                              color: kDarkGreen,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                          SizedBox(width: 4),
                          Icon(
                            Icons.keyboard_arrow_down,
                            color: kDarkGreen,
                            size: 16,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Avatar
                    Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          child: const CircleAvatar(
                            radius: 18,
                            backgroundColor: Color(0xFFBCAAA4),
                            child: Icon(
                              Icons.person,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: kDarkGreen,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // Search bar
                _SearchBar(onChanged: onSearchChanged),

                const SizedBox(height: 14),

                // Category chips
                _CategoryChips(
                  categories: categories,
                  selected: selectedCategory,
                  onChanged: onCategoryChanged,
                ),

                const SizedBox(height: 4),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  SEARCH BAR — matches HomeScreen exactly
// ─────────────────────────────────────────────────────────────────────────────
class _SearchBar extends StatelessWidget {
  final ValueChanged<String> onChanged;
  const _SearchBar({required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: TextField(
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: 'दस्तावेज खोजें',
          hintStyle: TextStyle(
            color: Colors.grey.shade500,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: const Icon(Icons.search, color: Colors.grey, size: 24),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  CATEGORY CHIPS — matches SchemesScreen sizing
// ─────────────────────────────────────────────────────────────────────────────
class _CategoryChips extends StatelessWidget {
  final List<Map<String, dynamic>> categories;
  final int selected;
  final ValueChanged<int> onChanged;

  const _CategoryChips({
    required this.categories,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 82,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(vertical: 2),
        itemCount: categories.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, i) {
          final cat = categories[i];
          final isSelected = selected == i;
          return GestureDetector(
            onTap: () => onChanged(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? kDarkGreen : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected ? kDarkGreen : Colors.grey.shade300,
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isSelected
                        ? kDarkGreen.withValues(alpha: 0.18)
                        : Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    cat['icon'] as IconData,
                    color: isSelected ? Colors.white : kDarkGreen,
                    size: 26,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    cat['label'] as String,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? Colors.white : Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  STATUS SUMMARY — 3 colored stat cards
// ─────────────────────────────────────────────────────────────────────────────
class _StatusSummary extends StatelessWidget {
  final int uploaded;
  final int missing;
  final int total;

  const _StatusSummary({
    required this.uploaded,
    required this.missing,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Aapke Documents Status',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w900,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _statusPill(
                Icons.check_circle_outline,
                'अपलोड किया गया',
                uploaded,
                kDarkGreen,
                const Color(0xFFE8F5E9),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _statusPill(
                Icons.warning_amber_outlined,
                'अनुपस्थित',
                missing,
                const Color(0xFFC62828),
                const Color(0xFFFFEBEE),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _statusPill(
                Icons.folder_outlined,
                'कुल आवश्यक',
                total,
                kMedGreen,
                const Color(0xFFE3F2FD),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _statusPill(
    IconData icon,
    String label,
    int count,
    Color iconColor,
    Color bgColor,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: iconColor.withValues(alpha: 0.15)),
      ),
      child: Column(
        children: [
          Icon(icon, color: iconColor, size: 24),
          const SizedBox(height: 6),
          Text(
            '$count',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: iconColor,
              height: 1,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: iconColor.withValues(alpha: 0.85),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  SECTION HEADER — matches SchemesScreen
// ─────────────────────────────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final int count;
  final bool sortMissingFirst;
  final VoidCallback onToggleSort;
  const _SectionHeader({required this.count, required this.sortMissingFirst, required this.onToggleSort});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'दस्तावेज सूची ($count)',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: Colors.black87,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onToggleSort,
              borderRadius: BorderRadius.circular(20),
              child: Row(
                children: [
                  Icon(Icons.sort_rounded, color: kDarkGreen, size: 18),
                  const SizedBox(width: 6),
                  Text(
                    sortMissingFirst ? 'पहले अनुपस्थित' : 'क्रमबद्ध',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: kDarkGreen,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  DOCUMENT CARD
// ─────────────────────────────────────────────────────────────────────────────
class _DocumentCard extends StatelessWidget {
  final _RequiredDoc doc;
  final UploadedDoc? uploaded;
  final VoidCallback onUpload;
  final VoidCallback onTap;

  const _DocumentCard({
    required this.doc,
    required this.uploaded,
    required this.onUpload,
    required this.onTap,
  });

  bool get _isUploaded => uploaded != null;
  Color get _statusColor => _isUploaded ? kDarkGreen : const Color(0xFFC62828);
  Color get _statusBg => _isUploaded ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE);
  IconData get _statusIcon => _isUploaded ? Icons.check_circle : Icons.cloud_off_outlined;

  String get _dateLabel {
    if (uploaded == null) return 'अभी अपलोड नहीं हुआ / Not uploaded yet';
    final d = uploaded!.uploadedAt;
    return 'Uploaded: ${d.day}/${d.month}/${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
            ],
            border: !_isUploaded ? Border.all(color: const Color(0xFFC62828).withValues(alpha: 0.25), width: 1.5) : null,
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                // Icon
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(color: _statusBg, shape: BoxShape.circle),
                  child: Icon(_iconFor(doc.name), color: _statusColor, size: 26),
                ),
                const SizedBox(width: 14),

                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        doc.name,
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: Color(0xFF1A1A1A), height: 1.25),
                      ),
                      if (uploaded != null) ...[
                        const SizedBox(height: 3),
                        Text(
                          uploaded!.fileName,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 12.5, color: Colors.grey.shade600, fontWeight: FontWeight.w600),
                        ),
                      ] else if (doc.neededFor.isNotEmpty) ...[
                        const SizedBox(height: 3),
                        Text(
                          'ज़रूरी: ${doc.neededFor.join(", ")}',
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontWeight: FontWeight.w600, fontStyle: FontStyle.italic),
                        ),
                      ],
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(Icons.calendar_today_outlined, size: 12, color: Colors.grey.shade500),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              _dateLabel,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 11.5, color: Colors.grey.shade500, fontWeight: FontWeight.w500),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Status badge + action
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: _statusBg,
                        borderRadius: BorderRadius.circular(20),
                        border: !_isUploaded ? null : Border.all(color: _statusColor.withValues(alpha: 0.2)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(_statusIcon, color: _statusColor, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            _isUploaded ? 'अपलोड किया गया' : 'अनुपस्थित',
                            style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: _statusColor),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (!_isUploaded)
                      GestureDetector(
                        onTap: onUpload,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFC62828),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(color: const Color(0xFFC62828).withValues(alpha: 0.3), blurRadius: 6, offset: const Offset(0, 2)),
                            ],
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.upload_outlined, color: Colors.white, size: 14),
                              SizedBox(width: 4),
                              Text('अपलोड', style: TextStyle(color: Colors.white, fontSize: 11.5, fontWeight: FontWeight.w800)),
                            ],
                          ),
                        ),
                      )
                    else
                      GestureDetector(
                        onTap: onTap,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(color: kBg, borderRadius: BorderRadius.circular(20)),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.visibility_outlined, color: kDarkGreen, size: 14),
                              SizedBox(width: 4),
                              Text('देखें', style: TextStyle(color: kDarkGreen, fontSize: 11.5, fontWeight: FontWeight.w800)),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  UPLOAD BUTTON
// ─────────────────────────────────────────────────────────────────────────────
class _UploadButton extends StatelessWidget {
  final VoidCallback onTap;
  const _UploadButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: double.infinity,
          height: 52,
          decoration: BoxDecoration(
            color: kDarkGreen,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: kDarkGreen.withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.cloud_upload_outlined, color: Colors.white, size: 24),
              SizedBox(width: 10),
              Text(
                'नया दस्तावेज अपलोड करें',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  HELP BANNER — matches SchemesScreen style
// ─────────────────────────────────────────────────────────────────────────────
class _HelpBanner extends StatelessWidget {
  final VoidCallback onAskTap;
  const _HelpBanner({required this.onAskTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: kDarkGreen,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: kDarkGreen.withValues(alpha: 0.25),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.headset_mic_outlined,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'दस्तावेज में मदद चाहिए?',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Yojana Mitra AI से पूछें',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onAskTap,
              borderRadius: BorderRadius.circular(22),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: kOrange,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: kOrange.withValues(alpha: 0.40),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.chat_bubble_outline_rounded, color: Colors.white, size: 16),
                    SizedBox(width: 6),
                    Text(
                      'पूछें',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  BOTTOM NAV BAR — matches HomeScreen/SchemesScreen/ProfileScreen exactly
// ─────────────────────────────────────────────────────────────────────────────
class _BottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;

  const _BottomNavBar({required this.selectedIndex, required this.onTap});

  static const _items = [
    _NavItem(Icons.home_outlined, Icons.home_filled, 'होम'),
    _NavItem(Icons.description_outlined, Icons.description, 'योजनाएं'),
    _NavItem(Icons.support_agent_outlined, Icons.support_agent, 'चैट'),
    _NavItem(Icons.folder_outlined, Icons.folder, 'दस्तावेज'),
    _NavItem(Icons.person_outline, Icons.person, 'प्रोफ़ाइल'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 75,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 15,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(_items.length, (i) {
          final item = _items[i];
          final isSelected = selectedIndex == i;
          return GestureDetector(
            onTap: () => onTap(i),
            behavior: HitTestBehavior.opaque,
            child: SizedBox(
              width: 60,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isSelected ? item.activeIcon : item.icon,
                    color: isSelected ? kDarkGreen : Colors.grey.shade400,
                    size: 26,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.label,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: isSelected
                          ? FontWeight.w800
                          : FontWeight.w600,
                      color: isSelected ? kDarkGreen : Colors.grey.shade500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutQuint,
                    height: 3,
                    width: isSelected ? 24 : 0,
                    decoration: BoxDecoration(
                      color: kDarkGreen,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  const _NavItem(this.icon, this.activeIcon, this.label);
}