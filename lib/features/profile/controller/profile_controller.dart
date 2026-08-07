import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/models/farmer_profile.dart';

class ProfileController {
  static final ProfileController _instance = ProfileController._internal();
  factory ProfileController() => _instance;
  ProfileController._internal();

  FarmerProfile? _cachedProfile;
  FarmerProfile? get currentProfile => _cachedProfile;

  Future<void> saveProfile(FarmerProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    // In a real app, use a proper JSON serialization method in your model
    await prefs.setString('farmer_profile', jsonEncode({
      'name': profile.name, 'state': profile.state, 'age': profile.age,
      'category': profile.category, 'landSizeHectares': profile.landSizeHectares,
      'occupation': profile.occupation, 'annualIncome': profile.annualIncome,
      // ... add other fields
    }));
    _cachedProfile = profile;
  }

  Future<bool> hasProfile() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('farmer_profile');
  }
}