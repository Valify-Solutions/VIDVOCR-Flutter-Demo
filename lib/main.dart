import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'package:vidvocr_flutter_plugin/vidvocr_flutter_plugin.dart';
import 'package:pretty_http_logger/pretty_http_logger.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _ocrResult = 'No result yet';
  final _vidvocrFlutterPlugin = VidvocrFlutterPlugin();

  // Example credentials, replace with real values
  final String baseURL = '';
  final String bundleKey = '';
  final String userName = '';
  final String password = '';
  final String clientID = '';
  final String clientSecret = '';

  // Configuration parameters
  bool _isArabic = false;
  bool _documentVerification = false;
  bool _reviewData = false;
  bool _captureOnlyMode = false;
  bool _manualCaptureMode = false;
  bool _previewCapturedImage = false;
  bool _enableLogging = false;
  bool _collectUserInfo = false;
  bool _advancedConfidence = false;
  bool _professionAnalysis = false;
  bool _documentVerificationPlus = false;

  // Function to generate a token using the provided credentials
  Future<String?> getToken() async {
    final String url = '$baseURL/api/o/token/';
    HttpWithMiddleware httpWithMiddleware = HttpWithMiddleware.build(middlewares: [
      HttpLogger(logLevel: LogLevel.BODY),
    ]);
    final Map<String, String> headers = {
      'Content-Type': 'application/x-www-form-urlencoded',
    };

    final String body = 'username=$userName&password=$password&client_id=$clientID&client_secret=$clientSecret&grant_type=password';

    final http.Response response = await httpWithMiddleware.post(
      Uri.parse(url),
      headers: headers,
      body: body,
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      return jsonResponse['access_token'];
    } else {
      print('Failed to retrieve token: ${response.statusCode}');
      return null;
    }
  }

  // Function to start the SDK after generating the token
  Future<void> startSDK() async {
    String? token;

    try {
      token = await getToken();
      if (token == null) {
        setState(() {
          _ocrResult = 'Failed to get token';
        });
        return;
      }
    } catch (e) {
      setState(() {
        _ocrResult = 'Error retrieving token: $e';
      });
      return;
    }

    // Prepare parameters based on checkbox states
    final Map<String, dynamic> params = {
      "base_url": baseURL,
      "access_token": token,
      "bundle_key": bundleKey,
      "language": _isArabic ? "ar" : "en",
      "document_verification": _documentVerification,
      "review_data": _reviewData,
      "capture_only_mode": _captureOnlyMode,
      "manual_capture_mode": _manualCaptureMode,
      "preview_captured_image": _previewCapturedImage,
      "primary_color": "#FF0000",
      "enable_logging": _enableLogging,
      "collect_user_info": _collectUserInfo,
      "advanced_confidence": _advancedConfidence,
      "profession_analysis": _professionAnalysis,
      "document_verification_plus": _documentVerificationPlus,
    };

    try {
      final String? result = await VidvocrFlutterPlugin.startOCR(params);
      setState(() {
        print(result);
        _ocrResult = result ?? 'Failed to start OCR process.';
      });
    } on PlatformException catch (e) {
      setState(() {
        _ocrResult = 'Failed to start SDK: ${e.message}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('OCR Plugin Example'),
        ),
        body: SingleChildScrollView( // Make the entire body scrollable
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const Text(
                'Configuration Options',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              CheckboxListTile(
                title: const Text('Language: Arabic'),
                value: _isArabic,
                onChanged: (bool? value) {
                  setState(() {
                    _isArabic = value ?? false;
                  });
                },
              ),
              CheckboxListTile(
                title: const Text('Document Verification'),
                value: _documentVerification,
                onChanged: (bool? value) {
                  setState(() {
                    _documentVerification = value ?? false;
                  });
                },
              ),
              CheckboxListTile(
                title: const Text('Review Data'),
                value: _reviewData,
                onChanged: (bool? value) {
                  setState(() {
                    _reviewData = value ?? false;
                  });
                },
              ),
              CheckboxListTile(
                title: const Text('Capture Only Mode'),
                value: _captureOnlyMode,
                onChanged: (bool? value) {
                  setState(() {
                    _captureOnlyMode = value ?? false;
                  });
                },
              ),
              CheckboxListTile(
                title: const Text('Manual Capture Mode'),
                value: _manualCaptureMode,
                onChanged: (bool? value) {
                  setState(() {
                    _manualCaptureMode = value ?? true;
                  });
                },
              ),
              CheckboxListTile(
                title: const Text('Preview Captured Image'),
                value: _previewCapturedImage,
                onChanged: (bool? value) {
                  setState(() {
                    _previewCapturedImage = value ?? true;
                  });
                },
              ),
              CheckboxListTile(
                title: const Text('Enable Logging'),
                value: _enableLogging,
                onChanged: (bool? value) {
                  setState(() {
                    _enableLogging = value ?? true;
                  });
                },
              ),
              CheckboxListTile(
                title: const Text('Collect User Info'),
                value: _collectUserInfo,
                onChanged: (bool? value) {
                  setState(() {
                    _collectUserInfo = value ?? false;
                  });
                },
              ),
              CheckboxListTile(
                title: const Text('Advanced Confidence'),
                value: _advancedConfidence,
                onChanged: (bool? value) {
                  setState(() {
                    _advancedConfidence = value ?? false;
                  });
                },
              ),
              CheckboxListTile(
                title: const Text('Profession Analysis'),
                value: _professionAnalysis,
                onChanged: (bool? value) {
                  setState(() {
                    _professionAnalysis = value ?? false;
                  });
                },
              ),
              CheckboxListTile(
                title: const Text('Document Verification Plus'),
                value: _documentVerificationPlus,
                onChanged: (bool? value) {
                  setState(() {
                    _documentVerificationPlus = value ?? false;
                  });
                },
              ),
              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: startSDK,
                child: const Text('Start OCR'),
              ),
              const SizedBox(height: 20),

              // Make the OCR result section scrollable
              Text(
                'OCR Result: $_ocrResult\n',
                textAlign: TextAlign.left,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
