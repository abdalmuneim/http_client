import 'dart:developer';

import 'package:http/http.dart' as http;
import 'dart:convert';
// ignore: depend_on_referenced_packages
import 'package:stack_trace/stack_trace.dart';

class LoggingHttpClient extends http.BaseClient {
  final http.Client inner = http.Client();

  // ### [packageName] It is the name of the project.
  // You can find it in the [yaml] file. In the first line, you will find the name
  // or you can use function [getName(ymalPath)] to get name automatcly
  final String packageName;

  // ### [isShowResponse] is optional variable to show response or not
  // Make this an false when building the [product] or don't pass it on
  bool showResponse;

  LoggingHttpClient(
      {
      // required this.inner,
      required this.packageName,
      this.showResponse = true});

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final stopwatch = Stopwatch()..start();
    final response = await inner.send(request);

    // Read the response stream
    final bytes = await response.stream.toBytes();
    final body = utf8.decode(bytes);

    // Stop stopwatch
    stopwatch.stop();

    // Print response details
    if (showResponse) {
      log('''
******** HTTP Response ********
- Status Code: ${response.statusCode}
- Duration: ${stopwatch.elapsedMilliseconds}ms
- Response Body: $body

******** END Response *********
*******************************
''');
    }
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

// Global instance of the logging client
  // final LoggingHttpClient globalClient = LoggingHttpClient(inner: sl());

  void _printRequest(String method, Uri url, String frame, dynamic repose) {
    List<String> frameList = frame.split(' ');
    if (showResponse) {
      log("""
******** HTTP Request ********
$method - $url
- Location: ${frame.split("package:$packageName").last}
- File: ${frameList.first}
- Method: ${frameList.last}
- Line: ${frameList[1]}
- Response Body: ${repose is http.Response ? jsonDecode(repose.body) : repose};
******** END Request ********
*****************************
""");
    }
  }

  @override
  Future<http.Response> get(Uri url, {Map<String, String>? headers}) async {
    final frame = Trace.current().frames[1];
    final response = await inner.get(url, headers: headers);
    _printRequest('GET', url, frame.toString(), response);
    return response;
  }

  @override
  Future<http.Response> post(Uri url,
      {Map<String, String>? headers, Object? body, Encoding? encoding}) async {
    final frame = Trace.current().frames[1];

    final response =
        await inner.post(url, headers: headers, body: body, encoding: encoding);
    _printRequest('POST', url, frame.toString(), response);
    return response;
  }

  @override
  Future<http.Response> put(Uri url,
      {Map<String, String>? headers, Object? body, Encoding? encoding}) async {
    final frame = Trace.current().frames[1];
    final response =
        await inner.put(url, headers: headers, body: body, encoding: encoding);
    _printRequest('PUT', url, frame.toString(), response);
    return response;
  }

  @override
  Future<http.Response> delete(Uri url,
      {Map<String, String>? headers, Object? body, Encoding? encoding}) async {
    final frame = Trace.current().frames[1];
    final response = await inner.delete(url,
        headers: headers, body: body, encoding: encoding);
    _printRequest('DELETE', url, frame.toString(), response);
    return response;
  }

  @override
  Future<String> read(Uri url, {Map<String, String>? headers}) async {
    final frame = Trace.current().frames[1];
    final String response = await inner.read(url, headers: headers);
    _printRequest('READ', url, frame.toString(), response);
    return response;
  }

  @override
  Future<http.Response> head(Uri url, {Map<String, String>? headers}) async {
    final frame = Trace.current().frames[1];
    final response = await inner.head(url, headers: headers);
    _printRequest('HEAD', url, frame.toString(), response);
    return response;
  }

  @override
  Future<http.Response> patch(Uri url,
      {Map<String, String>? headers, Object? body, Encoding? encoding}) async {
    final frame = Trace.current().frames[1];
    final response = await inner.patch(url,
        headers: headers, body: body, encoding: encoding);
    _printRequest('PATCH', url, frame.toString(), response);
    return response;
  }
}
