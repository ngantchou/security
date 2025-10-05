import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final FirebaseStorage _storage;

  StorageService({FirebaseStorage? storage})
      : _storage = storage ?? FirebaseStorage.instance;

  /// Upload audio file to Firebase Storage
  /// Returns the download URL of the uploaded file
  Future<String> uploadAudioFile({
    required String filePath,
    required String userId,
    String? alertId,
  }) async {
    final file = File(filePath);
    final fileName = '${DateTime.now().millisecondsSinceEpoch}.m4a';

    // Determine the storage path based on context
    final String storagePath;
    if (alertId != null) {
      // Audio associated with an alert
      storagePath = 'alerts/$alertId/audio/$fileName';
    } else {
      // General user audio (e.g., voice comments)
      storagePath = 'users/$userId/audio/$fileName';
    }

    try {
      // Upload file
      final ref = _storage.ref().child(storagePath);
      final uploadTask = ref.putFile(
        file,
        SettableMetadata(
          contentType: 'audio/mp4',
          customMetadata: {
            'uploadedBy': userId,
            'uploadedAt': DateTime.now().toIso8601String(),
          },
        ),
      );

      // Wait for upload to complete
      final snapshot = await uploadTask;

      // Get download URL
      final downloadUrl = await snapshot.ref.getDownloadURL();

      // Delete local file after successful upload
      try {
        await file.delete();
      } catch (e) {
        // Ignore deletion errors
      }

      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload audio: $e');
    }
  }

  /// Upload image file to Firebase Storage
  /// Returns the download URL of the uploaded file
  Future<String> uploadImageFile({
    required String filePath,
    required String userId,
    String? alertId,
  }) async {
    final file = File(filePath);
    final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';

    // Determine the storage path based on context
    final String storagePath;
    if (alertId != null) {
      // Image associated with an alert
      storagePath = 'alerts/$alertId/images/$fileName';
    } else {
      // General user images (e.g., profile pictures)
      storagePath = 'users/$userId/images/$fileName';
    }

    try {
      // Upload file
      final ref = _storage.ref().child(storagePath);
      final uploadTask = ref.putFile(
        file,
        SettableMetadata(
          contentType: 'image/jpeg',
          customMetadata: {
            'uploadedBy': userId,
            'uploadedAt': DateTime.now().toIso8601String(),
          },
        ),
      );

      // Wait for upload to complete
      final snapshot = await uploadTask;

      // Get download URL
      final downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }

  /// Delete file from Firebase Storage
  Future<void> deleteFile(String fileUrl) async {
    try {
      final ref = _storage.refFromURL(fileUrl);
      await ref.delete();
    } catch (e) {
      throw Exception('Failed to delete file: $e');
    }
  }

  /// Get file metadata
  Future<FullMetadata> getFileMetadata(String fileUrl) async {
    try {
      final ref = _storage.refFromURL(fileUrl);
      return await ref.getMetadata();
    } catch (e) {
      throw Exception('Failed to get file metadata: $e');
    }
  }
}
