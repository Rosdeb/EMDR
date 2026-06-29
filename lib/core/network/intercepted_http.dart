import 'dart:convert';

import 'package:http/http.dart' as raw;
import 'package:jonssony/core/network/api_client.dart';

export 'package:http/http.dart' show MultipartFile, MultipartRequest, Response, StreamedResponse, BaseRequest;

Future<raw.StreamedResponse> send(raw.BaseRequest request) =>
    ApiClient.instance.send(request);

Future<raw.Response> get(Uri url, {Map<String, String>? headers}) =>
    ApiClient.instance.get(url, headers: headers);

Future<raw.Response> post(
  Uri url, {
  Map<String, String>? headers,
  Object? body,
  Encoding? encoding,
}) => ApiClient.instance.post(
  url,
  headers: headers,
  body: body,
  encoding: encoding,
);

Future<raw.Response> put(
  Uri url, {
  Map<String, String>? headers,
  Object? body,
  Encoding? encoding,
}) => ApiClient.instance.put(
  url,
  headers: headers,
  body: body,
  encoding: encoding,
);

Future<raw.Response> patch(
  Uri url, {
  Map<String, String>? headers,
  Object? body,
  Encoding? encoding,
}) => ApiClient.instance.patch(
  url,
  headers: headers,
  body: body,
  encoding: encoding,
);

Future<raw.Response> delete(
  Uri url, {
  Map<String, String>? headers,
  Object? body,
  Encoding? encoding,
}) => ApiClient.instance.delete(
  url,
  headers: headers,
  body: body,
  encoding: encoding,
);
