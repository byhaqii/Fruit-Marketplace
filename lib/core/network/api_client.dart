// lib/core/network/api_client.dart
import 'dart:convert';
import 'package:dio/dio.dart'; // Import Dio

import '../../config/env.dart';

class ApiClient {
  final Dio dio;

  ApiClient({Dio? dioInstance})
    : dio =
          dioInstance ??
          Dio(
            BaseOptions(
              baseUrl: Env.apiBaseUrl,
              // PERBAIKAN 1: Gunakan Duration()
              connectTimeout: const Duration(milliseconds: 30000), 
              receiveTimeout: const Duration(milliseconds: 30000), 
            ),
          ) {
    // ...existing code...
  }

  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
      );
      return _decodeResponse(response);
    // Ubah DioError menjadi DioException
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<dynamic> post(
    String path,
    dynamic data, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return _decodeResponse(response);
    // Ubah DioError menjadi DioException
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  dynamic _decodeResponse(Response response) {
    final data = response.data;
    if (data == null) return null;
    if (data is String) {
      try {
        return jsonDecode(data);
      } catch (_) {
        return data;
      }
    }
    return data;
  }

  // Ubah DioError menjadi DioException
  Exception _handleDioError(DioException e) {
    // PERBAIKAN 2: Gunakan DioExceptionType dan perbarui nama konstanta
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return Exception('Request timed out');
    }
    
    if (e.response != null) {
      final status = e.response?.statusCode;
      final respData = e.response?.data;
      return Exception(
        'Request failed ($status): ${respData is String ? respData : jsonEncode(respData)}',
      );
    }
    // Menggunakan e.message (non-nullable di DioException)
    return Exception(e.message); 
  }
}