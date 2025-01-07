import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';  // Import this for clipboard functionality

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const ApiUrlInputScreen(),
    );
  }
}

class ApiUrlInputScreen extends StatefulWidget {
  const ApiUrlInputScreen({Key? key}) : super(key: key);

  @override
  _ApiUrlInputScreenState createState() => _ApiUrlInputScreenState();
}

class _ApiUrlInputScreenState extends State<ApiUrlInputScreen> {
  final TextEditingController _apiUrlController = TextEditingController();

  void _navigateToUrlShortener(String apiUrl) {
    if (apiUrl.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => UrlShortenerScreen(apiUrl: apiUrl),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Enter API URL'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _apiUrlController,
              decoration: const InputDecoration(
                labelText: 'Enter API URL',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                _navigateToUrlShortener(_apiUrlController.text);
              },
              child: const Text('Go to URL Shortener'),
            ),
          ],
        ),
      ),
    );
  }
}

class UrlShortenerScreen extends StatefulWidget {
  final String apiUrl;

  const UrlShortenerScreen({Key? key, required this.apiUrl}) : super(key: key);

  @override
  _UrlShortenerScreenState createState() => _UrlShortenerScreenState();
}

class _UrlShortenerScreenState extends State<UrlShortenerScreen> {
  final TextEditingController _urlController = TextEditingController();
  String? _shortenedUrl;
  bool _isLoading = false;

  Future<void> shortenUrl(String originalUrl) async {
    setState(() {
      _isLoading = true;
      _shortenedUrl = null;
    });

    try {
      final response = await http.post(
        Uri.parse(widget.apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'url': originalUrl}),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        setState(() {
          _shortenedUrl = responseData['short_url'];
        });
      } else {
        final responseData = jsonDecode(response.body);
        setState(() {
          _shortenedUrl = 'Error: ${responseData["error"]}';
        });
      }
    } catch (e) {
      setState(() {
        _shortenedUrl = 'An error occurred: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Function to copy the shortened URL to clipboard
  void _copyToClipboard() {
    if (_shortenedUrl != null) {
      Clipboard.setData(ClipboardData(text: _shortenedUrl!));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('URL copied to clipboard!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('URL Shortener'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _urlController,
              decoration: const InputDecoration(
                labelText: 'Enter URL to shorten',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                if (_urlController.text.isNotEmpty) {
                  shortenUrl(_urlController.text);
                }
              },
              child: const Text('Shorten URL'),
            ),
            const SizedBox(height: 16),
            if (_isLoading)
              const CircularProgressIndicator()
            else if (_shortenedUrl != null)
              Column(
                children: [
                  Text(
                    _shortenedUrl!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 18, color: Colors.blue),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _copyToClipboard,
                    child: const Text('Copy to Clipboard'),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
