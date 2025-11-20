class Challenge {
  final int id;
  final String title;
  final String description;
  final String icon;
  final String? date;
  final DateTime? startTime;
  final DateTime? endTime;

  Challenge({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    this.date,
    this.startTime,
    this.endTime,
  });

  factory Challenge.fromJson(Map<String, dynamic> json) {
    return Challenge(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      icon: json['icon'] ?? '📸',
      date: json['date'],
      startTime:
          json['startTime'] != null ? DateTime.parse(json['startTime']) : null,
      endTime: json['endTime'] != null ? DateTime.parse(json['endTime']) : null,
    );
  }

  bool get isActive {
    if (startTime == null || endTime == null)
      return true; // 24/7 challenges are always active
    final now = DateTime.now();
    return now.isAfter(startTime!) && now.isBefore(endTime!);
  }

  Duration get timeRemaining {
    if (endTime == null) return Duration.zero;
    final now = DateTime.now();
    if (now.isAfter(endTime!)) return Duration.zero;
    return endTime!.difference(now);
  }

  Duration get timeUntilStart {
    if (startTime == null) return Duration.zero;
    final now = DateTime.now();
    if (now.isAfter(startTime!)) return Duration.zero;
    return startTime!.difference(now);
  }
}
