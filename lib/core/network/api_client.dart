import 'dart:convert';
import 'package:dio/dio.dart';
import '../../config/env.dart';

class ApiClient {
  final Dio dio;

  ApiClient({Dio? dioInstance})
    : dio =
          dioInstance ??
          Dio(
            BaseOptions(
              baseUrl: Env.apiBaseUrl,
              connectTimeout: 30000,
              receiveTimeout: 30000,
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
    } on DioError catch (e) {
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
    } on DioError catch (e) {
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

  Exception _handleDioError(DioError e) {
    if (e.type == DioErrorType.connectTimeout ||
        e.type == DioErrorType.receiveTimeout) {
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
