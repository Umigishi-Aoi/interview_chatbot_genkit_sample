# Interview Chatbot - Genkit Dart

Genkit Dart + Flutter で構築した面接対策チャットアプリ。
AI面接官が模擬面接を行い、回答へのフィードバックを提供します。

## アーキテクチャ

```
Flutter App (フロント)
  └── genkit/client.dart の defineRemoteAction() で接続
          │
          ▼
Dart Server (バックエンド)
  ├── genkit         … Flow定義、LLM呼び出し
  ├── genkit_openai   … OpenAIプラグイン
  ├── genkit_shelf    … startFlowServer() でHTTPサーバー起動
  └── schemantic      … @Schema() による型安全な入出力定義
```

## 使用パッケージ

| パッケージ | 用途 |
|---|---|
| `genkit` | AIフレームワーク本体（Flow, generate, Message） |
| `genkit_openai` | OpenAI (GPT-4o-mini) プラグイン |
| `genkit_shelf` | `startFlowServer()` でサーバー起動（shelf直接依存不要） |
| `schemantic` | `@Schema()` で型安全なリクエスト/レスポンス定義 |
| `genkit/client.dart` | Flutter側から `defineRemoteAction()` でFlowを呼び出し |

## セットアップ

### 1. 環境変数

```bash
cp .env.example .env
# .env にOpenAI APIキーを設定
```

### 2. サーバー起動

```bash
cd server
export OPENAI_API_KEY="sk-..."
dart run bin/server.dart
```

サーバーが `http://localhost:8080` で起動し、`/interviewChat` エンドポイントが公開されます。

### 3. Flutter アプリ起動

```bash
flutter run
```

## 使い方

1. アプリを起動し「面接を始めて」と入力
2. AI面接官が自己紹介を求めるので回答
3. 技術質問、行動面接、志望動機など順に進行
4. 各回答にフィードバック（良い点・改善点）が付きます
5. 「終了」と入力すると総評が表示されます

## プロジェクト構成

```
interview_chatbot/
├── server/
│   ├── bin/
│   │   ├── server.dart       # Genkit Flow + startFlowServer
│   │   └── server.g.dart     # schemantic コード生成
│   └── pubspec.yaml
├── lib/
│   ├── main.dart             # Flutter エントリポイント
│   ├── chat_screen.dart      # チャットUI (Material 3)
│   └── chat_service.dart     # defineRemoteAction で Flow 呼び出し
├── .env.example
└── pubspec.yaml
```

## Genkit Dart のポイント

### サーバー側 — Flow + Schema + startFlowServer

```dart
// @Schema() で型安全な入力を定義
@Schema()
abstract class $ChatRequest {
  String get message;
  List<$ChatMessageInput>? get history;
}

// defineFlow() で AI ロジックをまとめる
final chatFlow = ai.defineFlow(
  name: 'interviewChat',
  inputSchema: ChatRequest.$schema,
  outputSchema: SchemanticType.string(),
  fn: (ChatRequest request, _) async { ... },
);

// genkit_shelf だけで HTTP サーバーが起動
await startFlowServer(flows: [chatFlow], port: 8080, cors: {'origin': '*'});
```

### Flutter側 — defineRemoteAction

```dart
final chatAction = defineRemoteAction<Map<String, dynamic>, String, void, void>(
  url: 'http://localhost:8080/interviewChat',
  outputSchema: SchemanticType.string(),
);
final result = await chatAction(input: {'message': 'こんにちは'});
```

## AI Skills

このプロジェクトには以下のスキルが含まれています:

- `.claude/skills/genkit-dart-server/` — Genkit Dartサーバーを構築する際のガイドスキル
- `.agents/skills/developing-genkit-dart/` — Genkit Dart公式の開発スキル（npx skills add genkit-ai/skills でインストール）
