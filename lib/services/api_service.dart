import 'package:dio/dio.dart';
import 'package:voice_chat_app/app/config.dart';
import 'package:voice_chat_app/core/utils/logger.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  late Dio _dio;
  final _storage = const FlutterSecureStorage();

  ApiService() {
    _initDio();
  }

  void _initDio() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.apiBaseUrl,
        connectTimeout: Duration(milliseconds: AppConfig.connectTimeout),
        receiveTimeout: Duration(milliseconds: AppConfig.receiveTimeout),
        contentType: 'application/json',
        headers: {'Accept': 'application/json'},
      ),
    );

    // إضافة اعتراضات للطلبات
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // إضافة رمز المصادقة إلى الطلب إذا كان موجوداً
          final token = await _storage.read(key: AppConfig.authTokenKey);
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          if (AppConfig.debugMode) {
            AppLogger.log(
              'API Request: ${options.method} ${options.path}',
              LogLevel.debug,
            );
          }

          return handler.next(options);
        },
        onResponse: (response, handler) {
          if (AppConfig.debugMode) {
            AppLogger.log(
              'API Response: ${response.statusCode}',
              LogLevel.debug,
            );
          }

          return handler.next(response);
        },
        onError: (DioException e, handler) {
          AppLogger.log('API Error: ${e.message}', LogLevel.error);

          // يمكن إضافة معالجة الأخطاء المخصصة هنا
          return handler.next(e);
        },
      ),
    );
  }

  // طرق API العامة
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      return await _dio.get(path, queryParameters: queryParameters);
    } catch (e) {
      AppLogger.log('GET Error: $path - $e', LogLevel.error);
      rethrow;
    }
  }

  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      return await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
      );
    } catch (e) {
      AppLogger.log('POST Error: $path - $e', LogLevel.error);
      rethrow;
    }
  }

  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      return await _dio.put(path, data: data, queryParameters: queryParameters);
    } catch (e) {
      AppLogger.log('PUT Error: $path - $e', LogLevel.error);
      rethrow;
    }
  }

  Future<Response> delete(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      return await _dio.delete(path, queryParameters: queryParameters);
    } catch (e) {
      AppLogger.log('DELETE Error: $path - $e', LogLevel.error);
      rethrow;
    }
  }

  // تسجيل الدخول
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await post(
        '/auth/login',
        data: {'email': email, 'password': password},
      );

      if (response.statusCode == 200) {
        final token = response.data['token'];
        await _storage.write(key: AppConfig.authTokenKey, value: token);
        return response.data;
      } else {
        throw Exception('فشل تسجيل الدخول');
      }
    } catch (e) {
      AppLogger.log('Login Error: $e', LogLevel.error);
      rethrow;
    }
  }

  // تسجيل الخروج
  Future<void> logout() async {
    try {
      await post('/auth/logout');
      await _storage.delete(key: AppConfig.authTokenKey);
    } catch (e) {
      AppLogger.log('Logout Error: $e', LogLevel.error);
      // نحذف الرمز المميز حتى لو فشل الاتصال بالخادم
      await _storage.delete(key: AppConfig.authTokenKey);
    }
  }
}
