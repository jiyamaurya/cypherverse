import 'package:flutter/material.dart';
import 'package:yojana_mitra/core/logic/scheme_matcher.dart';
import 'package:yojana_mitra/core/models/scheme.dart';
import 'package:yojana_mitra/core/state/document_store.dart';
import 'package:url_launcher/url_launcher.dart';
const _kDark   = Color(0xFF1B5E20);
const _kMed    = Color(0xFF2E7D32);
const _kOrange = Color(0xFFEF6C00);
const _kBg     = Color(0xFFF7F6F0);
const _kCard   = Colors.white;

class SchemeApplyScreen extends StatefulWidget {
  final MatchResult result;
  const SchemeApplyScreen({super.key, required this.result});
  @override
  State<SchemeApplyScreen> createState() => _SchemeApplyScreenState();
}

class _SchemeApplyScreenState extends State<SchemeApplyScreen> {
  late final List<bool> _docChecked;
  int _expandedFaq = -1;

  @override
  void initState() {
    super.initState();
    // Pre-fill from what's actually already uploaded in the Documents
    // screen — a document you uploaded there shouldn't ask you to re-tick
    // it here as if the app doesn't know about it.
    _docChecked = List.filled(widget.result.scheme.documentsNeeded.length, false);
    _loadUploadState();
  }

  Future<void> _loadUploadState() async {
    await DocumentStore.instance.load();
    if (!mounted) return;
    setState(() {
      final docs = widget.result.scheme.documentsNeeded;
      for (var i = 0; i < docs.length; i++) {
        if (DocumentStore.instance.isUploaded(docs[i])) _docChecked[i] = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final Scheme scheme           = widget.result.scheme;
    final List<String> steps      = _parseSteps(scheme.applicationSteps);
    final List<String> docs       = scheme.documentsNeeded;
    final List<SchemeFaq> faqs    = scheme.commonFaqs;
    final bool allChecked         = _docChecked.every((v) => v);

    return Scaffold(
      backgroundColor: _kBg,
      body: Stack(children: [
        Positioned(
          top: 0, left: 0, right: 0, height: 240,
          child: Stack(fit: StackFit.expand, children: [
            Image.asset('assets/images/home_bg.png',
              fit: BoxFit.cover, alignment: Alignment.topCenter,
              errorBuilder: (_, _, _) => Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter,
                    colors: [Color(0xFFE8F5E9), Color(0xFFC8E6C9)])))),
            Positioned.fill(child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.transparent, _kBg.withValues(alpha: 0.85), _kBg],
                  stops: const [0.0, 0.35, 0.72, 1.0])))),
          ]),
        ),
        SafeArea(
          bottom: false,
          child: Column(children: [
            _buildTopBar(context),
            Expanded(child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const SizedBox(height: 16),
                _buildProgressHeader(scheme, docs),
                const SizedBox(height: 16),
                _buildStepsCard(steps),
                const SizedBox(height: 16),
                _buildDocumentsCard(docs, scheme),
                const SizedBox(height: 16),
                _buildDeadlineCard(scheme),
                const SizedBox(height: 16),
                if (faqs.isNotEmpty) ...[_buildFaqCard(faqs), const SizedBox(height: 16)],
                _buildHelpCard(),
              ]),
            )),
          ]),
        ),
        Positioned(bottom: 0, left: 0, right: 0,
          child: _buildBottomCTA(context, allChecked, scheme)),
      ]),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      child: Row(children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(width: 42, height: 42,
            decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 8)]),
            child: const Icon(Icons.arrow_back_ios_new, size: 18, color: _kDark))),
        const Expanded(child: Text('आवेदन कैसे करें / How to Apply',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: _kDark))),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 6)]),
          child: const Text('चरण 3/3',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: _kOrange))),
      ]),
    );
  }

  Widget _buildProgressHeader(Scheme scheme, List<String> docs) {
    final int checked = _docChecked.where((v) => v).length;
    final double progress = docs.isEmpty ? 0.0 : checked / docs.length;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: _kCard, borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(scheme.schemeName,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: Colors.black87, height: 1.3)),
            const SizedBox(height: 4),
            Text('$checked / ${docs.length} दस्तावेज़ तैयार',
              style: TextStyle(fontSize: 12.5, color: Colors.grey.shade600, fontWeight: FontWeight.w600)),
          ])),
          
          SizedBox(width: 56, height: 56,
            child: Stack(alignment: Alignment.center, children: [
              CircularProgressIndicator(value: progress, strokeWidth: 5,
                backgroundColor: Colors.grey.shade200,
                valueColor: const AlwaysStoppedAnimation(_kMed)),
              Text('${(progress * 100).toInt()}%',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: _kDark)),
            ])),
        ]),
        const SizedBox(height: 14),
        Row(children: [
          _stepPill('1', 'विवरण', true),
          _stepConnector(),
          _stepPill('2', 'पात्रता', true),
          _stepConnector(),
          _stepPill('3', 'आवेदन', true, isActive: true),
        ]),
      ]),
    );
  }

  Widget _stepPill(String num, String label, bool done, {bool isActive = false}) {
    return Column(children: [
      Container(width: 32, height: 32,
        decoration: BoxDecoration(
          color: isActive ? _kOrange : done ? _kDark : Colors.grey.shade300,
          shape: BoxShape.circle),
        alignment: Alignment.center,
        child: Text(num, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w900))),
      const SizedBox(height: 4),
      Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700,
        color: isActive ? _kOrange : done ? _kDark : Colors.grey.shade400)),
    ]);
  }

  Widget _stepConnector() => Expanded(
    child: Container(height: 2, margin: const EdgeInsets.only(bottom: 18), color: _kDark.withValues(alpha: 0.3)));

  Widget _buildStepsCard(List<String> steps) {
    return _sectionCard(
      icon: Icons.format_list_numbered_rounded, iconBg: const Color(0xFFE3F2FD),
      iconColor: const Color(0xFF1565C0), title: 'आवेदन प्रक्रिया / Application Steps',
      child: Column(children: List.generate(steps.length, (i) {
        final bool isLast = i == steps.length - 1;
        return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Column(children: [
            Container(width: 34, height: 34,
              decoration: BoxDecoration(color: const Color(0xFF1565C0), shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: const Color(0xFF1565C0).withValues(alpha: 0.3), blurRadius: 8)]),
              alignment: Alignment.center,
              child: Text('${i + 1}', style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w900))),
            if (!isLast)
              Container(width: 2, height: 40, margin: const EdgeInsets.symmetric(vertical: 4),
                color: const Color(0xFF1565C0).withValues(alpha: 0.25)),
          ]),
          const SizedBox(width: 14),
          Expanded(child: Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : 24, top: 6),
            child: Text(steps[i],
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87, height: 1.5)))),
        ]);
      })),
    );
  }

  Widget _buildDocumentsCard(List<String> docs, Scheme scheme) {
    return _sectionCard(
      icon: Icons.checklist_rounded, iconBg: const Color(0xFFE8F5E9),
      iconColor: _kDark, title: 'दस्तावेज़ चेकलिस्ट / Document Checklist',
      child: Column(children: [
        Container(padding: const EdgeInsets.all(12), margin: const EdgeInsets.only(bottom: 14),
          decoration: BoxDecoration(color: const Color(0xFFF3E5F5), borderRadius: BorderRadius.circular(10)),
          child: const Row(children: [
            Icon(Icons.touch_app_rounded, color: Color(0xFF6A1B9A), size: 16),
            SizedBox(width: 8),
            Expanded(child: Text('दस्तावेज़ तैयार होने पर टिक करें',
              style: TextStyle(fontSize: 12.5, color: Color(0xFF6A1B9A), fontWeight: FontWeight.w600))),
          ])),
        if (docs.isEmpty)
          Container(
            padding: const EdgeInsets.all(14),
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(color: _kBg, borderRadius: BorderRadius.circular(10)),
            child: Text('दस्तावेज़ों की जानकारी उपलब्ध नहीं — कृपया आधिकारिक वेबसाइट देखें',
              style: TextStyle(fontSize: 12.5, color: Colors.grey.shade600)),
          ),
        ...List.generate(docs.length, (i) {
          final String doc   = docs[i];
          final bool checked = _docChecked[i];
          return GestureDetector(
            onTap: () => setState(() => _docChecked[i] = !_docChecked[i]),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: checked ? const Color(0xFFE8F5E9) : _kBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: checked ? _kMed.withValues(alpha: 0.4) : Colors.grey.shade300,
                  width: checked ? 1.5 : 1)),
              child: Row(children: [
                AnimatedContainer(duration: const Duration(milliseconds: 200),
                  width: 26, height: 26,
                  decoration: BoxDecoration(color: checked ? _kDark : Colors.white, shape: BoxShape.circle,
                    border: Border.all(color: checked ? _kDark : Colors.grey.shade400, width: 1.5)),
                  child: checked ? const Icon(Icons.check_rounded, color: Colors.white, size: 15) : null),
                const SizedBox(width: 14),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(doc, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700,
                    color: checked ? _kDark : Colors.black87)),
                  if (!checked)
                    GestureDetector(
                      onTap: () => Navigator.pushNamed(context, '/documents'),
                      child: Text('अपलोड करने के लिए यहां टैप करें / Tap to upload',
                        style: TextStyle(fontSize: 11, color: _kOrange, fontWeight: FontWeight.w600,
                          decoration: TextDecoration.underline)),
                    ),
                ])),
                if (checked) const Icon(Icons.check_circle_rounded, color: _kMed, size: 20),
              ]),
            ),
          );
        }),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: () async {
            final uri = Uri.tryParse(scheme.effectiveFormUrl);
            if (uri != null && uri.hasScheme) {
              await launchUrl(uri, mode: LaunchMode.platformDefault, webOnlyWindowName: '_blank');
            }
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3E0),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFFFB74D)),
            ),
            child: Row(children: [
              const Icon(Icons.download_rounded, color: Color(0xFFE65100), size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  scheme.hasRealFormDownload
                      ? 'फॉर्म डाउनलोड करें / Download Form'
                      : 'आधिकारिक वेबसाइट पर फॉर्म देखें / Find Form on Official Website',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFFE65100)),
                ),
              ),
              const Icon(Icons.arrow_forward_rounded, color: Color(0xFFE65100), size: 18),
            ]),
          ),
        ),
      ]),
    );
  }

  Widget _buildDeadlineCard(Scheme scheme) {
    final bool isOngoing = scheme.deadline == 'Ongoing';
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: _kCard, borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))]),
      child: Row(children: [
        Container(padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isOngoing ? const Color(0xFFE8F5E9) : const Color(0xFFFFF3E0),
            borderRadius: BorderRadius.circular(14)),
          child: Icon(Icons.event_rounded, color: isOngoing ? _kMed : _kOrange, size: 26)),
        const SizedBox(width: 16),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('अंतिम तिथि / Deadline',
            style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(scheme.deadline,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.black87)),
          if (isOngoing) const Text('कभी भी आवेदन करें',
            style: TextStyle(fontSize: 12, color: _kMed, fontWeight: FontWeight.w600)),
        ])),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: isOngoing ? const Color(0xFFE8F5E9) : const Color(0xFFFFF3E0),
            borderRadius: BorderRadius.circular(20)),
          child: Text(isOngoing ? 'चालू है' : 'सीमित समय',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800,
              color: isOngoing ? _kMed : _kOrange))),
      ]),
    );
  }

  Widget _buildFaqCard(List<SchemeFaq> faqs) {
    return _sectionCard(
      icon: Icons.quiz_outlined, iconBg: const Color(0xFFFFF3E0),
      iconColor: _kOrange, title: 'अक्सर पूछे जाने वाले सवाल / FAQs',
      child: Column(children: List.generate(faqs.length, (i) {
        final SchemeFaq faq  = faqs[i];
        final bool expanded  = _expandedFaq == i;
        return GestureDetector(
          onTap: () => setState(() => _expandedFaq = expanded ? -1 : i),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: expanded ? const Color(0xFFFFF8E1) : _kBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: expanded ? _kOrange.withValues(alpha: 0.3) : Colors.grey.shade200)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Padding(padding: const EdgeInsets.all(14),
                child: Row(children: [
                  Container(padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: expanded ? _kOrange : Colors.grey.shade300, shape: BoxShape.circle),
                    child: Text('?', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900,
                      color: expanded ? Colors.white : Colors.grey.shade600))),
                  const SizedBox(width: 10),
                  Expanded(child: Text(faq.question,
                    style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700,
                      color: expanded ? _kOrange : Colors.black87))),
                  Icon(expanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                    color: Colors.grey.shade500),
                ])),
              if (expanded) ...[
                const Divider(height: 1, color: Color(0xFFF0F0F0)),
                Padding(padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                  child: Text(faq.answer,
                    style: const TextStyle(fontSize: 13.5, color: Colors.black87, height: 1.5, fontWeight: FontWeight.w500))),
              ],
            ]),
          ),
        );
      })),
    );
  }

  Widget _buildHelpCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: _kDark, borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: _kDark.withValues(alpha: 0.3), blurRadius: 14, offset: const Offset(0, 5))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Row(children: [
          Icon(Icons.support_agent_rounded, color: Colors.white, size: 22),
          SizedBox(width: 10),
          Text('मदद चाहिए? / Need Help?',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: Colors.white)),
        ]),
        const SizedBox(height: 10),
        Text('आवेदन में कोई समस्या हो तो हमसे बात करें।',
          style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.85), height: 1.4)),
        const SizedBox(height: 14),
        Row(children: [
          Expanded(child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withValues(alpha: 0.2))),
            child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.mic_rounded, color: Colors.white, size: 18),
              SizedBox(width: 8),
              Text('बोलकर पूछें', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w800)),
            ]))),
          const SizedBox(width: 10),
          Expanded(child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(color: _kOrange, borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: _kOrange.withValues(alpha: 0.4), blurRadius: 8)]),
            child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.headset_mic_rounded, color: Colors.white, size: 18),
              SizedBox(width: 8),
              Text('हेल्पलाइन', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w800)),
            ]))),
        ]),
      ]),
    );
  }

  Widget _buildBottomCTA(BuildContext context, bool allChecked, Scheme scheme) {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(context).padding.bottom + 16),
      decoration: BoxDecoration(color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 20, offset: const Offset(0, -6))]),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        if (!allChecked)
          Container(width: double.infinity, padding: const EdgeInsets.all(10),
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(color: const Color(0xFFFFF8E1), borderRadius: BorderRadius.circular(10)),
            child: Text('सभी दस्तावेज़ चेक करने के बाद आवेदन करें', textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12.5, color: Colors.grey.shade700, fontWeight: FontWeight.w600))),
        Row(children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(width: 52, height: 52,
              decoration: BoxDecoration(color: _kBg, borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey.shade300)),
              child: const Icon(Icons.arrow_back_rounded, color: _kDark, size: 22))),
          const SizedBox(width: 12),
          Expanded(child: SizedBox(height: 52,
            child: ElevatedButton(
              onPressed: () => _showApplyDialog(context, scheme),
              style: ElevatedButton.styleFrom(
                backgroundColor: _kOrange, elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(allChecked ? Icons.rocket_launch_rounded : Icons.open_in_new_rounded,
                  color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Text(allChecked ? 'अभी आवेदन करें / Apply Now' : 'पोर्टल पर जाएं / Go to Portal',
                  style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w800)),
              ]),
            ))),
        ]),
      ]),
    );
  }

  void _showApplyDialog(BuildContext context, Scheme scheme) {
    showModalBottomSheet(
      context: context, backgroundColor: Colors.transparent, isScrollControlled: true,
      builder: (_) => Container(
        margin: const EdgeInsets.all(16), padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 48, height: 48,
            decoration: const BoxDecoration(color: Color(0xFFE8F5E9), shape: BoxShape.circle),
            child: const Icon(Icons.check_rounded, color: _kDark, size: 28)),
          const SizedBox(height: 16),
          const Text('आवेदन पोर्टल',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.black87)),
          const SizedBox(height: 8),
          Text('आवेदन के लिए आधिकारिक पोर्टल पर जाएं:', textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13.5, color: Colors.grey.shade600)),
          const SizedBox(height: 16),
          Container(width: double.infinity, padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: const Color(0xFFE8F5E9), borderRadius: BorderRadius.circular(12)),
            child: Text(scheme.effectiveApplyUrl, textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: _kDark))),
          const SizedBox(height: 20),
          SizedBox(width: double.infinity, height: 52,
            child: ElevatedButton(
              onPressed: () async {
                final uri = Uri.tryParse(scheme.effectiveApplyUrl);
                if (uri != null && uri.hasScheme) {
                  await launchUrl(uri, mode: LaunchMode.platformDefault, webOnlyWindowName: '_blank');
                }
                if (context.mounted) Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(backgroundColor: _kDark, elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
              child: const Text('पोर्टल खोलें / Open Portal',
                style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w800)))),
          SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
        ]),
      ),
    );
  }

  Widget _sectionCard({required IconData icon, required Color iconBg,
      required Color iconColor, required String title, required Widget child}) {
    return Container(
      width: double.infinity, padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: _kCard, borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: iconColor, size: 18)),
          const SizedBox(width: 10),
          Expanded(child: Text(title,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: Colors.black87))),
        ]),
        const SizedBox(height: 12),
        const Divider(height: 1, color: Color(0xFFF0F0F0)),
        const SizedBox(height: 14),
        child,
      ]),
    );
  }

  List<String> _parseSteps(String raw) {
    final pattern = RegExp(r'Step \d+:\s*');
    final parts   = raw.split(pattern).where((s) => s.trim().isNotEmpty).toList();
    return parts.isEmpty ? [raw] : parts.map((s) => s.trim()).toList();
  }
}