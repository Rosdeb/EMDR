import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:jonssony/core/network/network_controller.dart';
import 'package:jonssony/healper/route.dart';
import 'package:jonssony/services/app_url.dart';

class ApiClient {
  ApiClient._();

  static final ApiClient instance = ApiClient._();
  static const Duration _requestTimeout = Duration(seconds: 30);
  static const String _accessTokenKey = 'auth_token';
  static const String _refreshTokenKey = 'auth_refresh_token';

  final http.Client _client = http.Client();
  final GetStorage _storage = GetStorage();
  Future<bool>? _refreshFuture;

  Future<http.Response> get(Uri url, {Map<String, String>? headers}) =>
      _request('GET', url, headers: headers);

  Future<http.Response> post(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
  }) => _request('POST', url, headers: headers, body: body, encoding: encoding);

  Future<http.Response> put(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
  }) => _request('PUT', url, headers: headers, body: body, encoding: encoding);

  Future<http.Response> patch(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
  }) =>
      _request('PATCH', url, headers: headers, body: body, encoding: encoding);

  Future<http.Response> delete(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
  }) =>
      _request('DELETE', url, headers: headers, body: body, encoding: encoding);
  Future<http.StreamedResponse> send(
    http.BaseRequest request, {
    bool retriedAfterRefresh = false,
    bool retriedAfterOffline = false,
  }) async {
    try {
      final headers = _authenticatedHeaders(request.url, request.headers);
      request.headers.clear();
      request.headers.addAll(headers);

      final response = await _client.send(request).timeout(_requestTimeout);

      if (response.statusCode == 401 &&
          _isBackendUrl(request.url) &&
          !_isAuthUrl(request.url) &&
          !retriedAfterRefresh) {
        final refreshed = await _refreshAccessToken();
        if (refreshed) {
          // Re-apply headers with the newly refreshed token
          final newHeaders = _authenticatedHeaders(request.url, request.headers);
          request.headers.clear();
          request.headers.addAll(newHeaders);
          // Standard streamed requests cannot be re-sent if the stream is consumed,
          // but we still try to re-send in case it is cloneable or we want to attempt it.
        }
        _expireSession();
      }

      _networkController?.markOnline();
      return response;
    } on Object catch (error) {
      if (!_isNetworkFailure(error) || retriedAfterOffline) rethrow;
      final network = _networkController;
      if (network == null) rethrow;
      network.markOffline();
      await network.waitUntilOnline();
      return send(
        request,
        retriedAfterRefresh: retriedAfterRefresh,
        retriedAfterOffline: true,
      );
    }
  }


  Future<http.Response> _request(
    String method,
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
    bool retriedAfterRefresh = false,
    bool retriedAfterOffline = false,
  }) async {
    try {
      final response = await _send(
        method,
        url,
        headers: _authenticatedHeaders(url, headers),
        body: body,
        encoding: encoding,
      ).timeout(_requestTimeout);

      if (response.statusCode == 401 &&
          _isBackendUrl(url) &&
          !_isAuthUrl(url) &&
          !retriedAfterRefresh) {
        final refreshed = await _refreshAccessToken();
        if (refreshed) {
          return _request(
            method,
            url,
            headers: headers,
            body: body,
            encoding: encoding,
            retriedAfterRefresh: true,
            retriedAfterOffline: retriedAfterOffline,
          );
        }
        _expireSession();
      }

      _networkController?.markOnline();
      return response;
    } on Object catch (error) {
      if (!_isNetworkFailure(error) || retriedAfterOffline) rethrow;
      final network = _networkController;
      if (network == null) rethrow;
      network.markOffline();
      await network.waitUntilOnline();
      return _request(
        method,
        url,
        headers: headers,
        body: body,
        encoding: encoding,
        retriedAfterRefresh: retriedAfterRefresh,
        retriedAfterOffline: true,
      );
    }
  }

  Future<http.Response> _send(
    String method,
    Uri url, {
    required Map<String, String> headers,
    Object? body,
    Encoding? encoding,
  }) {
    switch (method) {
      case 'POST':
        return _client.post(
          url,
          headers: headers,
          body: body,
          encoding: encoding,
        );
      case 'PUT':
        return _client.put(
          url,
          headers: headers,
          body: body,
          encoding: encoding,
        );
      case 'PATCH':
        return _client.patch(
          url,
          headers: headers,
          body: body,
          encoding: encoding,
        );
      case 'DELETE':
        return _client.delete(
          url,
          headers: headers,
          body: body,
          encoding: encoding,
        );
      default:
        return _client.get(url, headers: headers);
    }
  }

  Map<String, String> _authenticatedHeaders(
    Uri url,
    Map<String, String>? headers,
  ) {
    final result = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      ...?headers,
    };
    if (!_isBackendUrl(url)) return result;

    if (!_isAuthUrl(url)) {
      result.removeWhere((key, _) => key.toLowerCase() == 'authorization');
      final token = _storage.read<String>(_accessTokenKey)?.trim() ?? '';
      if (token.isNotEmpty) result['Authorization'] = 'Bearer $token';
    }
    return result;
  }

  Future<bool> _refreshAccessToken() {
    final activeRefresh = _refreshFuture;
    if (activeRefresh != null) return activeRefresh;

    final refresh = _performRefresh().whenComplete(() {
      _refreshFuture = null;
    });
    _refreshFuture = refresh;
    return refresh;
  }

  Future<bool> _performRefresh() async {
    final refreshToken = _storage.read<String>(_refreshTokenKey)?.trim() ?? '';
    if (refreshToken.isEmpty) return false;

    try {
      final response = await _client
          .post(
            Uri.parse('${AppUrl.baseUrl}/auth/refresh-token'),
            headers: const {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({'refreshToken': refreshToken}),
          )
          .timeout(_requestTimeout);
      final decoded = jsonDecode(response.body);
      final body = decoded is Map
          ? Map<String, dynamic>.from(decoded)
          : <String, dynamic>{};
      final data = body['data'] is Map
          ? Map<String, dynamic>.from(body['data'] as Map)
          : body;
      final accessToken = data['accessToken']?.toString().trim() ?? '';
      if (response.statusCode < 200 ||
          response.statusCode >= 300 ||
          body['success'] != true ||
          accessToken.isEmpty) {
        return false;
      }

      await _storage.write(_accessTokenKey, accessToken);
      final rotatedRefreshToken = data['refreshToken']?.toString().trim() ?? '';
      if (rotatedRefreshToken.isNotEmpty) {
        await _storage.write(_refreshTokenKey, rotatedRefreshToken);
      }
      return true;
    } on Object catch (error) {
      if (_isNetworkFailure(error) && _networkController != null) {
        _networkController!.markOffline();
        await _networkController!.waitUntilOnline();
        return _performRefresh();
      }
      debugPrint('Access-token refresh failed: $error');
      return false;
    }
  }

  bool _isBackendUrl(Uri url) {
    final backend = Uri.parse(AppUrl.baseUrl);
    return url.scheme == backend.scheme && url.host == backend.host;
  }

  bool _isAuthUrl(Uri url) => url.path.contains('/auth/');

  bool _isNetworkFailure(Object error) {
    if (error is SocketException || error is http.ClientException) return true;
    if (error is TimeoutException)
      return _networkController?.isOffline.value == true;
    return false;
  }

  NetworkController? get _networkController =>
      Get.isRegistered<NetworkController>()
      ? Get.find<NetworkController>()
      : null;

  void _expireSession() {
    _storage.remove(_accessTokenKey);
    _storage.remove(_refreshTokenKey);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Get.currentRoute != RouteHelper.login) {
        Get.offAllNamed(RouteHelper.login);
        Get.snackbar(
          'Session expired',
          'Please sign in again.',
          snackPosition: SnackPosition.TOP,
        );
      }
    });
  }
}
