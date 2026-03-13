import 'dart:io';

import 'package:genkit/genkit.dart';
import 'package:genkit_openai/genkit_openai.dart';
import 'package:genkit_shelf/genkit_shelf.dart';
import 'package:schemantic/schemantic.dart';

part 'server.g.dart';

// --- Schemas ---

@Schema(description: 'A single chat message with role and content')
abstract class $ChatMessageInput {
  @StringField(enumValues: ['user', 'model'])
  String get role;

  String get content;
}

@Schema(description: 'Chat request with message and history')
abstract class $ChatRequest {
  String get message;

  List<$ChatMessageInput>? get history;
}

// --- System Prompt ---

const _systemPrompt = '''
あなたはプロの面接官です。ソフトウェアエンジニアの採用面接を行います。

## ルール
- 日本語で会話してください
- ユーザーが「面接を始めて」と言ったら、まず自己紹介を求めてください
- 一度に1つの質問だけをしてください
- ユーザーの回答に対して、簡潔なフィードバック（良い点・改善点）を述べてから次の質問に進んでください
- 技術的な質問、行動面接の質問、志望動機などをバランスよく出してください
- ユーザーが「終了」と言ったら、面接全体の総評をしてください

## 質問カテゴリ
1. 自己紹介・経歴
2. 技術スキル（使用技術に応じて深掘り）
3. 行動面接（過去の経験から具体例を聞く）
4. 問題解決力
5. チームワーク・コミュニケーション
6. キャリアビジョン・志望動機
''';

// --- Main ---

void main(List<String> args) async {
  final apiKey = Platform.environment['OPENAI_API_KEY'];
  if (apiKey == null || apiKey.isEmpty) {
    print('Error: OPENAI_API_KEY environment variable is not set.');
    exit(1);
  }

  final ai = Genkit(plugins: [
    openAI(apiKey: apiKey),
  ]);

  // Define the chat flow
  final chatFlow = ai.defineFlow(
    name: 'interviewChat',
    inputSchema: ChatRequest.$schema,
    outputSchema: SchemanticType.string(),
    fn: (ChatRequest request, _) async {
      final messages = <Message>[
        Message(
          role: Role.system,
          content: [TextPart(text: _systemPrompt)],
        ),
      ];

      for (final msg in request.history ?? []) {
        messages.add(Message(
          role: msg.role == 'user' ? Role.user : Role.model,
          content: [TextPart(text: msg.content)],
        ));
      }

      messages.add(Message(
        role: Role.user,
        content: [TextPart(text: request.message)],
      ));

      final response = await ai.generate(
        model: openAI.model('gpt-4o-mini'),
        messages: messages,
      );

      return response.text;
    },
  );

  // Start the server using genkit_shelf's built-in server
  await startFlowServer(
    flows: [chatFlow],
    port: int.parse(Platform.environment['PORT'] ?? '8080'),
    cors: {'origin': '*'},
  );
}
