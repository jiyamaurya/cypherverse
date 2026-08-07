import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  COLOR TOKENS  (shared across the whole app)
// ─────────────────────────────────────────────────────────────────────────────
const kDarkGreen = Color(0xFF1B5E20);
const kMedGreen = Color(0xFF2E7D32);
const kLightGreen = Color(0xFF43A047);
const kOrange = Color(0xFFEF6C00);
const kBg = Color(0xFFF7F6F0);

// ─────────────────────────────────────────────────────────────────────────────
//  DOCUMENTS SCREEN
// ─────────────────────────────────────────────────────────────────────────────
class DocumentsScreen extends StatefulWidget {
  const DocumentsScreen({super.key});

  @override
  State<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends State<DocumentsScreen> {
  int _selectedNavIndex = 3;
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
        Navigator.pushReplacementNamed(context, '/schemes');
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/chat');
        break;
      case 3:
        // Already here
        break;
      case 4:
        Navigator.pushReplacementNamed(context, '/profile');
        break;
    }
  }

  // ── Data ──────────────────────────────────────────────────────────────────
  final List<Map<String, dynamic>> _categories = [
    {'icon': Icons.grid_view_rounded, 'label': 'सभी दस्तावेज'},
    {'icon': Icons.badge_outlined, 'label': 'पहचान पत्र'},
    {'icon': Icons.account_balance_outlined, 'label': 'बैंक दस्तावेज'},
    {'icon': Icons.landscape_outlined, 'label': 'भूमि रिकॉर्ड'},
    {'icon': Icons.receipt_long_outlined, 'label': 'आय प्रमाण'},
    {'icon': Icons.more_horiz, 'label': 'अन्य'},
  ];

  final List<Map<String, dynamic>> _documents = [
    {
      'name': 'Aadhaar Card',
      'nameHi': 'आधार कार्ड',
      'icon': Icons.shield_outlined,
      'status': 'verified',
      'statusLabel': 'Verified',
      'statusLabelHi': 'सत्यापित',
      'date': 'Uploaded: 12 Jan 2025',
      'type': 'identity',
    },
    {
      'name': 'Bank Passbook',
      'nameHi': 'बैंक पासबुक',
      'icon': Icons.account_balance_outlined,
      'status': 'pending',
      'statusLabel': 'Pending',
      'statusLabelHi': 'लंबित',
      'date': 'Uploaded: 18 Jan 2025',
      'type': 'bank',
    },
    {
      'name': 'Land Record (Khasra)',
      'nameHi': 'खसरा नकल',
      'icon': Icons.landscape_outlined,
      'status': 'verified',
      'statusLabel': 'Verified',
      'statusLabelHi': 'सत्यापित',
      'date': 'Uploaded: 05 Feb 2025',
      'type': 'land',
    },
    {
      'name': 'PAN Card',
      'nameHi': 'पैन कार्ड',
      'icon': Icons.credit_card_outlined,
      'status': 'verified',
      'statusLabel': 'Verified',
      'statusLabelHi': 'सत्यापित',
      'date': 'Uploaded: 08 Feb 2025',
      'type': 'identity',
    },
    {
      'name': 'Ration Card',
      'nameHi': 'राशन कार्ड',
      'icon': Icons.food_bank_outlined,
      'status': 'pending',
      'statusLabel': 'Pending',
      'statusLabelHi': 'लंबित',
      'date': 'Uploaded: 20 Feb 2025',
      'type': 'identity',
    },
    {
      'name': 'Income Certificate',
      'nameHi': 'आय प्रमाण पत्र',
      'icon': Icons.description_outlined,
      'status': 'missing',
      'statusLabel': 'Missing',
      'statusLabelHi': 'अनुपस्थित',
      'date': 'Not uploaded yet',
      'type': 'income',
    },
    {
      'name': 'Caste Certificate',
      'nameHi': 'जाति प्रमाण पत्र',
      'icon': Icons.groups_outlined,
      'status': 'verified',
      'statusLabel': 'Verified',
      'statusLabelHi': 'सत्यापित',
      'date': 'Uploaded: 01 Mar 2025',
      'type': 'identity',
    },
  ];

  // ── Status counts ─────────────────────────────────────────────────────────
  int get _verifiedCount =>
      _documents.where((d) => d['status'] == 'verified').length;
  int get _pendingCount =>
      _documents.where((d) => d['status'] == 'pending').length;
  int get _missingCount =>
      _documents.where((d) => d['status'] == 'missing').length;

  // ── Filter documents by category ──────────────────────────────────────────
  List<Map<String, dynamic>> get _filteredDocs {
    if (_selectedCategory == 0) return _documents;
    final typeMap = {1: 'identity', 2: 'bank', 3: 'land', 4: 'income'};
    final type = typeMap[_selectedCategory];
    if (type == null) return _documents;
    return _documents.where((d) => d['type'] == type).toList();
  }

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
          // ── STICKY HEADER ZONE ─────────────────────────────────────────
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
                  // Status summary
                  Container(
                    decoration: const BoxDecoration(
                      color: kBg,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(24),
                      ),
                    ),
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: _StatusSummary(
                      verified: _verifiedCount,
                      pending: _pendingCount,
                      missing: _missingCount,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Section header
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    child: _SectionHeader(count: _filteredDocs.length),
                  ),

                  // Document list
                  ..._filteredDocs.map(
                    (doc) => Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                      child: _DocumentCard(document: doc),
                    ),
                  ),

                  // Upload button
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 14),
                    child: _UploadButton(),
                  ),

                  // Help banner
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
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
//  STICKY HEADER — identical background treatment to HomeScreen
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
          // ── Hero image — IDENTICAL to HomeScreen ─────────────────────
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            bottom: 0,
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

          // ── UI content over image ────────────────────────────────────
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
                    // Back button
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_new,
                          size: 19,
                          color: kDarkGreen,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'दस्तावेज',
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
                          'अपने सभी दस्तावेज एक जगह',
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
                    // Language pill
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
                    // Avatar
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
                              color: kDarkGreen,
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
//  SEARCH BAR — matches HomeScreen exactly
// ─────────────────────────────────────────────────────────────────────────────
class _SearchBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
          hintText: 'दस्तावेज खोजें या बोल कर पूछें',
          hintStyle: TextStyle(
            color: Colors.grey.shade500,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: const Icon(Icons.search, color: Colors.grey, size: 24),
          suffixIcon: Padding(
            padding: const EdgeInsets.all(6.0),
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
}

// ─────────────────────────────────────────────────────────────────────────────
//  CATEGORY CHIPS — matches SchemesScreen sizing
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
      height: 82,
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? kDarkGreen : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected ? kDarkGreen : Colors.grey.shade300,
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isSelected
                        ? kDarkGreen.withValues(alpha: 0.18)
                        : Colors.black.withValues(alpha: 0.04),
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
                    size: 26,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    cat['label'] as String,
                    style: TextStyle(
                      fontSize: 11,
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
//  STATUS SUMMARY — 3 colored stat cards
// ─────────────────────────────────────────────────────────────────────────────
class _StatusSummary extends StatelessWidget {
  final int verified;
  final int pending;
  final int missing;

  const _StatusSummary({
    required this.verified,
    required this.pending,
    required this.missing,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Aapke Documents Status',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w900,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _statusPill(
                Icons.verified,
                'सत्यापित',
                verified,
                kDarkGreen,
                const Color(0xFFE8F5E9),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _statusPill(
                Icons.access_time,
                'लंबित',
                pending,
                kOrange,
                const Color(0xFFFFF3E0),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _statusPill(
                Icons.warning_amber_outlined,
                'अनुपस्थित',
                missing,
                const Color(0xFFC62828),
                const Color(0xFFFFEBEE),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _statusPill(
    IconData icon,
    String label,
    int count,
    Color iconColor,
    Color bgColor,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: iconColor.withValues(alpha: 0.15)),
      ),
      child: Column(
        children: [
          Icon(icon, color: iconColor, size: 24),
          const SizedBox(height: 6),
          Text(
            '$count',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: iconColor,
              height: 1,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: iconColor.withValues(alpha: 0.85),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  SECTION HEADER — matches SchemesScreen
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
          'दस्तावेज सूची ($count)',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: Colors.black87,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
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
              Icon(Icons.sort_rounded, color: kDarkGreen, size: 18),
              SizedBox(width: 6),
              Text(
                'क्रमबद्ध',
                style: TextStyle(
                  fontSize: 13,
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
//  DOCUMENT CARD
// ─────────────────────────────────────────────────────────────────────────────
class _DocumentCard extends StatelessWidget {
  final Map<String, dynamic> document;
  const _DocumentCard({required this.document});

  Color get _statusColor {
    switch (document['status']) {
      case 'verified':
        return kDarkGreen;
      case 'pending':
        return kOrange;
      case 'missing':
        return const Color(0xFFC62828);
      default:
        return Colors.grey;
    }
  }

  Color get _statusBg {
    switch (document['status']) {
      case 'verified':
        return const Color(0xFFE8F5E9);
      case 'pending':
        return const Color(0xFFFFF3E0);
      case 'missing':
        return const Color(0xFFFFEBEE);
      default:
        return Colors.grey.shade200;
    }
  }

  IconData get _statusIcon {
    switch (document['status']) {
      case 'verified':
        return Icons.check_circle;
      case 'pending':
        return Icons.access_time;
      case 'missing':
        return Icons.cloud_off_outlined;
      default:
        return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMissing = document['status'] == 'missing';

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
        border: isMissing
            ? Border.all(
                color: const Color(0xFFC62828).withValues(alpha: 0.25),
                width: 1.5,
              )
            : null,
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            // Icon
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: _statusBg,
                shape: BoxShape.circle,
              ),
              child: Icon(
                document['icon'] as IconData,
                color: _statusColor,
                size: 26,
              ),
            ),
            const SizedBox(width: 14),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          document['name'] as String,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF1A1A1A),
                            height: 1.25,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Icon(
                        Icons.volume_up_rounded,
                        color: kDarkGreen,
                        size: 20,
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    document['nameHi'] as String,
                    style: TextStyle(
                      fontSize: 12.5,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today_outlined,
                        size: 12,
                        color: Colors.grey.shade500,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        document['date'] as String,
                        style: TextStyle(
                          fontSize: 11.5,
                          color: Colors.grey.shade500,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Status badge + action
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: _statusBg,
                    borderRadius: BorderRadius.circular(20),
                    border: isMissing
                        ? null
                        : Border.all(color: _statusColor.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(_statusIcon, color: _statusColor, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        document['statusLabelHi'] as String,
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w800,
                          color: _statusColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                // Action button
                if (isMissing)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFC62828),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFC62828).withValues(alpha: 0.3),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.upload_outlined,
                          color: Colors.white,
                          size: 14,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'अपलोड',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  )
                else if (document['status'] == 'verified')
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: kBg,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.visibility_outlined,
                          color: kDarkGreen,
                          size: 14,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'देखें',
                          style: TextStyle(
                            color: kDarkGreen,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: kBg,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.replay_outlined, color: kOrange, size: 14),
                        SizedBox(width: 4),
                        Text(
                          'दोबारा',
                          style: TextStyle(
                            color: kOrange,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  UPLOAD BUTTON
// ─────────────────────────────────────────────────────────────────────────────
class _UploadButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 52,
      decoration: BoxDecoration(
        color: kDarkGreen,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: kDarkGreen.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.cloud_upload_outlined, color: Colors.white, size: 24),
          SizedBox(width: 10),
          Text(
            'नया दस्तावेज अपलोड करें',
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  HELP BANNER — matches SchemesScreen style
// ─────────────────────────────────────────────────────────────────────────────
class _HelpBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: kDarkGreen,
        borderRadius: BorderRadius.circular(10),
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
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.headset_mic_outlined,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'दस्तावेज में मदद चाहिए?',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'सेवा केंद्र से संपर्क करें या बोल कर पूछें',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
                Icon(Icons.mic_rounded, color: Colors.white, size: 16),
                SizedBox(width: 6),
                Text(
                  'बोल कर पूछें',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12.5,
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
//  BOTTOM NAV BAR — matches HomeScreen/SchemesScreen/ProfileScreen exactly
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
        children: List.generate(_items.length, (i) {
          final item = _items[i];
          final isSelected = selectedIndex == i;
          return GestureDetector(
            onTap: () => onTap(i),
            behavior: HitTestBehavior.opaque,
            child: SizedBox(
              width: 60,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isSelected ? item.activeIcon : item.icon,
                    color: isSelected ? kDarkGreen : Colors.grey.shade400,
                    size: 26,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.label,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: isSelected
                          ? FontWeight.w800
                          : FontWeight.w600,
                      color: isSelected ? kDarkGreen : Colors.grey.shade500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutQuint,
                    height: 3,
                    width: isSelected ? 24 : 0,
                    decoration: BoxDecoration(
                      color: kDarkGreen,
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
