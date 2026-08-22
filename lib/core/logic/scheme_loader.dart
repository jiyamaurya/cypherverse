import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

import '../models/scheme.dart';

/// Loads and parses the bundled scheme seed data.
/// Call this once at app startup (or lazily the first time the
/// schemes screen opens) and cache the result — don't reload on every build.
Future<List<Scheme>> loadSchemes() async {
  final jsonString =
      await rootBundle.loadString('assets/data/schemes_seed.json');
  final List<dynamic> jsonList = json.decode(jsonString) as List<dynamic>;
  return jsonList
      .map((item) => Scheme.fromJson(item as Map<String, dynamic>))
      .toList();
}