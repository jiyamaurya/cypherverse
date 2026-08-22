import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';

import '../../../core/models/farmer_profile.dart';
import '../../../core/state/profile_store.dart';

const _kDarkGreen  = Color(0xFF1B5E20);
const _kLightGreen = Color(0xFF43A047);
const _kOrange     = Color(0xFFEF6C00);
const _kBg         = Color(0xFFF7F6F0);
const _kCard       = Colors.white;

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});
  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _step = 0;
  static const int _totalSteps = 5;
  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

  // ── Controllers ───────────────────────────────────────────────
  final _nameCtrl     = TextEditingController();
  final _villageCtrl  = TextEditingController();
  final _districtCtrl = TextEditingController();
  final _phoneCtrl    = TextEditingController();
  final _ageCtrl      = TextEditingController();
  final _incomeCtrl   = TextEditingController();

  String? _gender;
  String? _state;
  String? _category;
  String? _occupation;
  double? _landSizeHectares;
  bool?   _ownsPuccaHouse;
  bool?   _hasMotorizedVehicle;
  bool?   _isIncomeTaxPayer;
  bool?   _isFpoMember;
  bool    _didPrefillPhone = false;

  // ── Live validation error messages (null = valid / not yet checked) ──
  String? _nameError;
  String? _phoneError;
  String? _villageError;
  String? _districtError;
  String? _ageError;
  String? _incomeError;

  // Becomes true the first time the user tries to move past a step —
  // used so "required" errors don't show on a completely untouched field.
  bool _validationTriggered = false;

  // ── Validators — letters (Hindi + English) only for names/places ──
  static final RegExp _nameRegex  = RegExp(r"^[A-Za-z\u0900-\u097F][A-Za-z\u0900-\u097F\s.'-]*$");
  static final RegExp _phoneRegex = RegExp(r'^[6-9]\d{9}$');

  String? _validateName(String v) {
    final t = v.trim();
    if (t.isEmpty) return _validationTriggered ? 'नाम आवश्यक है / Name is required' : null;
    if (t.length < 3) return 'कम से कम 3 अक्षर चाहिए / At least 3 characters needed';
    if (!_nameRegex.hasMatch(t)) return 'केवल अक्षर मान्य हैं, संख्या नहीं / Only letters allowed, no numbers';
    return null;
  }

  String? _validatePlace(String v, String labelHi, String labelEn) {
    final t = v.trim();
    if (t.isEmpty) return _validationTriggered ? '$labelHi आवश्यक है / $labelEn is required' : null;
    if (t.length < 2) return 'बहुत छोटा नाम है / Too short';
    if (!_nameRegex.hasMatch(t)) return 'केवल अक्षर मान्य हैं, संख्या/चिन्ह नहीं / Only letters allowed, no numbers or symbols';
    return null;
  }

  String? _validatePhone(String v) {
    final t = v.trim();
    if (t.isEmpty) return _validationTriggered ? 'मोबाइल नंबर आवश्यक है / Mobile number is required' : null;
    if (t.length < 10) return 'नंबर 10 अंकों का होना चाहिए (${t.length}/10) / Must be 10 digits (${t.length}/10)';
    if (t.length > 10) return 'नंबर केवल 10 अंकों का होना चाहिए / Must be exactly 10 digits';
    if (!_phoneRegex.hasMatch(t)) return 'मान्य नंबर 6-9 से शुरू होना चाहिए / Number must start with 6-9';
    return null;
  }

  String? _validateAge(String v) {
    final t = v.trim();
    if (t.isEmpty) return _validationTriggered ? 'आयु आवश्यक है / Age is required' : null;
    final n = int.tryParse(t);
    if (n == null) return 'मान्य संख्या दर्ज करें / Enter a valid number';
    if (n < 1) return 'आयु 1 से कम नहीं हो सकती / Age cannot be less than 1';
    if (n > 120) return 'आयु 120 से अधिक नहीं हो सकती / Age cannot be more than 120';
    return null;
  }

  String? _validateIncome(String v) {
    final t = v.trim();
    if (t.isEmpty) return _validationTriggered ? 'वार्षिक आय आवश्यक है / Annual income is required' : null;
    final n = int.tryParse(t);
    if (n == null) return 'मान्य संख्या दर्ज करें / Enter a valid number';
    if (n < 0) return 'आय ऋणात्मक नहीं हो सकती / Income cannot be negative';
    if (n > 10000000) return 'यह राशि बहुत अधिक लगती है, जांचें / This amount looks too large, please check';
    return null;
  }

  // Recomputes every error message for the fields visible on [step].
  void _revalidateStep(int step) {
    switch (step) {
      case 0:
        _nameError     = _validateName(_nameCtrl.text);
        _phoneError    = _validatePhone(_phoneCtrl.text);
        _villageError  = _validatePlace(_villageCtrl.text, 'गांव', 'Village');
        _districtError = _validatePlace(_districtCtrl.text, 'जिला', 'District');
        break;
      case 3:
        _ageError    = _validateAge(_ageCtrl.text);
        _incomeError = _validateIncome(_incomeCtrl.text);
        break;
    }
  }

  // ── Static data ───────────────────────────────────────────────
  static const _states = [
    'Andaman & Nicobar','Andhra Pradesh','Arunachal Pradesh','Assam','Bihar',
    'Chandigarh','Chhattisgarh','Delhi','Goa','Gujarat','Haryana',
    'Himachal Pradesh','Jammu & Kashmir','Jharkhand','Karnataka','Kerala',
    'Ladakh','Madhya Pradesh','Maharashtra','Manipur','Meghalaya','Mizoram',
    'Nagaland','Odisha','Puducherry','Punjab','Rajasthan','Sikkim',
    'Tamil Nadu','Telangana','Tripura','Uttar Pradesh','Uttarakhand',
    'West Bengal',
  ];

  static const _categories = [
    {'value': 'general', 'label': 'General', 'labelHi': 'सामान्य'},
    {'value': 'obc',     'label': 'OBC',     'labelHi': 'OBC'},
    {'value': 'sc',      'label': 'SC',      'labelHi': 'SC'},
    {'value': 'st',      'label': 'ST',      'labelHi': 'ST'},
  ];

  static const _occupations = [
    {'value': 'farmer',               'label': 'Farmer',          'labelHi': 'किसान',           'icon': Icons.agriculture_rounded},
    {'value': 'tenant_farmer',        'label': 'Tenant Farmer',   'labelHi': 'बंटाईदार',         'icon': Icons.grass_rounded},
    {'value': 'agricultural_laborer', 'label': 'Farm Laborer',    'labelHi': 'खेत मजदूर',        'icon': Icons.front_hand_outlined},
    {'value': 'government_employee',  'label': 'Govt. Employee',  'labelHi': 'सरकारी कर्मचारी', 'icon': Icons.account_balance_outlined},
    {'value': 'other',                'label': 'Other',           'labelHi': 'अन्य',             'icon': Icons.more_horiz},
  ];

  static const _landOptions = [
    {'label': '< 1 एकड़',  'sub': 'Less than 1 acre',     'hectares': 0.3},
    {'label': '1–2 एकड़',  'sub': '1 to 2 acres',          'hectares': 0.8},
    {'label': '2–5 एकड़',  'sub': '2 to 5 acres',          'hectares': 2.0},
    {'label': '5–10 एकड़', 'sub': '5 to 10 acres',         'hectares': 4.0},
    {'label': '10+ एकड़',  'sub': 'More than 10 acres',    'hectares': 8.0},
  ];

  // Step meta
  static const _stepMeta = [
    {'emoji': '👤', 'title': 'Personal Details',  'titleHi': 'व्यक्तिगत जानकारी'},
    {'emoji': '📍', 'title': 'Location',           'titleHi': 'राज्य और श्रेणी'},
    {'emoji': '🌾', 'title': 'Work & Land',        'titleHi': 'काम और भूमि'},
    {'emoji': '💰', 'title': 'Age & Income',        'titleHi': 'आयु और आय'},
    {'emoji': '✅', 'title': 'Assets',              'titleHi': 'अंतिम जानकारी'},
  ];

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 350));
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _fadeCtrl.forward();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_didPrefillPhone) {
      final arg = ModalRoute.of(context)?.settings.arguments;
      if (arg is String && arg.isNotEmpty) _phoneCtrl.text = arg;
      _didPrefillPhone = true;
    }
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _pageController.dispose();
    _nameCtrl.dispose(); _villageCtrl.dispose(); _districtCtrl.dispose();
    _phoneCtrl.dispose(); _ageCtrl.dispose(); _incomeCtrl.dispose();
    super.dispose();
  }

  // ── Validation ────────────────────────────────────────────────
  // Returns the first blocking error message for the current step, or
  // null if everything required is filled in and valid.
  String? get _firstStepError {
    switch (_step) {
      case 0:
        if (_nameError != null) return _nameError;
        if (_gender == null) return 'कृपया लिंग चुनें / Please select a gender';
        if (_phoneError != null) return _phoneError;
        if (_villageError != null) return _villageError;
        if (_districtError != null) return _districtError;
        return null;
      case 1:
        if (_state == null) return 'कृपया राज्य चुनें / Please select a state';
        if (_category == null) return 'कृपया श्रेणी चुनें / Please select a category';
        return null;
      case 2:
        if (_occupation == null) return 'कृपया व्यवसाय चुनें / Please select an occupation';
        if (_landSizeHectares == null) return 'कृपया भूमि का आकार चुनें / Please select a land size';
        return null;
      case 3:
        if (_ageError != null) return _ageError;
        if (_incomeError != null) return _incomeError;
        return null;
      case 4:
        if (_ownsPuccaHouse == null) return 'कृपया "पक्का मकान" का उत्तर दें / Please answer the "pucca house" question';
        if (_hasMotorizedVehicle == null) return 'कृपया "मोटर वाहन" का उत्तर दें / Please answer the "motorized vehicle" question';
        if (_isIncomeTaxPayer == null) return 'कृपया "इनकम टैक्स" का उत्तर दें / Please answer the "income tax" question';
        if (_isFpoMember == null) return 'कृपया "FPO सदस्यता" का उत्तर दें / Please answer the "FPO membership" question';
        return null;
      default:
        return null;
    }
  }

  void _goNext() {
    setState(() {
      _validationTriggered = true;
      _revalidateStep(_step);
    });
    final error = _firstStepError;
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 18),
            const SizedBox(width: 10),
            Expanded(child: Text(error, style: const TextStyle(fontWeight: FontWeight.w600))),
          ]),
          backgroundColor: _kOrange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
      return;
    }
    if (_step == _totalSteps - 1) { _submit(); return; }
    setState(() {
      _step++;
      _validationTriggered = false;
    });
    _fadeCtrl.reset(); _fadeCtrl.forward();
    _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeOutCubic);
  }

  void _goBack() {
    if (_step == 0) { Navigator.pop(context); return; }
    setState(() {
      _step--;
      _validationTriggered = false;
    });
    _fadeCtrl.reset(); _fadeCtrl.forward();
    _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeOutCubic);
  }

  Future<void> _submit() async {
    final profile = FarmerProfile(
      name: _nameCtrl.text.trim(),
      gender: _gender!,
      phone: _phoneCtrl.text.trim(),
      village: _villageCtrl.text.trim(),
      district: _districtCtrl.text.trim(),
      state: _state!,
      landSizeHectares: _landSizeHectares!,
      category: _category!,
      annualIncome: double.tryParse(_incomeCtrl.text.trim()) ?? 0,
      occupation: _occupation!,
      age: int.tryParse(_ageCtrl.text.trim()) ?? 0,
      ownsPuccaHouse: _ownsPuccaHouse!,
      hasMotorizedVehicle: _hasMotorizedVehicle!,
      isIncomeTaxPayer: _isIncomeTaxPayer!,
      isFpoMember: _isFpoMember!,
    );
    await ProfileStore.instance.saveProfile(profile);
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      body: Stack(
        children: [
          // Base flat colour underneath everything
          const Positioned.fill(child: ColoredBox(color: _kBg)),

          // ── Background — same home_bg.png, now fills the whole screen
          // with FRACTIONAL gradient stops (not fixed pixels) so it always
          // fades smoothly into _kBg no matter the device/window height —
          // matches the fix applied to the chat screen.
          Positioned.fill(
            child: Stack(fit: StackFit.expand, children: [
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
                        _kBg.withValues(alpha: 0.35),
                        _kBg.withValues(alpha: 0.7),
                        _kBg.withValues(alpha: 0.92),
                        _kBg,
                      ],
                      stops: const [0.0, 0.18, 0.32, 0.45, 0.56, 0.65],
                    ),
                  ),
                ),
              ),
            ]),
          ),

          // ── Content ──────────────────────────────────────────
          SafeArea(
            child: Column(
              children: [
                _buildTopBar(),
                Expanded(
                  child: FadeTransition(
                    opacity: _fadeAnim,
                    child: PageView(
                      controller: _pageController,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        _scrollPage(_buildStep0()),
                        _scrollPage(_buildStep1()),
                        _scrollPage(_buildStep2()),
                        _scrollPage(_buildStep3()),
                        _scrollPage(_buildStep4()),
                      ],
                    ),
                  ),
                ),
                _buildBottomBar(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _scrollPage(Widget child) => SingleChildScrollView(
    physics: const BouncingScrollPhysics(),
    padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
    child: child,
  );

  // ── Top bar with progress — frosted glass card, matches login screen ──
  Widget _buildTopBar() {
    final meta = _stepMeta[_step];
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.fromLTRB(10, 10, 16, 14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.82),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: Colors.white.withValues(alpha: 0.85), width: 1.2),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 14, offset: const Offset(0, 4)),
              ],
            ),
            child: Column(children: [
              Row(children: [
                GestureDetector(
                  onTap: _goBack,
                  child: Container(
                    width: 38, height: 38,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 6)],
                    ),
                    child: const Icon(Icons.arrow_back_ios_new_rounded, size: 17, color: _kDarkGreen),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(children: [
                    Text(
                      meta['titleHi']!,
                      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: _kDarkGreen),
                    ),
                    Text(
                      '${meta['title']} • Step ${_step + 1} of $_totalSteps',
                      style: TextStyle(fontSize: 11.5, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                    ),
                  ]),
                ),
                // Step circle indicator
                Container(
                  width: 42, height: 42,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    shape: BoxShape.circle,
                    border: Border.all(color: _kDarkGreen.withValues(alpha: 0.3), width: 1.5),
                  ),
                  alignment: Alignment.center,
                  child: Text(meta['emoji']!, style: const TextStyle(fontSize: 20)),
                ),
              ]),
              const SizedBox(height: 12),
              // Step dots + bar, with a checkmark on completed steps
              Row(children: List.generate(_totalSteps, (i) {
                final done = i < _step;
                final active = i == _step;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      height: 6,
                      decoration: BoxDecoration(
                        color: done ? _kDarkGreen : active ? _kLightGreen : Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: (done || active)
                            ? [BoxShadow(color: _kDarkGreen.withValues(alpha: 0.25), blurRadius: 4, offset: const Offset(0, 1))]
                            : null,
                      ),
                    ),
                  ),
                );
              })),
            ]),
          ),
        ),
      ),
    );
  }

  // ── Bottom bar ────────────────────────────────────────────────
  Widget _buildBottomBar() {
    final isLast = _step == _totalSteps - 1;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      decoration: BoxDecoration(
        color: _kBg,
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 12, offset: const Offset(0, -4)),
        ],
      ),
      child: Row(children: [
        Expanded(
          child: Container(
            height: 52,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: (isLast ? _kOrange : _kDarkGreen).withValues(alpha: 0.35),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: _goNext,
              style: ElevatedButton.styleFrom(
                backgroundColor: isLast ? _kOrange : _kDarkGreen,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text(
                  isLast ? 'योजनाएं देखें / Start' : 'आगे बढ़ें / Next',
                  style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w800),
                ),
                const SizedBox(width: 8),
                Icon(
                  isLast ? Icons.rocket_launch_rounded : Icons.arrow_forward_rounded,
                  color: Colors.white, size: 18,
                ),
              ]),
            ),
          ),
        ),
      ]),
    );
  }

  // ══════════════════════════════════════════════════════════════
  //  STEP 0 — Personal Details
  // ══════════════════════════════════════════════════════════════
  Widget _buildStep0() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _sectionCard(
        icon: Icons.badge_outlined,
        titleHi: 'बुनियादी जानकारी',
        titleEn: 'Basic Info',
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _fieldLabel('आपका पूरा नाम', 'Full Name'),
        _textInput(_nameCtrl, 'जैसे रामलाल वर्मा', Icons.person_outline,
            errorText: _nameError,
            onChanged: (v) => setState(() => _nameError = _validateName(v))),
        const SizedBox(height: 20),
        _fieldLabel('लिंग', 'Gender'),
        Row(children: [
          _genderTile('पुरुष', 'Male',  Icons.man_rounded,   'male'),
          const SizedBox(width: 10),
          _genderTile('महिला', 'Female', Icons.woman_rounded, 'female'),
          const SizedBox(width: 10),
          _genderTile('अन्य', 'Other',  Icons.person_outline, 'other'),
        ]),
        if (_validationTriggered && _gender == null) _selectionError('कृपया लिंग चुनें / Please select a gender'),
        const SizedBox(height: 20),
        _fieldLabel('मोबाइल नंबर', 'Mobile Number'),
        _textInput(_phoneCtrl, '10-digit number', Icons.smartphone_outlined,
            type: TextInputType.phone,
            maxLen: 10,
            formatters: [FilteringTextInputFormatter.digitsOnly],
            errorText: _phoneError,
            onChanged: (v) => setState(() => _phoneError = _validatePhone(v))),
      ])),
      const SizedBox(height: 14),
      _sectionCard(
        icon: Icons.location_on_outlined,
        titleHi: 'पता',
        titleEn: 'Address',
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _fieldLabel('गांव', 'Village'),
        _textInput(_villageCtrl, 'जैसे रामपुर', Icons.holiday_village_outlined,
            errorText: _villageError,
            onChanged: (v) => setState(() => _villageError = _validatePlace(v, 'गांव', 'Village'))),
        const SizedBox(height: 20),
        _fieldLabel('जिला', 'District'),
        _textInput(_districtCtrl, 'जैसे लुधियाना', Icons.location_on_outlined,
            errorText: _districtError,
            onChanged: (v) => setState(() => _districtError = _validatePlace(v, 'जिला', 'District'))),
      ])),
    ]);
  }

  // Small red hint shown below selection-based fields (chips/tiles) once
  // the user has tried to move forward without picking an option.
  Widget _selectionError(String msg) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(children: [
        Icon(Icons.error_outline, size: 14, color: Colors.red.shade600),
        const SizedBox(width: 6),
        Expanded(
          child: Text(msg, style: TextStyle(color: Colors.red.shade700, fontSize: 12, fontWeight: FontWeight.w600)),
        ),
      ]),
    );
  }

  // ══════════════════════════════════════════════════════════════
  //  STEP 1 — State + Category
  // ══════════════════════════════════════════════════════════════
  Widget _buildStep1() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _sectionCard(
        icon: Icons.map_outlined,
        titleHi: 'निवास स्थान',
        titleEn: 'Where You Live',
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _fieldLabel('राज्य', 'State'),
        const SizedBox(height: 4),
        // Dropdown for state (too many for chips)
        _styledDropdown<String>(
          value: _state,
          hint: 'अपना राज्य चुनें / Select State',
          items: _states.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
          onChanged: (v) => setState(() => _state = v),
        ),
        if (_validationTriggered && _state == null) _selectionError('कृपया राज्य चुनें / Please select a state'),
      ])),
      const SizedBox(height: 14),
      _sectionCard(
        icon: Icons.groups_outlined,
        titleHi: 'सामाजिक श्रेणी',
        titleEn: 'Social Category',
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _fieldLabel('जाति श्रेणी', 'Caste Category'),
        const SizedBox(height: 4),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 3,
          children: _categories.map((c) {
            final val = c['value']!;
            final isSelected = _category == val;
            return _chipTile(
              label: '${c['labelHi']} / ${c['label']}',
              isSelected: isSelected,
              onTap: () => setState(() => _category = val),
            );
          }).toList(),
        ),
        if (_validationTriggered && _category == null) _selectionError('कृपया श्रेणी चुनें / Please select a category'),
      ])),
    ]);
  }

  // ══════════════════════════════════════════════════════════════
  //  STEP 2 — Occupation + Land
  // ══════════════════════════════════════════════════════════════
  Widget _buildStep2() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _sectionCard(
        icon: Icons.work_outline,
        titleHi: 'आप क्या करते हैं?',
        titleEn: 'Your Occupation',
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _fieldLabel('व्यवसाय', 'Occupation'),
        const SizedBox(height: 4),
        ...(_occupations.map((o) {
          final val = o['value'] as String;
          final isSelected = _occupation == val;
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _occupationTile(o, isSelected, () => setState(() => _occupation = val)),
          );
        })),
        if (_validationTriggered && _occupation == null) _selectionError('कृपया व्यवसाय चुनें / Please select an occupation'),
      ])),
      const SizedBox(height: 14),
      _sectionCard(
        icon: Icons.terrain_outlined,
        titleHi: 'खेती की भूमि',
        titleEn: 'Farm Land',
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _fieldLabel('भूमि का आकार', 'Land Size'),
        const SizedBox(height: 4),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 2.8,
          children: _landOptions.map((o) {
            final val = o['hectares'] as double;
            final isSelected = _landSizeHectares == val;
            return _landChip(o['label'] as String, o['sub'] as String, isSelected,
                () => setState(() => _landSizeHectares = val));
          }).toList(),
        ),
        if (_validationTriggered && _landSizeHectares == null) _selectionError('कृपया भूमि का आकार चुनें / Please select a land size'),
      ])),
    ]);
  }

  // ══════════════════════════════════════════════════════════════
  //  STEP 3 — Age + Income
  // ══════════════════════════════════════════════════════════════
  Widget _buildStep3() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _sectionCard(
        icon: Icons.cake_outlined,
        titleHi: 'आयु विवरण',
        titleEn: 'Age Details',
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _fieldLabel('आयु', 'Age (years)'),
        _textInput(_ageCtrl, 'जैसे 45', Icons.cake_outlined,
            type: TextInputType.number,
            maxLen: 3,
            formatters: [FilteringTextInputFormatter.digitsOnly],
            errorText: _ageError,
            onChanged: (v) => setState(() => _ageError = _validateAge(v))),
      ])),
      const SizedBox(height: 14),
      _sectionCard(
        icon: Icons.account_balance_wallet_outlined,
        titleHi: 'आय विवरण',
        titleEn: 'Income Details',
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _fieldLabel('वार्षिक आय', 'Annual Income (₹)'),
        _textInput(_incomeCtrl, 'जैसे 80000', Icons.currency_rupee_rounded,
            type: TextInputType.number,
            maxLen: 8,
            formatters: [FilteringTextInputFormatter.digitsOnly],
            errorText: _incomeError,
            onChanged: (v) => setState(() => _incomeError = _validateIncome(v))),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFE8F5E9),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(children: [
            const Icon(Icons.lock_outline, color: _kDarkGreen, size: 16),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'यह जानकारी केवल योजना पात्रता जांचने हेतु उपयोग होती है।\nThis is used only for scheme eligibility.',
                style: TextStyle(fontSize: 11, color: Colors.grey.shade700, height: 1.4),
              ),
            ),
          ]),
        ),
      ])),
    ]);
  }

  // ══════════════════════════════════════════════════════════════
  //  STEP 4 — Assets (Yes/No)
  // ══════════════════════════════════════════════════════════════
  Widget _buildStep4() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _yesNoCard(
        'क्या आपका पक्का मकान है?',
        'Do you own a pucca house?',
        Icons.home_outlined,
        _ownsPuccaHouse,
        (v) => setState(() => _ownsPuccaHouse = v),
        showError: _validationTriggered && _ownsPuccaHouse == null,
      ),
      const SizedBox(height: 12),
      _yesNoCard(
        'क्या आपके पास मोटर वाहन है?',
        'Do you own a motorized vehicle?',
        Icons.directions_car_outlined,
        _hasMotorizedVehicle,
        (v) => setState(() => _hasMotorizedVehicle = v),
        showError: _validationTriggered && _hasMotorizedVehicle == null,
      ),
      const SizedBox(height: 12),
      _yesNoCard(
        'क्या आप इनकम टैक्स भरते हैं?',
        'Are you an income tax payer?',
        Icons.receipt_long_outlined,
        _isIncomeTaxPayer,
        (v) => setState(() => _isIncomeTaxPayer = v),
        showError: _validationTriggered && _isIncomeTaxPayer == null,
      ),
      const SizedBox(height: 12),
      _yesNoCard(
        'क्या आप किसी FPO के सदस्य हैं?',
        'Member of a Farmer Producer Organization?',
        Icons.people_outline,
        _isFpoMember,
        (v) => setState(() => _isFpoMember = v),
        showError: _validationTriggered && _isFpoMember == null,
      ),
    ]);
  }

  // ══════════════════════════════════════════════════════════════
  //  REUSABLE WIDGETS
  // ══════════════════════════════════════════════════════════════

  Widget _sectionCard({IconData? icon, String? titleHi, String? titleEn, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black.withValues(alpha: 0.03)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 16, offset: const Offset(0, 6)),
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 3, offset: const Offset(0, 1)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null && titleHi != null) ...[
            Row(children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: _kDarkGreen, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: RichText(
                  text: TextSpan(children: [
                    TextSpan(
                      text: titleHi,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: _kDarkGreen),
                    ),
                    if (titleEn != null)
                      TextSpan(
                        text: '  · $titleEn',
                        style: TextStyle(fontSize: 11.5, color: Colors.grey.shade500, fontWeight: FontWeight.w500),
                      ),
                  ]),
                ),
              ),
            ]),
            const SizedBox(height: 4),
            Divider(color: Colors.grey.shade200, height: 22, thickness: 1),
          ],
          child,
        ],
      ),
    );
  }

  Widget _fieldLabel(String hi, String en) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: RichText(
        text: TextSpan(children: [
          TextSpan(text: '$hi  ', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.black87)),
          TextSpan(text: '/ $en', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.grey.shade500)),
        ]),
      ),
    );
  }

  Widget _textInput(
    TextEditingController ctrl,
    String hint,
    IconData icon, {
    TextInputType type = TextInputType.text,
    int? maxLen,
    List<TextInputFormatter>? formatters,
    String? errorText,
    ValueChanged<String>? onChanged,
  }) {
    final radius = BorderRadius.circular(13);
    return TextField(
      controller: ctrl,
      keyboardType: type,
      maxLength: maxLen,
      inputFormatters: formatters,
      cursorColor: _kDarkGreen,
      onChanged: onChanged,
      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black87),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13.5, fontWeight: FontWeight.w400),
        prefixIcon: Container(
          margin: const EdgeInsets.all(10),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: const Color(0xFFE8F5E9), borderRadius: BorderRadius.circular(9)),
          child: Icon(icon, color: _kDarkGreen, size: 18),
        ),
        counterText: '',
        filled: true,
        fillColor: _kBg,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        errorText: errorText,
        errorMaxLines: 2,
        errorStyle: const TextStyle(color: Colors.red, fontSize: 11.5, fontWeight: FontWeight.w600, height: 1.3),
        border: OutlineInputBorder(borderRadius: radius, borderSide: BorderSide(color: Colors.grey.shade300, width: 1.5)),
        enabledBorder: OutlineInputBorder(borderRadius: radius, borderSide: BorderSide(color: Colors.grey.shade300, width: 1.5)),
        // Highlights green on focus — a small, premium touch
        focusedBorder: OutlineInputBorder(borderRadius: radius, borderSide: const BorderSide(color: _kDarkGreen, width: 2)),
        errorBorder: OutlineInputBorder(borderRadius: radius, borderSide: BorderSide(color: Colors.red.shade400, width: 1.5)),
        focusedErrorBorder: OutlineInputBorder(borderRadius: radius, borderSide: BorderSide(color: Colors.red.shade600, width: 2)),
      ),
    );
  }

  Widget _genderTile(String hi, String en, IconData icon, String value) {
    final isSelected = _gender == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _gender = value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isSelected ? _kDarkGreen : _kBg,
            borderRadius: BorderRadius.circular(13),
            border: Border.all(
              color: isSelected ? _kDarkGreen : Colors.grey.shade300,
              width: isSelected ? 2 : 1.5,
            ),
          ),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(icon, size: 24, color: isSelected ? Colors.white : Colors.grey.shade600),
            const SizedBox(height: 6),
            Text(hi, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800,
                color: isSelected ? Colors.white : Colors.black87)),
            Text(en, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500,
                color: isSelected ? Colors.white70 : Colors.grey.shade500)),
          ]),
        ),
      ),
    );
  }

  Widget _styledDropdown<T>({
    required T? value,
    required String hint,
    required List<DropdownMenuItem<T>> items,
    required void Function(T?) onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: _kBg,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: Colors.grey.shade300, width: 1.5),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isExpanded: true,
          hint: Text(hint, style: TextStyle(color: Colors.grey.shade400, fontSize: 13.5)),
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: _kDarkGreen),
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.black87),
          items: items,
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _chipTile({required String label, required bool isSelected, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? _kDarkGreen : _kBg,
          borderRadius: BorderRadius.circular(11),
          border: Border.all(color: isSelected ? _kDarkGreen : Colors.grey.shade300, width: 1.5),
        ),
        child: Text(label,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700,
                color: isSelected ? Colors.white : Colors.black87)),
      ),
    );
  }

  Widget _occupationTile(Map<dynamic, dynamic> o, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE8F5E9) : _kBg,
          borderRadius: BorderRadius.circular(13),
          border: Border.all(
            color: isSelected ? _kDarkGreen : Colors.grey.shade300,
            width: isSelected ? 2 : 1.5,
          ),
        ),
        child: Row(children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isSelected ? _kDarkGreen : Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(o['icon'] as IconData, size: 20,
                color: isSelected ? Colors.white : Colors.grey.shade500),
          ),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(o['labelHi'] as String,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800,
                    color: isSelected ? _kDarkGreen : Colors.black87)),
            Text(o['label'] as String,
                style: TextStyle(fontSize: 11.5, color: Colors.grey.shade500, fontWeight: FontWeight.w500)),
          ])),
          if (isSelected)
            const Icon(Icons.check_circle_rounded, color: _kDarkGreen, size: 22),
        ]),
      ),
    );
  }

  Widget _landChip(String label, String sub, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFFF3E0) : _kBg,
          borderRadius: BorderRadius.circular(11),
          border: Border.all(
            color: isSelected ? _kOrange : Colors.grey.shade300,
            width: isSelected ? 2 : 1.5,
          ),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800,
              color: isSelected ? _kOrange : Colors.black87)),
          Text(sub, style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
        ]),
      ),
    );
  }

  Widget _yesNoCard(
    String hi, String en, IconData icon,
    bool? value, void Function(bool) onChanged, {
    bool showError = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.circular(16),
        border: showError ? Border.all(color: Colors.red.shade300, width: 1.5) : null,
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 3)),
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(color: const Color(0xFFE8F5E9), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: _kDarkGreen, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(hi, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.black87)),
            Text(en, style: TextStyle(fontSize: 11.5, color: Colors.grey.shade500)),
          ])),
        ]),
        const SizedBox(height: 14),
        Row(children: [
          Expanded(child: _yesNoBtn('हां / Yes', true,  value, onChanged)),
          const SizedBox(width: 12),
          Expanded(child: _yesNoBtn('नहीं / No', false, value, onChanged)),
        ]),
        if (showError) _selectionError('कृपया उत्तर दें / Please answer this question'),
      ]),
    );
  }

  Widget _yesNoBtn(String label, bool opt, bool? selected, void Function(bool) onChanged) {
    final isSelected = selected == opt;
    final color = opt ? _kDarkGreen : Colors.redAccent.shade200;
    return GestureDetector(
      onTap: () => onChanged(opt),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 46,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? color : _kBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? color : Colors.grey.shade300, width: 1.5),
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(opt ? Icons.check_rounded : Icons.close_rounded,
              size: 16, color: isSelected ? Colors.white : Colors.grey.shade500),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700,
              color: isSelected ? Colors.white : Colors.black87)),
        ]),
      ),
    );
  }
}