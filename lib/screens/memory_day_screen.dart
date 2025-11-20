import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/photo.dart';
import '../services/api_service.dart';
import '../widgets/photo_card.dart';

class MemoryDayScreen extends StatefulWidget {
  final String date;
  final String? username;

  const MemoryDayScreen({
    super.key,
    required this.date,
    this.username,
  });

  @override
  State<MemoryDayScreen> createState() => _MemoryDayScreenState();
}

class _MemoryDayScreenState extends State<MemoryDayScreen> {
  List<Photo> _photos = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPhotos();
  }

  Future<void> _loadPhotos() async {
    setState(() => _isLoading = true);
    try {
      final apiService = context.read<ApiService>();
      final photos = await apiService.getMemoriesForDate(
        widget.date,
        username: widget.username,
      );

      setState(() {
        _photos = photos;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fehler: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('EEEE, dd. MMMM yyyy', 'de_DE')
        .format(DateTime.parse(widget.date));

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Memory', style: TextStyle(fontSize: 16)),
            Text(
              formattedDate,
              style:
                  const TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _photos.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.photo_library_outlined,
                          size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'Keine Fotos an diesem Tag',
                        style: TextStyle(color: Colors.grey[600], fontSize: 16),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: _photos.length,
                  itemBuilder: (context, index) {
                    return PhotoCard(
                      photo: _photos[index],
                      onDelete: widget.username == null ? _deletePhoto : null,
                      onRefresh: _loadPhotos,
                    );
                  },
                ),
    );
  }

  Future<void> _deletePhoto(String photoId) async {
    try {
      final apiService = context.read<ApiService>();
      await apiService.deletePhoto(photoId);
      await _loadPhotos();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Foto gelöscht')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fehler: $e')),
        );
      }
    }
  }
}
