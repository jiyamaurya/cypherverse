import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
  bool get _step0Valid =>
      _nameCtrl.text.trim().isNotEmpty && _gender != null &&
      _phoneCtrl.text.trim().length == 10 &&
      _villageCtrl.text.trim().isNotEmpty && _districtCtrl.text.trim().isNotEmpty;
  bool get _step1Valid => _state != null && _category != null;
  bool get _step2Valid => _occupation != null && _landSizeHectares != null;
  bool get _step3Valid =>
      _ageCtrl.text.trim().isNotEmpty &&
      int.tryParse(_ageCtrl.text.trim()) != null &&
      _incomeCtrl.text.trim().isNotEmpty;
  bool get _step4Valid =>
      _ownsPuccaHouse != null && _hasMotorizedVehicle != null &&
      _isIncomeTaxPayer != null && _isFpoMember != null;

  bool get _currentStepValid {
    switch (_step) {
      case 0: return _step0Valid;
      case 1: return _step1Valid;
      case 2: return _step2Valid;
      case 3: return _step3Valid;
      case 4: return _step4Valid;
      default: return false;
    }
  }

  void _goNext() {
    if (!_currentStepValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(children: [
            Icon(Icons.info_outline, color: Colors.white, size: 18),
            SizedBox(width: 10),
            Text('कृपया सभी जानकारी भरें / Please fill all fields',
                style: TextStyle(fontWeight: FontWeight.w600)),
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
    setState(() => _step++);
    _fadeCtrl.reset(); _fadeCtrl.forward();
    _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeOutCubic);
  }

  void _goBack() {
    if (_step == 0) { Navigator.pop(context); return; }
    setState(() => _step--);
    _fadeCtrl.reset(); _fadeCtrl.forward();
    _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeOutCubic);
  }

  void _submit() {
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
    ProfileStore.instance.saveProfile(profile);
    Navigator.pushReplacementNamed(context, '/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      body: Stack(
        children: [
          // ── Background — same home_bg.png ─────────────────────
          Positioned(
            top: 0, left: 0, right: 0, height: 280,
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
                        _kBg.withValues(alpha: 0.8),
                        _kBg,
                      ],
                      stops: const [0.0, 0.5, 0.80, 1.0],
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

  // ── Top bar with progress ─────────────────────────────────────
  Widget _buildTopBar() {
    final meta = _stepMeta[_step];
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 20, 0),
      child: Column(children: [
        Row(children: [
          IconButton(
            onPressed: _goBack,
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
            color: _kDarkGreen,
          ),
          Expanded(
            child: Column(children: [
              Text(
                meta['titleHi']!,
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: _kDarkGreen),
              ),
              Text(
                '${meta['title']} • Step ${_step + 1} of $_totalSteps',
                style: TextStyle(fontSize: 11.5, color: Colors.grey.shade500, fontWeight: FontWeight.w500),
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
        const SizedBox(height: 10),
        // Step dots + bar
        Row(children: List.generate(_totalSteps, (i) {
          final done = i < _step;
          final active = i == _step;
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: 5,
                decoration: BoxDecoration(
                  color: done ? _kDarkGreen : active ? _kLightGreen : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          );
        })),
        const SizedBox(height: 4),
      ]),
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
        // Back pill button
        if (_step > 0) ...[
          GestureDetector(
            onTap: _goBack,
            child: Container(
              height: 52,
              padding: const EdgeInsets.symmetric(horizontal: 18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey.shade300, width: 1.5),
              ),
              alignment: Alignment.center,
              child: const Icon(Icons.arrow_back_rounded, color: _kDarkGreen, size: 22),
            ),
          ),
          const SizedBox(width: 12),
        ],
        Expanded(
          child: SizedBox(
            height: 52,
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
      _sectionCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _fieldLabel('आपका पूरा नाम', 'Full Name'),
        _textInput(_nameCtrl, 'जैसे रामलाल वर्मा', Icons.person_outline),
        const SizedBox(height: 20),
        _fieldLabel('लिंग', 'Gender'),
        Row(children: [
          _genderTile('पुरुष', 'Male',  Icons.man_rounded,   'male'),
          const SizedBox(width: 10),
          _genderTile('महिला', 'Female', Icons.woman_rounded, 'female'),
          const SizedBox(width: 10),
          _genderTile('अन्य', 'Other',  Icons.person_outline, 'other'),
        ]),
        const SizedBox(height: 20),
        _fieldLabel('मोबाइल नंबर', 'Mobile Number'),
        _textInput(_phoneCtrl, '10-digit number', Icons.smartphone_outlined,
            type: TextInputType.phone,
            maxLen: 10,
            formatters: [FilteringTextInputFormatter.digitsOnly]),
      ])),
      const SizedBox(height: 14),
      _sectionCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _fieldLabel('गांव', 'Village'),
        _textInput(_villageCtrl, 'जैसे रामपुर', Icons.holiday_village_outlined),
        const SizedBox(height: 20),
        _fieldLabel('जिला', 'District'),
        _textInput(_districtCtrl, 'जैसे लुधियाना', Icons.location_on_outlined),
      ])),
    ]);
  }

  // ══════════════════════════════════════════════════════════════
  //  STEP 1 — State + Category
  // ══════════════════════════════════════════════════════════════
  Widget _buildStep1() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _sectionCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _fieldLabel('राज्य', 'State'),
        const SizedBox(height: 4),
        // Dropdown for state (too many for chips)
        _styledDropdown<String>(
          value: _state,
          hint: 'अपना राज्य चुनें / Select State',
          items: _states.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
          onChanged: (v) => setState(() => _state = v),
        ),
      ])),
      const SizedBox(height: 14),
      _sectionCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
      ])),
    ]);
  }

  // ══════════════════════════════════════════════════════════════
  //  STEP 2 — Occupation + Land
  // ══════════════════════════════════════════════════════════════
  Widget _buildStep2() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _sectionCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
      ])),
      const SizedBox(height: 14),
      _sectionCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
      ])),
    ]);
  }

  // ══════════════════════════════════════════════════════════════
  //  STEP 3 — Age + Income
  // ══════════════════════════════════════════════════════════════
  Widget _buildStep3() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _sectionCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _fieldLabel('आयु', 'Age (years)'),
        _textInput(_ageCtrl, 'जैसे 45', Icons.cake_outlined,
            type: TextInputType.number,
            formatters: [FilteringTextInputFormatter.digitsOnly]),
      ])),
      const SizedBox(height: 14),
      _sectionCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _fieldLabel('वार्षिक आय', 'Annual Income (₹)'),
        _textInput(_incomeCtrl, 'जैसे 80000', Icons.currency_rupee_rounded,
            type: TextInputType.number,
            formatters: [FilteringTextInputFormatter.digitsOnly]),
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
      ),
      const SizedBox(height: 12),
      _yesNoCard(
        'क्या आपके पास मोटर वाहन है?',
        'Do you own a motorized vehicle?',
        Icons.directions_car_outlined,
        _hasMotorizedVehicle,
        (v) => setState(() => _hasMotorizedVehicle = v),
      ),
      const SizedBox(height: 12),
      _yesNoCard(
        'क्या आप इनकम टैक्स भरते हैं?',
        'Are you an income tax payer?',
        Icons.receipt_long_outlined,
        _isIncomeTaxPayer,
        (v) => setState(() => _isIncomeTaxPayer = v),
      ),
      const SizedBox(height: 12),
      _yesNoCard(
        'क्या आप किसी FPO के सदस्य हैं?',
        'Member of a Farmer Producer Organization?',
        Icons.people_outline,
        _isFpoMember,
        (v) => setState(() => _isFpoMember = v),
      ),
    ]);
  }

  // ══════════════════════════════════════════════════════════════
  //  REUSABLE WIDGETS
  // ══════════════════════════════════════════════════════════════

  Widget _sectionCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: child,
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
  }) {
    return Container(
      decoration: BoxDecoration(
        color: _kBg,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: Colors.grey.shade300, width: 1.5),
      ),
      child: TextField(
        controller: ctrl,
        keyboardType: type,
        maxLength: maxLen,
        inputFormatters: formatters,
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
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        ),
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
    bool? value, void Function(bool) onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.circular(16),
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