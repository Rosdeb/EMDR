import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:jonssony/services/app_url.dart';

const _defaultCategoryName = 'Bilateral Stimulation Visual icon';
const _defaultFiles = ['assets/images/Butterfly Lottie Animation.gif'];

Future<void> main(List<String> args) async {
  final token =
      _argValue(args, '--token') ?? Platform.environment['AUTH_TOKEN'];
  final baseUrl = (_argValue(args, '--base-url') ?? AppUrl.baseUrl)
      .replaceFirst(RegExp(r'/$'), '');
  final categoryName = _argValue(args, '--category') ?? _defaultCategoryName;
  final files = _argValues(args, '--file');

  if (token == null || token.trim().isEmpty) {
    _fail('Missing token. Pass --token <access-token> or set AUTH_TOKEN.');
  }

  final filePaths = files.isEmpty ? _defaultFiles : files;
  final categoryId = await _resolveCategoryId(
    baseUrl: baseUrl,
    token: token,
    categoryName: categoryName,
  );

  stdout.writeln('Uploading ${filePaths.length} object file(s)...');
  for (final filePath in filePaths) {
    await _uploadMedia(
      baseUrl: baseUrl,
      token: token,
      categoryId: categoryId,
      filePath: filePath,
    );
  }
  stdout.writeln('Done.');
}

Future<String> _resolveCategoryId({
  required String baseUrl,
  required String token,
  required String categoryName,
}) async {
  final response = await http.get(
    Uri.parse('$baseUrl/categories'),
    headers: _headers(token),
  );
  final body = _decodeResponse(response);
  final data = body['data'];

  if (data is! List) {
    _fail('Category response did not include a data list.');
  }

  final category = data.cast<dynamic>().firstWhere(
    (item) =>
        item is Map &&
        item['categoryName']?.toString().trim().toLowerCase() ==
            categoryName.trim().toLowerCase(),
    orElse: () => null,
  );

  if (category is! Map) {
    _fail('Category "$categoryName" was not found.');
  }

  final id = (category['_id'] ?? category['id'])?.toString();
  if (id == null || id.isEmpty) {
    _fail('Category "$categoryName" did not include an id.');
  }

  stdout.writeln('Category: $categoryName ($id)');
  return id;
}

Future<void> _uploadMedia({
  required String baseUrl,
  required String token,
  required String categoryId,
  required String filePath,
}) async {
  final file = File(filePath);
  if (!file.existsSync()) {
    _fail('File not found: $filePath');
  }

  final request = http.MultipartRequest('POST', Uri.parse('$baseUrl/media'));
  request.headers.addAll({
    'Authorization': 'Bearer $token',
    'Accept': 'application/json',
  });
  request.fields['categoryId'] = categoryId;
  request.files.add(await http.MultipartFile.fromPath('file', file.path));

  final streamedResponse = await request.send();
  final response = await http.Response.fromStream(streamedResponse);
  _decodeResponse(response);
  stdout.writeln('Uploaded: $filePath');
}

Map<String, String> _headers(String token) => {
  'Content-Type': 'application/json',
  'Accept': 'application/json',
  'Authorization': 'Bearer $token',
};

Map<String, dynamic> _decodeResponse(http.Response response) {
  Map<String, dynamic> body;
  try {
    body = jsonDecode(response.body) as Map<String, dynamic>;
  } catch (_) {
    _fail('Invalid server response (${response.statusCode}): ${response.body}');
  }

  if (response.statusCode < 200 || response.statusCode >= 300) {
    final message = body['message'] ?? body['error'] ?? response.body;
    _fail('Request failed (${response.statusCode}): $message');
  }

  return body;
}

String? _argValue(List<String> args, String name) {
  final index = args.indexOf(name);
  if (index == -1 || index + 1 >= args.length) return null;
  return args[index + 1];
}

List<String> _argValues(List<String> args, String name) {
  final values = <String>[];
  for (var i = 0; i < args.length; i++) {
    if (args[i] == name && i + 1 < args.length) {
      values.add(args[i + 1]);
      i++;
    }
  }
  return values;
}

Never _fail(String message) {
  stderr.writeln(message);
  exit(1);
}
