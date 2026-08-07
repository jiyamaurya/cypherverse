import '../models/farmer_profile.dart';

/// Simple in-memory store for the farmer's profile, shared across screens.
///
/// This is intentionally NOT persisted to disk yet (no SQLite/Hive/shared_prefs).
/// That means the profile resets if the app fully restarts — acceptable for
/// a hackathon demo, but a known limitation. Swap this for real local storage
/// before any real-user testing (see Yojana_Mitra deck: "local-first" promise
/// requires data to survive app restarts, which this does not yet do).
class ProfileStore {
  ProfileStore._();
  static final ProfileStore instance = ProfileStore._();

  FarmerProfile? _profile;

  bool get hasProfile => _profile != null;

  FarmerProfile get profile {
    // Falls back to placeholder if accessed before the form is filled,
    // so screens built before the form (e.g. schemes_screen) don't crash.
    return _profile ?? FarmerProfile.placeholder();
  }

  void saveProfile(FarmerProfile profile) {
    _profile = profile;
  }

  void clear() {
    _profile = null;
  }
}