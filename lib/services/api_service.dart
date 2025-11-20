import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/user.dart';
import '../models/photo.dart';
import '../models/challenge.dart';
import '../config/app_config.dart';
import 'auth_service.dart';

class ApiService {
  static String get baseUrl => AppConfig.apiBaseUrl;

  final AuthService authService;

  ApiService(this.authService);

  Map<String, String> get _headers {
    final headers = {'Content-Type': 'application/json'};
    if (authService.token != null) {
      headers['Authorization'] = 'Bearer ${authService.token}';
    }
    return headers;
  }

  // Auth
  Future<Map<String, dynamic>> register(
    String username,
    String email,
    String password,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'email': email,
        'password': password,
        'confirmPassword': password,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['data'];
    } else {
      throw Exception(jsonDecode(response.body)['message']);
    }
  }

  Future<Map<String, dynamic>> login(String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['data'];
    } else {
      throw Exception(jsonDecode(response.body)['message']);
    }
  }

  Future<void> verifyEmail(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/auth/verify-email?token=$token'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode != 200) {
      throw Exception(jsonDecode(response.body)['message']);
    }
  }

  // Challenge
  Future<Map<String, dynamic>> getTodayChallenge() async {
    final response = await http.get(
      Uri.parse('$baseUrl/challenge/today'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['challenge'];
    } else {
      throw Exception('Failed to load challenge');
    }
  }

  // Photos
  Future<void> uploadPhoto(String imageData, String caption) async {
    final response = await http.post(
      Uri.parse('$baseUrl/photos/upload'),
      headers: _headers,
      body: jsonEncode({'imageData': imageData, 'caption': caption}),
    );

    if (response.statusCode != 200) {
      throw Exception(jsonDecode(response.body)['message']);
    }
  }

  Future<List<Photo>> getTodayPhotos() async {
    final response = await http.get(
      Uri.parse('$baseUrl/photos/today'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final photos = data['photos'] as List;
      return photos.map((p) => Photo.fromJson(p)).toList();
    } else {
      throw Exception('Failed to load photos');
    }
  }

  Future<List<Photo>> getMyTodayPhotos() async {
    final response = await http.get(
      Uri.parse('$baseUrl/photos/me/today'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final photos = data['photos'] as List;
      return photos.map((p) => Photo.fromJson(p)).toList();
    } else {
      throw Exception('Failed to load photos');
    }
  }

  // Memories - Fotos von allen Tagen
  Future<List<Photo>> getMyMemories({int limit = 30}) async {
    final response = await http.get(
      Uri.parse('$baseUrl/photos/memories'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final photos = data['data']['photos'] as List;
      return photos.map((p) => Photo.fromJson(p)).toList();
    } else {
      throw Exception('Failed to load memories');
    }
  }

  // Memory Calendar - neue Endpoints
  Future<Map<String, int>> getMemoryCalendar({
    String? username,
    int? year,
    int? month,
  }) async {
    String url = '$baseUrl/memories/calendar';
    List<String> queryParams = [];

    if (username != null) queryParams.add('username=$username');
    if (year != null) queryParams.add('year=$year');
    if (month != null) queryParams.add('month=$month');

    if (queryParams.isNotEmpty) {
      url += '?${queryParams.join('&')}';
    }

    final response = await http.get(Uri.parse(url), headers: _headers);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final calendar = data['data']['calendar'] as Map<String, dynamic>;
      return calendar.map((key, value) => MapEntry(key, value as int));
    } else {
      throw Exception('Failed to load calendar');
    }
  }

  Future<List<Photo>> getMemoriesForDate(
    String date, {
    String? username,
  }) async {
    String url = '$baseUrl/memories/date/$date';
    if (username != null) {
      url += '?username=$username';
    }

    final response = await http.get(Uri.parse(url), headers: _headers);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final photos = data['data']['photos'] as List;
      return photos.map((p) => Photo.fromJson(p)).toList();
    } else {
      throw Exception('Failed to load memories for date');
    }
  }

  Future<bool> toggleMemoriesPrivacy() async {
    final response = await http.post(
      Uri.parse('$baseUrl/memories/toggle-privacy'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['data']['memoriesPublic'] as bool;
    } else {
      throw Exception('Failed to toggle privacy');
    }
  }

  Future<bool> getMemoriesPrivacy({String? username}) async {
    String url = '$baseUrl/memories/privacy';
    if (username != null) {
      url += '?username=$username';
    }

    final response = await http.get(Uri.parse(url), headers: _headers);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['data']['memoriesPublic'] as bool? ?? false;
    } else {
      throw Exception('Failed to get privacy status');
    }
  }

  Future<List<Photo>> getFriendMemories(String username) async {
    final response = await http.get(
      Uri.parse('$baseUrl/friends/$username/memories'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final photos = data['data']['photos'] as List;
      return photos.map((p) => Photo.fromJson(p)).toList();
    } else {
      throw Exception('Failed to load friend memories');
    }
  }

  /// Sends a toggle like request and returns the updated likes list from server.
  Future<List<String>> likePhoto(
    String photoId,
    String username,
    String date,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/photos/like'),
      headers: _headers,
      body: jsonEncode({
        'photoId': photoId,
        'photoUsername': username,
        'photoDate': date,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to like photo');
    }

    final data = jsonDecode(response.body);
    if (data['success'] == true && data['photo'] != null) {
      final photo = data['photo'];
      final likes = (photo['likes'] as List? ?? [])
          .map((e) => e as String)
          .toList();
      // Helpful debug logging for troubleshooting like-state
      try {
        // ignore: avoid_print
        print('Like API: status=${response.statusCode}, likes=${likes.length}');
      } catch (_) {}
      return likes;
    }

    return [];
  }

  Future<void> commentPhoto(
    String photoId,
    String username,
    String date,
    String text,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/photos/comment'),
      headers: _headers,
      body: jsonEncode({
        'photoId': photoId,
        'photoUsername': username,
        'photoDate': date,
        'text': text,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to comment');
    }
  }

  Future<void> deletePhoto(String photoId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/photos/delete'),
      headers: _headers,
      body: jsonEncode({'photoId': photoId}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete photo');
    }
  }

  // Friends
  Future<List<String>> getFriends() async {
    final response = await http.get(
      Uri.parse('$baseUrl/friends'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final friends = data['data']['friends'] as List;
      return friends.map((f) => f['username'] as String).toList();
    } else {
      throw Exception('Failed to load friends');
    }
  }

  Future<void> addFriend(String username) async {
    final response = await http.post(
      Uri.parse('$baseUrl/friends/add'),
      headers: _headers,
      body: jsonEncode({'friendUsername': username}),
    );

    if (response.statusCode != 200) {
      throw Exception(jsonDecode(response.body)['message']);
    }
  }

  Future<void> acceptFriend(String username) async {
    final response = await http.post(
      Uri.parse('$baseUrl/friends/accept'),
      headers: _headers,
      body: jsonEncode({'friendUsername': username}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to accept');
    }
  }

  Future<void> removeFriend(String username) async {
    final response = await http.post(
      Uri.parse('$baseUrl/friends/remove'),
      headers: _headers,
      body: jsonEncode({'friendUsername': username}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to remove');
    }
  }

  Future<List<String>> getPendingRequests() async {
    final response = await http.get(
      Uri.parse('$baseUrl/friends/requests'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final requests = data['data']['requests'] as List;
      return requests.map((r) => r['username'] as String).toList();
    } else {
      throw Exception('Failed to load requests');
    }
  }

  // Notifications
  Future<void> registerDevice({String? fcmToken}) async {
    try {
      await http.post(
        Uri.parse('$baseUrl/notifications/register'),
        headers: _headers,
        body: jsonEncode({
          'deviceToken': fcmToken ?? 'flutter_device',
          'platform': 'android',
        }),
      );
      debugPrint('✅ Device registered with FCM token');
    } catch (e) {
      debugPrint('Device registration failed: $e');
    }
  }

  Future<Map<String, dynamic>> getNotifications() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/notifications'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] != null) {
          return data['data'];
        }
      }
      // Return empty notifications if request fails
      return {'notifications': [], 'unreadCount': 0};
    } catch (e) {
      debugPrint('Get notifications error: $e');
      return {'notifications': [], 'unreadCount': 0};
    }
  }

  Future<void> markNotificationsRead() async {
    await http.post(
      Uri.parse('$baseUrl/notifications/read'),
      headers: _headers,
    );
  }

  // Profile Updates
  Future<void> updateProfileImage(String base64Image) async {
    final response = await http.post(
      Uri.parse('$baseUrl/profile/image'),
      headers: _headers,
      body: jsonEncode({'profileImage': base64Image}),
    );

    if (response.statusCode != 200) {
      throw Exception(jsonDecode(response.body)['message']);
    }
  }

  Future<void> updateEmail(String newEmail, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/profile/email'),
      headers: _headers,
      body: jsonEncode({'newEmail': newEmail, 'password': password}),
    );

    if (response.statusCode != 200) {
      throw Exception(jsonDecode(response.body)['message']);
    }
  }

  Future<void> updatePassword(String oldPassword, String newPassword) async {
    final response = await http.post(
      Uri.parse('$baseUrl/profile/password'),
      headers: _headers,
      body: jsonEncode({
        'oldPassword': oldPassword,
        'newPassword': newPassword,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(jsonDecode(response.body)['message']);
    }
  }

  Future<Map<String, dynamic>> getProfile() async {
    final response = await http.get(
      Uri.parse('$baseUrl/profile'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['data']['user'];
    } else {
      throw Exception('Failed to load profile');
    }
  }

  // Admin methods
  Future<List<Photo>> getAllPhotos() async {
    final response = await http.get(
      Uri.parse('$baseUrl/admin/photos'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final photos = data['data']['photos'] as List;
      return photos.map((p) => Photo.fromJson(p)).toList();
    } else {
      throw Exception('Failed to load all photos');
    }
  }

  Future<List<Challenge>> getAllChallenges() async {
    final response = await http.get(
      Uri.parse('$baseUrl/admin/challenges'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final challenges = data['data']['challenges'] as List;
      return challenges.map((c) => Challenge.fromJson(c)).toList();
    } else {
      throw Exception('Failed to load challenges');
    }
  }

  Future<void> setTodayChallenge(int challengeId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/admin/challenge/set'),
      headers: _headers,
      body: jsonEncode({'challengeId': challengeId}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to set challenge');
    }
  }
}
