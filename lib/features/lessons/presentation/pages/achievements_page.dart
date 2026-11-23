import 'package:flutter/material.dart';
import 'package:techsisters/features/lessons/domain/entities/achievement.dart';
import 'package:techsisters/features/lessons/presentation/pages/certificate_page.dart';
import 'package:techsisters/features/lessons/presentation/widgets/lessons_colors.dart';

/// Shows every badge (earned or still locked) and the learner's certificates.
class AchievementsPage extends StatelessWidget {
  final AchievementSummary summary;

  /// The name printed on certificates.
  final String holderName;

  const AchievementsPage({
    super.key,
    required this.summary,
    required this.holderName,
  });

  /// The icon drawn on each badge, chosen by the badge id.
  static IconData _iconFor(String id) {
    switch (id) {
      case 'first_lesson':
        return Icons.flag;
      case 'three_lessons':
        return Icons.looks_3;
      case 'five_lessons':
        return Icons.directions_run;
      case 'streak_3':
        return Icons.local_fire_department;
      case 'points_50':
        return Icons.star;
      case 'first_course':
        return Icons.emoji_events;
      default:
        return Icons.workspace_premium;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LessonsColors.background,
      appBar: AppBar(title: const Text('Badges & certificates')),
      body: SafeArea(
        // Scrolls so small phones and landscape never overflow.
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _SectionTitle(
              'Badges  ${summary.badgesEarned}/${summary.achievements.length}',
            ),
            GridView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                mainAxisExtent: 132, // fixed height, so the text always fits
              ),
              children: [
                for (final badge in summary.achievements)
                  _BadgeCard(badge: badge, icon: _iconFor(badge.id)),
              ],
            ),
            const SizedBox(height: 24),
            const _SectionTitle('Certificates'),
            if (summary.certificates.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'Finish every lesson of a course to earn your first '
                  'certificate.',
                  style: TextStyle(color: LessonsColors.slate),
                ),
              )
            else
              for (final certificate in summary.certificates)
                _CertificateTile(
                  certificate: certificate,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => CertificatePage(
                        certificate: certificate,
                        holderName: holderName,
                      ),
                    ),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: LessonsColors.ink,
        ),
      ),
    );
  }
}

/// One badge. Earned badges are coloured; locked ones are grey with a lock.
class _BadgeCard extends StatelessWidget {
  final Achievement badge;
  final IconData icon;

  const _BadgeCard({required this.badge, required this.icon});

  @override
  Widget build(BuildContext context) {
    final earned = badge.earned;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: LessonsColors.border),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: earned
                  ? LessonsColors.purpleSurface
                  : LessonsColors.background,
            ),
            child: Icon(
              earned ? icon : Icons.lock_outline,
              color: earned ? LessonsColors.purple : LessonsColors.slate,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            badge.title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: earned ? LessonsColors.ink : LessonsColors.slate,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            badge.description,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12, color: LessonsColors.slate),
          ),
        ],
      ),
    );
  }
}

/// A row for one certificate; tapping it opens the full certificate.
class _CertificateTile extends StatelessWidget {
  final Certificate certificate;
  final VoidCallback onTap;

  const _CertificateTile({required this.certificate, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: LessonsColors.border),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: LessonsColors.greenSurface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.workspace_premium,
                    color: LessonsColors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        certificate.courseTitle,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: LessonsColors.ink,
                        ),
                      ),
                      Text(
                        'Completed ${formatCertificateDate(certificate.completedOn)}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: LessonsColors.slate,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: LessonsColors.slate),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
