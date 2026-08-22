import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/farmer_profile.dart';

/// Store for the farmer's profile, shared across screens.
///
/// Persisted via SharedPreferences, so the profile survives an app
/// restart/page refresh — previously this was in-memory only, which meant
/// the profile (and anything derived from it, like eligibility results and
/// required documents) silently reset on every reload.
class ProfileStore {
  ProfileStore._();
  static final ProfileStore instance = ProfileStore._();

  static const _prefsKey = 'yojana_mitra_profile_v1';

  FarmerProfile? _profile;
  bool _loaded = false;

  bool get hasProfile => _profile != null;

  FarmerProfile get profile {
    // Falls back to placeholder if accessed before the form is filled (or
    // before `load()` has resolved), so screens built before the form
    // (e.g. schemes_screen) don't crash.
    return _profile ?? FarmerProfile.placeholder();
  }

  /// Must be awaited once (e.g. in main() or the first screen's initState)
  /// before relying on a previously-saved profile being available.
  Future<void> load() async {
    if (_loaded) return;
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    if (raw != null && raw.isNotEmpty) {
      try {
        _profile = FarmerProfile.fromJson(jsonDecode(raw) as Map<String, dynamic>);
      } catch (_) {
        // Corrupt/old-format data — start clean rather than crash.
        _profile = null;
      }
    }
    _loaded = true;
  }

  Future<void> saveProfile(FarmerProfile profile) async {
    _profile = profile;
    _loaded = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, jsonEncode(profile.toJson()));
  }

  Future<void> clear() async {
    _profile = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefsKey);
  }
}