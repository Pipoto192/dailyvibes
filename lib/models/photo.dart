class Photo {
  final String id;
  final String username;
  final String date;
  final String imageData;
  final String caption;
  final String challenge;
  final List<String> likes;
  final List<Comment> comments;
  final String? userProfileImage;
  final String? createdAt;
  final int? userStreak;
  final List<String>? userAchievements;

  Photo({
    required this.id,
    required this.username,
    required this.date,
    required this.imageData,
    required this.caption,
    required this.challenge,
    required this.likes,
    required this.comments,
    this.userProfileImage,
    this.createdAt,
    this.userStreak,
    this.userAchievements,
  });

  factory Photo.fromJson(Map<String, dynamic> json) {
    return Photo(
      id: json['id'] ?? json['_id'] ?? '${json['username']}_${json['date']}',
      username: json['username'],
      date: json['date'],
      imageData: json['imageData'],
      caption: json['caption'] ?? '',
      challenge: json['challenge'],
      likes: List<String>.from(json['likes'] ?? []),
      comments: (json['comments'] as List?)
              ?.map((c) => Comment.fromJson(c))
              .toList() ??
          [],
      userProfileImage: json['userProfileImage'],
      createdAt: json['createdAt'],
      userStreak: json['userStreak'],
      userAchievements: json['userAchievements'] != null
          ? List<String>.from(json['userAchievements'])
          : null,
    );
  }
}

class Comment {
  final String username;
  final String text;
  final String timestamp;

  Comment({
    required this.username,
    required this.text,
    required this.timestamp,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      username: json['username'],
      text: json['text'],
      timestamp: json['timestamp'],
    );
  }
}
