import 'package:flutter/material.dart';
import 'package:yojana_mitra/core/logic/scheme_matcher.dart';
import 'package:yojana_mitra/core/models/scheme.dart';
import 'package:yojana_mitra/shared/widgets/explainer_widget.dart';
import 'scheme_eligibility_screen.dart';
import 'package:url_launcher/url_launcher.dart';

const _kDark   = Color(0xFF1B5E20);
const _kMed    = Color(0xFF2E7D32);
const _kOrange = Color(0xFFEF6C00);
const _kBg     = Color(0xFFF7F6F0);
const _kCard   = Colors.white;

class SchemeDetailScreen extends StatelessWidget {
  final MatchResult result;
  const SchemeDetailScreen({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final Scheme scheme    = result.scheme;
    final statusStyle      = _statusStyle(result.status);

    return Scaffold(
      backgroundColor: _kBg,
      body: Stack(
        children: [
          Positioned(
            top: 0, left: 0, right: 0, height: 320,
            child: Stack(fit: StackFit.expand, children: [
              Image.asset('assets/images/home_bg.png',
                fit: BoxFit.cover, alignment: Alignment.topCenter,
                errorBuilder: (_, _, _) => Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xFFE8F5E9), Color(0xFFC8E6C9)]),
                  ),
                ),
              ),
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Colors.transparent,
                        _kBg.withValues(alpha: 0.85), _kBg],
                      stops: const [0.0, 0.45, 0.78, 1.0]),
                  ),
                ),
              ),
            ]),
          ),

          SafeArea(
            bottom: false,
            child: Column(children: [
              _buildTopBar(context),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const SizedBox(height: 16),
                    _buildHeroCard(scheme, statusStyle),
                    const SizedBox(height: 16),
                    _buildBenefitCard(scheme),
                    const SizedBox(height: 16),
                    _buildQuickStats(scheme),
                    const SizedBox(height: 16),
                    _buildAboutCard(scheme),
                    const SizedBox(height: 16),
                    _buildWhoQualifiesCard(scheme),
                    const SizedBox(height: 16),
                    _buildWhoDoesNotCard(scheme),
                  ]),
                ),
              ),
            ]),
          ),

          Positioned(bottom: 0, left: 0, right: 0, child: _buildBottomCTA(context)),
        ],
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      child: Row(children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(width: 42, height: 42,
            decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 8)]),
            child: const Icon(Icons.arrow_back_ios_new, size: 18, color: _kDark)),
        ),
        const Expanded(
          child: Text('योजना विवरण / Scheme Detail', textAlign: TextAlign.center,
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: _kDark)),
        ),
        Container(width: 42, height: 42,
          decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 8)]),
          child: const Icon(Icons.share_outlined, size: 20, color: _kDark)),
      ]),
    );
  }

  Widget _buildHeroCard(Scheme scheme, Map<String, dynamic> statusStyle) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: _kCard, borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 16, offset: const Offset(0, 6))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(width: 64, height: 64,
            decoration: BoxDecoration(color: const Color(0xFFE8F5E9), borderRadius: BorderRadius.circular(16)),
            child: Icon(_iconForType(scheme.benefitType), color: _kMed, size: 32)),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(scheme.schemeName,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: Colors.black87, height: 1.3)),
            const SizedBox(height: 8),
            Wrap(spacing: 8, runSpacing: 6, children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(color: statusStyle['bg'] as Color, borderRadius: BorderRadius.circular(20)),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(statusStyle['icon'] as IconData, size: 13, color: statusStyle['fg'] as Color),
                  const SizedBox(width: 5),
                  Text(statusStyle['label'] as String,
                    style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: statusStyle['fg'] as Color)),
                ]),
              ),
              if (scheme.needsVerification)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(color: const Color(0xFFFFF3E0), borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFFFB74D))),
                  child: const Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.warning_amber_rounded, size: 13, color: Color(0xFFE65100)),
                    SizedBox(width: 5),
                    Text('असत्यापित / Unverified',
                      style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: Color(0xFFE65100))),
                  ]),
                ),
            ]),
          ])),
        ]),
        const SizedBox(height: 16),
        const Divider(height: 1, color: Color(0xFFF0F0F0)),
        const SizedBox(height: 14),
        Wrap(spacing: 8, runSpacing: 8, children: [
          _metaChip(Icons.account_balance_outlined, scheme.ministry),
          _metaChip(Icons.location_on_outlined,
            scheme.state == 'central' ? 'केंद्र सरकार / Central Govt.' : scheme.state),
          _metaChip(Icons.calendar_today_outlined, scheme.deadline),
        ]),
      ]),
    );
  }

  Widget _buildBenefitCard(Scheme scheme) {
    return _sectionCard(
      icon: Icons.card_giftcard_outlined, iconBg: const Color(0xFFFFF3E0), iconColor: _kOrange,
      title: 'लाभ / Benefit',
      explainTitle: 'लाभ / Benefit',
      explainContent: scheme.benefit,
      child: Container(
        width: double.infinity, padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: const Color(0xFFFFF3E0), borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _kOrange.withValues(alpha: 0.2))),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(color: _kOrange, shape: BoxShape.circle),
            child: const Icon(Icons.currency_rupee, color: Colors.white, size: 18)),
          const SizedBox(width: 12),
          Expanded(child: Text(scheme.benefit,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.black87, height: 1.4))),
        ]),
      ),
    );
  }

  Widget _buildQuickStats(Scheme scheme) {
    return Row(children: [
      Expanded(child: _statCard(Icons.category_outlined, 'प्रकार\nType',
        _labelForType(scheme.benefitType), const Color(0xFFE8F5E9), _kDark)),
      const SizedBox(width: 10),
      Expanded(child: _statCard(Icons.description_outlined, 'दस्तावेज़\nDocs',
        '${scheme.documentsNeeded.length} items', const Color(0xFFE3F2FD), const Color(0xFF1565C0))),
      const SizedBox(width: 10),
      Expanded(child: _statCard(Icons.check_circle_outline, 'शर्तें\nCriteria',
        '${scheme.whoQualifies.length} rules', const Color(0xFFF3E5F5), const Color(0xFF6A1B9A))),
    ]);
  }

  Widget _statCard(IconData icon, String label, String value, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: _kCard, borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 3))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, color: fg, size: 16)),
        const SizedBox(height: 10),
        Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: fg)),
        const SizedBox(height: 3),
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey, height: 1.3)),
      ]),
    );
  }

  Widget _buildAboutCard(Scheme scheme) {
    final aboutText = '${scheme.schemeName} भारत सरकार की एक महत्वपूर्ण योजना है। '
        'इसका उद्देश्य ${scheme.benefit.toLowerCase()} देना है। '
        'यह योजना ${scheme.state == "central" ? "केंद्र सरकार" : scheme.state} द्वारा चलाई जाती है।';

    return _sectionCard(
      icon: Icons.info_outline, iconBg: const Color(0xFFE8F5E9), iconColor: _kMed,
      title: 'इस योजना के बारे में / About',
      explainTitle: 'इस योजना के बारे में / About',
      explainContent: aboutText,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(
          aboutText,
          style: const TextStyle(fontSize: 14, color: Colors.black87, height: 1.6, fontWeight: FontWeight.w500)),
        const SizedBox(height: 14),
        InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () async {
            final uri = Uri.tryParse(scheme.sourceUrl);
            if (uri != null && uri.hasScheme) {
              await launchUrl(uri, mode: LaunchMode.platformDefault, webOnlyWindowName: '_blank');
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(color: _kBg, borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade300)),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.open_in_new_rounded, color: _kDark, size: 16),
              const SizedBox(width: 8),
              Flexible(child: Text(scheme.sourceUrl,
                style: const TextStyle(fontSize: 12, color: _kDark, fontWeight: FontWeight.w700))),
            ]),
          ),
        ),
      ]),
    );
  }

  Widget _buildWhoQualifiesCard(Scheme scheme) {
    final joined = scheme.whoQualifies.map((Rule r) => r.description).join('. ');
    return _sectionCard(
      icon: Icons.check_circle_outline, iconBg: const Color(0xFFE8F5E9), iconColor: _kMed,
      title: 'पात्रता / Who Qualifies',
      explainTitle: 'पात्रता / Who Qualifies',
      explainContent: joined,
      child: Column(
        children: scheme.whoQualifies.map<Widget>((Rule rule) =>
          _listRow(Icons.check_rounded, rule.description, _kMed, const Color(0xFFE8F5E9))
        ).toList(),
      ),
    );
  }

  Widget _buildWhoDoesNotCard(Scheme scheme) {
    final joined = scheme.whoDoesNotQualify.map((Rule r) => r.description).join('. ');
    return _sectionCard(
      icon: Icons.cancel_outlined, iconBg: const Color(0xFFFFEBEE), iconColor: const Color(0xFFC62828),
      title: 'अपात्रता / Who Does Not Qualify',
      explainTitle: 'अपात्रता / Who Does Not Qualify',
      explainContent: joined,
      child: Column(
        children: scheme.whoDoesNotQualify.map<Widget>((Rule rule) =>
          _listRow(Icons.close_rounded, rule.description, const Color(0xFFC62828), const Color(0xFFFFEBEE))
        ).toList(),
      ),
    );
  }

  Widget _buildBottomCTA(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(context).padding.bottom + 16),
      decoration: BoxDecoration(color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 20, offset: const Offset(0, -6))]),
      child: Row(children: [
        Container(width: 52, height: 52,
          decoration: BoxDecoration(color: _kBg, borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.grey.shade300, width: 1.5)),
          child: const Icon(Icons.bookmark_border_rounded, color: _kDark, size: 22)),
        const SizedBox(width: 12),
        Expanded(child: SizedBox(height: 52,
          child: ElevatedButton(
            onPressed: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => SchemeEligibilityScreen(result: result))),
            style: ElevatedButton.styleFrom(backgroundColor: _kDark, elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
            child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text('पात्रता जांचें / Check Eligibility',
                style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w800)),
              SizedBox(width: 8),
              Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 18),
            ]),
          ),
        )),
      ]),
    );
  }

  // ── Helpers ──────────────────────────────────────────────────
  Widget _sectionCard({required IconData icon, required Color iconBg,
      required Color iconColor, required String title, required Widget child,
      String? explainTitle, String? explainContent}) {
    final hasExplain = explainContent != null && explainContent.trim().isNotEmpty;
    return Container(
      width: double.infinity, padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: _kCard, borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: iconColor, size: 18)),
          const SizedBox(width: 10),
          Expanded(child: Text(title,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: Colors.black87))),
          if (hasExplain)
            ExplainIconButton(title: explainTitle ?? title, content: explainContent),
        ]),
        const SizedBox(height: 14),
        const Divider(height: 1, color: Color(0xFFF0F0F0)),
        const SizedBox(height: 14),
        child,
      ]),
    );
  }

  Widget _listRow(IconData icon, String text, Color iconColor, Color iconBg) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
          child: Icon(icon, size: 13, color: iconColor)),
        const SizedBox(width: 10),
        Expanded(child: Text(text,
          style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: Colors.black87, height: 1.4))),
      ]),
    );
  }

  Widget _metaChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: _kBg, borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 13, color: Colors.grey.shade600),
        const SizedBox(width: 5),
        Flexible(child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: Colors.grey.shade700))),
      ]),
    );
  }

  IconData _iconForType(String t) {
    switch (t) {
      case 'cash':      return Icons.currency_rupee_rounded;
      case 'insurance': return Icons.health_and_safety_outlined;
      case 'subsidy':   return Icons.agriculture_rounded;
      case 'pension':   return Icons.elderly_outlined;
      default:          return Icons.description_outlined;
    }
  }

  String _labelForType(String t) {
    switch (t) {
      case 'cash':      return 'नकद / Cash';
      case 'insurance': return 'बीमा / Insurance';
      case 'subsidy':   return 'सब्सिडी / Subsidy';
      case 'pension':   return 'पेंशन / Pension';
      default:          return 'अन्य / Other';
    }
  }

  Map<String, dynamic> _statusStyle(EligibilityStatus s) {
    switch (s) {
      case EligibilityStatus.eligible:
        return {'bg': const Color(0xFFE8F5E9), 'fg': _kMed,
          'icon': Icons.check_circle_rounded, 'label': 'आप पात्र हैं'};
      case EligibilityStatus.possiblyEligible:
        return {'bg': const Color(0xFFFFF3E0), 'fg': _kOrange,
          'icon': Icons.help_outline_rounded, 'label': 'जांच करें'};
      case EligibilityStatus.notEligible:
        return {'bg': const Color(0xFFFFEBEE), 'fg': const Color(0xFFC62828),
          'icon': Icons.cancel_rounded, 'label': 'पात्र नहीं'};
    }
  }
}