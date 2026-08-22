/// A single eligibility condition, either structured (auto-evaluable)
/// or flagged as `manual_review` when it can't be safely auto-checked.
class Rule {
  final String field;
  final String operator;
  final dynamic value;
  final String description;

  Rule({
    required this.field,
    required this.operator,
    required this.value,
    required this.description,
  });

  factory Rule.fromJson(Map<String, dynamic> json) {
    return Rule(
      field: json['field'] as String,
      operator: json['operator'] as String,
      value: json['value'],
      description: json['description'] as String,
    );
  }
}

/// A single FAQ entry attached to a scheme.
class SchemeFaq {
  final String question;
  final String answer;

  SchemeFaq({required this.question, required this.answer});

  factory SchemeFaq.fromJson(Map<String, dynamic> json) {
    return SchemeFaq(
      question: json['q'] as String,
      answer: json['a'] as String,
    );
  }
}

/// Full scheme record, matching every field in assets/data/schemes_seed.json.
class Scheme {
  final String schemeName;
  final String ministry;
  final String benefit;
  final String benefitType;
  final List<Rule> whoQualifies;
  final List<Rule> whoDoesNotQualify;
  final List<String> documentsNeeded;
  final String applicationSteps;
  final String deadline;
  final String state; // "central", "Punjab", "Uttar Pradesh", "Bihar", etc.
  final String sourceUrl;
  final String? applicationUrl;
  final String? formDownloadUrl;

  String get effectiveApplyUrl =>
      (applicationUrl != null && applicationUrl!.trim().isNotEmpty) ? applicationUrl! : sourceUrl;

  bool get hasRealFormDownload => formDownloadUrl != null && formDownloadUrl!.trim().isNotEmpty;

  String get effectiveFormUrl => hasRealFormDownload ? formDownloadUrl! : effectiveApplyUrl;
  final bool needsVerification;
  final List<String> rejectionReasons;
  final List<SchemeFaq> commonFaqs;

  Scheme({
    required this.schemeName,
    required this.ministry,
    required this.benefit,
    required this.benefitType,
    required this.whoQualifies,
    required this.whoDoesNotQualify,
    required this.documentsNeeded,
    required this.applicationSteps,
    required this.deadline,
    required this.state,
    required this.sourceUrl,
    this.applicationUrl,
    this.formDownloadUrl,
    this.needsVerification = false,
    required this.rejectionReasons,
    required this.commonFaqs,
  });

  factory Scheme.fromJson(Map<String, dynamic> json) {
    return Scheme(
      schemeName: json['scheme_name'] as String,
      ministry: json['ministry'] as String,
      benefit: json['benefit'] as String,
      benefitType: json['benefit_type'] as String,
      whoQualifies: (json['who_qualifies'] as List)
          .map((e) => Rule.fromJson(e as Map<String, dynamic>))
          .toList(),
      // Note the JSON key is "who_does_NOT_qualify" (mixed case) — must match exactly.
      whoDoesNotQualify: (json['who_does_NOT_qualify'] as List)
          .map((e) => Rule.fromJson(e as Map<String, dynamic>))
          .toList(),
      documentsNeeded: (json['documents_needed'] as List)
          .map((e) => e as String)
          .toList(),
      applicationSteps: json['application_steps'] as String,
      deadline: json['deadline'] as String,
      state: json['state'] as String,
      sourceUrl: json['source_url'] as String,
      applicationUrl: json['application_url'] as String?,
      formDownloadUrl: json['form_download_url'] as String?,
      needsVerification: json['needs_verification'] as bool? ?? false,
      rejectionReasons: (json['rejection_reasons'] as List)
          .map((e) => e as String)
          .toList(),
      commonFaqs: (json['common_faqs'] as List)
          .map((e) => SchemeFaq.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}