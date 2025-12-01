import 'package:google_generative_ai/google_generative_ai.dart';
import 'storage_service.dart';

/// AI chat message model
class ChatMessage {
  final String id;
  final String content;
  final bool isUser;
  final DateTime timestamp;
  final bool isError;

  const ChatMessage({
    required this.id,
    required this.content,
    required this.isUser,
    required this.timestamp,
    this.isError = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'is_user': isUser,
      'timestamp': timestamp.toIso8601String(),
      'is_error': isError,
    };
  }

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'],
      content: json['content'],
      isUser: json['is_user'],
      timestamp: DateTime.parse(json['timestamp']),
      isError: json['is_error'] ?? false,
    );
  }
}

/// AI Service for Gemini integration
class AIService {
  final GenerativeModel model;
  final StorageService storageService;
  
  ChatSession? _chatSession;
  final List<ChatMessage> _messages = [];

  AIService({
    required this.model,
    required this.storageService,
  });

  /// Get current messages
  List<ChatMessage> get messages => List.unmodifiable(_messages);

  /// Get system prompt based on user context
  String _getSystemPrompt() {
    final branchId = storageService.branchId;
    final semester = storageService.semester;

    return '''
You are KTU Scholar AI, an intelligent study assistant for students of APJ Abdul Kalam Technological University (KTU), Kerala, India.

USER CONTEXT:
- Branch: ${branchId ?? 'Not selected'}
- Semester: ${semester != null ? 'Semester $semester' : 'Not selected'}

YOUR CAPABILITIES:
1. **Doubt Solving**: Explain complex engineering concepts in simple terms
2. **Problem Solving**: Provide step-by-step solutions to numerical problems
3. **Exam Preparation**: Share important topics, exam tips, and study strategies
4. **Code Help**: Debug and explain programming concepts
5. **Quick Reference**: Provide formulas, definitions, and key points

GUIDELINES:
- Be concise but thorough
- Use examples relevant to engineering students
- Format mathematical equations properly
- When explaining code, use proper syntax highlighting
- If asked about topics outside your knowledge, be honest
- Be encouraging and supportive
- Use bullet points and structured formatting for clarity

Remember: You're helping students prepare for their KTU exams and understand their coursework better.
''';
  }

  /// Initialize or reset chat session
  void initializeChat() {
    _chatSession = model.startChat(
      history: [
        Content.text(_getSystemPrompt()),
      ],
    );
    _messages.clear();
  }

  /// Send a message and get response
  Future<ChatMessage> sendMessage(String userMessage) async {
    // Add user message
    final userMsg = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: userMessage,
      isUser: true,
      timestamp: DateTime.now(),
    );
    _messages.add(userMsg);

    try {
      // Ensure chat session is initialized
      _chatSession ??= model.startChat(
        history: [
          Content.text(_getSystemPrompt()),
        ],
      );

      // Send message and get response
      final response = await _chatSession!.sendMessage(
        Content.text(userMessage),
      );

      final responseText = response.text ?? 'Sorry, I could not generate a response.';

      // Add AI response
      final aiMsg = ChatMessage(
        id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
        content: responseText,
        isUser: false,
        timestamp: DateTime.now(),
      );
      _messages.add(aiMsg);

      return aiMsg;
    } catch (e) {
      // Add error message
      final errorMsg = ChatMessage(
        id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
        content: 'Sorry, I encountered an error. Please try again.',
        isUser: false,
        timestamp: DateTime.now(),
        isError: true,
      );
      _messages.add(errorMsg);

      return errorMsg;
    }
  }

  /// Send message with streaming response
  Stream<String> sendMessageStream(String userMessage) async* {
    // Add user message
    final userMsg = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: userMessage,
      isUser: true,
      timestamp: DateTime.now(),
    );
    _messages.add(userMsg);

    try {
      // Ensure chat session is initialized
      _chatSession ??= model.startChat(
        history: [
          Content.text(_getSystemPrompt()),
        ],
      );

      // Send message and stream response
      final response = _chatSession!.sendMessageStream(
        Content.text(userMessage),
      );

      final buffer = StringBuffer();

      await for (final chunk in response) {
        final text = chunk.text ?? '';
        buffer.write(text);
        yield text;
      }

      // Add complete AI response
      final aiMsg = ChatMessage(
        id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
        content: buffer.toString(),
        isUser: false,
        timestamp: DateTime.now(),
      );
      _messages.add(aiMsg);
    } catch (e) {
      yield 'Sorry, I encountered an error. Please try again.';
      
      // Add error message
      final errorMsg = ChatMessage(
        id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
        content: 'Sorry, I encountered an error. Please try again.',
        isUser: false,
        timestamp: DateTime.now(),
        isError: true,
      );
      _messages.add(errorMsg);
    }
  }

  /// Clear chat history
  void clearChat() {
    _messages.clear();
    _chatSession = null;
  }

  /// Quick prompts for common questions
  static const List<String> quickPrompts = [
    'Explain this topic in simple terms',
    'Give me examples',
    'Solve this step by step',
    'What are the important points?',
    'Previous year questions on this',
    'Help me debug this code',
  ];
}
