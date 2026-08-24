import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Cloudinary image upload service using unsigned upload presets.
/// No SDK required — uses Cloudinary's REST upload API.
///
/// Setup:
///   1. Log in at https://cloudinary.com/console
///   2. Go to Settings → Upload → Upload presets → Add upload preset
///   3. Set Signing mode = Unsigned, Folder = rudram
///   4. Copy Cloud name from Dashboard, copy Preset name from above
///   5. Replace the two const values below
class CloudinaryService {
  // ──────────────────────────────────────────────────────
  //  🔧 CONFIGURED VIA .env FILE
  // ──────────────────────────────────────────────────────
  static String get _cloudName => dotenv.env['CLOUDINARY_CLOUD_NAME'] ?? 'YOUR_CLOUD_NAME';
  static String get _uploadPreset => dotenv.env['CLOUDINARY_UPLOAD_PRESET'] ?? 'rudram';
  // ──────────────────────────────────────────────────────

  static const String _baseUrl = 'https://api.cloudinary.com/v1_1';

  /// Uploads a file from the local filesystem (mobile/desktop).
  ///
  /// [file] — File picked via image_picker on mobile.
  /// [folder] — Cloudinary folder to store in (e.g. 'profiles', 'products').
  ///
  /// Returns the secure HTTPS URL of the uploaded image, or null on failure.
  static Future<String?> uploadFile(
    File file, {
    String folder = 'rudram',
    String? publicId,
  }) async {
    try {
      final mimeType = lookupMimeType(file.path) ?? 'image/jpeg';
      final parts = mimeType.split('/');

      final uri = Uri.parse('$_baseUrl/$_cloudName/image/upload');
      final request = http.MultipartRequest('POST', uri);

      request.fields['upload_preset'] = _uploadPreset;
      request.fields['folder'] = folder;
      if (publicId != null) request.fields['public_id'] = publicId;

      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          file.path,
          contentType: MediaType(parts[0], parts[1]),
        ),
      );

      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 60),
      );
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return json['secure_url'] as String?;
      } else {
        final error = jsonDecode(response.body);
        throw Exception('Cloudinary upload failed: ${error['error']?['message'] ?? response.body}');
      }
    } catch (e) {
      // ignore: avoid_print
      print('[CloudinaryService] uploadFile error: $e');
      return null;
    }
  }

  /// Uploads raw bytes (for web where File is not available).
  ///
  /// [bytes] — Uint8List of the image bytes.
  /// [fileName] — Original filename (used to detect MIME type).
  static Future<String?> uploadBytes(
    List<int> bytes,
    String fileName, {
    String folder = 'rudram',
    String? publicId,
  }) async {
    try {
      final mimeType = lookupMimeType(fileName, headerBytes: bytes.take(12).toList()) ?? 'image/jpeg';
      final parts = mimeType.split('/');

      final uri = Uri.parse('$_baseUrl/$_cloudName/image/upload');
      final request = http.MultipartRequest('POST', uri);

      request.fields['upload_preset'] = _uploadPreset;
      request.fields['folder'] = folder;
      if (publicId != null) request.fields['public_id'] = publicId;

      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          bytes,
          filename: fileName,
          contentType: MediaType(parts[0], parts[1]),
        ),
      );

      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 60),
      );
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return json['secure_url'] as String?;
      } else {
        final error = jsonDecode(response.body);
        throw Exception('Cloudinary upload failed: ${error['error']?['message'] ?? response.body}');
      }
    } catch (e) {
      // ignore: avoid_print
      print('[CloudinaryService] uploadBytes error: $e');
      return null;
    }
  }

  /// Deletes an image from Cloudinary by its public ID.
  ///
  /// ⚠️ Requires your API Secret — do NOT call this from the client directly
  /// in production. Use a backend Cloud Function or Cloudinary webhook instead.
  /// This is provided for development/admin use only.
  static Future<bool> deleteImage(String publicId) async {
    // Not implemented on client — handle deletions server-side.
    throw UnimplementedError(
      'deleteImage must be called from a backend. '
      'Use a Cloud Function or Cloudinary webhook to delete images.',
    );
  }

  /// Returns an optimised Cloudinary URL with transformation applied.
  ///
  /// Example: [toOptimisedUrl] with width=300 returns a 300px wide WebP.
  static String toOptimisedUrl(
    String originalUrl, {
    int? width,
    int? height,
    String format = 'auto',
    String quality = 'auto',
  }) {
    if (!originalUrl.contains('cloudinary.com')) return originalUrl;

    final transforms = <String>[
      if (width != null) 'w_$width',
      if (height != null) 'h_$height',
      'f_$format',
      'q_$quality',
      'c_fill',
    ].join(',');

    // Insert transformation string before /upload/ in the URL
    return originalUrl.replaceFirst('/upload/', '/upload/$transforms/');
  }

  /// Whether Cloudinary is properly configured (placeholders replaced).
  static bool get isConfigured =>
      _cloudName != 'YOUR_CLOUD_NAME' && _uploadPreset != 'YOUR_UPLOAD_PRESET';
}
