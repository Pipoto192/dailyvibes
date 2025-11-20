import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../services/simple_notification_service.dart';
import '../services/web_notification_service.dart';
import '../models/challenge.dart';
import '../models/photo.dart';
import '../models/user.dart';
import 'camera_screen.dart';
import 'friends_screen.dart';
import 'profile_screen.dart';
import 'memory_calendar_screen.dart';
import 'notifications_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Challenge? _challenge;
  List<Photo> _myPhotos = [];
  List<Photo> _friendsPhotos = [];
  Timer? _refreshTimer;
  Timer? _countdownTimer;
  bool _isLoading = true;
  int _unreadCount = 0;
  List<Map<String, dynamic>> _lastNotifications = [];
  bool _showNotificationBanner = false;
  // Track in-flight like requests to prevent duplicate taps
  final Set<String> _likingPhotos = {};
  // Track pending comments by photoId, each value is a list of temp comment timestamps
  // (currently not used, placeholder for future improvements)
  // final Map<String, List<String>> _pendingComments = {};

  @override
  void initState() {
    super.initState();
    _checkNotificationPermission();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Load user profile in background (non-blocking)
    _loadUserProfile();

    // Register device for notifications (non-blocking)
    _registerDevice();

    // Load data in background (non-blocking)
    _loadData();

    // Start auto-refresh immediately
    _startAutoRefresh();
  }

  Future<void> _loadUserProfile() async {
    try {
      final api = context.read<ApiService>();
      final auth = context.read<AuthService>();

      final profileData = await api.getProfile();
      final updatedUser = User.fromJson(profileData);
      await auth.updateUser(updatedUser);
    } catch (e) {
      // Silent fail - profile will load from cache
      debugPrint('Profile load error: $e');
    }
  }

  void _checkNotificationPermission() {
    if (kIsWeb) {
      final permission = WebNotificationService.getPermissionStatus();
      setState(() {
        _showNotificationBanner = permission != 'granted';
      });
    }
  }

  Future<void> _requestNotificationPermission() async {
    if (!kIsWeb) return;

    try {
      debugPrint('🔔 Requesting notification permission...');
      final permission = await WebNotificationService.requestPermission();
      debugPrint('🔔 Permission result: $permission');

      if (permission == 'granted') {
        final api = context.read<ApiService>();
        await WebNotificationService.initialize(api);
        setState(() {
          _showNotificationBanner = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Benachrichtigungen aktiviert!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else if (permission == 'denied') {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  '⚠️ Benachrichtigungen wurden blockiert. Bitte aktiviere sie in den Browser-Einstellungen.'),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 5),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'ℹ️ Safari auf iOS unterstützt keine Web-Benachrichtigungen. Nutze die Android-App oder einen anderen Browser.'),
              backgroundColor: Colors.blue,
              duration: Duration(seconds: 5),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error requesting permission: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Fehler: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _registerDevice() async {
    try {
      final api = context.read<ApiService>();
      await api.registerDevice();

      // Initialize web notifications if on web
      if (kIsWeb) {
        await WebNotificationService.initialize(api);
      }

      debugPrint('Device registered for notifications');
    } catch (e) {
      debugPrint('Device registration error: $e');
    }
  }

  final Map<String, Uint8List> _imageCache = {};

  Uint8List _decodeBase64Image(String imageData) {
    if (_imageCache.containsKey(imageData)) {
      return _imageCache[imageData]!;
    }
    String base64String = imageData;
    if (imageData.contains(',')) {
      base64String = imageData.split(',').last;
    }
    final bytes = base64Decode(base64String);
    _imageCache[imageData] = bytes;
    return bytes;
  }

  // Cached image widget to avoid re-decoding
  Widget _buildCachedImage(
    String imageData, {
    required double width,
    required double height,
    BoxFit fit = BoxFit.cover,
    BorderRadius? borderRadius,
  }) {
    final bytes = _decodeBase64Image(imageData);
    final image = Image.memory(
      bytes,
      width: width,
      height: height,
      fit: fit,
      gaplessPlayback: true,
      cacheWidth: 800,
    );

    if (borderRadius != null) {
      return ClipRRect(
        borderRadius: borderRadius,
        child: image,
      );
    }
    return image;
  }

  void _startAutoRefresh() {
    _refreshTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      _loadData(silent: true);
    });
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  Future<void> _loadData({bool silent = false}) async {
    if (!silent) setState(() => _isLoading = true);

    try {
      final api = context.read<ApiService>();

      // Load all data in parallel instead of sequentially
      final results = await Future.wait([
        api.getTodayChallenge(),
        api.getMyTodayPhotos(),
        api.getTodayPhotos(),
        api.getNotifications().catchError((e) {
          debugPrint('Notification loading error: $e');
          return {'unreadCount': 0, 'notifications': []};
        }),
      ]);

      _challenge = Challenge.fromJson(results[0] as Map<String, dynamic>);
      _myPhotos = results[1] as List<Photo>;
      _friendsPhotos = results[2] as List<Photo>;

      final notifs = results[3] as Map<String, dynamic>;
      _unreadCount = notifs['unreadCount'] ?? 0;

      // Check for new notifications
      final notifications = notifs['notifications'] as List? ?? [];
      for (var notif in notifications) {
        if (!_lastNotifications.any((n) => n['id'] == notif['id'])) {
          final title = notif['title'] ?? 'Daily Vibes';
          final body = notif['body'] ?? '';
          _showNotification(title, body);
        }
      }
      _lastNotifications = List<Map<String, dynamic>>.from(notifications);

      if (mounted) setState(() => _isLoading = false);
    } catch (e) {
      if (mounted && !silent) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fehler: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _showNotification(String title, String body) async {
    debugPrint('🔔 _showNotification called: $title - $body');
    try {
      await SimpleNotificationService.showNotification(
        title: title,
        body: body,
      );
      debugPrint('✅ Notification sent successfully');
    } catch (e) {
      debugPrint('❌ Notification error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body:
            Center(child: CircularProgressIndicator(color: Color(0xFFFF6B9D))),
      );
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1A1A1A), Color(0xFF0A0A0A)],
          ),
        ),
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: () => _loadData(),
            color: const Color(0xFFFF6B9D),
            child: CustomScrollView(
              slivers: [
                _buildAppBar(),
                if (kIsWeb && _showNotificationBanner)
                  SliverToBoxAdapter(child: _buildNotificationBanner()),
                SliverToBoxAdapter(child: _buildChallengeCard()),
                SliverToBoxAdapter(child: _buildMyPhotoSection()),
                SliverToBoxAdapter(child: _buildFriendsPhotosSection()),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: _buildCameraButton(),
    );
  }

  Widget _buildAppBar() {
    final auth = context.watch<AuthService>();

    return SliverAppBar(
      floating: true,
      backgroundColor: const Color(0xFF1A1A1A),
      title: ShaderMask(
        shaderCallback: (bounds) => const LinearGradient(
          colors: [Color(0xFFFF6B9D), Color(0xFFFFA07A)],
        ).createShader(bounds),
        child: const Text(
          'Daily Vibes',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      actions: [
        // Notifications button with badge
        Stack(
          children: [
            IconButton(
              icon: Icon(Icons.notifications,
                  color: Colors.white.withOpacity(0.9)),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NotificationsScreen()),
              ),
            ),
            if (_unreadCount > 0)
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: Text(
                    _unreadCount > 9 ? '9+' : _unreadCount.toString(),
                    style: const TextStyle(
                        fontSize: 10, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
        IconButton(
          icon:
              Icon(Icons.calendar_today, color: Colors.white.withOpacity(0.9)),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const MemoryCalendarScreen()),
          ),
        ),
        IconButton(
          icon: Icon(Icons.people, color: Colors.white.withOpacity(0.9)),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const FriendsScreen()),
          ),
        ),
        IconButton(
          icon: auth.user?.profileImage != null &&
                  auth.user!.profileImage!.isNotEmpty
              ? CircleAvatar(
                  backgroundImage: MemoryImage(
                    _decodeBase64Image(auth.user!.profileImage!),
                  ),
                )
              : CircleAvatar(
                  backgroundColor: const Color(0xFFFF6B9D),
                  child: Text(
                    auth.user?.username[0].toUpperCase() ?? 'U',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ProfileScreen()),
          ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildNotificationBanner() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFF6B9D).withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFF6B9D)),
      ),
      child: Row(
        children: [
          const Icon(Icons.notifications_active, color: Color(0xFFFF6B9D)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Benachrichtigungen aktivieren',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Erhalte Benachrichtigungen über Likes, Kommentare & neue Fotos',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: _requestNotificationPermission,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF6B9D),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            child: const Text('Aktivieren'),
          ),
        ],
      ),
    );
  }

  Widget _buildChallengeCard() {
    if (_challenge == null) return const SizedBox();

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFFF6B9D).withOpacity(0.15),
            const Color(0xFFFFA07A).withOpacity(0.15),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFFF6B9D).withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(_challenge!.icon, style: const TextStyle(fontSize: 40)),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _challenge!.title,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _challenge!.description,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildTimer(),
        ],
      ),
    );
  }

  Widget _buildTimer() {
    if (_challenge == null) return const SizedBox();

    final now = DateTime.now();

    String formatDuration(Duration duration) {
      final hours = duration.inHours;
      final minutes = duration.inMinutes.remainder(60);
      final seconds = duration.inSeconds.remainder(60);

      if (hours > 0) {
        return '${hours}h ${minutes}m';
      } else if (minutes > 0) {
        return '${minutes}m ${seconds}s';
      } else {
        return '${seconds}s';
      }
    }

    String statusText = 'Noch heute:';
    Color statusColor = Colors.green;

    // Calculate time until midnight (end of day)
    final midnight = DateTime(now.year, now.month, now.day + 1, 0, 0, 0);
    final timeUntilMidnight = midnight.difference(now);
    String timeText = formatDuration(timeUntilMidnight);
    String nextChallengeText = 'Neue Challenge um Mitternacht';

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                statusText,
                style: TextStyle(
                  color: statusColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                timeText,
                style: TextStyle(
                  color: statusColor,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFFF6B9D).withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.schedule, size: 16, color: Color(0xFFFF6B9D)),
              const SizedBox(width: 8),
              Text(
                nextChallengeText,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFFFF6B9D),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMyPhotoSection() {
    final hasPhotos = _myPhotos.isNotEmpty;
    final photoCount = _myPhotos.length;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Deine Bilder von heute',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              if (hasPhotos)
                Text(
                  '$photoCount/3 Fotos',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (hasPhotos)
            SizedBox(
              height: 550,
              child: PageView.builder(
                itemCount: _myPhotos.length + (photoCount < 3 ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == _myPhotos.length) {
                    return _buildAddPhotoCard();
                  }
                  return _buildMyPhotoCard(_myPhotos[index]);
                },
              ),
            )
          else
            _buildAddPhotoCard(),
        ],
      ),
    );
  }

  Widget _buildAddPhotoCard() {
    return GestureDetector(
      onTap: () async {
        if (_myPhotos.length >= 3) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Du hast bereits 3 Fotos heute hochgeladen!'),
              backgroundColor: Colors.orange,
            ),
          );
          return;
        }
        final result = await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CameraScreen()),
        );
        if (result == true) _loadData();
      },
      child: Container(
        height: 450,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withOpacity(0.2),
            width: 2,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.add_a_photo,
                size: 64,
                color: Colors.white.withOpacity(0.5),
              ),
              const SizedBox(height: 16),
              Text(
                'Tippe um ein Foto zu machen',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMyPhotoCard(Photo photo) {
    final myUsername = context.read<AuthService>().user?.username ?? '';
    final isLiked = photo.likes.contains(myUsername);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header with challenge name
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      const Text('📸', style: TextStyle(fontSize: 20)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  myUsername,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                if (photo.userStreak != null &&
                                    photo.userStreak! >= 2)
                                  GestureDetector(
                                    onTap: () {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            '🔥 Streak: ${photo.userStreak} Tage in Folge hochgeladen!',
                                          ),
                                          duration: const Duration(seconds: 2),
                                        ),
                                      );
                                    },
                                    child: Row(
                                      children: [
                                        const Text(
                                          '🔥',
                                          style: TextStyle(fontSize: 16),
                                        ),
                                        Text(
                                          '${photo.userStreak}',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.purple[300],
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                      ],
                                    ),
                                  ),
                                ..._buildAchievementBadges(photo),
                              ],
                            ),
                            Text(
                              photo.challenge,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.6),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () => _deletePhoto(photo.id),
                ),
              ],
            ),
          ),
          // Image
          GestureDetector(
            onTap: () => _showFullscreenImage(photo.imageData),
            child: _buildCachedImage(
              photo.imageData,
              width: double.infinity,
              height: 300,
            ),
          ),
          // Caption, likes, comments
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (photo.caption.isNotEmpty) ...[
                  Text(
                    photo.caption,
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 12),
                ],
                Row(
                  children: [
                    // Like button with optimistic UI update & AnimatedSwitcher for smoothness
                    IconButton(
                      icon: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 180),
                        transitionBuilder: (child, animation) => ScaleTransition(
                          scale: animation,
                          child: child,
                        ),
                        child: Icon(
                          isLiked ? Icons.favorite : Icons.favorite_border,
                          color: isLiked ? Colors.red : Colors.white,
                          key: ValueKey<bool>(isLiked),
                        ),
                      ),
                      onPressed: () => _likePhoto(photo),
                    ),
                    Text('${photo.likes.length}'),
                    const SizedBox(width: 16),
                    IconButton(
                      icon: Icon(Icons.comment,
                          color: Colors.white.withOpacity(0.7)),
                      onPressed: () => _showCommentsDialog(photo),
                    ),
                    Text('${photo.comments.length}'),
                  ],
                ),
                if (photo.comments.isNotEmpty) ...[
                  const Divider(height: 24),
                  ...photo.comments.take(2).map((comment) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: RichText(
                          text: TextSpan(
                            style: const TextStyle(
                                color: Colors.white, fontSize: 13),
                            children: [
                              TextSpan(
                                text: '${comment.username} ',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              TextSpan(text: comment.text),
                            ],
                          ),
                        ),
                      )),
                  if (photo.comments.length > 2)
                    GestureDetector(
                      onTap: () => _showCommentsDialog(photo),
                      child: Text(
                        'Alle ${photo.comments.length} Kommentare ansehen',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 12,
                        ),
                      ),
                    ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deletePhoto(String photoId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text('Foto löschen'),
        content: const Text('Möchtest du dieses Foto wirklich löschen?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Abbrechen'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Löschen'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await context.read<ApiService>().deletePhoto(photoId);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Foto gelöscht')),
        );
        _loadData();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fehler: $e')),
        );
      }
    }
  }

  Widget _buildFriendsPhotosSection() {
    final friendPhotos = List<Photo>.from(_friendsPhotos)
      ..sort((a, b) => (b.createdAt ?? '').compareTo(a.createdAt ?? ''));

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Fotos deiner Freunde',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          if (friendPhotos.isEmpty)
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(
                  'Noch keine Fotos heute 📸',
                  style: TextStyle(color: Colors.white.withOpacity(0.5)),
                ),
              ),
            )
          else
            SizedBox(
              height: 550,
              child: PageView.builder(
                itemCount: friendPhotos.length,
                itemBuilder: (context, index) {
                  return _buildPhotoCard(friendPhotos[index]);
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPhotoCard(Photo photo) {
    final myUsername = context.read<AuthService>().user?.username ?? '';
    final isLiked = photo.likes.contains(myUsername);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // User header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                photo.userProfileImage != null &&
                        photo.userProfileImage!.isNotEmpty
                    ? CircleAvatar(
                        backgroundImage: MemoryImage(
                          _decodeBase64Image(photo.userProfileImage!),
                        ),
                      )
                    : CircleAvatar(
                        backgroundColor: const Color(0xFFFF6B9D),
                        child: Text(
                          photo.username[0].toUpperCase(),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            photo.username,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(width: 6),
                          if (photo.userStreak != null &&
                              photo.userStreak! >= 2)
                            GestureDetector(
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      '🔥 Streak: ${photo.userStreak} Tage in Folge hochgeladen!',
                                    ),
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                              },
                              child: Row(
                                children: [
                                  const Text(
                                    '🔥',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  Text(
                                    '${photo.userStreak}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.purple[300],
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                ],
                              ),
                            ),
                          ..._buildAchievementBadges(photo),
                        ],
                      ),
                      Text(
                        photo.challenge,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Image
          GestureDetector(
            onTap: () => _showFullscreenImage(photo.imageData),
            child: _buildCachedImage(
              photo.imageData,
              width: double.infinity,
              height: 300,
            ),
          ),
          // Actions and comments
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (photo.caption.isNotEmpty) ...[
                  Text(
                    photo.caption,
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 12),
                ],
                Row(
                  children: [
                    IconButton(
                      icon: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 180),
                        transitionBuilder: (child, animation) => ScaleTransition(
                          scale: animation,
                          child: child,
                        ),
                        child: Icon(
                          isLiked ? Icons.favorite : Icons.favorite_border,
                          color: isLiked ? Colors.red : Colors.white,
                          key: ValueKey<bool>(isLiked),
                        ),
                      ),
                      onPressed: () => _likePhoto(photo),
                    ),
                    Text('${photo.likes.length}'),
                    const SizedBox(width: 16),
                    IconButton(
                      icon: Icon(Icons.comment,
                          color: Colors.white.withOpacity(0.7)),
                      onPressed: () => _showCommentsDialog(photo),
                    ),
                    Text('${photo.comments.length}'),
                  ],
                ),
                if (photo.comments.isNotEmpty) ...[
                  const Divider(height: 24),
                  ...photo.comments.take(2).map((comment) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: RichText(
                          text: TextSpan(
                            style: const TextStyle(
                                color: Colors.white, fontSize: 13),
                            children: [
                              TextSpan(
                                text: '${comment.username} ',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              TextSpan(text: comment.text),
                            ],
                          ),
                        ),
                      )),
                  if (photo.comments.length > 2)
                    GestureDetector(
                      onTap: () => _showCommentsDialog(photo),
                      child: Text(
                        'Alle ${photo.comments.length} Kommentare anzeigen',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 12,
                        ),
                      ),
                    ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _likePhoto(Photo photo) async {
    final myUsername = context.read<AuthService>().user?.username ?? '';
    if (myUsername.isEmpty) return;

    // prevent repeated taps while request in flight
    if (_likingPhotos.contains(photo.id)) return;
    _likingPhotos.add(photo.id);

    final wasLiked = photo.likes.contains(myUsername);

    // Optimistically update UI
    setState(() {
      if (wasLiked) {
        photo.likes.remove(myUsername);
      } else {
        photo.likes.add(myUsername);
      }
    });

    try {
      await context
          .read<ApiService>()
          .likePhoto(photo.id, photo.username, photo.date);
    } catch (e) {
      // Revert optimistic change on error
      setState(() {
        if (wasLiked) {
          photo.likes.add(myUsername);
        } else {
          photo.likes.remove(myUsername);
        }
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fehler beim Liken: $e')),
        );
      }
    } finally {
      _likingPhotos.remove(photo.id);
    }
  }

  void _showFullscreenImage(String imageData) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Stack(
          children: [
            Center(
              child: InteractiveViewer(
                child: Image.memory(
                  _decodeBase64Image(imageData),
                  fit: BoxFit.contain,
                ),
              ),
            ),
            Positioned(
              top: 40,
              right: 20,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 30),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCommentsDialog(Photo photo) {
    final TextEditingController commentController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text('Kommentare'),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (photo.comments.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Noch keine Kommentare',
                    style: TextStyle(color: Colors.white.withOpacity(0.5)),
                  ),
                )
              else
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: photo.comments.length,
                    itemBuilder: (context, index) {
                      final comment = photo.comments[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            RichText(
                              text: TextSpan(
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 14),
                                children: [
                                  TextSpan(
                                    text: '${comment.username} ',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                  TextSpan(text: comment.text),
                                ],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _formatTimestamp(comment.timestamp),
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.4),
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: commentController,
                      decoration: InputDecoration(
                        hintText: 'Kommentar schreiben...',
                        hintStyle:
                            TextStyle(color: Colors.white.withOpacity(0.5)),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.05),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.send, color: Color(0xFFFF6B9D)),
                    onPressed: () async {
                      final text = commentController.text.trim();
                      if (text.isEmpty) return;

                      final myUsername = context.read<AuthService>().user?.username ?? '';
                      if (myUsername.isEmpty) return;

                      // Create a pending comment locally
                      final pendingComment = Comment(
                        username: myUsername,
                        text: text,
                        timestamp: DateTime.now().toIso8601String(),
                      );

                      // Add locally (optimistic)
                      setState(() {
                        photo.comments.add(pendingComment);
                      });
                      // Update dialog state too
                      setDialogState(() {});

                      // clear input for UX
                      commentController.clear();

                      try {
                        await context.read<ApiService>().commentPhoto(
                              photo.id,
                              photo.username,
                              photo.date,
                              text,
                            );

                        // On success, reload to sync with server
                        if (context.mounted) {
                          await _loadData(silent: true);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Kommentar gepostet!'),
                              backgroundColor: Colors.green,
                              duration: Duration(seconds: 1),
                            ),
                          );
                          // close dialog after post
                          Navigator.pop(context);
                        }
                      } catch (e) {
                        // Remove the pending comment if the request failed
                        setState(() {
                          photo.comments.removeWhere((c) =>
                              c.timestamp == pendingComment.timestamp && c.username == pendingComment.username && c.text == pendingComment.text);
                        });
                        setDialogState(() {});
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Fehler: $e'), backgroundColor: Colors.red),
                          );
                        }
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Schließen'),
          ),
        ],
      ); // end AlertDialog
          },
        ); // end StatefulBuilder
      },
    );
  }

  List<Widget> _buildAchievementBadges(Photo photo) {
    if (photo.createdAt == null) return [];

    List<Widget> badges = [];

    try {
      final uploadTime = DateTime.parse(photo.createdAt!);
      final hour = uploadTime.hour;

      // Frühaufsteher: 5-8 Uhr
      if (hour >= 5 && hour < 8) {
        badges.add(Tooltip(
          message: 'Frühaufsteher (5-8 Uhr)',
          child: GestureDetector(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                      '🌅 Frühaufsteher: Foto zwischen 5-8 Uhr hochgeladen'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            child: const Text('🌅', style: TextStyle(fontSize: 14)),
          ),
        ));
        badges.add(const SizedBox(width: 2));
      }

      // Nachteule: 22-4 Uhr
      if (hour >= 22 || hour < 4) {
        badges.add(Tooltip(
          message: 'Nachteule (22-4 Uhr)',
          child: GestureDetector(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content:
                      Text('🦉 Nachteule: Foto zwischen 22-4 Uhr hochgeladen'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            child: const Text('🦉', style: TextStyle(fontSize: 14)),
          ),
        ));
        badges.add(const SizedBox(width: 2));
      }

      // Pünktlich: innerhalb der ersten Stunde
      if (photo.userAchievements != null &&
          photo.userAchievements!.contains('punctual')) {
        badges.add(Tooltip(
          message: 'Pünktlich (erste Stunde)',
          child: GestureDetector(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                      '⏰ Pünktlich: Foto innerhalb der ersten Stunde hochgeladen'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            child: const Text('⏰', style: TextStyle(fontSize: 14)),
          ),
        ));
        badges.add(const SizedBox(width: 2));
      }
    } catch (e) {
      // Ignore parse errors
    }

    return badges;
  }

  String _formatTimestamp(String timestamp) {
    try {
      final date = DateTime.parse(timestamp);
      final now = DateTime.now();
      final diff = now.difference(date);

      if (diff.inMinutes < 1) {
        return 'Gerade eben';
      } else if (diff.inHours < 1) {
        return 'vor ${diff.inMinutes}m';
      } else if (diff.inDays < 1) {
        return 'vor ${diff.inHours}h';
      } else if (diff.inDays < 7) {
        return 'vor ${diff.inDays}d';
      } else {
        return '${date.day}.${date.month}.${date.year}';
      }
    } catch (e) {
      return '';
    }
  }

  Widget _buildCameraButton() {
    return FloatingActionButton.large(
      onPressed: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CameraScreen()),
        );
        if (result == true) _loadData();
      },
      backgroundColor: const Color(0xFFFF6B9D),
      child: const Icon(Icons.add_a_photo, size: 32),
    );
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _countdownTimer?.cancel();
    super.dispose();
  }
}
