import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  COLOR TOKENS  (shared across the whole app — matches HomeScreen exactly)
// ─────────────────────────────────────────────────────────────────────────────
const kDarkGreen = Color(0xFF1B5E20);
const kMedGreen = Color(0xFF2E7D32);
const kLightGreen = Color(0xFF43A047);
const kOrange = Color(0xFFEF6C00);
const kBg = Color(0xFFF7F6F0); // ✅ now matches HomeScreen's bgColor

// ─────────────────────────────────────────────────────────────────────────────
//  SCHEMES SCREEN
// ─────────────────────────────────────────────────────────────────────────────
class SchemesScreen extends StatefulWidget {
  const SchemesScreen({super.key});

  @override
  State<SchemesScreen> createState() => _SchemesScreenState();
}

class _SchemesScreenState extends State<SchemesScreen> {
  int _selectedNavIndex = 1;
  int _selectedCategory = 0;

  // ── Navigation routing ────────────────────────────────────────────────────
  void _onNavTap(int index) {
    if (index == _selectedNavIndex) return;
    setState(() => _selectedNavIndex = index);

    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/home');
        break;
      case 1:
        // Already here
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/chat');
        break;
      case 3:
        Navigator.pushReplacementNamed(context, '/documents');
        break;
      case 4:
        Navigator.pushReplacementNamed(context, '/profile');
        break;
    }
  }

  // ── Data ──────────────────────────────────────────────────────────────────
  final List<Map<String, dynamic>> _categories = [
    {'icon': Icons.grid_view_rounded, 'label': 'सभी योजनाएं'},
    {'icon': Icons.agriculture_outlined, 'label': 'किसान सहायता'},
    {'icon': Icons.security_outlined, 'label': 'फसल बीमा'},
    {'icon': Icons.pets_outlined, 'label': 'पशुपालन'},
    {'icon': Icons.currency_rupee_outlined, 'label': 'ऋण और क्रेडिट'},
    {'icon': Icons.more_horiz, 'label': 'और अधिक'},
  ];

  final List<Map<String, dynamic>> _schemes = [
    {
      'name': 'PM-Kisan Samman Nidhi',
      'tag': 'DIRECT BENEFIT',
      'tagColor': kMedGreen,
      'tagBg': Color(0xFFE8F5E9),
      'desc': 'पैसे की मदद: ₹2000 प्रति किस्त',
      'beneficiaries': '12.5 करोड़+ किसान लाभान्वित',
      'imageUrl':
          'https://images.unsplash.com/photo-1574323347407-f5e1ad6d020b?q=80&w=500&auto=format&fit=crop',
    },
    {
      'name': 'PM Fasal Bima Yojana',
      'tag': 'बीमा योजना',
      'tagColor': Color(0xFFE65100),
      'tagBg': Color(0xFFFFF3E0),
      'desc': 'फसल नुकसान पर बीमा सुरक्षा',
      'beneficiaries': '3.2 करोड़+ किसान लाभान्वित',
      'imageUrl':
          'https://images.unsplash.com/photo-1464226184884-fa280b87c399?q=80&w=500&auto=format&fit=crop',
    },
    {
      'name': 'पशुपालन विकास योजना',
      'tag': 'पशुपालन',
      'tagColor': Color(0xFF6A1B9A),
      'tagBg': Color(0xFFF3E5F5),
      'desc': 'पशुओं के पालन के लिए सहायता',
      'beneficiaries': '45 लाख+ किसान लाभान्वित',
      'imageUrl':
          'https://images.unsplash.com/photo-1560493676-04071c5f467b?q=80&w=500&auto=format&fit=crop',
    },
    {
      'name': 'किसान क्रेडिट कार्ड (KCC)',
      'tag': 'ऋण योजना',
      'tagColor': Color(0xFF01579B),
      'tagBg': Color(0xFFE3F2FD),
      'desc': 'सस्ता और आसान कृषि लोन',
      'beneficiaries': '6.8 करोड़+ किसान लाभान्वित',
      'imageUrl':
          'https://images.unsplash.com/photo-1559827260-dc66d52bef19?q=80&w=500&auto=format&fit=crop',
    },
  ];

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
      body: Column(
        children: [
          // ── STICKY HEADER ZONE (matches HomeScreen bg treatment) ───────
          _StickyHeader(
            selectedCategory: _selectedCategory,
            categories: _categories,
            onCategoryChanged: (i) => setState(() => _selectedCategory = i),
          ),

          // ── SCROLLABLE CONTENT ZONE ────────────────────────────────────
          Expanded(
            child: Container(
              color: kBg,
              child: ListView(
                padding: EdgeInsets.zero,
                physics: const BouncingScrollPhysics(),
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      color: kBg,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(24),
                      ),
                    ),
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: _SectionHeader(count: _schemes.length),
                  ),
                  const SizedBox(height: 12),
                  ..._schemes.map(
                    (s) => Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: _SchemeCard(scheme: s),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                    child: _HelpBanner(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  STICKY HEADER — background now matches HomeScreen exactly
//  Same image, same gradient fade, same fallback gradient
// ─────────────────────────────────────────────────────────────────────────────
class _StickyHeader extends StatelessWidget {
  final int selectedCategory;
  final List<Map<String, dynamic>> categories;
  final ValueChanged<int> onCategoryChanged;

  const _StickyHeader({
    required this.selectedCategory,
    required this.categories,
    required this.onCategoryChanged,
  });

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Container(
      decoration: const BoxDecoration(color: kBg),
      child: Stack(
        children: [
          // ── Hero image — IDENTICAL treatment to HomeScreen ─────────────
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            bottom: 0,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // ✅ Same image + same fallback gradient as HomeScreen
                Image.asset(
                  'assets/images/home_bg.png',
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                  errorBuilder: (_, __, ___) => Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0xFFE8F5E9), Color(0xFFC8E6C9)],
                      ),
                    ),
                  ),
                ),
                // ✅ Same gradient fade as HomeScreen (no radial darken)
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.transparent,
                          kBg.withOpacity(0.8),
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

          // ── UI content over image ────────────────────────────────────────
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
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'योजनाएं',
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
                          'आपके लिए सभी सरकारी योजनाएं',
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
                    // ✅ Language pill — same style as HomeScreen
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
                            color: Colors.black.withOpacity(0.05),
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
                    // ✅ Avatar — same style as HomeScreen
                    Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
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
                              color:
                                  kDarkGreen, // ✅ same green dot as HomeScreen
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
                _SearchBar(),

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
//  SEARCH BAR — ✅ now matches HomeScreen sizing exactly
// ─────────────────────────────────────────────────────────────────────────────
class _SearchBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30), // ✅ same radius as HomeScreen
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'योजना ढूंढें या बोल कर पूछें',
          hintStyle: TextStyle(
            color: Colors.grey.shade500, // ✅ same shade as HomeScreen
            fontSize: 13.5,
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: const Icon(
            Icons.search,
            color: Colors.grey,
            size: 24,
          ), // ✅ same
          suffixIcon: Padding(
            padding: const EdgeInsets.all(6.0), // ✅ same padding as HomeScreen
            child: Container(
              decoration: BoxDecoration(
                color: kOrange,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: kOrange.withOpacity(0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Icon(
                Icons.mic,
                color: Colors.white,
                size: 20,
              ), // ✅ same size
            ),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16, // ✅ same vertical padding as HomeScreen
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  CATEGORY CHIPS — ✅ bumped up sizes for better phone tap targets
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
      height: 82, // ✅ was 74 — more room for touch
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(vertical: 2),
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, i) {
          final cat = categories[i];
          final isSelected = selected == i;
          return GestureDetector(
            onTap: () => onChanged(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 10,
              ), // ✅ was 14/8
              decoration: BoxDecoration(
                color: isSelected ? kDarkGreen : Colors.white,
                borderRadius: BorderRadius.circular(16), // ✅ was 14
                border: Border.all(
                  color: isSelected ? kDarkGreen : Colors.grey.shade300,
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isSelected
                        ? kDarkGreen.withOpacity(0.18)
                        : Colors.black.withOpacity(
                            0.04,
                          ), // ✅ slightly lighter like HomeScreen
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
                    size: 26, // ✅ was 22 — easier to see on phone
                  ),
                  const SizedBox(height: 6), // ✅ was 5
                  Text(
                    cat['label'] as String,
                    style: TextStyle(
                      fontSize: 11, // ✅ was 10 — more readable
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
//  SECTION HEADER — ✅ bumped font to match HomeScreen heading sizes
// ─────────────────────────────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final int count;
  const _SectionHeader({required this.count});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'सभी योजनाएं ($count)',
          style: const TextStyle(
            fontSize:
                18, // ✅ was 16 — matches HomeScreen's "आपके लिए सुझाव" size
            fontWeight: FontWeight.w900,
            color: Colors.black87,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 8,
          ), // ✅ was 12/7
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Row(
            children: [
              Icon(
                Icons.filter_list_rounded,
                color: kDarkGreen,
                size: 18,
              ), // ✅ was 16
              SizedBox(width: 6), // ✅ was 5
              Text(
                'फ़िल्टर',
                style: TextStyle(
                  fontSize: 13, // ✅ was 12
                  fontWeight: FontWeight.w700,
                  color: kDarkGreen,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  SCHEME CARD — ✅ all sizes increased for better phone readability
// ─────────────────────────────────────────────────────────────────────────────
class _SchemeCard extends StatelessWidget {
  final Map<String, dynamic> scheme;
  const _SchemeCard({required this.scheme});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(
              0.05,
            ), // ✅ was 0.07 — matches HomeScreen
            blurRadius: 10, // ✅ was 14 — matches HomeScreen
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Image — wider for better visual impact ───────────────────
            SizedBox(
              width:
                  135, // ✅ was 120 — closer to HomeScreen's 135 suggestion card
              child: ClipRRect(
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(16),
                ),
                child: Image.network(
                  scheme['imageUrl'] as String,
                  fit: BoxFit.cover,
                  loadingBuilder: (_, child, progress) => progress == null
                      ? child
                      : Container(
                          color: const Color(0xFFE8F5E9),
                          child: const Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: kMedGreen,
                            ),
                          ),
                        ),
                  errorBuilder: (_, __, ___) => Container(
                    color: const Color(0xFFE8F5E9),
                    child: const Icon(
                      Icons.agriculture_rounded,
                      color: kMedGreen,
                      size: 44,
                    ), // ✅ was 40
                  ),
                ),
              ),
            ),

            // ── Details — bigger fonts, more spacing ─────────────────────
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  14,
                  14,
                  14,
                  14,
                ), // ✅ was 12/13/12/13
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name + speaker icon
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            scheme['name'] as String,
                            style: const TextStyle(
                              fontSize:
                                  15, // ✅ was 14 — matches HomeScreen suggestion card
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF1A1A1A),
                              height: 1.25,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(
                          Icons.volume_up_rounded,
                          color: kDarkGreen,
                          size: 20,
                        ), // ✅ was 18 — matches HomeScreen
                      ],
                    ),
                    const SizedBox(height: 8), // ✅ was 7
                    // Tag badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ), // ✅ vertical was 3
                      decoration: BoxDecoration(
                        color: scheme['tagBg'] as Color,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        scheme['tag'] as String,
                        style: TextStyle(
                          fontSize: 9.5, // ✅ was 9
                          fontWeight: FontWeight.w900,
                          color: scheme['tagColor'] as Color,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8), // ✅ was 7
                    // Description
                    Text(
                      scheme['desc'] as String,
                      style: TextStyle(
                        fontSize: 13, // ✅ was 12 — more readable
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w600,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 6),

                    // Beneficiaries
                    Row(
                      children: [
                        Icon(
                          Icons.people_alt_outlined,
                          size: 14,
                          color: Colors.grey.shade500,
                        ), // ✅ was 12
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            scheme['beneficiaries'] as String,
                            style: TextStyle(
                              fontSize: 11.5, // ✅ was 10.5
                              color: Colors.grey.shade500,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // CTA button — matches HomeScreen suggestion button
                    SizedBox(
                      width: double.infinity,
                      height: 40, // ✅ was 36 — closer to HomeScreen's 38
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kDarkGreen,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ), // ✅ was 10 — matches HomeScreen
                          padding: EdgeInsets.zero,
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'पात्रता जानें',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13, // ✅ was 12.5
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(width: 6),
                            Icon(
                              Icons.arrow_forward_rounded,
                              color: Colors.white,
                              size: 16,
                            ), // ✅ was 14 — matches HomeScreen
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  HELP BANNER — ✅ bumped fonts for readability
// ─────────────────────────────────────────────────────────────────────────────
class _HelpBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 16,
      ), // ✅ was 14/13
      decoration: BoxDecoration(
        color: kDarkGreen,
        borderRadius: BorderRadius.circular(
          10,
        ), // ✅ matches HomeScreen footer banner radius
        boxShadow: [
          BoxShadow(
            color: kDarkGreen.withOpacity(0.25),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8), // ✅ was 7
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.info_outline,
              color: Colors.white,
              size: 20,
            ), // ✅ was 18
          ),
          const SizedBox(width: 12), // ✅ was 10
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'कोई योजना नहीं मिल रही?',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14, // ✅ was 13
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 3), // ✅ was 2
                Text(
                  'हमसे बात करें, हम मदद करेंगे',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12, // ✅ was 11
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10), // ✅ was 8
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 10,
            ), // ✅ was 12/9
            decoration: BoxDecoration(
              color: kOrange,
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: kOrange.withOpacity(0.40),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.mic_rounded,
                  color: Colors.white,
                  size: 16,
                ), // ✅ was 15
                SizedBox(width: 6), // ✅ was 5
                Text(
                  'बोल कर पूछें',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12.5, // ✅ was 11.5
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  BOTTOM NAV BAR — ✅ now matches HomeScreen exactly
//  Height: 75, icon: 26, label: 11, active color: kDarkGreen, indicator: kDarkGreen
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
      height: 75, // ✅ was 62 — matches HomeScreen
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(
              0.06,
            ), // ✅ was 0.08 — matches HomeScreen
            blurRadius: 15, // ✅ was 16
            offset: const Offset(0, -5), // ✅ was -4 — matches HomeScreen
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
              width: 60, // ✅ matches HomeScreen
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isSelected ? item.activeIcon : item.icon,
                    color: isSelected
                        ? kDarkGreen
                        : Colors.grey.shade400, // ✅ was kMedGreen
                    size: 26, // ✅ was 24 — matches HomeScreen
                  ),
                  const SizedBox(height: 4), // ✅ matches HomeScreen
                  Text(
                    item.label,
                    style: TextStyle(
                      fontSize: 11, // ✅ was 10.5 — matches HomeScreen
                      fontWeight: isSelected
                          ? FontWeight.w800
                          : FontWeight.w600, // ✅ was w500 — matches HomeScreen
                      color: isSelected
                          ? kDarkGreen // ✅ was kMedGreen — matches HomeScreen
                          : Colors.grey.shade500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300), // ✅ was 280
                    curve: Curves.easeOutQuint,
                    height: 3, // ✅ was 2.5 — matches HomeScreen
                    width: isSelected ? 24 : 0, // ✅ was 22 — matches HomeScreen
                    decoration: BoxDecoration(
                      color: kDarkGreen, // ✅ was kOrange — matches HomeScreen
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
