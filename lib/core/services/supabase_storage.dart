import 'package:flutter/services.dart';
import 'package:resturant_funny/core/errors/exception.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

//Servicio de supabase de almancenamiento de archivos
class SupabaseStorageService {
  static final SupabaseClient _supabase = Supabase.instance.client;

  /// Sube un archivo al bucket indicado
  static Future<String> uploadFile({
    required String bucket,
    required String path,
    required Uint8List fileBytes,
    String? contentType,
  }) async {
    try {
      final response =
          await _supabase.storage.from(bucket).uploadBinary(path, fileBytes,
              fileOptions: FileOptions(
                contentType: contentType ?? 'image/png',
                upsert: true,
              ));

      return response;
    } catch (e) {
      throw DatabaseException('Error al subir archivo: $e');
    }
  }

  /// Obtiene la URL pública del archivo
  static String getPublicUrl({
    required String bucket,
    required String path,
  }) {
    return _supabase.storage.from(bucket).getPublicUrl(path);
  }

  /// Elimina un archivo del bucket
  static Future<void> deleteFile({
    required String bucket,
    required String path,
  }) async {
    try {
      await _supabase.storage.from(bucket).remove([path]);
    } catch (e) {
      throw DatabaseException('Error al eliminar archivo: $e');
    }
  }

  /// Descarga un archivo como bytes (si necesitas mostrarlo directo en Flutter)
  static Future<Uint8List?> downloadFile({
    required String bucket,
    required String path,
  }) async {
    try {
      final response = await _supabase.storage.from(bucket).download(path);
      return response;
    } catch (e) {
      throw DatabaseException('Error al descargar archivo: $e');
    }
  }
}
