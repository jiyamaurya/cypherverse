import 'package:flutter/material.dart';

import '../../../core/state/profile_store.dart';
import 'dart:ui';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _selectedNavIndex = 4; // ✅ was 3 — profile is 5th item (index 4)
  bool _voiceAssistantEnabled = true;
  final profile = ProfileStore.instance.profile;

  static const Color darkForestGreen = Color(0xFF1B5E20);
  static const Color mediumForestGreen = Color(0xFF2E7D32);
  static const Color orange = Color(0xFFEF6C00);
  static const Color bgColor = Color(0xFFF7F6F0);

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
        Navigator.pushReplacementNamed(context, '/documents');
        break;
      case 4:
        // Already here
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      bottomNavigationBar: _buildBottomNav(),
      body: Stack(
        children: [
          // ── LAYER 1: Same background as HomeScreen ✅ ─────────────
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

          // ── LAYER 2: Content ─────────────────────────────────────
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                _buildTopBar(),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                    child: Column(
                      children: [
                        _buildProfileCard(),
                        const SizedBox(height: 14),
                        _buildWelcomeCard(),
                        const SizedBox(height: 14),
                        _buildPersonalInfoCard(),
                        const SizedBox(height: 14),
                        _buildEligibleSchemesCard(),
                        const SizedBox(height: 14),
                        _buildDocumentVaultCard(),
                        const SizedBox(height: 14),
                        _buildSettingsCard(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Floating mic ─────────────────────────────────────────
          Positioned(
            right: 16,
            bottom: 90,
            child: Container(
              width: 56, // ✅ was 54
              height: 56, // ✅ was 54
              decoration: BoxDecoration(
                color: darkForestGreen,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: darkForestGreen.withValues(alpha: 0.4),
                    blurRadius: 14,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: const Icon(
                Icons.mic,
                color: Colors.white,
                size: 28,
              ), // ✅ was 26
            ),
          ),
        ],
      ),
    );
  }

  // ── Top bar ──────────────────────────────────────────────────
  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 44,
              height: 44, // ✅ was 42
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
                color: darkForestGreen,
              ), // ✅ was 18
            ),
          ),
          const Expanded(
            child: Text(
              'मेरी प्रोफाइल / My Profile',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: darkForestGreen,
              ),
            ),
          ),
          Stack(
            children: [
              Container(
                width: 44,
                height: 44, // ✅ was 42
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
                  Icons.notifications_outlined,
                  size: 23,
                  color: darkForestGreen,
                ), // ✅ was 22
              ),
              Positioned(
                top: 9,
                right: 9, // ✅ adjusted for bigger container
                child: Container(
                  width: 10,
                  height: 10, // ✅ was 9
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Profile hero card ─────────────────────────────────────────
  Widget _buildProfileCard() {
    return _glassCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar
          Stack(
            children: [
              Container(
                width: 92,
                height: 92, // ✅ was 90
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: mediumForestGreen, width: 3),
                ),
                child: const CircleAvatar(
                  radius: 44, // ✅ was 43
                  backgroundImage: NetworkImage(
                    'https://i.pravatar.cc/150?img=11',
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 30,
                  height: 30, // ✅ was 28
                  decoration: BoxDecoration(
                    color: mediumForestGreen,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(
                    Icons.camera_alt,
                    color: Colors.white,
                    size: 15,
                  ), // ✅ was 14
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile.name,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: darkForestGreen,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '+91 ${profile.phone}',
                  style: const TextStyle(
                    fontSize: 14.5, // ✅ was 14
                    color: Colors.black54,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ), // ✅ vertical was 5
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: mediumForestGreen.withValues(alpha: 0.3),
                    ),
                  ),
                  child: const Text(
                    'Yojana ID: YM12567890',
                    style: TextStyle(
                      fontSize: 12.5, // ✅ was 12
                      fontWeight: FontWeight.w700,
                      color: darkForestGreen,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ), // ✅ vertical was 5
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.verified,
                        color: mediumForestGreen,
                        size: 17,
                      ), // ✅ was 16
                      SizedBox(width: 5),
                      Text(
                        'Aadhaar Verified',
                        style: TextStyle(
                          fontSize: 12.5, // ✅ was 12
                          fontWeight: FontWeight.w700,
                          color: mediumForestGreen,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(10), // ✅ was 9
            decoration: const BoxDecoration(
              color: Color(0xFFE8F5E9),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.edit_outlined,
              color: mediumForestGreen,
              size: 22,
            ), // ✅ was 20
          ),
        ],
      ),
    );
  }

  // ── Welcome banner ────────────────────────────────────────────
  Widget _buildWelcomeCard() {
    return _glassCard(
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Namaste ${profile.name} 👋',
                  style: const TextStyle(
                    fontSize: 17, // ✅ was 16
                    fontWeight: FontWeight.w900,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'आपकी सरकारी योजनाएं एक जगह',
                  style: TextStyle(
                    fontSize: 13.5, // ✅ was 13
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            children: [
              Container(
                padding: const EdgeInsets.all(11), // ✅ was 10
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.wb_sunny_outlined,
                  color: orange,
                  size: 28,
                ), // ✅ was 26
              ),
              const SizedBox(height: 4),
              const Text(
                'आपका साथी\nसरकारी योजनाओं में',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 10.5, // ✅ was 10
                  fontWeight: FontWeight.w700,
                  color: darkForestGreen,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Personal info ─────────────────────────────────────────────
  Widget _buildPersonalInfoCard() {
    final genderText = profile.gender == 'male'
        ? 'पुरुष'
        : profile.gender == 'female'
            ? 'महिला'
            : 'अन्य';

    final info = [
      {
        'icon': Icons.person_outline,
        'label': 'आयु / Age',
        'value': '${profile.age} वर्ष',
      },
      {
        'icon': Icons.wc_outlined,
        'label': 'लिंग / Gender',
        'value': genderText,
      },
      {
        'icon': Icons.map_outlined,
        'label': 'राज्य / State',
        'value': profile.state,
      },
      {
        'icon': Icons.location_on_outlined,
        'label': 'जिला / District',
        'value': profile.district,
      },
      {
        'icon': Icons.home_outlined,
        'label': 'गांव / Village',
        'value': profile.village,
      },
      {
        'icon': Icons.landscape_outlined,
        'label': 'भूमि / Land Size',
        'value': '${profile.landSizeHectares} hectares',
      },
      {
        'icon': Icons.agriculture_outlined,
        'label': 'व्यवसाय / Occupation',
        'value': _occupationLabel(profile.occupation),
      },
    ];

    return _sectionCard(
      title: 'व्यक्तिगत जानकारी / Personal Information',
      child: Column(
        children: [
          for (int i = 0; i < info.length - 1; i += 2)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Expanded(child: _infoTile(info[i])),
                  const SizedBox(width: 10),
                  Expanded(child: _infoTile(info[i + 1])),
                ],
              ),
            ),
          if (info.length.isOdd)
            Row(
              children: [
                Expanded(child: _infoTile(info.last)),
                const Expanded(child: SizedBox()),
              ],
            ),
        ],
      ),
    );
  }

  String _occupationLabel(String occ) {
  switch (occ) {
    case 'farmer':               return 'किसान (Farmer)';
    case 'tenant_farmer':        return 'बंटाईदार (Tenant Farmer)';
    case 'agricultural_laborer': return 'खेत मजदूर (Farm Laborer)';
    case 'government_employee':  return 'सरकारी कर्मचारी (Govt. Employee)';
    default:                     return occ;
  }
}

  Widget _infoTile(Map<String, dynamic> item) {
    return Container(
      padding: const EdgeInsets.all(13), // ✅ was 12
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8), // ✅ was 7
            decoration: const BoxDecoration(
              color: Color(0xFFE8F5E9),
              shape: BoxShape.circle,
            ),
            child: Icon(
              item['icon'] as IconData,
              color: darkForestGreen,
              size: 18,
            ), // ✅ was 16
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['label'] as String,
                  style: TextStyle(
                    fontSize: 11.5, // ✅ was 10.5
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  item['value'] as String,
                  style: const TextStyle(
                    fontSize: 14, // ✅ was 13.5
                    fontWeight: FontWeight.w800,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Eligible schemes ──────────────────────────────────────────
  Widget _buildEligibleSchemesCard() {
    final schemes = [
      {
        'icon': Icons.grass,
        'iconColor': mediumForestGreen,
        'name': 'PM Kisan\nसम्मान निधि',
        'status': 'पात्र हैं',
        'type': 'eligible',
      },
      {
        'icon': Icons.security_outlined,
        'iconColor': mediumForestGreen,
        'name': 'फसल बीमा\nयोजना',
        'status': 'पात्र हैं',
        'type': 'eligible',
      },
      {
        'icon': Icons.currency_rupee,
        'iconColor': orange,
        'name': 'KCC लोन\nयोजना',
        'status': 'Pending',
        'type': 'pending',
      },
      {
        'icon': Icons.people_outlined,
        'iconColor': orange,
        'name': 'पेंशन योजना',
        'status': 'जांचें',
        'type': 'check',
      },
    ];

    return _sectionCard(
      title: 'आप किन योजनाओं के लिए पात्र हैं',
      child: SizedBox(
        height: 170, // ✅ was 155
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: schemes.length,
          separatorBuilder: (_, _) => const SizedBox(width: 10),
          itemBuilder: (context, i) {
            final s = schemes[i];
            final isEligible = s['type'] == 'eligible';
            return Container(
              width: 130, // ✅ was 120
              padding: const EdgeInsets.all(13), // ✅ was 12
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE0E0E0)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(13), // ✅ was 12
                    decoration: BoxDecoration(
                      color: isEligible
                          ? const Color(0xFFE8F5E9)
                          : const Color(0xFFFFF3E0),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      s['icon'] as IconData,
                      color: s['iconColor'] as Color,
                      size: 28,
                    ), // ✅ was 26
                  ),
                  Text(
                    s['name'] as String,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 12.5, // ✅ was 12
                      fontWeight: FontWeight.w800,
                      color: Colors.black87,
                      height: 1.3,
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 7), // ✅ was 6
                    decoration: BoxDecoration(
                      color: isEligible
                          ? darkForestGreen
                          : const Color(0xFFFFF3E0),
                      borderRadius: BorderRadius.circular(20),
                      border: isEligible
                          ? null
                          : Border.all(color: orange.withValues(alpha: 0.6)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          isEligible ? Icons.check_circle : Icons.access_time,
                          color: isEligible ? Colors.white : orange,
                          size: 14, // ✅ was 13
                        ),
                        const SizedBox(width: 4),
                        Text(
                          s['status'] as String,
                          style: TextStyle(
                            fontSize: 11.5, // ✅ was 11
                            fontWeight: FontWeight.w800,
                            color: isEligible ? Colors.white : orange,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // ── Document vault ────────────────────────────────────────────
  Widget _buildDocumentVaultCard() {
    return _sectionCard(
      title: 'दस्तावेज / Document Vault',
      child: Row(
        children: [
          Expanded(
            child: _docTile(
              Icons.shield_outlined,
              'Aadhaar',
              'Linked',
              darkForestGreen,
              false,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _docTile(
              Icons.account_balance_outlined,
              'Bank Account',
              'Verified',
              darkForestGreen,
              false,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _docTile(
              Icons.warning_amber_outlined,
              'Land Record',
              'Uploaded',
              orange,
              true,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(13), // ✅ was 12
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.folder_outlined,
                    color: darkForestGreen,
                    size: 28,
                  ), // ✅ was 26
                  const SizedBox(height: 6),
                  const Text(
                    'सभी दस्तावेज',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11.5, // ✅ was 11
                      fontWeight: FontWeight.w800,
                      color: darkForestGreen,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'देखें / डाउनलोड करें',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 10.5, // ✅ was 9.5
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
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

  Widget _docTile(
    IconData icon,
    String title,
    String status,
    Color iconColor,
    bool isWarning,
  ) {
    return Container(
      padding: const EdgeInsets.all(13), // ✅ was 12
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: iconColor, size: 28), // ✅ was 26
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12.5, // ✅ was 12
              fontWeight: FontWeight.w800,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            status,
            style: TextStyle(
              fontSize: 11.5, // ✅ was 11
              fontWeight: FontWeight.w700,
              color: isWarning ? orange : darkForestGreen,
            ),
          ),
        ],
      ),
    );
  }

  // ── Settings ──────────────────────────────────────────────────
  Widget _buildSettingsCard() {
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
      child: Column(
        children: [
          _settingRow(
            Icons.language_outlined,
            'भाषा बदलें',
            'Change Language',
            trailing: const Icon(
              Icons.chevron_right,
              color: Colors.grey,
              size: 22,
            ),
          ),
          _divider(),
          _settingRow(
            Icons.notifications_outlined,
            'नोटिफिकेशन प्राथमिकताएं',
            'Notification Preferences',
            trailing: const Icon(
              Icons.chevron_right,
              color: Colors.grey,
              size: 22,
            ),
          ),
          _divider(),
          _settingRow(
            Icons.mic_outlined,
            'वॉइस असिस्टेंट',
            'Voice Assistant',
            trailing: Transform.scale(
              scale: 0.85,
              child: Switch(
                value: _voiceAssistantEnabled,
                onChanged: (val) =>
                    setState(() => _voiceAssistantEnabled = val),
                activeThumbColor: mediumForestGreen,
              ),
            ),
          ),
          _divider(),
          _settingRow(
            Icons.headset_mic_outlined,
            'हेल्प सेंटर',
            'Help Center',
            trailing: const Icon(
              Icons.chevron_right,
              color: Colors.grey,
              size: 22,
            ),
          ),
        ],
      ),
    );
  }

  Widget _settingRow(
    IconData icon,
    String hi,
    String en, {
    required Widget trailing,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10), // ✅ was 9
            decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
            child: Icon(icon, color: darkForestGreen, size: 22), // ✅ was 20
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hi,
                  style: const TextStyle(
                    fontSize: 14.5, // ✅ was 14
                    fontWeight: FontWeight.w800,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  en,
                  style: TextStyle(
                    fontSize: 12.5, // ✅ was 12
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          trailing,
        ],
      ),
    );
  }

  Widget _divider() => const Divider(
    height: 1,
    indent: 16,
    endIndent: 16,
    color: Color(0xFFF0F0F0),
  );

  // ── Reusable section card ─────────────────────────────────────
  Widget _sectionCard({required String title, required Widget child}) {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize:
                          16, // ✅ was 14 — matches HomeScreen heading style
                      fontWeight: FontWeight.w900,
                      color: Colors.black87,
                    ),
                  ),
                ),
                Text(
                  'View All',
                  style: TextStyle(
                    fontSize: 13, // ✅ was 13 (unchanged, already good)
                    fontWeight: FontWeight.w700,
                    color: mediumForestGreen,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFF0F0F0)),
          Padding(padding: const EdgeInsets.all(14), child: child),
        ],
      ),
    );
  }

  // ── Glass card (for top cards over background) ────────────────
  Widget _glassCard({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white, width: 1.5),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8),
            ],
          ),
          child: child,
        ),
      ),
    );
  }

  // ── Bottom nav — ✅ now matches HomeScreen & SchemesScreen exactly ──
  // 5 items, Hindi labels, same dimensions, same colors
  Widget _buildBottomNav() {
    final navItems = [
      {
        'icon': Icons.home_outlined,
        'activeIcon': Icons.home_filled,
        'label': 'होम',
      }, // ✅ was "Home"
      {
        'icon': Icons.description_outlined,
        'activeIcon': Icons.description,
        'label': 'योजनाएं',
      }, // ✅ was "Schemes"
      {
        'icon': Icons.support_agent_outlined,
        'activeIcon': Icons.support_agent,
        'label': 'चैट',
      }, // ✅ was "AI सहायता", icon matched
      {
        'icon': Icons.folder_outlined,
        'activeIcon': Icons.folder,
        'label': 'दस्तावेज',
      }, // ✅ NEW — was missing entirely
      {
        'icon': Icons.person_outline,
        'activeIcon': Icons.person,
        'label': 'प्रोफ़ाइल',
      }, // ✅ was "Profile"
    ];

    return Container(
      height: 75, // ✅ matches HomeScreen
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06), // ✅ matches HomeScreen
            blurRadius: 15,
            offset: const Offset(0, -5),
          ), // ✅ matches HomeScreen
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(navItems.length, (index) {
          final isSelected = _selectedNavIndex == index;
          return GestureDetector(
            onTap: () => _onNavTap(index),
            behavior: HitTestBehavior.opaque,
            child: SizedBox(
              width: 60, // ✅ was 75 — matches HomeScreen
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isSelected
                        ? navItems[index]['activeIcon'] as IconData
                        : navItems[index]['icon'] as IconData,
                    color: isSelected
                        ? darkForestGreen
                        : Colors.grey.shade400, // ✅ matches
                    size: 26, // ✅ matches HomeScreen
                  ),
                  const SizedBox(height: 4),
                  Text(
                    navItems[index]['label'] as String,
                    style: TextStyle(
                      fontSize: 11, // ✅ matches HomeScreen
                      fontWeight: isSelected
                          ? FontWeight.w800
                          : FontWeight.w600, // ✅ matches
                      color: isSelected
                          ? darkForestGreen
                          : Colors.grey.shade500, // ✅ matches
                    ),
                  ),
                  const SizedBox(height: 4),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300), // ✅ matches
                    curve: Curves.easeOutQuint,
                    height: 3, // ✅ matches HomeScreen
                    width: isSelected ? 24 : 0, // ✅ matches HomeScreen
                    decoration: BoxDecoration(
                      color: darkForestGreen, // ✅ matches HomeScreen
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