// lib/core/network/api_client.dart

import 'dart:convert';
import 'package:dio/dio.dart';
import '../../config/env.dart';
// Import untuk mengakses token di PreferencesHelper
import '../storage/preferences_helper.dart'; 

class ApiClient {
  final Dio dio;

  ApiClient({Dio? dioInstance})
    : dio =
          dioInstance ??
          Dio(
            BaseOptions(
              baseUrl: Env.apiBaseUrl,
              // Perbaikan Dio v5: Gunakan Duration
              connectTimeout: const Duration(milliseconds: 30000), 
              receiveTimeout: const Duration(milliseconds: 30000),
            ),
          ) {
    // Anda bisa menambahkan Interceptor di sini jika diperlukan
  }
  
  // Fungsi yang dibutuhkan oleh AuthProvider untuk mengirim token
  Future<Options> optionsWithAuth() async {
    final token = await PreferencesHelper.getAuthToken();
    return Options(
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
  }

  // Helper untuk menentukan apakah route perlu token
  Options? _getFinalOptions(String path, Options? options) {
    // Jika path BUKAN untuk auth (login, register), kirim token
    if (!path.contains('/auth/')) {
        return optionsWithAuth() as Options?; // Menunggu Future<Options>
    }
    return options;
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
        options: _getFinalOptions(path, options),
      );
      return _decodeResponse(response);
    } on DioException catch (e) { // DioError diganti DioException
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
        options: _getFinalOptions(path, options),
      );
      return _decodeResponse(response);
    } on DioException catch (e) { // DioError diganti DioException
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

  Exception _handleDioError(DioException e) { // DioError diganti DioException
    // Perbaikan Dio v5: Gunakan enum DioExceptionType yang baru
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
    return Exception(e.message);
  }
}