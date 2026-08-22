import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'dart:ui';

import '../../../core/state/profile_store.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  // Real logged-in user's profile — replaces the old hardcoded "Ramesh Ji".
  final profile = ProfileStore.instance.profile;

  static const Color darkForestGreen = Color(0xFF1B5E20);
  static const Color mediumForestGreen = Color(0xFF2E7D32);
  static const Color orange = Color(0xFFEF6C00);
  static const Color bgColor = Color(0xFFF7F6F0);

  void _onNavTap(int index) {
    if (index == _selectedIndex) return;

    if (index == 0) {
      setState(() => _selectedIndex = index);
    } else if (index == 1) {
      Navigator.pushReplacementNamed(context, '/schemes');
    } else if (index == 2) {
      Navigator.pushReplacementNamed(context, '/chat');
    } else if (index == 3) {
      Navigator.pushReplacementNamed(context, '/documents');
    } else if (index == 4) {
      Navigator.pushReplacementNamed(context, '/profile');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          // LAYER 1: Illustrated background with fade
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 480,
            child: Stack(
              fit: StackFit.expand,
              children: [
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
                          bgColor.withValues(alpha: 0.8),
                          bgColor,
                        ],
                        stops: const [0.0, 0.6, 0.85, 1.0],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // LAYER 2: Scrollable content
          SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 12.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 28),
                  _buildGreeting(),
                  const SizedBox(height: 24),
                  _buildStatusCards(),
                  const SizedBox(height: 16),
                  _buildProgressCard(),
                  const SizedBox(height: 24),
                  _buildSearchBar(),
                  const SizedBox(height: 28),
                  _buildResponsiveGridMenu(),
                  const SizedBox(height: 28),
                  _buildSuggestions(),
                  const SizedBox(height: 20),
                  _buildFooterBanner(),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildCustomBottomNav(),
    );
  }

  // ── Header ───────────────────────────────────────────────────
  Widget _buildHeader() {
    return Row(
      children: [
        SizedBox(
          width: 48,
          height: 38,
          child: Image.asset('assets/images/app_logo.png', fit: BoxFit.contain),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Yojana Mitra',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: darkForestGreen,
                letterSpacing: -0.5,
              ),
            ),
            Text(
              'आपका साथी सरकारी योजनाओं में',
              style: TextStyle(
                fontSize: 11, // ✅ was 10.5
                fontWeight: FontWeight.w700,
                color: mediumForestGreen,
              ),
            ),
          ],
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4),
            ],
          ),
          child: const Row(
            children: [
              Text(
                'हिंदी',
                style: TextStyle(
                  color: darkForestGreen,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
              SizedBox(width: 4),
              Icon(Icons.keyboard_arrow_down, color: darkForestGreen, size: 16),
            ],
          ),
        ),
        const SizedBox(width: 12),
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
              child: CircleAvatar(
  radius: 18,
  backgroundColor: darkForestGreen.withValues(alpha: 0.15),
  backgroundImage: const NetworkImage(
    'https://i.pravatar.cc/150?img=11',
  ),
  onBackgroundImageError: (exception, stackTrace) {
    // Avoid crashing the app if the avatar fails to load.
  },
),
            ),
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: darkForestGreen,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ── Greeting ─────────────────────────────────────────────────
  Widget _buildGreeting() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Namaste, ${profile.name} 👋',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w900,
            color: Colors.black87,
            letterSpacing: -0.5,
            shadows: [
              Shadow(color: Colors.white.withValues(alpha: 0.8), blurRadius: 4),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Aaj ki sahi yojana dekhiye',
          style: TextStyle(
            fontSize: 14.5, // ✅ was 14
            color: Colors.black87.withValues(alpha: 0.8),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  // ── Status cards ─────────────────────────────────────────────
  Widget _buildStatusCards() {
    return Row(
      children: [
        Expanded(
          child: _glassCard(
            child: Row(
              children: [
                const Icon(
                  Icons.cloud_done,
                  color: darkForestGreen,
                  size: 24,
                ), // ✅ was 22
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Offline Mode Active',
                        style: TextStyle(
                          fontSize: 12.5, // ✅ was 11.5
                          fontWeight: FontWeight.w800,
                          color: darkForestGreen,
                        ),
                      ),
                      Text(
                        'Last sync: Aaj, 8:30 AM',
                        style: TextStyle(
                          fontSize: 11, // ✅ was 10
                          color: darkForestGreen.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _glassCard(
            child: Row(
              children: [
                const Icon(
                  Icons.security,
                  color: darkForestGreen,
                  size: 24,
                ), // ✅ was 22
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Aapka data surakshit hai',
                        style: TextStyle(
                          fontSize: 12.5, // ✅ was 11.5
                          fontWeight: FontWeight.w800,
                          color: darkForestGreen,
                        ),
                      ),
                      Text(
                        '100% Govt. compliant',
                        style: TextStyle(
                          fontSize: 11, // ✅ was 10
                          color: darkForestGreen.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── Progress card ─────────────────────────────────────────────
  Widget _buildProgressCard() {
    return _glassCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Aapki Pragati / Your Progress',
            style: TextStyle(
              fontSize: 16, // ✅ was 15
              fontWeight: FontWeight.w900,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 20),
          Stack(
            children: [
              Positioned(
                top: 15, // ✅ was 14 — adjusted for bigger icons
                left: 40,
                right: 40,
                child: Row(
                  children: [
                    Expanded(
                      child: Container(height: 2, color: darkForestGreen),
                    ),
                    Expanded(
                      child: Container(height: 2, color: Colors.grey.shade400),
                    ),
                  ],
                ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildProgressStep(
                    Icons.check_circle,
                    darkForestGreen,
                    '3 schemes',
                    'eligible',
                  ),
                  _buildProgressStep(
                    Icons.assignment_turned_in,
                    orange,
                    '1 applied',
                    '',
                  ),
                  _buildProgressStep(
                    Icons.account_balance_wallet,
                    darkForestGreen,
                    '₹6000',
                    'benefit received',
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressStep(
    IconData icon,
    Color iconColor,
    String title,
    String subtitle,
  ) {
    return SizedBox(
      width: 90,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
            child: Icon(icon, color: iconColor, size: 32), // ✅ was 30
          ),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13.5, // ✅ was 12.5
              fontWeight: FontWeight.w800,
              color: Colors.black87,
            ),
          ),
          if (subtitle.isNotEmpty)
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11.5, // ✅ was 10.5
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
        ],
      ),
    );
  }

  // ── Search bar ───────────────────────────────────────────────
  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
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
          hintText: 'Yojana dhundhein ya bol kar poochhein',
          hintStyle: TextStyle(
            color: Colors.grey.shade500,
            fontSize: 14, // ✅ was 13.5
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: const Icon(Icons.search, color: Colors.grey, size: 24),
          suffixIcon: Padding(
            padding: const EdgeInsets.all(6.0),
            child: Container(
              decoration: BoxDecoration(
                color: orange,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: orange.withValues(alpha: 0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Icon(Icons.mic, color: Colors.white, size: 20),
            ),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  // ── Grid menu ─────────────────────────────────────────────────
  Widget _buildResponsiveGridMenu() {
    final List<Map<String, dynamic>> menuItems = [
      {
        'icon': Icons.build_circle_outlined,
        'titleEn': 'Find Schemes',
        'titleHi': 'योजना ढूंढें',
        'color': darkForestGreen,
        'onTap': () => _onNavTap(1),
      },
      {
        'icon': Icons.person_search_outlined,
        'titleEn': 'My Eligibility',
        'titleHi': 'मेरी पात्रता',
        'color': orange,
        'onTap': () {},
      },
      {
        'icon': Icons.assignment_outlined,
        'titleEn': 'My Applications',
        'titleHi': 'मेरे आवेदन',
        'color': const Color(0xFF1976D2),
        'onTap': () {},
      },
      {
        'icon': Icons.receipt_long_outlined,
        'titleEn': 'Document Checklist',
        'titleHi': 'दस्तावेज',
        'color': const Color(0xFFE64A19),
        'onTap': () => _onNavTap(3),
      },
      {
        'icon': Icons.location_on_outlined,
        'titleEn': 'Nearby CSC',
        'titleHi': 'नज़दीकी केंद्र',
        'color': const Color(0xFF388E3C),
        'onTap': () {},
      },
      {
        'icon': Icons.mic_none,
        'titleEn': 'Voice Assistant',
        'titleHi': 'बोलकर पूछें',
        'color': orange,
        'isHighlight': true,
        'onTap': () {},
      },
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final itemWidth = (constraints.maxWidth - 24) / 3;
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: menuItems.map((item) {
            final isHighlight = item['isHighlight'] == true;
            return Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: item['onTap'] as VoidCallback,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  width: itemWidth,
                  padding: const EdgeInsets.symmetric(vertical: 18), // ✅ was 16
                  decoration: BoxDecoration(
                    color: isHighlight ? const Color(0xFFFFF3E0) : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: isHighlight
                        ? Border.all(color: orange.withValues(alpha: 0.4), width: 1.5)
                        : Border.all(color: Colors.transparent),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        item['icon'] as IconData,
                        color: item['color'] as Color,
                        size: 34, // ✅ was 32
                      ),
                      const SizedBox(height: 10),
                      Text(
                        item['titleEn'] as String,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 12.5, // ✅ was 11.5
                          fontWeight: FontWeight.w800,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item['titleHi'] as String,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 11, // ✅ was 10
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  // ── Suggestions ──────────────────────────────────────────────
  Widget _buildSuggestions() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'आपके लिए सुझाव',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: Colors.black87,
              ),
            ),
            GestureDetector(
              onTap: () => _onNavTap(1),
              child: const Row(
                children: [
                  Text(
                    'View all',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: mediumForestGreen,
                    ),
                  ),
                  Icon(Icons.chevron_right, color: mediumForestGreen, size: 18),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          height: 155, // ✅ was 145
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
          child: Row(
            children: [
              SizedBox(
                width: 135,
                height: double.infinity,
                child: ClipRRect(
                  borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(16),
                  ),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        'https://images.unsplash.com/photo-1574323347407-f5e1ad6d020b?q=80&w=500&auto=format&fit=crop',
                        fit: BoxFit.cover,
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7, // ✅ was 6
                            vertical: 5, // ✅ was 4
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.95),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Row(
                            children: [
                              Icon(
                                Icons.auto_awesome,
                                color: mediumForestGreen,
                                size: 13, // ✅ was 12
                              ),
                              SizedBox(width: 4),
                              Text(
                                '95% Match',
                                style: TextStyle(
                                  fontSize: 10, // ✅ was 9.5
                                  fontWeight: FontWeight.w900,
                                  color: mediumForestGreen,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              'PM-Kisan Samman Nidhi',
                              style: TextStyle(
                                fontSize: 15, // ✅ was 14 — matches scheme card
                                fontWeight: FontWeight.w900,
                                height: 1.2,
                              ),
                            ),
                          ),
                          SizedBox(width: 6), // ✅ added explicit spacing
                          Icon(
                            Icons.volume_up,
                            color: darkForestGreen,
                            size: 20,
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7, // ✅ was 6
                              vertical: 4, // ✅ was 3
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F5E9),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'DIRECT BENEFIT',
                              style: TextStyle(
                                fontSize: 9, // ✅ was 8
                                fontWeight: FontWeight.w900,
                                color: darkForestGreen,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Benefit: ₹2000/term',
                            style: TextStyle(
                              fontSize: 11.5, // ✅ was 10.5
                              color: Colors.grey.shade800,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        width: double.infinity,
                        height: 40, // ✅ was 38 — matches scheme card CTA
                        child: ElevatedButton(
                          onPressed: () => _onNavTap(1),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: darkForestGreen,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Check Eligibility',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize:
                                      13, // ✅ was 12.5 — matches scheme card
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(width: 6),
                              Icon(
                                Icons.arrow_forward,
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
      ],
    );
  }

  // ── Footer banner ─────────────────────────────────────────────
  Widget _buildFooterBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16), // ✅ was 14
      decoration: BoxDecoration(
        color: darkForestGreen,
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _FooterItem(icon: Icons.lock_outline, text: 'Data Safe'),
          Text('|', style: TextStyle(color: Colors.white38)),
          _FooterItem(icon: Icons.account_balance, text: 'Govt. Aligned'),
          Text('|', style: TextStyle(color: Colors.white38)),
          _FooterItem(icon: Icons.language, text: '12 Languages'),
        ],
      ),
    );
  }

  // ── Bottom nav ────────────────────────────────────────────────
  Widget _buildCustomBottomNav() {
    final navItems = [
      {
        'icon': Icons.home_outlined,
        'activeIcon': Icons.home_filled,
        'label': 'होम',
      },
      {
        'icon': Icons.description_outlined,
        'activeIcon': Icons.description,
        'label': 'योजनाएं',
      },
      {
        'icon': Icons.support_agent_outlined,
        'activeIcon': Icons.support_agent,
        'label': 'चैट',
      },
      {
        'icon': Icons.folder_outlined,
        'activeIcon': Icons.folder,
        'label': 'दस्तावेज',
      },
      {
        'icon': Icons.person_outline,
        'activeIcon': Icons.person,
        'label': 'प्रोफ़ाइल',
      },
    ];

    return Container(
      height: 75,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 15,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(navItems.length, (index) {
          final isSelected = _selectedIndex == index;
          return GestureDetector(
            onTap: () => _onNavTap(index),
            behavior: HitTestBehavior.opaque,
            child: SizedBox(
              width: 60,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isSelected
                        ? navItems[index]['activeIcon'] as IconData
                        : navItems[index]['icon'] as IconData,
                    color: isSelected ? darkForestGreen : Colors.grey.shade400,
                    size: 26,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    navItems[index]['label'] as String,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: isSelected
                          ? FontWeight.w800
                          : FontWeight.w600,
                      color: isSelected
                          ? darkForestGreen
                          : Colors.grey.shade500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutQuint,
                    height: 3,
                    width: isSelected ? 24 : 0,
                    decoration: BoxDecoration(
                      color: darkForestGreen,
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

  // ── Glass card helper ─────────────────────────────────────────
  Widget _glassCard({
    required Widget child,
    EdgeInsetsGeometry padding = const EdgeInsets.all(12),
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
              ), // ✅ was 0.03
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

// ── Footer item ───────────────────────────────────────────────
class _FooterItem extends StatelessWidget {
  final IconData icon;
  final String text;
  const _FooterItem({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFFFFCA28), size: 18), // ✅ was 16
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12, // ✅ was 11
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

// ── Logo painter ──────────────────────────────────────────────
class _YojanaMitraLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint fieldPaint = Paint()
      ..color = const Color(0xFF1B5E20)
      ..style = PaintingStyle.fill;
    final Paint leafPaint = Paint()
      ..color = const Color(0xFF2E7D32)
      ..style = PaintingStyle.fill;
    final Paint sunPaint = Paint()
      ..color = const Color(0xFFF57C00)
      ..style = PaintingStyle.fill;
    final Paint rayPaint = Paint()
      ..color = const Color(0xFFFFA726)
      ..style = PaintingStyle.fill;

    final double sunCx = (size.width / 2) + 5;
    final double sunCy = size.height * 0.35;
    canvas.drawCircle(Offset(sunCx, sunCy), 9, sunPaint);

    for (int i = 0; i < 8; i++) {
      final double angle = (i * math.pi / 4) - (math.pi / 2);
      final double dx = sunCx + 14 * math.cos(angle);
      final double dy = sunCy + 14 * math.sin(angle);
      if (dy < sunCy + 5) canvas.drawCircle(Offset(dx, dy), 2, rayPaint);
    }

    canvas.save();
    canvas.translate(size.width * 0.3, size.height * 0.4);
    canvas.rotate(-0.52);
    canvas.drawOval(
      Rect.fromCenter(center: Offset.zero, width: 24, height: 10),
      leafPaint,
    );
    canvas.restore();

    canvas.save();
    canvas.translate(size.width * 0.45, size.height * 0.3);
    canvas.rotate(0.52);
    canvas.drawOval(
      Rect.fromCenter(center: Offset.zero, width: 20, height: 9),
      leafPaint,
    );
    canvas.restore();

    final List<double> rowWidths = [1.0, 0.78, 0.58, 0.40];
    const double rowHeight = 5.5;
    const double rowGap = 3.5;
    double currentY = size.height - rowHeight;

    for (int i = 0; i < 4; i++) {
      final double w = size.width * rowWidths[i];
      final double x = (size.width - w) / 2;
      final Rect rect = Rect.fromLTWH(x, currentY, w, rowHeight);
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(3)),
        fieldPaint,
      );
      currentY -= (rowHeight + rowGap);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}