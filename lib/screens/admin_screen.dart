import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../models/photo.dart';
import '../models/challenge.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  List<Photo> _allPhotos = [];
  List<Challenge> _allChallenges = [];
  Challenge? _currentChallenge;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final api = context.read<ApiService>();
      final photos = await api.getAllPhotos();
      final challenges = await api.getAllChallenges();
      final todayChallengeMap = await api.getTodayChallenge();

      print('DEBUG: Photos loaded: ${photos.length}');
      print('DEBUG: Challenges loaded: ${challenges.length}');
      print('DEBUG: Today challenge: $todayChallengeMap');

      setState(() {
        _allPhotos = photos;
        _allChallenges = challenges;
        _currentChallenge = Challenge.fromJson(todayChallengeMap);
        _isLoading = false;
      });
    } catch (e) {
      print('DEBUG: Error loading data: $e');
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fehler: $e')),
        );
      }
    }
  }

  Future<void> _setChallenge(int challengeId) async {
    try {
      await context.read<ApiService>().setTodayChallenge(challengeId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Challenge gesetzt!')),
      );
      _loadData();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fehler: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text('🔧 Admin Panel'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildChallengeSection(),
                  const SizedBox(height: 24),
                  _buildPhotosSection(),
                ],
              ),
            ),
    );
  }

  Widget _buildChallengeSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Heutige Challenge',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          if (_currentChallenge != null) ...[
            Row(
              children: [
                Text(_currentChallenge!.icon,
                    style: const TextStyle(fontSize: 32)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _currentChallenge!.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _currentChallenge!.description,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
          const Divider(),
          const SizedBox(height: 12),
          const Text(
            'Challenge ändern:',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _allChallenges.map((challenge) {
              final isActive = _currentChallenge?.id == challenge.id;
              return GestureDetector(
                onTap: () => _setChallenge(challenge.id),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isActive
                        ? const Color(0xFFFF6B9D)
                        : Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isActive
                          ? const Color(0xFFFF6B9D)
                          : Colors.white.withOpacity(0.2),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(challenge.icon,
                          style: const TextStyle(fontSize: 18)),
                      const SizedBox(width: 6),
                      Text(
                        challenge.title,
                        style: TextStyle(
                          fontWeight:
                              isActive ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotosSection() {
    final sortedPhotos = List<Photo>.from(_allPhotos)
      ..sort((a, b) => (b.createdAt ?? '').compareTo(a.createdAt ?? ''));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Alle Fotos (${_allPhotos.length})',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ...sortedPhotos.map((photo) => _buildPhotoCard(photo)),
      ],
    );
  }

  Widget _buildPhotoCard(Photo photo) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                CircleAvatar(
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
                      Text(
                        photo.username,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        '${photo.challenge} • ${photo.date}',
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
          Image.memory(
            _decodeBase64Image(photo.imageData),
            width: double.infinity,
            height: 300,
            fit: BoxFit.cover,
          ),
          if (photo.caption.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(photo.caption),
            ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Icon(Icons.favorite,
                    size: 16, color: Colors.white.withOpacity(0.7)),
                const SizedBox(width: 4),
                Text('${photo.likes.length}'),
                const SizedBox(width: 16),
                Icon(Icons.comment,
                    size: 16, color: Colors.white.withOpacity(0.7)),
                const SizedBox(width: 4),
                Text('${photo.comments.length}'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Uint8List _decodeBase64Image(String base64String) {
    return base64Decode(base64String.split(',').last);
  }
}
