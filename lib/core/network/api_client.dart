// lib/core/network/api_client.dart
import 'dart:convert';
import 'package:dio/dio.dart'; // Pastikan Dio diimpor
import '../../config/env.dart';
import '../storage/preferences_helper.dart'; 

class ApiClient {
  final Dio dio;

  ApiClient({Dio? dioInstance})
    : dio =
          dioInstance ??
          Dio(
            BaseOptions(
              baseUrl: Env.apiBaseUrl,
              connectTimeout: const Duration(milliseconds: 30000), 
              receiveTimeout: const Duration(milliseconds: 30000),
            ),
          ) {
    // ...
  }
  
  Future<Options> optionsWithAuth() async {
    final token = await PreferencesHelper.getAuthToken();
    return Options(
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
  }

  Future<Options?> _getFinalOptions(String path, Options? options) async {
    if (options != null) return options;
    if (path == '/auth/login' || path == '/auth/register') {
      return null; 
    }
    return await optionsWithAuth();
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
        options: await _getFinalOptions(path, options),
      );
      return _decodeResponse(response);
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
      
      // --- PERBAIKAN LOGIKA PENGIRIMAN DATA ---
      dynamic postData = data;
      // Jika ini adalah login atau register, ubah Map menjadi FormData
      // agar backend PHP dapat membacanya sebagai form-data.
      if ((path == '/auth/login' || path == '/auth/register') && data is Map<String, dynamic>) {
        postData = FormData.fromMap(data); 
      }
      // --- AKHIR PERBAIKAN ---

      final response = await dio.post(
        path,
        data: postData, // Gunakan postData yang sudah diformat
        queryParameters: queryParameters,
        options: await _getFinalOptions(path, options),
      );
      return _decodeResponse(response);
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

  Exception _handleDioError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout || 
        e.type == DioExceptionType.receiveTimeout) {
      return Exception('Request timed out. Pastikan IP/Firewall benar.');
    }
    if (e.response != null) {
      final status = e.response?.statusCode;
      final respData = e.response?.data;
      
      String errorMessage = 'Terjadi kesalahan tidak dikenal.';
      try {
        if (respData is Map<String, dynamic> && respData.containsKey('message')) {
            errorMessage = respData['message'];
        } else if (respData is String) {
            errorMessage = respData;
        }
      } catch (_) {
        // Abaikan jika decoding gagal
      }
      
      return Exception(
        'Permintaan gagal ($status): $errorMessage',
      );
    }
    return Exception(e.message);
  }
}