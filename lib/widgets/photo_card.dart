import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../models/photo.dart';

class PhotoCard extends StatelessWidget {
  final Photo photo;
  final VoidCallback? onRefresh;
  final Function(String)? onDelete;

  const PhotoCard({
    super.key,
    required this.photo,
    this.onRefresh,
    this.onDelete,
  });

  Uint8List _decodeBase64Image(String base64String) {
    String cleanBase64 = base64String;
    if (base64String.contains(',')) {
      cleanBase64 = base64String.split(',')[1];
    }
    return base64Decode(cleanBase64);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
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
                      Text(
                        photo.username,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
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
                if (onDelete != null)
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _showDeleteDialog(context),
                  ),
              ],
            ),
          ),
          // Image
          GestureDetector(
            onTap: () => _showFullscreenImage(context),
            child: Image.memory(
              _decodeBase64Image(photo.imageData),
              width: double.infinity,
              height: 300,
              fit: BoxFit.cover,
            ),
          ),
          // Caption and info
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
                  const SizedBox(height: 8),
                ],
                Row(
                  children: [
                    Icon(Icons.favorite,
                        color: Colors.red.withOpacity(0.7), size: 16),
                    const SizedBox(width: 4),
                    Text('${photo.likes.length}',
                        style: TextStyle(color: Colors.white.withOpacity(0.7))),
                    const SizedBox(width: 16),
                    Icon(Icons.comment,
                        color: Colors.white.withOpacity(0.7), size: 16),
                    const SizedBox(width: 4),
                    Text('${photo.comments.length}',
                        style: TextStyle(color: Colors.white.withOpacity(0.7))),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showFullscreenImage(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: InteractiveViewer(
            child: Image.memory(
              _decodeBase64Image(photo.imageData),
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Foto löschen?'),
        content: const Text('Möchtest du dieses Foto wirklich löschen?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Abbrechen'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onDelete?.call(photo.id);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Löschen'),
          ),
        ],
      ),
    );
  }
}
