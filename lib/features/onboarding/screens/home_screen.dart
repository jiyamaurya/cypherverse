import 'dart:math' show cos, sin;
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF9F2),
      body: Stack(
        children: [
          // ═══════════════════════════════════════════════════════════════
          //  FULL SCREEN BACKGROUND IMAGE (visible behind ALL content)
          // ═══════════════════════════════════════════════════════════════
          SizedBox(
            width: size.width,
            height: size.height,
            child: Image.asset(
              'assets/images/home_bg.png',
              fit: BoxFit.cover,
              alignment: const Alignment(0.2, -0.4),
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0xFF8BC34A),
                        Color(0xFF4CAF50),
                        Color(0xFF2E7D32),
                        Color(0xFFFFF9F2),
                      ],
                      stops: [0.0, 0.3, 0.5, 1.0],
                    ),
                  ),
                );
              },
            ),
          ),

          // ═══════════════════════════════════════════════════════════════
          //  GRADIENT OVERLAY: Image visible at top → fades to cream
          // ═══════════════════════════════════════════════════════════════
          Container(
            width: size.width,
            height: size.height,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const [0.0, 0.22, 0.40, 0.65, 0.85, 1.0],
                colors: [
                  const Color(0xFF1B5E20).withOpacity(0.35),
                  const Color(0xFF2E7D32).withOpacity(0.25),
                  const Color(0xFF388E3C).withOpacity(0.15),
                  const Color(0xFFFFF9F2).withOpacity(0.70),
                  const Color(0xFFFFF9F2).withOpacity(0.92),
                  const Color(0xFFFFF9F2).withOpacity(0.98),
                ],
              ),
            ),
          ),

          // ═══════════════════════════════════════════════════════════════
          //  SCROLLABLE CONTENT
          // ═══════════════════════════════════════════════════════════════
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 140),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),

                  // ── TOP BAR: Logo + Hindi + Avatar ──
                  _buildTopBar(),

                  const SizedBox(height: 18),

                  // ── GREETING ──
                  _buildGreeting(),

                  const SizedBox(height: 16),

                  // ── STATUS CARDS ROW ──
                  _buildStatusCards(),

                  const SizedBox(height: 16),

                  // ── PROGRESS CARD with Stepper ──
                  _buildProgressCard(),

                  const SizedBox(height: 14),

                  // ── SEARCH BAR ──
                  _buildSearchBar(),

                  const SizedBox(height: 16),

                  // ── QUICK ACTIONS (3×2 Grid) ──
                  _buildQuickActions(),

                  const SizedBox(height: 20),

                  // ── RECOMMENDED SECTION ──
                  _buildRecommendedSection(),

                  const SizedBox(height: 16),

                  // ── TRUST STRIP ──
                  _buildTrustStrip(),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),

          // ═══════════════════════════════════════════════════════════════
          //  BOTTOM NAVIGATION (5 items)
          // ═══════════════════════════════════════════════════════════════
          _buildBottomNav(),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════
  //  TOP BAR: Yojana Mitra Logo | Hindi Dropdown | Profile Avatar
  // ══════════════════════════════════════════════════════════════════════
  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // Logo + App Name
          Row(
            children: [
              // Custom Logo Widget
              _YojanaMitraLogo(size: 38),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Yojana Mitra',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          color: Colors.black26,
                          blurRadius: 4,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    'आपका साथी सरकारी योजनाओं में',
                    style: TextStyle(
                      fontSize: 9,
                      color: Colors.white.withOpacity(0.90),
                      shadows: const [
                        Shadow(
                          color: Colors.black26,
                          blurRadius: 4,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),

          const Spacer(),

          // Hindi Language Selector
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.90),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white.withOpacity(0.5)),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'हिंदी',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2E7D32),
                  ),
                ),
                SizedBox(width: 2),
                Icon(
                  Icons.keyboard_arrow_down,
                  color: Color(0xFF2E7D32),
                  size: 16,
                ),
              ],
            ),
          ),

          const SizedBox(width: 10),

          // Profile Avatar with Green Dot
          Stack(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  color: Colors.grey.shade300,
                ),
                child: ClipOval(
                  child: Image.asset(
                    'assets/images/avatar.png',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.person,
                        color: Colors.white,
                        size: 24,
                      );
                    },
                  ),
                ),
              ),
              Positioned(
                bottom: 2,
                right: 2,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CAF50),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════
  //  GREETING SECTION
  // ══════════════════════════════════════════════════════════════════════
  Widget _buildGreeting() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Namaste, Ramesh Ji 👋',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              shadows: [
                Shadow(
                  color: Colors.black26,
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Aaj ki sahi yojana dekhiye',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Colors.white.withOpacity(0.92),
              shadows: const [
                Shadow(
                  color: Colors.black26,
                  blurRadius: 4,
                  offset: Offset(0, 1),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════
  //  STATUS CARDS (Offline Mode + Data Secure)
  // ══════════════════════════════════════════════════════════════════════
  Widget _buildStatusCards() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // Offline Mode Card
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.88),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.6)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 26,
                        height: 26,
                        decoration: const BoxDecoration(
                          color: Color(0xFF4CAF50),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'Offline Mode Active',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1B5E20),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Last sync: Aaj, 8:30 AM',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Data Secure Card
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.88),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.6)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 26,
                        height: 26,
                        decoration: BoxDecoration(
                          color: const Color(0xFF2E7D32).withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.shield,
                          color: Color(0xFF2E7D32),
                          size: 14,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'Aapka data surakshit hai',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1B5E20),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '100% Govt. compliant',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════
  //  PROGRESS CARD with Visual Stepper
  // ══════════════════════════════════════════════════════════════════════
  Widget _buildProgressCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.92),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Aapki Pragati / Your Progress',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A5C2E),
              ),
            ),
            const SizedBox(height: 18),

            // Stepper Row with Connecting Lines
            Row(
              children: [
                // Step 1: Completed
                _buildStep(
                  icon: Icons.check_circle,
                  iconBgColor: const Color(0xFF2E7D32).withOpacity(0.15),
                  iconColor: const Color(0xFF2E7D32),
                  value: '3 schemes',
                  label: 'eligible',
                ),
                // Connector 1 (Solid Green)
                Expanded(
                  child: Container(
                    height: 2,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    color: const Color(0xFF2E7D32),
                  ),
                ),
                // Step 2: Current
                _buildStep(
                  icon: Icons.description,
                  iconBgColor: const Color(0xFFEF6C00).withOpacity(0.12),
                  iconColor: const Color(0xFFEF6C00),
                  value: '1 applied',
                  label: '',
                ),
                // Connector 2 (Grey)
                Expanded(
                  child: Container(
                    height: 2,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    color: Colors.grey.shade300,
                  ),
                ),
                // Step 3: Pending
                _buildStep(
                  icon: Icons.savings,
                  iconBgColor: const Color(0xFF2E7D32).withOpacity(0.15),
                  iconColor: const Color(0xFF2E7D32),
                  value: '₹6000',
                  label: 'benefit received',
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Progress Bar
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Application Progress',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey.shade500,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Text(
                      '1 of 3 completed',
                      style: TextStyle(
                        fontSize: 10,
                        color: Color(0xFF2E7D32),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: 0.33,
                    minHeight: 6,
                    backgroundColor: const Color(0xFFE8F5E9),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFF43A047),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep({
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
    required String value,
    required String label,
  }) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconBgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 18,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A5C2E),
            ),
          ),
          if (label.isNotEmpty)
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 9,
                color: Colors.grey.shade600,
              ),
            ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════
  //  SEARCH BAR
  // ══════════════════════════════════════════════════════════════════════
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.92),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            const SizedBox(width: 14),
            Icon(Icons.search, color: Colors.grey.shade400, size: 22),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Yojana dhundhein ya bol kar poochhein',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade500,
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.all(4),
              width: 42,
              height: 42,
              decoration: const BoxDecoration(
                color: Color(0xFFEF6C00),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.mic,
                color: Colors.white,
                size: 22,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════
  //  QUICK ACTIONS GRID (3 columns × 2 rows = 6 items)
  // ══════════════════════════════════════════════════════════════════════
  Widget _buildQuickActions() {
    final actions = [
      _ActionData(
        icon: Icons.build_outlined,
        label: 'Find Schemes',
        subLabel: 'योजना ढूंढें',
        color: const Color(0xFF2E7D32),
        bgColor: const Color(0xFF2E7D32).withOpacity(0.10),
      ),
      _ActionData(
        icon: Icons.person_outline,
        label: 'My Eligibility',
        subLabel: 'मेरी पात्रता',
        color: const Color(0xFFEF6C00),
        bgColor: const Color(0xFFEF6C00).withOpacity(0.10),
      ),
      _ActionData(
        icon: Icons.assignment_turned_in_outlined,
        label: 'My Applications',
        subLabel: 'मेरे आवेदन',
        color: const Color(0xFF1976D2),
        bgColor: const Color(0xFF1976D2).withOpacity(0.10),
      ),
      _ActionData(
        icon: Icons.description_outlined,
        label: 'Document Checklist',
        subLabel: 'दस्तावेज़',
        color: const Color(0xFFEF6C00),
        bgColor: const Color(0xFFEF6C00).withOpacity(0.10),
      ),
      _ActionData(
        icon: Icons.location_on_outlined,
        label: 'Nearby CSC',
        subLabel: 'नज़दीकी केंद्र',
        color: const Color(0xFF2E7D32),
        bgColor: const Color(0xFF2E7D32).withOpacity(0.10),
      ),
      _ActionData(
        icon: Icons.mic,
        label: 'Voice Assistant',
        subLabel: 'बोलकर पूछें',
        color: const Color(0xFFEF6C00),
        bgColor: const Color(0xFFEF6C00).withOpacity(0.10),
        isHighlighted: true,
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Actions / त्वरित सेवाएं',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A5C2E),
            ),
          ),
          const SizedBox(height: 12),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 3,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 0.95,
            children: actions.map((a) => _ActionItem(data: a)).toList(),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════
  //  RECOMMENDED SECTION: "आपके लिए सुझाव" with Image Card
  // ══════════════════════════════════════════════════════════════════════
  Widget _buildRecommendedSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'आपके लिए सुझाव',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A5C2E),
                ),
              ),
              Row(
                children: [
                  Text(
                    'View all',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF2E7D32),
                    ),
                  ),
                  const SizedBox(width: 2),
                  const Icon(
                    Icons.arrow_forward_ios,
                    color: Color(0xFF2E7D32),
                    size: 12,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Scheme Card
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left Image with Match Badge
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset(
                          'assets/images/wheat_field.png',
                          width: 110,
                          height: 110,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 110,
                              height: 110,
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFE082),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.wb_sunny,
                                color: Color(0xFFFFA000),
                                size: 40,
                              ),
                            );
                          },
                        ),
                      ),
                      // 95% Match Badge
                      Positioned(
                        top: 6,
                        left: 6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.95),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.auto_awesome,
                                color: Color(0xFF2E7D32),
                                size: 10,
                              ),
                              const SizedBox(width: 3),
                              const Text(
                                '95% Match',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF2E7D32),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 12),

                  // Right Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title Row with Speaker
                        Row(
                          children: [
                            const Expanded(
                              child: Text(
                                'PM-Kisan Samman Nidhi',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF1A5C2E),
                                ),
                              ),
                            ),
                            Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: const Color(0xFF2E7D32).withOpacity(0.10),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.volume_up,
                                color: Color(0xFF2E7D32),
                                size: 14,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // Tags Row
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE8F5E9),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'DIRECT BENEFIT',
                                style: TextStyle(
                                  fontSize: 8,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF2E7D32),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Benefit: ₹2000/term',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 10),

                        // Check Eligibility Button
                        SizedBox(
                          width: double.infinity,
                          height: 38,
                          child: ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2E7D32),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: EdgeInsets.zero,
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Check Eligibility',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(width: 6),
                                Icon(Icons.arrow_forward, size: 14),
                              ],
                            ),
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
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════
  //  TRUST STRIP
  // ══════════════════════════════════════════════════════════════════════
  Widget _buildTrustStrip() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF1B5E20),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Row(
              children: [
                Icon(Icons.lock, color: Colors.white, size: 14),
                SizedBox(width: 6),
                Text(
                  'Data Safe',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            Text('|', style: TextStyle(color: Colors.white38, fontSize: 11)),
            Row(
              children: [
                Icon(Icons.account_balance, color: Colors.white, size: 14),
                SizedBox(width: 6),
                Text(
                  'Govt. Aligned',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            Text('|', style: TextStyle(color: Colors.white38, fontSize: 11)),
            Row(
              children: [
                Icon(Icons.language, color: Colors.white, size: 14),
                SizedBox(width: 6),
                Text(
                  '12 Languages',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════
  //  BOTTOM NAVIGATION (5 items)
  // ══════════════════════════════════════════════════════════════════════
  Widget _buildBottomNav() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.only(top: 8, bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
          border: Border(
            top: BorderSide(color: Colors.grey.shade200, width: 0.5),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(
              icon: Icons.home,
              label: 'Home',
              isActive: true,
            ),
            _buildNavItem(
              icon: Icons.article_outlined,
              label: 'Schemes',
              isActive: false,
            ),
            _buildNavItem(
              icon: Icons.chat_bubble_outline,
              label: 'Chat',
              isActive: false,
            ),
            _buildNavItem(
              icon: Icons.description_outlined,
              label: 'Documents',
              isActive: false,
            ),
            _buildNavItem(
              icon: Icons.person_outline,
              label: 'Profile',
              isActive: false,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required bool isActive,
  }) {
    return GestureDetector(
      onTap: () {},
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 22,
            color: isActive ? const Color(0xFF2E7D32) : Colors.grey.shade400,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
              color: isActive ? const Color(0xFF2E7D32) : Colors.grey.shade400,
            ),
          ),
          if (isActive) ...[
            const SizedBox(height: 2),
            Container(
              width: 4,
              height: 4,
              decoration: const BoxDecoration(
                color: Color(0xFF2E7D32),
                shape: BoxShape.circle,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════
//  YOJANA MITRA LOGO (Custom Widget matching the design)
// ══════════════════════════════════════════════════════════════════════
class _YojanaMitraLogo extends StatelessWidget {
  final double size;

  const _YojanaMitraLogo({required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(10),
      ),
      child: CustomPaint(
        size: Size(size, size),
        painter: _LogoPainter(),
      ),
    );
  }
}

class _LogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final padding = w * 0.18;

    // Sun (orange circle with rays)
    final sunPaint = Paint()..color = const Color(0xFFFF9800);
    final sunCenter = Offset(w * 0.55, h * 0.32);
    final sunRadius = w * 0.12;
    canvas.drawCircle(sunCenter, sunRadius, sunPaint);

    // Sun rays
    final rayPaint = Paint()
      ..color = const Color(0xFFFFB74D)
      ..strokeWidth = 1.5;
    for (int i = 0; i < 8; i++) {
      final angle = (i * 45) * 3.14159 / 180;
      final start = Offset(
        sunCenter.dx + (sunRadius + 2) * cos(angle),
        sunCenter.dy + (sunRadius + 2) * sin(angle),
      );
      final end = Offset(
        sunCenter.dx + (sunRadius + 6) * cos(angle),
        sunCenter.dy + (sunRadius + 6) * sin(angle),
      );
      canvas.drawLine(start, end, rayPaint);
    }

    // Green fields (curved lines)
    final fieldPaint = Paint()
      ..color = const Color(0xFF2E7D32)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    // Field line 1 (top)
    final path1 = Path()
      ..moveTo(padding, h * 0.55)
      ..quadraticBezierTo(w * 0.35, h * 0.48, w * 0.65, h * 0.52)
      ..quadraticBezierTo(w * 0.82, h * 0.55, w - padding, h * 0.50);
    canvas.drawPath(path1, fieldPaint);

    // Field line 2 (middle)
    final path2 = Path()
      ..moveTo(padding, h * 0.68)
      ..quadraticBezierTo(w * 0.30, h * 0.62, w * 0.60, h * 0.66)
      ..quadraticBezierTo(w * 0.80, h * 0.70, w - padding, h * 0.64);
    canvas.drawPath(path2, fieldPaint..strokeWidth = 3);

    // Field line 3 (bottom)
    final path3 = Path()
      ..moveTo(padding, h * 0.82)
      ..quadraticBezierTo(w * 0.35, h * 0.76, w * 0.65, h * 0.80)
      ..quadraticBezierTo(w * 0.85, h * 0.84, w - padding, h * 0.78);
    canvas.drawPath(path3, fieldPaint..strokeWidth = 3.5);

    // Leaf on top of sun
    final leafPaint = Paint()..color = const Color(0xFF4CAF50);
    final leafPath = Path()
      ..moveTo(w * 0.42, h * 0.22)
      ..quadraticBezierTo(w * 0.38, h * 0.12, w * 0.45, h * 0.08)
      ..quadraticBezierTo(w * 0.52, h * 0.12, w * 0.48, h * 0.22)
      ..close();
    canvas.drawPath(leafPath, leafPaint);

    // Leaf stem
    canvas.drawLine(
      Offset(w * 0.45, h * 0.22),
      Offset(w * 0.45, h * 0.28),
      Paint()
        ..color = const Color(0xFF2E7D32)
        ..strokeWidth = 1.5,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ══════════════════════════════════════════════════════════════════════
//  ACTION DATA & WIDGET
// ══════════════════════════════════════════════════════════════════════
class _ActionData {
  final IconData icon;
  final String label;
  final String subLabel;
  final Color color;
  final Color bgColor;
  final bool isHighlighted;

  _ActionData({
    required this.icon,
    required this.label,
    required this.subLabel,
    required this.color,
    required this.bgColor,
    this.isHighlighted = false,
  });
}

class _ActionItem extends StatelessWidget {
  final _ActionData data;

  const _ActionItem({required this.data});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        decoration: BoxDecoration(
          color: data.isHighlighted
              ? const Color(0xFFFFF3E0)
              : Colors.white.withOpacity(0.92),
          borderRadius: BorderRadius.circular(14),
          border: data.isHighlighted
              ? Border.all(color: const Color(0xFFEF6C00).withOpacity(0.3))
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: data.bgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(data.icon, color: data.color, size: 20),
            ),
            const SizedBox(height: 6),
            Text(
              data.label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Color(0xFF424242),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              data.subLabel,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 9,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}