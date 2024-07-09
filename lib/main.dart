import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'config.dart';  // Import the configuration file

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ChatBot with Hugging Face API',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ChatScreen(),
    );
  }
}

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<String> _messages = [];

  void _sendMessage() async {
    if (_controller.text.isEmpty) return;
    setState(() {
      _messages.add("You: ${_controller.text}");
    });
    try {
      final response = await fetchChatResponse(_controller.text);
      setState(() {
        _messages.add("Bot: $response");
      });
    } catch (e) {
      setState(() {
        _messages.add("Bot: Failed to load response: $e");
      });
    }
    _controller.clear();
  }

  Future<String> fetchChatResponse(String prompt) async {
    final url = Uri.parse('https://api-inference.huggingface.co/models/gpt2');
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $apiKey',  // Use the imported API key
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'inputs': prompt,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data[0]['generated_text'].trim();
    } else {
      final errorResponse = jsonDecode(response.body);
      throw Exception('Failed to load response: ${errorResponse['error']}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ChatBot with Hugging Face API'),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_messages[index]),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      labelText: 'Type a message',
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
