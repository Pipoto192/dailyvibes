import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import 'memory_calendar_screen.dart';

class FriendMemoriesScreen extends StatefulWidget {
  final String friendUsername;

  const FriendMemoriesScreen({
    super.key,
    required this.friendUsername,
  });

  @override
  State<FriendMemoriesScreen> createState() => _FriendMemoriesScreenState();
}

class _FriendMemoriesScreenState extends State<FriendMemoriesScreen> {
  bool _isPublic = false;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _checkPrivacy();
  }

  Future<void> _checkPrivacy() async {
    setState(() => _isLoading = true);
    try {
      final apiService = context.read<ApiService>();
      final isPublic = await apiService.getMemoriesPrivacy(
        username: widget.friendUsername,
      );

      setState(() {
        _isPublic = isPublic;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.friendUsername}\'s Memories'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline,
                          size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'Fehler beim Laden',
                        style: TextStyle(color: Colors.grey[600], fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _errorMessage!,
                        style: TextStyle(color: Colors.grey[500], fontSize: 14),
                      ),
                    ],
                  ),
                )
              : !_isPublic
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.lock, size: 64, color: Colors.grey[400]),
                          const SizedBox(height: 16),
                          Text(
                            '🔒 Memories sind privat',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${widget.friendUsername} hat die Memories auf privat gestellt',
                            style: TextStyle(
                                color: Colors.grey[500], fontSize: 14),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                  : Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.calendar_month,
                              size: 80, color: const Color(0xFFFF6B9D)),
                          const SizedBox(height: 24),
                          Text(
                            '${widget.friendUsername}\'s Memories',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Schau dir alle Memories im Kalender an',
                            style: TextStyle(
                                color: Colors.grey[600], fontSize: 16),
                          ),
                          const SizedBox(height: 32),
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => MemoryCalendarScreen(
                                    friendUsername: widget.friendUsername,
                                  ),
                                ),
                              );
                            },
                            icon: const Icon(Icons.calendar_today),
                            label: const Text('Kalender öffnen'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFF6B9D),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                                vertical: 16,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
    );
  }
}
