import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class AIAssistantScreen extends StatefulWidget {
  const AIAssistantScreen({super.key});

  @override
  State<AIAssistantScreen> createState() => _AIAssistantScreenState();
}

class _AIAssistantScreenState extends State<AIAssistantScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final SpeechToText _speechToText = SpeechToText();
  final FlutterTts _flutterTts = FlutterTts();
  
  // Gemini AI setup
  late GenerativeModel _model;
  late ChatSession _chat;
  
  bool _isListening = false;
  bool _isTyping = false;
  bool _isSpeaking = false;
  String _lastWords = '';
  
  List<ChatMessage> _messages = [
    ChatMessage(
      text: "Hello! I'm your Bangalore City Assistant powered by AI. I can help you with traffic, events, safety, and more. How can I assist you today?",
      isUser: false,
      timestamp: DateTime.now(),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _initializeSpeech();
    _initializeTTS();
    _initializeGemini();
  }

  void _initializeGemini() {
    // Initialize Gemini AI
    _model = GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: 'AIzaSyBs0XNVvtLpb-Lu6C9Kz8IyKR1we55SqXE', // Replace with your actual API key
    );
    _chat = _model.startChat();
    
    // Set up the AI with context about Bangalore
    _setupAIContext();
  }

  void _setupAIContext() async {
    const contextPrompt = '''
    You are a helpful AI assistant for Bangalore city. You have access to real-time information about:
    - Traffic conditions in different areas (MG Road, Koramangala, Whitefield, Electronic City, etc.)
    - Local events and activities
    - Public transport (BMTC buses, Metro, auto-rickshaws)
    - Safety tips and emergency information
    - Weather conditions
    - Parking availability
    - Local business recommendations
    
    Always provide accurate, helpful, and Bangalore-specific information. Be conversational but professional. 
    If you don't have real-time data, provide general guidance and suggest checking the app's live features.
    
    Keep responses concise but informative. Use bullet points when appropriate for better readability.
    ''';
    
    try {
      await _chat.sendMessage(Content.text(contextPrompt));
    } catch (e) {
      print('Error setting up AI context: $e');
    }
  }

  void _initializeSpeech() async {
    bool available = await _speechToText.initialize();
    if (available) {
      setState(() {});
    }
  }

  void _initializeTTS() async {
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF4299E1), Color(0xFF3182CE)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.smart_toy, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            const Text(
              'AI City Assistant',
              style: TextStyle(
                color: Color(0xFF2D3748),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: Icon(
              _isSpeaking ? Icons.volume_off : Icons.volume_up,
              color: const Color(0xFF4299E1),
            ),
            onPressed: _toggleTTS,
            tooltip: 'Toggle Voice',
          ),
        ],
      ),
      body: Column(
        children: [
          // Chat Messages
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              child: ListView.builder(
                controller: _scrollController,
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  return _buildMessage(_messages[index]);
                },
              ),
            ),
          ),
          
          // Quick Actions
          if (_messages.length == 1) _buildQuickActions(),
          
          // Input Section
          _buildInputSection(),
        ],
      ),
    );
  }

  Widget _buildMessage(ChatMessage message) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF4299E1), Color(0xFF3182CE)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.smart_toy, color: Colors.white, size: 16),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: message.isUser ? const Color(0xFF4299E1) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.text,
                    style: TextStyle(
                      color: message.isUser ? Colors.white : const Color(0xFF2D3748),
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatTime(message.timestamp),
                    style: TextStyle(
                      color: message.isUser ? Colors.white70 : Colors.grey[500],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (message.isUser) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF4299E1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.person, color: Colors.white, size: 16),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    final quickActions = [
      {'icon': Icons.traffic, 'text': 'Traffic Update', 'query': 'How is the traffic to MG Road?'},
      {'icon': Icons.event, 'text': 'Events Today', 'query': 'What events are happening today?'},
      {'icon': Icons.security, 'text': 'Safety Tips', 'query': 'Give me some safety tips for today'},
      {'icon': Icons.directions_bus, 'text': 'Public Transport', 'query': 'What are the best public transport options?'},
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3748),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: quickActions.map((action) {
              return GestureDetector(
                onTap: () => _sendMessage(action['query'] as String),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFF4299E1)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        action['icon'] as IconData,
                        color: const Color(0xFF4299E1),
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        action['text'] as String,
                        style: const TextStyle(
                          color: Color(0xFF4299E1),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildInputSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Voice Button
          GestureDetector(
            onTap: _isListening ? _stopListening : _startListening,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _isListening ? Colors.red : const Color(0xFF4299E1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _isListening ? Icons.mic : Icons.mic_none,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
          const SizedBox(width: 12),
          
          // Text Input
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF7FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: TextField(
                controller: _messageController,
                decoration: const InputDecoration(
                  hintText: 'Ask me about traffic, events, safety...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.grey),
                ),
                onSubmitted: (text) => _sendMessage(text),
              ),
            ),
          ),
          const SizedBox(width: 12),
          
          // Send Button
          GestureDetector(
            onTap: () => _sendMessage(_messageController.text),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF4299E1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.send,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _startListening() async {
    if (!_isListening) {
      bool available = await _speechToText.initialize();
      if (available) {
        setState(() {
          _isListening = true;
        });
        _speechToText.listen(
          onResult: (result) {
            setState(() {
              _lastWords = result.recognizedWords;
            });
          },
          listenFor: const Duration(seconds: 30),
          pauseFor: const Duration(seconds: 3),
        );
      }
    }
  }

  void _stopListening() async {
    _speechToText.stop();
    setState(() {
      _isListening = false;
    });
    if (_lastWords.isNotEmpty) {
      _sendMessage(_lastWords);
      _lastWords = '';
    }
  }

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;
    
    setState(() {
      _messages.add(ChatMessage(
        text: text,
        isUser: true,
        timestamp: DateTime.now(),
      ));
      _isTyping = true;
    });
    
    _messageController.clear();
    _scrollToBottom();
    
    // Get AI response from Gemini
    _getGeminiResponse(text);
  }

  void _getGeminiResponse(String userMessage) async {
    try {
      final response = await _chat.sendMessage(Content.text(userMessage));
      final responseText = response.text ?? 'Sorry, I couldn\'t process that request.';
      
      setState(() {
        _messages.add(ChatMessage(
          text: responseText,
          isUser: false,
          timestamp: DateTime.now(),
        ));
        _isTyping = false;
      });
      
      _scrollToBottom();
      
      // Speak the response if TTS is enabled
      if (_isSpeaking) {
        _speakText(responseText);
      }
    } catch (e) {
      print('Error getting Gemini response: $e');
      
      // Fallback response
      setState(() {
        _messages.add(ChatMessage(
          text: 'Sorry, I\'m having trouble connecting right now. Please try again in a moment.',
          isUser: false,
          timestamp: DateTime.now(),
        ));
        _isTyping = false;
      });
      
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _toggleTTS() {
    setState(() {
      _isSpeaking = !_isSpeaking;
    });
  }

  void _speakText(String text) async {
    await _flutterTts.speak(text);
  }

  String _formatTime(DateTime timestamp) {
    return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _speechToText.cancel();
    _flutterTts.stop();
    super.dispose();
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
} 