/// The farmer's profile data, used to evaluate scheme eligibility rules
/// and to personalize the app (greetings, document names, etc.).
/// Eligibility field names intentionally match the snake_case keys used
/// in Rule.field (e.g. "land_size_hectares") via the switch in matcher.dart.
class FarmerProfile {
  // ── Personal details (not used in eligibility matching, but needed
  // for a real, usable app — greetings, applications, document prefill) ──
  final String name;
  final String gender; // "male", "female", "other"
  final String phone;
  final String village;
  final String district;

  // ── Eligibility fields (consumed by scheme_matcher.dart) ──────────────
  final String state;
  final double landSizeHectares;
  final String category; // "general", "sc", "st", "obc"
  final double annualIncome;
  final String occupation; // "farmer", "tenant_farmer", "agricultural_laborer", "government_employee", "other"
  final int age;
  final bool ownsPuccaHouse;
  final bool hasMotorizedVehicle;
  final bool isIncomeTaxPayer;
  final bool isFpoMember;

  FarmerProfile({
    required this.name,
    required this.gender,
    required this.phone,
    required this.village,
    required this.district,
    required this.state,
    required this.landSizeHectares,
    required this.category,
    required this.annualIncome,
    required this.occupation,
    required this.age,
    required this.ownsPuccaHouse,
    required this.hasMotorizedVehicle,
    required this.isIncomeTaxPayer,
    required this.isFpoMember,
  });

  /// A safe placeholder profile for testing before the real form is filled.
  factory FarmerProfile.placeholder() {
    return FarmerProfile(
      name: 'किसान जी',
      gender: 'male',
      phone: '',
      village: '',
      district: '',
      state: 'Punjab',
      landSizeHectares: 1.5,
      category: 'general',
      annualIncome: 80000,
      occupation: 'farmer',
      age: 45,
      ownsPuccaHouse: false,
      hasMotorizedVehicle: false,
      isIncomeTaxPayer: false,
      isFpoMember: false,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'gender': gender,
        'phone': phone,
        'village': village,
        'district': district,
        'state': state,
        'landSizeHectares': landSizeHectares,
        'category': category,
        'annualIncome': annualIncome,
        'occupation': occupation,
        'age': age,
        'ownsPuccaHouse': ownsPuccaHouse,
        'hasMotorizedVehicle': hasMotorizedVehicle,
        'isIncomeTaxPayer': isIncomeTaxPayer,
        'isFpoMember': isFpoMember,
      };

  factory FarmerProfile.fromJson(Map<String, dynamic> j) => FarmerProfile(
        name: j['name'] as String,
        gender: j['gender'] as String,
        phone: j['phone'] as String,
        village: j['village'] as String,
        district: j['district'] as String,
        state: j['state'] as String,
        landSizeHectares: (j['landSizeHectares'] as num).toDouble(),
        category: j['category'] as String,
        annualIncome: (j['annualIncome'] as num).toDouble(),
        occupation: j['occupation'] as String,
        age: (j['age'] as num).toInt(),
        ownsPuccaHouse: j['ownsPuccaHouse'] as bool,
        hasMotorizedVehicle: j['hasMotorizedVehicle'] as bool,
        isIncomeTaxPayer: j['isIncomeTaxPayer'] as bool,
        isFpoMember: j['isFpoMember'] as bool,
      );
}