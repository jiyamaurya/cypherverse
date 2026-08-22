import '../models/farmer_profile.dart';
import '../models/scheme.dart';

enum EligibilityStatus { eligible, possiblyEligible, notEligible }

class MatchResult {
  final Scheme scheme;
  final EligibilityStatus status;
  final List<String> matchedReasons;
  final List<String> blockingReasons;
  final List<String> manualReviewNotes;

  MatchResult({
    required this.scheme,
    required this.status,
    required this.matchedReasons,
    required this.blockingReasons,
    required this.manualReviewNotes,
  });
}

/// Evaluates a single rule against a farmer profile.
/// Returns:
///   true  -> the condition is met
///   false -> the condition is not met
///   null  -> cannot be auto-evaluated (manual_review)
bool? evaluateRule(Rule rule, FarmerProfile profile) {
  if (rule.field == 'manual_review') return null;

  dynamic profileValue;
  switch (rule.field) {
    case 'state':
      profileValue = profile.state;
      break;
    case 'land_size_hectares':
      profileValue = profile.landSizeHectares;
      break;
    case 'category':
      profileValue = profile.category;
      break;
    case 'annual_income':
      profileValue = profile.annualIncome;
      break;
    case 'occupation':
      profileValue = profile.occupation;
      break;
    case 'age':
      profileValue = profile.age;
      break;
    case 'owns_pucca_house':
      profileValue = profile.ownsPuccaHouse;
      break;
    case 'has_motorized_vehicle':
      profileValue = profile.hasMotorizedVehicle;
      break;
    case 'is_income_tax_payer':
      profileValue = profile.isIncomeTaxPayer;
      break;
    case 'is_fpo_member':
      profileValue = profile.isFpoMember;
      break;
    default:
      // Unknown field — fail safe to "not met" rather than crash.
      return false;
  }

  switch (rule.operator) {
    case 'eq':
      return profileValue == rule.value;
    case 'neq':
      return profileValue != rule.value;
    case 'lte':
      if (profileValue is! num || rule.value is! num) return false;
      return profileValue <= (rule.value as num);
    case 'gte':
      if (profileValue is! num || rule.value is! num) return false;
      return profileValue >= (rule.value as num);
    case 'lt':
      if (profileValue is! num || rule.value is! num) return false;
      return profileValue < (rule.value as num);
    case 'gt':
      if (profileValue is! num || rule.value is! num) return false;
      return profileValue > (rule.value as num);
   case 'in':
  if (rule.value is! List) return false;
  final checkList = rule.value as List;
  if (profileValue == 'tenant_farmer' && checkList.contains('farmer')) return true;
  return checkList.contains(profileValue);
    case 'not_in':
      if (rule.value is! List) return false;
      return !(rule.value as List).contains(profileValue);
    default:
      return false;
  }
}

/// Matches a farmer profile against a list of schemes and returns
/// a MatchResult per scheme, sorted eligible -> possiblyEligible -> notEligible.
///
/// PRECEDENCE LOGIC (safety-critical — this affects real welfare access):
///   1. Any hard disqualifier in who_does_NOT_qualify that evaluates TRUE
///      wins immediately -> notEligible. A clear "you don't qualify" signal
///      must never be overridden by an unclear "maybe you do" signal.
///   2. If no hard disqualifier fired, but ANY rule (in either list) is
///      manual_review -> possiblyEligible. We never claim certainty we
///      don't have — better to ask the farmer to verify than to give a
///      false yes or a false no.
///   3. If every who_qualifies rule evaluates TRUE with no ambiguity
///      -> eligible.
///   4. Otherwise (a required qualifying condition failed, no ambiguity)
///      -> notEligible.
List<MatchResult> matchSchemes(FarmerProfile profile, List<Scheme> schemes) {
  final results = schemes.map((scheme) {
    final matched = <String>[];
    final blocked = <String>[];
    final manual = <String>[];

    bool isHardDisqualified = false;

    // Step 1: check disqualifiers first — they take priority over everything.
    for (final rule in scheme.whoDoesNotQualify) {
      final result = evaluateRule(rule, profile);
      if (result == true) {
        isHardDisqualified = true;
        blocked.add(rule.description);
      } else if (result == null) {
        manual.add(rule.description);
      }
    }

    EligibilityStatus status;

    if (isHardDisqualified) {
      status = EligibilityStatus.notEligible;
    } else {
      bool allQualifiersMet = true;

      for (final rule in scheme.whoQualifies) {
        final result = evaluateRule(rule, profile);
        if (result == false) {
          allQualifiersMet = false;
        } else if (result == true) {
          matched.add(rule.description);
        } else {
          // result == null -> manual_review
          manual.add(rule.description);
        }
      }

      if (manual.isNotEmpty) {
        status = EligibilityStatus.possiblyEligible;
      } else if (allQualifiersMet) {
        status = EligibilityStatus.eligible;
      } else {
        status = EligibilityStatus.notEligible;
      }
    }

    return MatchResult(
      scheme: scheme,
      status: status,
      matchedReasons: matched,
      blockingReasons: blocked,
      manualReviewNotes: manual,
    );
  }).toList();

  // Sort: eligible (0) -> possiblyEligible (1) -> notEligible (2)
  results.sort((a, b) => a.status.index.compareTo(b.status.index));
  return results;
}