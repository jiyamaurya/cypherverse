import 'dart:convert';
import 'dart:typed_data';
import 'package:shared_preferences/shared_preferences.dart';

/// Metadata for a document the farmer has actually uploaded on this device.
///
/// We store only metadata (name, path, size, upload time) — not raw file
/// bytes — via SharedPreferences, so upload state survives an app restart
/// on Android/iOS. On Flutter Web the OS file path isn't stable across a
/// full page reload, so uploads there persist for the current session only.
/// That's a normal, honest limitation of browser storage, not something we
/// fake — we simply don't claim persistence we can't actually provide.
class UploadedDoc {
  final String docName;   // the required-document label this satisfies
  final String fileName;  // the file the user actually picked
  final String? filePath; // null on web
  final int sizeBytes;
  final DateTime uploadedAt;

  UploadedDoc({
    required this.docName,
    required this.fileName,
    required this.filePath,
    required this.sizeBytes,
    required this.uploadedAt,
  });

  Map<String, dynamic> toJson() => {
        'docName': docName,
        'fileName': fileName,
        'filePath': filePath,
        'sizeBytes': sizeBytes,
        'uploadedAt': uploadedAt.toIso8601String(),
      };

  factory UploadedDoc.fromJson(Map<String, dynamic> j) => UploadedDoc(
        docName: j['docName'] as String,
        fileName: j['fileName'] as String,
        filePath: j['filePath'] as String?,
        sizeBytes: (j['sizeBytes'] as num).toInt(),
        uploadedAt: DateTime.parse(j['uploadedAt'] as String),
      );

  String get prettySize {
    if (sizeBytes < 1024) return '$sizeBytes B';
    if (sizeBytes < 1024 * 1024) return '${(sizeBytes / 1024).toStringAsFixed(1)} KB';
    return '${(sizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

/// Simple on-device store for uploaded-document metadata, keyed by the
/// required-document's name (case-insensitive). Real persistence via
/// SharedPreferences — same pattern as ProfileStore.
class DocumentStore {
  DocumentStore._();
  static final DocumentStore instance = DocumentStore._();

  static const _prefsKey = 'yojana_mitra_uploaded_docs_v1';

  final Map<String, UploadedDoc> _docs = {}; // key = docName.toLowerCase().trim()
  // Raw file bytes, kept ONLY in memory for the current session — this is
  // what lets us actually show a real image preview of what you uploaded.
  // Not persisted (too large for SharedPreferences), so it's gone after a
  // full page reload — the metadata above still survives, just not the
  // visual preview.
  final Map<String, Uint8List> _sessionBytes = {};
  bool _loaded = false;

  String _key(String docName) => docName.trim().toLowerCase();

  Future<void> load() async {
    if (_loaded) return;
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    if (raw != null && raw.isNotEmpty) {
      try {
        final list = jsonDecode(raw) as List;
        for (final item in list) {
          final doc = UploadedDoc.fromJson(item as Map<String, dynamic>);
          _docs[_key(doc.docName)] = doc;
        }
      } catch (_) {
        // Corrupt/old-format data — start clean rather than crash the screen.
      }
    }
    _loaded = true;
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    final list = _docs.values.map((d) => d.toJson()).toList();
    await prefs.setString(_prefsKey, jsonEncode(list));
  }

  bool isUploaded(String docName) => _docs.containsKey(_key(docName));
  UploadedDoc? get(String docName) => _docs[_key(docName)];
  Uint8List? getPreviewBytes(String docName) => _sessionBytes[_key(docName)];

  Future<void> save(UploadedDoc doc, {Uint8List? previewBytes}) async {
    _docs[_key(doc.docName)] = doc;
    if (previewBytes != null) {
      _sessionBytes[_key(doc.docName)] = previewBytes;
    } else {
      _sessionBytes.remove(_key(doc.docName));
    }
    await _persist();
  }

  Future<void> remove(String docName) async {
    _docs.remove(_key(docName));
    _sessionBytes.remove(_key(docName));
    await _persist();
  }
}