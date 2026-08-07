import 'package:flutter/material.dart';
import 'package:yojana_mitra/core/logic/scheme_matcher.dart';
import 'package:yojana_mitra/core/models/scheme.dart';
import 'package:yojana_mitra/core/models/farmer_profile.dart';
import 'package:yojana_mitra/core/state/profile_store.dart';
import 'scheme_apply_screen.dart';

const _kDark   = Color(0xFF1B5E20);
const _kMed    = Color(0xFF2E7D32);
const _kOrange = Color(0xFFEF6C00);
const _kBg     = Color(0xFFF7F6F0);
const _kCard   = Colors.white;

class SchemeEligibilityScreen extends StatelessWidget {
  final MatchResult result;
  const SchemeEligibilityScreen({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final Scheme scheme       = result.scheme;
    final FarmerProfile profile = ProfileStore.instance.profile;
    final EligibilityStatus status = result.status;

    return Scaffold(
      backgroundColor: _kBg,
      body: Stack(children: [
        Positioned(
          top: 0, left: 0, right: 0, height: 260,
          child: Stack(fit: StackFit.expand, children: [
            Image.asset('assets/images/home_bg.png',
              fit: BoxFit.cover, alignment: Alignment.topCenter,
              errorBuilder: (_, _, _) => Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter,
                    colors: [Color(0xFFE8F5E9), Color(0xFFC8E6C9)])),
              )),
            Positioned.fill(child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.transparent, _kBg.withValues(alpha: 0.85), _kBg],
                  stops: const [0.0, 0.4, 0.75, 1.0])),
            )),
          ]),
        ),
        SafeArea(
          bottom: false,
          child: Column(children: [
            _buildTopBar(context),
            Expanded(child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const SizedBox(height: 16),
                _buildVerdictCard(status, scheme),
                const SizedBox(height: 16),
                _buildProfileSummaryCard(profile),
                const SizedBox(height: 16),
                _buildCriteriaCard(scheme, profile),
                const SizedBox(height: 16),
                _buildExclusionCard(scheme),
                const SizedBox(height: 16),
                _buildRejectionCard(scheme),
              ]),
            )),
          ]),
        ),
        Positioned(bottom: 0, left: 0, right: 0, child: _buildBottomCTA(context, status)),
      ]),
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
            child: const Icon(Icons.arrow_back_ios_new, size: 18, color: _kDark))),
        const Expanded(child: Text('पात्रता जांच / Eligibility Check',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: _kDark))),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 6)]),
          child: const Text('चरण 2/3',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: _kDark))),
      ]),
    );
  }

  Widget _buildVerdictCard(EligibilityStatus status, Scheme scheme) {
    final v = _verdictData(status);
    return Container(
      width: double.infinity, padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: v['bg'] as Color, borderRadius: BorderRadius.circular(20),
        border: Border.all(color: (v['accent'] as Color).withValues(alpha: 0.3), width: 1.5),
        boxShadow: [BoxShadow(color: (v['accent'] as Color).withValues(alpha: 0.12), blurRadius: 16, offset: const Offset(0, 6))]),
      child: Column(children: [
        Container(width: 72, height: 72,
          decoration: BoxDecoration(color: (v['accent'] as Color).withValues(alpha: 0.15), shape: BoxShape.circle),
          child: Icon(v['icon'] as IconData, color: v['accent'] as Color, size: 36)),
        const SizedBox(height: 14),
        Text(v['title'] as String,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: v['accent'] as Color)),
        const SizedBox(height: 6),
        Text(v['subtitle'] as String, textAlign: TextAlign.center,
          style: TextStyle(fontSize: 13.5, color: Colors.grey.shade700, height: 1.4, fontWeight: FontWeight.w500)),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.8), borderRadius: BorderRadius.circular(20)),
          child: Text(scheme.schemeName, textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: v['accent'] as Color))),
      ]),
    );
  }

  Widget _buildProfileSummaryCard(FarmerProfile profile) {
    final genderText = profile.gender == 'male' ? 'पुरुष'
        : profile.gender == 'female' ? 'महिला' : 'अन्य';
    final items = [
      {'icon': Icons.person_outline,     'label': 'नाम',      'value': profile.name},
      {'icon': Icons.cake_outlined,       'label': 'आयु',      'value': '${profile.age} वर्ष'},
      {'icon': Icons.wc_outlined,         'label': 'लिंग',     'value': genderText},
      {'icon': Icons.map_outlined,        'label': 'राज्य',    'value': profile.state},
      {'icon': Icons.agriculture_rounded, 'label': 'व्यवसाय', 'value': _occupationLabel(profile.occupation)},
      {'icon': Icons.landscape_outlined,  'label': 'भूमि',     'value': '${profile.landSizeHectares} ha'},
      {'icon': Icons.currency_rupee,      'label': 'आय',       'value': '₹${profile.annualIncome.toStringAsFixed(0)}'},
    ];
    return _card(
      header: Row(children: [
        Container(padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: const Color(0xFFE8F5E9), borderRadius: BorderRadius.circular(10)),
          child: const Icon(Icons.person_pin_outlined, color: _kDark, size: 18)),
        const SizedBox(width: 10),
        const Text('आपकी प्रोफाइल / Your Profile',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: Colors.black87)),
      ]),
      child: GridView.count(
        crossAxisCount: 2, shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 2.6,
        children: items.map((item) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(color: _kBg, borderRadius: BorderRadius.circular(10)),
          child: Row(children: [
            Icon(item['icon'] as IconData, size: 15, color: Colors.grey.shade500),
            const SizedBox(width: 7),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center, children: [
              Text(item['label'] as String,
                style: TextStyle(fontSize: 9.5, color: Colors.grey.shade500, fontWeight: FontWeight.w500)),
              Text(item['value'] as String, maxLines: 1, overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: Colors.black87)),
            ])),
          ]),
        )).toList(),
      ),
    );
  }

  Widget _buildCriteriaCard(Scheme scheme, FarmerProfile profile) {
    return _card(
      header: Row(children: [
        Container(padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: const Color(0xFFE8F5E9), borderRadius: BorderRadius.circular(10)),
          child: const Icon(Icons.rule_rounded, color: _kDark, size: 18)),
        const SizedBox(width: 10),
        const Text('पात्रता मानदंड / Eligibility Criteria',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: Colors.black87)),
      ]),
      child: Column(
        children: scheme.whoQualifies.map<Widget>((Rule rule) {
          final bool isManual = rule.field == 'manual_review';
          final bool? match   = isManual ? null : evaluateRule(rule, profile);
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: match == null ? const Color(0xFFFFFDE7)
                    : match ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: match == null ? const Color(0xFFFFEE58).withValues(alpha: 0.5)
                      : match ? _kMed.withValues(alpha: 0.3) : const Color(0xFFC62828).withValues(alpha: 0.3))),
              child: Row(children: [
                Container(padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: match == null ? const Color(0xFFFFF9C4)
                        : match ? const Color(0xFFC8E6C9) : const Color(0xFFFFCDD2),
                    shape: BoxShape.circle),
                  child: Icon(
                    match == null ? Icons.help_outline_rounded
                        : match ? Icons.check_rounded : Icons.close_rounded,
                    size: 14,
                    color: match == null ? const Color(0xFFF57F17)
                        : match ? _kDark : const Color(0xFFC62828))),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(rule.description,
                    style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700,
                      color: Colors.black87, height: 1.3)),
                  const SizedBox(height: 4),
                  if (!isManual)
                    Text(_profileValueLabel(rule.field, profile),
                      style: TextStyle(fontSize: 11.5, color: Colors.grey.shade600, fontWeight: FontWeight.w500))
                  else
                    const Text('मैनुअल जांच आवश्यक है',
                      style: TextStyle(fontSize: 11, color: Color(0xFFF57F17), fontWeight: FontWeight.w600)),
                ])),
              ]),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildExclusionCard(Scheme scheme) {
    return _card(
      header: Row(children: [
        Container(padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: const Color(0xFFFFEBEE), borderRadius: BorderRadius.circular(10)),
          child: const Icon(Icons.block_rounded, color: Color(0xFFC62828), size: 18)),
        const SizedBox(width: 10),
        const Expanded(child: Text('अपात्रता शर्तें / Exclusion Criteria',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: Colors.black87))),
      ]),
      child: Column(
        children: scheme.whoDoesNotQualify.map<Widget>((Rule rule) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(padding: const EdgeInsets.all(5),
              decoration: const BoxDecoration(color: Color(0xFFFFCDD2), shape: BoxShape.circle),
              child: const Icon(Icons.close_rounded, size: 12, color: Color(0xFFC62828))),
            const SizedBox(width: 10),
            Expanded(child: Text(rule.description,
              style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600,
                color: Colors.black87, height: 1.4))),
          ]),
        )).toList(),
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

  Widget _buildRejectionCard(Scheme scheme) {
    return _card(
      header: Row(children: [
        Container(padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: const Color(0xFFFFF3E0), borderRadius: BorderRadius.circular(10)),
          child: const Icon(Icons.warning_amber_rounded, color: _kOrange, size: 18)),
        const SizedBox(width: 10),
        const Expanded(child: Text('अस्वीकृति के कारण / Common Rejections',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: Colors.black87))),
      ]),
      child: Column(
        children: scheme.rejectionReasons.map<Widget>((String reason) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(color: const Color(0xFFFFF8E1), borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _kOrange.withValues(alpha: 0.2))),
            child: Row(children: [
              const Icon(Icons.info_outline_rounded, color: _kOrange, size: 16),
              const SizedBox(width: 10),
              Expanded(child: Text(reason,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                  color: Colors.black87, height: 1.3))),
            ]),
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildBottomCTA(BuildContext context, EligibilityStatus status) {
    final bool isEligible = status == EligibilityStatus.eligible;
    final bool canApply   = status != EligibilityStatus.notEligible;
    return Container(
      padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(context).padding.bottom + 16),
      decoration: BoxDecoration(color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 20, offset: const Offset(0, -6))]),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        if (status == EligibilityStatus.notEligible)
          Container(
            width: double.infinity, margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: const Color(0xFFFFEBEE), borderRadius: BorderRadius.circular(12)),
            child: const Row(children: [
              Icon(Icons.info_outline, color: Color(0xFFC62828), size: 16),
              SizedBox(width: 8),
              Expanded(child: Text('आप इस योजना के लिए पात्र नहीं हैं।',
                style: TextStyle(fontSize: 12.5, color: Color(0xFFC62828), fontWeight: FontWeight.w600))),
            ])),
        Row(children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(width: 52, height: 52,
              decoration: BoxDecoration(color: _kBg, borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey.shade300)),
              child: const Icon(Icons.arrow_back_rounded, color: _kDark, size: 22))),
          const SizedBox(width: 12),
          Expanded(child: SizedBox(height: 52,
            child: ElevatedButton(
              onPressed: canApply
                  ? () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => SchemeApplyScreen(result: result)))
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: canApply ? (isEligible ? _kDark : _kOrange) : Colors.grey.shade400,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text(canApply ? 'आवेदन करें / How to Apply' : 'पात्र नहीं / Not Eligible',
                  style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w800)),
                if (canApply) ...[
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 18),
                ],
              ]),
            ))),
        ]),
      ]),
    );
  }

  Widget _card({required Widget header, required Widget child}) {
    return Container(
      width: double.infinity, padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: _kCard, borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        header,
        const SizedBox(height: 12),
        const Divider(height: 1, color: Color(0xFFF0F0F0)),
        const SizedBox(height: 14),
        child,
      ]),
    );
  }

  String _profileValueLabel(String field, FarmerProfile profile) {
    switch (field) {
      case 'occupation': return 'आपका: ${_occupationLabel(profile.occupation)}';
      case 'land_size_hectares':    return 'आपकी: ${profile.landSizeHectares} ha';
      case 'state':                 return 'आपका: ${profile.state}';
      case 'age':                   return 'आपकी: ${profile.age} वर्ष';
      case 'annual_income':         return 'आपकी: ₹${profile.annualIncome.toStringAsFixed(0)}';
      case 'is_income_tax_payer':   return 'आपका: ${profile.isIncomeTaxPayer ? "हां" : "नहीं"}';
      case 'owns_pucca_house':      return 'आपका: ${profile.ownsPuccaHouse ? "हां" : "नहीं"}';
      case 'has_motorized_vehicle': return 'आपका: ${profile.hasMotorizedVehicle ? "हां" : "नहीं"}';
      case 'is_fpo_member':         return 'आपका: ${profile.isFpoMember ? "हां" : "नहीं"}';
      default:                      return '';
    }
  }

  Map<String, dynamic> _verdictData(EligibilityStatus s) {
    switch (s) {
      case EligibilityStatus.eligible:
        return {'bg': const Color(0xFFE8F5E9), 'accent': _kMed,
          'icon': Icons.check_circle_rounded, 'title': 'आप पात्र हैं! 🎉',
          'subtitle': 'आपकी प्रोफाइल इस योजना की सभी शर्तें पूरी करती है।\nअभी आवेदन करें।'};
      case EligibilityStatus.possiblyEligible:
        return {'bg': const Color(0xFFFFF8E1), 'accent': _kOrange,
          'icon': Icons.help_rounded, 'title': 'जांच की आवश्यकता है 🔍',
          'subtitle': 'कुछ जानकारी मैनुअल जांच के बाद तय होगी।\nआवेदन करके पता लगाएं।'};
      case EligibilityStatus.notEligible:
        return {'bg': const Color(0xFFFFEBEE), 'accent': const Color(0xFFC62828),
          'icon': Icons.cancel_rounded, 'title': 'पात्र नहीं हैं',
          'subtitle': 'आपकी प्रोफाइल इस योजना की शर्तें पूरी नहीं करती।\nअन्य योजनाएं देखें।'};
    }
  }
}