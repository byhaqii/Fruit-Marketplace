// lib/core/network/api_client.dart

import 'dart:convert';
import 'package:dio/dio.dart';
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
    // Menambahkan Interceptor opsional untuk logging jika diperlukan
  }
  
  Future<Options> optionsWithAuth() async {
    final token = await PreferencesHelper.getAuthToken();
    return Options(
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json', // Tambahkan ini agar Backend merespon JSON
      },
    );
  }

  // Helper untuk menentukan apakah route perlu token
  Future<Options?> _getFinalOptions(String path, Options? options) async {
    if (options != null) return options;
    // Jika path BUKAN untuk auth (login, register), kirim token
    if (!path.contains('/auth/')) {
        return await optionsWithAuth();
    }
    return null;
  }

  // --- GET ---
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

  // --- POST ---
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
        options: await _getFinalOptions(path, options),
      );
      return _decodeResponse(response);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // --- PUT (BARU DITAMBAHKAN) ---
  Future<dynamic> put(
    String path,
    dynamic data, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: await _getFinalOptions(path, options),
      );
      return _decodeResponse(response);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // --- DELETE (BARU DITAMBAHKAN) ---
  Future<dynamic> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await dio.delete(
        path,
        data: data,
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