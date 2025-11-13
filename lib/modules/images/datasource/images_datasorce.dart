import 'dart:typed_data';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:resturant_funny/core/services/supabase_storage.dart';
import 'package:resturant_funny/core/utils/either.dart';
import 'package:resturant_funny/modules/images/repository/images_repository.dart';

class ImagesDataSource implements ImagesRepository {
  const ImagesDataSource();

  @override
  Future<Either<Failure, bool>> deleteFile({
    required String path,
    String bucket = 'imagenes',
  }) async {
    try {
      await SupabaseStorageService.deleteFile(bucket: bucket, path: path);
      return const Right(true);
    } catch (e) {
      return Left(ServerFailure('No se pudo eliminar el archivo: $e'));
    }
  }

  @override
  Future<Either<Failure, Uint8List>> downloadFile({
    required String path,
    String bucket = 'imagenes',
  }) async {
    try {
      final bytes = await SupabaseStorageService.downloadFile(
        bucket: bucket,
        path: path,
      );
      if (bytes == null) {
        return const Left(NotFoundFailure('Archivo no encontrado en storage'));
      }
      return Right(bytes);
    } catch (e) {
      return Left(ServerFailure('No se pudo descargar el archivo: $e'));
    }
  }

  @override
  Future<Either<Failure, String>> getPublicUrl({
    required String path,
    String bucket = 'imagenes',
  }) async {
    try {
      final url = SupabaseStorageService.getPublicUrl(
        bucket: bucket,
        path: path,
      );
      return Right(url);
    } catch (e) {
      debugPrint('Error: $e');
      return Left(ServerFailure('No se pudo obtener la URL pública: $e'));
    }
  }

  @override
  Future<Either<Failure, String>> uploadFile({
    required String path,
    required Uint8List bytes,
    String bucket = 'imagenes',
    String? contentType,
  }) async {
    try {
      final storagePath = await SupabaseStorageService.uploadFile(
        bucket: bucket,
        path: path,
        fileBytes: bytes,
        contentType: contentType,
      );
      return Right(storagePath);
    } catch (e) {
      return Left(ServerFailure('No se pudo subir el archivo: $e'));
    }
  }
}
