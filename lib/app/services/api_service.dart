import 'package:dio/dio.dart';
import 'package:get/get.dart' hide Response;
import 'package:pududuk_app/app/utils/env_config.dart';

class ApiService extends GetxService {
  late Dio _dio;

  @override
  void onInit() {
    super.onInit();
    _initializeDio();
  }

  void _initializeDio() {
    _dio = Dio();

    // 기본 설정
    _dio.options.connectTimeout = const Duration(seconds: 10);
    _dio.options.receiveTimeout = const Duration(seconds: 10);
    _dio.options.headers = {'Content-Type': 'application/json'};

    // TODO: 실제 서버 URL로 변경
    _dio.options.baseUrl = 'https://your-server.com/api';

    // 요청/응답 인터셉터 (로깅용)
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          print('🚀 요청: ${options.method} ${options.path}');
          print('📝 데이터: ${options.data}');
          handler.next(options);
        },
        onResponse: (response, handler) {
          print('✅ 응답: ${response.statusCode} ${response.requestOptions.path}');
          print('📥 응답 데이터: ${response.data}');
          print('📋 응답 헤더: ${response.headers.map}');
          handler.next(response);
        },
        onError: (error, handler) {
          print('❌ 에러: ${error.message}');
          print('📍 에러 응답: ${error.response?.data}');
          handler.next(error);
        },
      ),
    );
  }

  // GET 요청
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.get<T>(
        EnvConfig.apiBaseUrl + path,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  // POST 요청
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.post<T>(
        EnvConfig.apiBaseUrl + path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  // PUT 요청
  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.put<T>(
        EnvConfig.apiBaseUrl + path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  // PATCH 요청
  Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.patch<T>(
        EnvConfig.apiBaseUrl + path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  // DELETE 요청
  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.delete<T>(
        EnvConfig.apiBaseUrl + path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  // 에러 처리
  void _handleError(DioException error) {
    String message = '알 수 없는 오류가 발생했습니다.';

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        message = '네트워크 연결 시간이 초과되었습니다.';
        break;
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        if (statusCode != null) {
          if (statusCode >= 400 && statusCode < 500) {
            message = '잘못된 요청입니다. ($statusCode)';
          } else if (statusCode >= 500) {
            message = '서버 오류가 발생했습니다. ($statusCode)';
          }
        }
        break;
      case DioExceptionType.connectionError:
        message = '네트워크 연결을 확인해주세요.';
        break;
      case DioExceptionType.cancel:
        message = '요청이 취소되었습니다.';
        break;
      default:
        message = error.message ?? '알 수 없는 오류가 발생했습니다.';
    }

    // 전역 에러 처리 (필요시 스낵바 표시)
    print('API 에러: $message');
  }

  // 토큰 설정 (로그인 후 사용)
  void setAuthToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  // 토큰 제거 (로그아웃 시 사용)
  void clearAuthToken() {
    _dio.options.headers.remove('Authorization');
  }
}
