import 'package:flutter/material.dart';

/// Picks a sensible icon for a required-document name, based on keywords.
/// Shared by any screen that needs to display a document (Documents,
/// Profile's Document Vault, the per-scheme Document Checklist), so the
/// same document always gets the same icon everywhere in the app.
IconData iconForDocument(String name) {
  final n = name.toLowerCase();
  if (n.contains('aadhaar') || n.contains('आधार')) return Icons.shield_outlined;
  if (n.contains('pan') || n.contains('पैन')) return Icons.credit_card_outlined;
  if (n.contains('bank') || n.contains('passbook') || n.contains('बैंक') || n.contains('पासबुक')) {
    return Icons.account_balance_outlined;
  }
  if (n.contains('land') || n.contains('khasra') || n.contains('khatauni') || n.contains('भूमि')) {
    return Icons.landscape_outlined;
  }
  if (n.contains('income') || n.contains('आय')) return Icons.receipt_long_outlined;
  if (n.contains('caste') || n.contains('जाति')) return Icons.groups_outlined;
  if (n.contains('ration') || n.contains('राशन')) return Icons.food_bank_outlined;
  if (n.contains('photo')) return Icons.photo_camera_outlined;
  if (n.contains('certificate') || n.contains('प्रमाण')) return Icons.description_outlined;
  return Icons.insert_drive_file_outlined;
}