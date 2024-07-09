import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:stack_trace/stack_trace.dart';

class LoggingHttpClient extends http.BaseClient {
  final http.Client _inner;

  LoggingHttpClient(this._inner);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final stopwatch = Stopwatch()..start();
    final response = await _inner.send(request);

    // Read the response stream
    final bytes = await response.stream.toBytes();
    final body = utf8.decode(bytes);

    // Stop stopwatch
    stopwatch.stop();

    // Print response details
    print('''
******** HTTP Response ********
- Status Code: ${response.statusCode}
- Duration: ${stopwatch.elapsedMilliseconds}ms
- Response Body: $body
''');

    // Create a new response with the same body
    return http.StreamedResponse(
      http.ByteStream.fromBytes(bytes),
      response.statusCode,
      contentLength: response.contentLength,
      request: response.request,
      headers: response.headers,
      reasonPhrase: response.reasonPhrase,
      isRedirect: response.isRedirect,
      persistentConnection: response.persistentConnection,
    );
  }
}

// Global instance of the logging client
final LoggingHttpClient _client = LoggingHttpClient(http.Client());

void _printRequest(String method, Uri url, String frame) {
  List<String> frameList = frame.split(' ');

  print('''
******** HTTP Request ********
$method - $url
- Location: $frame
- File: ${frameList.first}
- Method: ${frameList.last}
- Line: ${frameList[1]}
''');
}

@override
Future<http.Response> get(Uri url, {Map<String, String>? headers}) async {
  final frame = Trace.current().frames[1];
  _printRequest('GET', url, frame.toString());
  return _client.get(url, headers: headers);
}

@override
Future<http.Response> post(Uri url, {Map<String, String>? headers, Object? body, Encoding? encoding}) async {
  final frame = Trace.current().frames[1];
  _printRequest('POST', url, frame.toString());
  return _client.post(url, headers: headers, body: body, encoding: encoding);
}

@override
Future<http.Response> put(Uri url, {Map<String, String>? headers, Object? body, Encoding? encoding}) async {
  final frame = Trace.current().frames[1];
  _printRequest('PUT', url, frame.toString());
  return _client.put(url, headers: headers, body: body, encoding: encoding);
}

@override
Future<http.Response> delete(Uri url, {Map<String, String>? headers, Object? body, Encoding? encoding}) async {
  final frame = Trace.current().frames[1];
  _printRequest('DELETE', url, frame.toString());
  return _client.delete(url, headers: headers, body: body, encoding: encoding);
}

@override
Future<String> read(Uri url, {Map<String, String>? headers}) async {
  final frame = Trace.current().frames[1];
  _printRequest('READ', url, frame.toString());
  return _client.read(url, headers: headers);
}

@override
Future<http.Response> head(Uri url, {Map<String, String>? headers}) async {
  final frame = Trace.current().frames[1];
  _printRequest('HEAD', url, frame.toString());
  return _client.head(url, headers: headers);
}

@override
Future<http.Response> patch(Uri url, {Map<String, String>? headers, Object? body, Encoding? encoding}) async {
  final frame = Trace.current().frames[1];
  _printRequest('PATCH', url, frame.toString());
  return _client.patch(url, headers: headers, body: body, encoding: encoding);
}