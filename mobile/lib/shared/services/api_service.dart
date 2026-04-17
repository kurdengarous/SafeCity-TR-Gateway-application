import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:turkiye_cevre_guvenligi/shared/models/api_response.dart';

class ApiService {
  late final Dio _dio;

  ApiService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: dotenv.env['API_URL'] ?? 'http://localhost:3000',
        connectTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 20),
        headers: {
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          print('[API Request] ${options.method} ${options.uri}');
          return handler.next(options);
        },
        onResponse: (response, handler) {
          print('[API Response] ${response.statusCode} ${response.requestOptions.uri}');
          return handler.next(response);
        },
        onError: (error, handler) {
          print('[API Error] ${error.message} ${error.requestOptions.uri}');
          return handler.next(error);
        },
      ),
    );
  }

  Future<ApiResponse<T>> get<T>(
    String url, {
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    ResponseType responseType = ResponseType.json,
    bool followRedirects = true,
    required T Function(dynamic data) parser,
  }) async {
    try {
      final response = await _dio.get(
        url,
        queryParameters: queryParameters,
        options: Options(
          headers: headers,
          responseType: responseType,
          followRedirects: followRedirects,
          validateStatus: (status) => status != null && status >= 200 && status < 400,
        ),
      );
      return ApiResponse.success(parser(response.data));
    } on DioException catch (e) {
      return ApiResponse.error(_handleDioError(e));
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  Future<ApiResponse<T>> post<T>(
    String url, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    ResponseType responseType = ResponseType.json,
    bool followRedirects = true,
    required T Function(dynamic data) parser,
  }) async {
    try {
      final response = await _dio.post(
        url,
        data: data,
        queryParameters: queryParameters,
        options: Options(
          headers: headers,
          responseType: responseType,
          followRedirects: followRedirects,
          validateStatus: (status) => status != null && status >= 200 && status < 400,
        ),
      );
      return ApiResponse.success(parser(response.data));
    } on DioException catch (e) {
      return ApiResponse.error(_handleDioError(e));
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  String _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return 'Bağlantı zaman aşımına uğradı';
      case DioExceptionType.receiveTimeout:
        return 'Sunucu yanıt vermedi';
      case DioExceptionType.badResponse:
        return 'Sunucu hatası: ${error.response?.statusCode}';
      case DioExceptionType.connectionError:
        return 'İnternet bağlantısı yok';
      case DioExceptionType.cancel:
        return 'İstek iptal edildi';
      default:
        return error.message ?? 'Bilinmeyen hata oluştu';
    }
  }
}
