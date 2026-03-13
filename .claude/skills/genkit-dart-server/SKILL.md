---
name: genkit-dart-server
description: Genkit Dartパッケージのみでサーバーを構築するガイド。Use when building a Dart backend with Genkit flows, defining schemas with schemantic, or serving flows via genkit_shelf.
---

# Genkit Dart Server 構築ガイド

Genkit Dart のパッケージだけでサーバーを構築するためのルールとパターン集。
shelf や shelf_router を直接依存に追加せず、genkit エコシステム内で完結させる。

## Instructions

### Step 1: 依存パッケージ（必要最小限）

```yaml
dependencies:
  genkit: ^0.11.1
  genkit_shelf: ^0.1.2
  schemantic: ^0.1.0
  # LLMプラグインは1つ以上選択
  genkit_openai: ^0.2.2       # OpenAI / OpenAI互換
  # genkit_google_genai: ...   # Google Gemini
  # genkit_anthropic: ...      # Anthropic Claude

dev_dependencies:
  build_runner: ^2.12.2        # schemantic のコード生成に必須
```

**重要**: `shelf` や `shelf_router` を直接追加しないこと。`genkit_shelf` が内部で依存しているため不要。

### Step 2: スキーマ定義（schemantic）

入出力の型は `@Schema()` アノテーションで定義する。`part 'ファイル名.g.dart';` を忘れないこと。

```dart
import 'package:schemantic/schemantic.dart';

part 'server.g.dart';

@Schema(description: '説明文')
abstract class $MyInput {
  String get field1;
  int? get optionalField;
  List<$NestedType>? get nestedList;
}
```

- クラス名は `$` プレフィックス付き（生成後は `$` なしで使用）
- フィールドは getter で定義
- `@StringField()`, `@IntegerField()` 等でバリデーション追加可能
- 定義後 `dart run build_runner build` でコード生成

### Step 3: Flow 定義

```dart
final myFlow = ai.defineFlow(
  name: 'flowName',                        // URLパスになる（/flowName）
  inputSchema: MyInput.$schema,            // 生成されたスキーマ
  outputSchema: SchemanticType.string(),   // プリミティブ型はSchemanticType経由
  fn: (MyInput input, _) async {
    final response = await ai.generate(
      model: openAI.model('gpt-4o-mini'),
      messages: [...],
    );
    return response.text;
  },
);
```

**outputSchema のプリミティブ型一覧:**
- `SchemanticType.string()`
- `SchemanticType.integer()`
- `SchemanticType.boolean()`
- `SchemanticType.dynamicSchema()`
- `SchemanticType.list(SchemanticType.string())`
- `SchemanticType.map(SchemanticType.string(), SchemanticType.dynamicSchema())`

### Step 4: サーバー起動（startFlowServer）

```dart
await startFlowServer(
  flows: [myFlow],                  // 複数Flow登録可能
  port: 8080,
  cors: {'origin': '*'},            // CORS設定（省略可）
);
```

- Router, Pipeline, CORS ミドルウェアは `startFlowServer` が自動構築
- 各 Flow は `POST /{flow.name}` で公開される
- リクエスト形式: `{"data": <input>}`
- レスポンス形式: `{"result": <output>}`

### Step 5: Flutter クライアントからの呼び出し

Flutter側では `genkit/client.dart` の `defineRemoteAction` を使用する。

```dart
import 'package:genkit/client.dart';
import 'package:schemantic/schemantic.dart';

final myAction = defineRemoteAction<Map<String, dynamic>, String, void, void>(
  url: 'http://localhost:8080/flowName',
  outputSchema: SchemanticType.string(),
);

final result = await myAction(input: {'field1': 'value'});
```

- `defineRemoteAction` は `{data: ...}` ラップと `{result: ...}` アンラップを自動処理
- 型引数は `<Input, Output, Chunk, Init>` の4つ（ストリーミング不要なら後ろ2つは `void`）
- Flutter の `pubspec.yaml` に `genkit` と `schemantic` を追加すること

### Step 6: コード生成と検証

```bash
# schemantic のコード生成
cd server && dart run build_runner build --delete-conflicting-outputs

# 静的解析
dart analyze

# サーバー起動テスト
OPENAI_API_KEY="sk-..." dart run bin/server.dart
```

## Common Issues

### `@Schema()` クラスが見つからない
- `part 'ファイル名.g.dart';` が宣言されているか確認
- `dart run build_runner build` を実行してコード生成

### SchemanticType が undefined
- `import 'package:schemantic/schemantic.dart';` を追加
- `genkit/genkit.dart` からは re-export されていないため、明示的な import が必要

### shelfHandler の規約
- リクエストは `{"data": <input>}` でラップする必要がある
- 素の JSON を送ると `400 INVALID_ARGUMENT` が返る
- Flutter 側は `defineRemoteAction` を使えば自動ハンドルされる

### CORS エラー
- `startFlowServer` の `cors` パラメータを設定する
- `cors: {'origin': '*'}` で全オリジン許可
- カスタム: `cors: {'origin': 'http://localhost:3000'}`

### shelf を直接使いたい場合
- `startFlowServer` ではなく `shelfHandler(flow)` を使い、自前の Router に登録可能
- その場合は `shelf`, `shelf_router` を依存に追加し、CORS ミドルウェアも自前実装が必要
- 基本的には `startFlowServer` で十分
