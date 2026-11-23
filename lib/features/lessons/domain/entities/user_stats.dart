import 'package:equatable/equatable.dart';

/// A user's XP, level and daily streak, stored on the `users/{uid}` document.
class UserStats extends Equatable {
  static const int xpPerLevel = 600;

  final int xp;
  final int streak;
  final DateTime? lastActive;

  const UserStats({required this.xp, required this.streak, this.lastActive});

  static const UserStats empty = UserStats(xp: 0, streak: 0);

  int get level => xp ~/ xpPerLevel + 1;

  /// XP earned inside the current level, 0 to [xpPerLevel].
  int get xpInLevel => xp % xpPerLevel;

  /// Stats after finishing a new lesson on [now]: adds [points] and updates
  /// the streak (same day keeps it, the next day extends it, a gap restarts).
  UserStats afterLesson(DateTime now, {required int points}) {
    final today = DateTime(now.year, now.month, now.day);
    final last = lastActive;
    int newStreak;
    if (last == null) {
      newStreak = 1;
    } else {
      final lastDay = DateTime(last.year, last.month, last.day);
      final gap = today.difference(lastDay).inDays;
      if (gap <= 0) {
        newStreak = streak < 1 ? 1 : streak;
      } else if (gap == 1) {
        newStreak = streak + 1;
      } else {
        newStreak = 1;
      }
    }
    return UserStats(xp: xp + points, streak: newStreak, lastActive: now);
  }

  @override
  List<Object?> get props => [xp, streak, lastActive];
}
