import 'package:genkit/client.dart';
import 'package:schemantic/schemantic.dart';

class ChatMessage {
  final String role;
  final String content;

  ChatMessage({required this.role, required this.content});

  Map<String, dynamic> toJson() => {'role': role, 'content': content};
}

class ChatService {
  late final RemoteAction<Map<String, dynamic>, String, void, void> _chatAction;

  ChatService({String baseUrl = 'http://localhost:8080'}) {
    _chatAction = defineRemoteAction<Map<String, dynamic>, String, void, void>(
      url: '$baseUrl/interviewChat',
      outputSchema: SchemanticType.string(),
    );
  }

  Future<String> sendMessage(
    String message,
    List<ChatMessage> history,
  ) async {
    final result = await _chatAction(
      input: {
        'message': message,
        'history': history.map((m) => m.toJson()).toList(),
      },
    );
    return result;
  }
}
