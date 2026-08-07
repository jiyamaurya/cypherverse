import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'scheme_detail_screen.dart';
import '../../../core/logic/scheme_loader.dart';
import '../../../core/logic/scheme_matcher.dart';
import '../../../core/state/profile_store.dart';

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
  String _selectedCategoryKey = 'all';

  // Real data: loaded once from the JSON asset, then matched against the
  // farmer profile. Using a Future so the FutureBuilder below can show a
  // loading state instead of a blank/crashed screen on first frame.
  late final Future<List<MatchResult>> _matchResultsFuture = _loadAndMatch();

  Future<List<MatchResult>> _loadAndMatch() async {
    final schemes = await loadSchemes();
    // Reads the real farmer profile saved during the one-time setup form.
    // Falls back to a placeholder internally if the form hasn't been
    // filled yet (see ProfileStore.profile), so this never crashes —
    // but results will be generic/wrong until the form is completed.
    final profile = ProfileStore.instance.profile;
    return matchSchemes(profile, schemes);
  }

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

  // ── Category chips (UI-only for now — not yet wired to filter real data) ──
  final List<Map<String, dynamic>> _categories = [
  {'icon': Icons.grid_view_rounded,        'label': 'सभी योजनाएं',   'key': 'all'},
  {'icon': Icons.agriculture_outlined,     'label': 'किसान सहायता', 'key': 'farmer'},
  {'icon': Icons.security_outlined,        'label': 'फसल बीमा',     'key': 'insurance'},
  {'icon': Icons.pets_outlined,            'label': 'पशुपालन',      'key': 'animal'},
  {'icon': Icons.currency_rupee_outlined,  'label': 'ऋण और क्रेडिट','key': 'cash'},
  {'icon': Icons.more_horiz,               'label': 'और अधिक',      'key': 'other'},
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
            onCategoryChanged: (i) => setState(() {
  _selectedCategory = i;
  _selectedCategoryKey = _categories[i]['key'] as String;
}),
          ),

          // ── SCROLLABLE CONTENT ZONE ────────────────────────────────────
          Expanded(
            child: Container(
              color: kBg,
              child: FutureBuilder<List<MatchResult>>(
                future: _matchResultsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return const Center(
                      child: CircularProgressIndicator(color: kMedGreen),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          'योजनाएं लोड नहीं हो सकीं। कृपया फिर से प्रयास करें।\n(${snapshot.error})',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ),
                    );
                  }

                  final allResults = snapshot.data ?? [];
final results = _selectedCategoryKey == 'all'
    ? allResults
    : allResults.where((r) {
        if (_selectedCategoryKey == 'insurance') {
          return r.scheme.benefitType == 'insurance';
        } else if (_selectedCategoryKey == 'cash') {
          return r.scheme.benefitType == 'cash';
        } else if (_selectedCategoryKey == 'farmer') {
          return r.scheme.whoQualifies.any((rule) =>
              rule.field == 'occupation' &&
              (rule.value == 'farmer' || (rule.value is List && (rule.value as List).contains('farmer'))));
        } else if (_selectedCategoryKey == 'animal') {
          return r.scheme.schemeName.toLowerCase().contains('pashu') ||
              r.scheme.schemeName.toLowerCase().contains('animal') ||
              r.scheme.ministry.toLowerCase().contains('animal');
        }
        return true;
      }).toList();

                  return ListView(
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
                        child: _SectionHeader(count: results.length),
                      ),
                      const SizedBox(height: 12),
                      ...results.map(
                        (r) => Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          child: _SchemeCard(result: r),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                        child: _HelpBanner(),
                      ),
                    ],
                  );
                },
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
                          kBg.withValues(alpha: 0.8),
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
                            color: Colors.black.withValues(alpha: 0.05),
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
                                color: Colors.black.withValues(alpha: 0.1),
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
            color: Colors.black.withValues(alpha: 0.06),
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
                    color: kOrange.withValues(alpha: 0.3),
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
        separatorBuilder: (_, _) => const SizedBox(width: 10),
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
                        ? kDarkGreen.withValues(alpha: 0.18)
                        : Colors.black.withValues(alpha: 
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
                color: Colors.black.withValues(alpha: 0.04),
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
// ─────────────────────────────────────────────────────────────────────────────
//  ELIGIBILITY BADGE — 3-state: eligible / possiblyEligible / notEligible
//  Never silently hides "not eligible" or "needs verification" — see
//  scheme_matcher.dart precedence comments for why honesty here matters.
// ─────────────────────────────────────────────────────────────────────────────
class _EligibilityBadge extends StatelessWidget {
  final EligibilityStatus status;
  const _EligibilityBadge({required this.status});

  ({Color bg, Color fg, String label}) get _style {
    switch (status) {
      case EligibilityStatus.eligible:
        return (bg: const Color(0xFFE8F5E9), fg: kMedGreen, label: 'पात्र हैं');
      case EligibilityStatus.possiblyEligible:
        return (
          bg: const Color(0xFFFFF3E0),
          fg: const Color(0xFFE65100),
          label: 'जांच करें',
        );
      case EligibilityStatus.notEligible:
        return (
          bg: const Color(0xFFFFEBEE),
          fg: const Color(0xFFC62828),
          label: 'पात्र नहीं',
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = _style;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: s.bg,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        s.label,
        style: TextStyle(
          fontSize: 9.5,
          fontWeight: FontWeight.w900,
          color: s.fg,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Maps a scheme's benefit_type to a representative icon — no network
//  images, since real scheme data has no photos and the app is offline-first.
// ─────────────────────────────────────────────────────────────────────────────
IconData _iconForBenefitType(String benefitType) {
  switch (benefitType) {
    case 'cash':
      return Icons.currency_rupee_rounded;
    case 'insurance':
      return Icons.health_and_safety_outlined;
    case 'subsidy':
      return Icons.agriculture_rounded;
    case 'pension':
      return Icons.elderly_outlined;
    case 'scholarship':
      return Icons.school_outlined;
    default:
      return Icons.description_outlined;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  SCHEME CARD — now driven by real MatchResult data
// ─────────────────────────────────────────────────────────────────────────────
class _SchemeCard extends StatelessWidget {
  final MatchResult result;
  const _SchemeCard({required this.result});

  @override
  Widget build(BuildContext context) {
    final scheme = result.scheme;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Icon block — replaces network image; offline-safe ────────
            SizedBox(
              width: 100,
              child: ClipRRect(
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(16),
                ),
                child: Container(
                  color: const Color(0xFFE8F5E9),
                  child: Center(
                    child: Icon(
                      _iconForBenefitType(scheme.benefitType),
                      color: kMedGreen,
                      size: 40,
                    ),
                  ),
                ),
              ),
            ),

            // ── Details ────────────────────────────────────────────────────
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name + speaker icon
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            scheme.schemeName,
                            style: const TextStyle(
                              fontSize: 15,
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
                        ),
                      ],
                    ),
                    if (scheme.needsVerification) ...[
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF3E0),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: const Color(0xFFFFB74D)),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.warning_amber_rounded, size: 12, color: Color(0xFFE65100)),
                            SizedBox(width: 4),
                            Text(
                              'असत्यापित / Unverified',
                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFFE65100)),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),

                    // Eligibility badge — replaces the old fake category tag
                    _EligibilityBadge(status: result.status),
                    const SizedBox(height: 8),

                    // Benefit description (real data)
                    Text(
                      scheme.benefit,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w600,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 6),

                    // Ministry + state, replaces fake "beneficiaries" stat
                    Row(
                      children: [
                        Icon(
                          Icons.account_balance_outlined,
                          size: 14,
                          color: Colors.grey.shade500,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            scheme.state == 'central'
                                ? 'केंद्र सरकार'
                                : scheme.state,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11.5,
                              color: Colors.grey.shade500,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // CTA button
                    SizedBox(
                      width: double.infinity,
                      height: 40,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => SchemeDetailScreen(result: result),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kDarkGreen,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: EdgeInsets.zero,
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'पात्रता जानें',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(width: 6),
                            Icon(
                              Icons.arrow_forward_rounded,
                              color: Colors.white,
                              size: 16,
                            ),
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
            color: kDarkGreen.withValues(alpha: 0.25),
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
              color: Colors.white.withValues(alpha: 0.15),
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
                  color: kOrange.withValues(alpha: 0.40),
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
            color: Colors.black.withValues(alpha: 
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
