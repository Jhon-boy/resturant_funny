import 'dart:typed_data';

import 'package:dartz/dartz.dart';
import 'package:resturant_funny/core/utils/either.dart';

abstract class ImagesRepository {
  Future<Either<Failure, String>> uploadFile({
    required String path,
    required Uint8List bytes,
    String bucket = 'imagenes',
    String? contentType,
  });
  Future<Either<Failure, String>> getPublicUrl({
    required String path,
    String bucket = 'imagenes',
  });
  Future<Either<Failure, bool>> deleteFile({
    required String path,
    String bucket = 'imagenes',
  });
  Future<Either<Failure, Uint8List>> downloadFile({
    required String path,
    String bucket = 'imagenes',
  });
}
