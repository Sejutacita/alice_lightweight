import 'dart:convert';

import 'package:alice_lightweight/helper/alice_conversion_helper.dart';
import 'package:alice_lightweight/model/alice_http_call.dart';
import 'package:alice_lightweight/utils/alice_parser.dart';

class AliceSaveHelper {
  static JsonEncoder _encoder = new JsonEncoder.withIndent('  ');

  static Future<String> _buildAliceLog() async {
    StringBuffer stringBuffer = StringBuffer();
    stringBuffer.write("Alice - HTTP Inspector\n");
    stringBuffer.write("Generated: " + DateTime.now().toIso8601String() + "\n");
    stringBuffer.write("\n");
    return stringBuffer.toString();
  }

  static String _buildCallLog(AliceHttpCall call) {
    StringBuffer stringBuffer = StringBuffer();
    stringBuffer.write("===========================================\n");
    stringBuffer.write("Id: ${call.id}\n");
    stringBuffer.write("============================================\n");
    stringBuffer.write("--------------------------------------------\n");
    stringBuffer.write("General data\n");
    stringBuffer.write("--------------------------------------------\n");
    stringBuffer.write("Server: ${call.server} \n");
    stringBuffer.write("Method: ${call.method} \n");
    stringBuffer.write("Endpoint: ${call.endpoint} \n");
    stringBuffer.write("Client: ${call.client} \n");
    stringBuffer
        .write("Duration ${AliceConversionHelper.formatTime(call.duration)}\n");
    stringBuffer.write("Secured connection: ${call.secure}\n");
    stringBuffer.write("Completed: ${!call.loading} \n");
    stringBuffer.write("--------------------------------------------\n");
    stringBuffer.write("Request\n");
    stringBuffer.write("--------------------------------------------\n");
    stringBuffer.write("Request time: ${call.request?.time}\n");
    stringBuffer.write("Request content type: ${call.request?.contentType}\n");
    stringBuffer
        .write("Request cookies: ${_encoder.convert(call.request?.cookies)}\n");
    stringBuffer
        .write("Request headers: ${_encoder.convert(call.request?.headers)}\n");
    if (call.request?.queryParameters != null &&
        call.request!.queryParameters.length > 0) {
      stringBuffer.write(
          "Request query params: ${_encoder.convert(call.request?.queryParameters)}\n");
    }
    stringBuffer.write(
        "Request size: ${AliceConversionHelper.formatBytes(call.request?.size ?? 0)}\n");
    stringBuffer.write(
        "Request body: ${AliceParser.formatBody(call.request?.body, AliceParser.getContentType(call.request?.headers ?? {}))}\n");
    stringBuffer.write("--------------------------------------------\n");
    stringBuffer.write("Response\n");
    stringBuffer.write("--------------------------------------------\n");
    stringBuffer.write("Response time: ${call.response?.time}\n");
    stringBuffer.write("Response status: ${call.response?.status}\n");
    stringBuffer.write(
        "Response size: ${AliceConversionHelper.formatBytes(call.response?.size ?? 0)}\n");
    stringBuffer.write(
        "Response headers: ${_encoder.convert(call.response?.headers)}\n");
    stringBuffer.write(
        "Response body: ${AliceParser.formatBody(call.response?.body, AliceParser.getContentType(call.response?.headers ?? {}))}\n");
    if (call.error != null) {
      stringBuffer.write("--------------------------------------------\n");
      stringBuffer.write("Error\n");
      stringBuffer.write("--------------------------------------------\n");
      stringBuffer.write("Error: ${call.error?.error}\n");
      if (call.error?.stackTrace != null) {
        stringBuffer.write("Error stacktrace: ${call.error?.stackTrace}\n");
      }
    }
    stringBuffer.write("--------------------------------------------\n");
    stringBuffer.write("Curl\n");
    stringBuffer.write("--------------------------------------------\n");
    stringBuffer.write("${call.getCurlCommand()}");
    stringBuffer.write("\n");
    stringBuffer.write("==============================================\n");
    stringBuffer.write("\n");

    return stringBuffer.toString();
  }

  static String _buildLogMap(AliceHttpCall call) {
    final requestHeader = AliceParser.formatBody(call.request?.headers,
        AliceParser.getContentType(call.request?.headers ?? {}));
    final requestBody = AliceParser.formatBody(call.request?.body,
        AliceParser.getContentType(call.request?.headers ?? {}));
    final responseBody = AliceParser.formatBody(call.response?.body,
        AliceParser.getContentType(call.response?.headers ?? {}));

    final callMap = {
      "server": call.server,
      "method": call.method,
      "endpoint": call.endpoint,
      "duration": AliceConversionHelper.formatTime(call.duration),
      "request": {
        if (call.request?.headers.toString().isNotEmpty ?? false) ...{
          "headers": jsonDecode(requestHeader)
        },
        if (call.request?.body.toString().isNotEmpty ?? false) ...{
          "body": jsonDecode(requestBody)
        },
        "queryParameters": call.request?.queryParameters,
        "cookies": call.request?.cookies,
        "contentType": call.request?.contentType,
        "fromDataFields": call.request?.formDataFields,
        "fromDataFiles": call.request?.formDataFiles,
        "size": AliceConversionHelper.formatBytes(call.request?.size ?? 0),
      },
      "response": {
        "status": call.response?.status,
        "size": AliceConversionHelper.formatBytes(call.response?.size ?? 0),
        if (call.response?.body.toString().isNotEmpty ?? false) ...{
          "body": jsonDecode(responseBody)
        },
      },
      "error": {
        "error": call.error?.error,
        "stackTrace": call.error?.stackTrace,
      },
    };

    return jsonEncode(callMap);
  }

  static Future<String> buildCallLog(AliceHttpCall call) async {
    try {
      return await _buildAliceLog() + _buildCallLog(call);
    } catch (exception) {
      return "Failed to generate call log";
    }
  }

  static Future<String?> getErrorId(AliceHttpCall call) async {
    try {
      final errorBody = call.response?.body;
      final responseContentType =
          AliceParser.getContentType(call.response?.headers ?? {});
      final responseBody =
          AliceParser.formatBody(errorBody, responseContentType);

      final Map<String, dynamic> responseMap = json.decode(responseBody);

      if (responseMap.containsKey("errorId")) {
        return responseMap["errorId"];
      }

      return null;
    } catch (exception) {
      return null;
    }
  }

  static Future<String> buildLogMap(AliceHttpCall call) async {
    try {
      return _buildLogMap(call);
    } catch (exception) {
      return "Failed to generate call log map";
    }
  }

  static Future<String?> getResponseBody(AliceHttpCall call) async {
    try {
      final body = AliceParser.formatBody(call.response?.body,
          AliceParser.getContentType(call.response?.headers ?? {}));

      final decodedBody = jsonDecode(body);

      final response = {
        "response": {
          "body": decodedBody,
          "status": call.response?.status,
        },
      };

      final responseString = jsonEncode(response);

      return responseString;
    } catch (exception) {
      return null;
    }
  }

  static Future<String?> getPayload(AliceHttpCall call) async {
    try {
      final body = AliceParser.formatBody(call.request?.body,
          AliceParser.getContentType(call.request?.headers ?? {}));

      final payload = {
        "request": {
          "body": body,
          "queryParameters": call.request?.queryParameters,
          "fromDataFields": call.request?.formDataFields,
          "fromDataFiles": call.request?.formDataFiles,
        },
      };

      // Convert to JSON string
      final payloadString = jsonEncode(payload);

      return payloadString;
    } catch (exception) {
      return null;
    }
  }
}
