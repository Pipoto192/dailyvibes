import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../models/photo.dart';

class MemoriesScreen extends StatefulWidget {
  const MemoriesScreen({super.key});

  @override
  State<MemoriesScreen> createState() => _MemoriesScreenState();
}

class _MemoriesScreenState extends State<MemoriesScreen> {
  List<Photo> _memories = [];
  bool _isLoading = true;
  final Map<String, Uint8List> _imageCache = {};

  @override
  void initState() {
    super.initState();
    _loadMemories();
  }

  Uint8List _decodeBase64Image(String imageData) {
    // Return cached version if available
    if (_imageCache.containsKey(imageData)) {
      return _imageCache[imageData]!;
    }

    // Entfernt "data:image/...;base64," prefix falls vorhanden
    String base64String = imageData;
    if (imageData.contains(',')) {
      base64String = imageData.split(',').last;
    }
    final bytes = base64Decode(base64String);

    // Cache the decoded bytes
    _imageCache[imageData] = bytes;
    return bytes;
  }

  Future<void> _loadMemories() async {
    setState(() => _isLoading = true);
    try {
      final memories =
          await context.read<ApiService>().getMyMemories(limit: 50);
      setState(() {
        _memories = memories;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fehler: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Memories'),
        backgroundColor: const Color(0xFF1A1A1A),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1A1A1A), Color(0xFF0A0A0A)],
          ),
        ),
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Color(0xFFFF6B9D)))
            : _memories.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.photo_library_outlined,
                          size: 80,
                          color: Colors.white.withOpacity(0.3),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Noch keine Memories',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white.withOpacity(0.5),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Mach dein erstes Foto!',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.3),
                          ),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _loadMemories,
                    color: const Color(0xFFFF6B9D),
                    child: GridView.builder(
                      padding: const EdgeInsets.all(8),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 4,
                        mainAxisSpacing: 4,
                      ),
                      itemCount: _memories.length,
                      itemBuilder: (context, index) {
                        final memory = _memories[index];
                        return GestureDetector(
                          onTap: () => _showMemoryDetail(memory),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.memory(
                                  _decodeBase64Image(memory.imageData),
                                  fit: BoxFit.cover,
                                  cacheWidth: 300,
                                ),
                              ),
                              // Gradient overlay mit Datum
                              Positioned(
                                bottom: 0,
                                left: 0,
                                right: 0,
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: const BorderRadius.only(
                                      bottomLeft: Radius.circular(8),
                                      bottomRight: Radius.circular(8),
                                    ),
                                    gradient: LinearGradient(
                                      begin: Alignment.bottomCenter,
                                      end: Alignment.topCenter,
                                      colors: [
                                        Colors.black.withOpacity(0.7),
                                        Colors.transparent,
                                      ],
                                    ),
                                  ),
                                  padding: const EdgeInsets.all(4),
                                  child: Text(
                                    _formatDate(memory.date),
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
      ),
    );
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      final diff = now.difference(date);

      if (diff.inDays == 0) {
        return 'Heute';
      } else if (diff.inDays == 1) {
        return 'Gestern';
      } else if (diff.inDays < 7) {
        return 'vor ${diff.inDays}d';
      } else {
        return '${date.day}.${date.month}.';
      }
    } catch (e) {
      return dateStr;
    }
  }

  void _showMemoryDetail(Photo memory) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.7,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: const Color(0xFF1A1A1A),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Text(
                          memory.challenge,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),
                  // Bild
                  Flexible(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(20),
                      ),
                      child: Image.memory(
                        _decodeBase64Image(memory.imageData),
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  // Info
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (memory.caption.isNotEmpty) ...[
                          Text(
                            memory.caption,
                            style: const TextStyle(fontSize: 14),
                          ),
                          const SizedBox(height: 8),
                        ],
                        Row(
                          children: [
                            Icon(Icons.favorite,
                                size: 16, color: Colors.red.withOpacity(0.7)),
                            const SizedBox(width: 4),
                            Text('${memory.likes.length}',
                                style: const TextStyle(fontSize: 14)),
                            const SizedBox(width: 16),
                            Icon(Icons.comment,
                                size: 16, color: Colors.white.withOpacity(0.7)),
                            const SizedBox(width: 4),
                            Text('${memory.comments.length}',
                                style: const TextStyle(fontSize: 14)),
                            const Spacer(),
                            Text(
                              _formatFullDate(memory.date),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white.withOpacity(0.5),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatFullDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day}.${date.month}.${date.year}';
    } catch (e) {
      return dateStr;
    }
  }
}
