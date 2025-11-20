class User {
  final String username;
  final String email;
  final String? profileImage;

  User({required this.username, required this.email, this.profileImage});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      username: json['username'],
      email: json['email'],
      profileImage: json['profileImage'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'email': email,
      'profileImage': profileImage,
    };
  }
}
