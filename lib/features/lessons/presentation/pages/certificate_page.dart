import 'package:flutter/material.dart';
import 'package:techsisters/features/lessons/domain/entities/achievement.dart';
import 'package:techsisters/features/lessons/presentation/widgets/lessons_colors.dart';

/// Turns a date into text such as "22 November 2026".
String formatCertificateDate(DateTime date) {
  const months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];
  return '${date.day} ${months[date.month - 1]} ${date.year}';
}

/// A certificate of completion for one course.
class CertificatePage extends StatelessWidget {
  final Certificate certificate;

  /// The learner's name printed on the certificate.
  final String holderName;

  const CertificatePage({
    super.key,
    required this.certificate,
    required this.holderName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LessonsColors.background,
      appBar: AppBar(title: const Text('Certificate')),
      body: SafeArea(
        // Scrolls so it fits small phones and landscape.
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: LessonsColors.purple, width: 2),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.workspace_premium,
                  size: 64,
                  color: LessonsColors.purple,
                ),
                const SizedBox(height: 12),
                const Text(
                  'CERTIFICATE OF COMPLETION',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                    color: LessonsColors.slate,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'This certifies that',
                  style: TextStyle(color: LessonsColors.slate),
                ),
                const SizedBox(height: 8),
                Text(
                  holderName,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: LessonsColors.purple,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'has successfully completed',
                  style: TextStyle(color: LessonsColors.slate),
                ),
                const SizedBox(height: 8),
                Text(
                  certificate.courseTitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: LessonsColors.ink,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  formatCertificateDate(certificate.completedOn),
                  style: const TextStyle(color: LessonsColors.slate),
                ),
                const SizedBox(height: 4),
                const Text(
                  'TechSisters',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: LessonsColors.ink,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
