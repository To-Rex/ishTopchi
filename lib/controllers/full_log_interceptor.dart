import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class FullLogInterceptor extends Interceptor {
  static const int _chunkSize = 800;

  void _printLong(String text) {
    for (int i = 0; i < text.length; i += _chunkSize) {
      debugPrint(text.substring(
        i,
        i + _chunkSize > text.length ? text.length : i + _chunkSize,
      ));
    }
  }

  String _prettyJson(dynamic data) {
    try {
      return const JsonEncoder.withIndent('  ').convert(data);
    } catch (_) {
      return data.toString();
    }
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    debugPrint('┌────── REQUEST ──────');
    debugPrint('${options.method} ${options.uri}');
    debugPrint('Headers: ${options.headers}');
    if (options.data != null) {
      _printLong('Body:\n${_prettyJson(options.data)}');
    }
    debugPrint('└────────────────────');
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    debugPrint('┌────── RESPONSE ──────');
    debugPrint(
      '${response.requestOptions.method} ${response.requestOptions.uri}');
    debugPrint('Status: ${response.statusCode}');
    _printLong('Data:\n${_prettyJson(response.data)}');
    debugPrint('└─────────────────────');
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    debugPrint('┌────── ERROR ──────');
    debugPrint(
      '${err.requestOptions.method} ${err.requestOptions.uri}');
    debugPrint('Message: ${err.message}');
    if (err.response?.data != null) {
      _printLong('Error Data:\n${_prettyJson(err.response?.data)}');
    }
    debugPrint('└──────────────────');
    super.onError(err, handler);
  }
}
