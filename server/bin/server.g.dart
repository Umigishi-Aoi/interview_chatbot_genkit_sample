// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'server.dart';

// **************************************************************************
// SchemaGenerator
// **************************************************************************

base class ChatMessageInput {
  factory ChatMessageInput.fromJson(Map<String, dynamic> json) =>
      $schema.parse(json);

  ChatMessageInput._(this._json);

  ChatMessageInput({required String role, required String content}) {
    _json = {'role': role, 'content': content};
  }

  late final Map<String, dynamic> _json;

  static const SchemanticType<ChatMessageInput> $schema =
      _ChatMessageInputTypeFactory();

  String get role {
    return _json['role'] as String;
  }

  set role(String value) {
    _json['role'] = value;
  }

  String get content {
    return _json['content'] as String;
  }

  set content(String value) {
    _json['content'] = value;
  }

  @override
  String toString() {
    return _json.toString();
  }

  Map<String, dynamic> toJson() {
    return _json;
  }
}

base class _ChatMessageInputTypeFactory
    extends SchemanticType<ChatMessageInput> {
  const _ChatMessageInputTypeFactory();

  @override
  ChatMessageInput parse(Object? json) {
    return ChatMessageInput._(json as Map<String, dynamic>);
  }

  @override
  JsonSchemaMetadata get schemaMetadata => JsonSchemaMetadata(
    name: 'ChatMessageInput',
    definition: $Schema
        .object(
          properties: {
            'role': $Schema.string(enumValues: ['user', 'model']),
            'content': $Schema.string(),
          },
          required: ['role', 'content'],
          description: 'A single chat message with role and content',
        )
        .value,
    dependencies: [],
  );
}

base class ChatRequest {
  factory ChatRequest.fromJson(Map<String, dynamic> json) =>
      $schema.parse(json);

  ChatRequest._(this._json);

  ChatRequest({required String message, List<ChatMessageInput>? history}) {
    _json = {
      'message': message,
      'history': ?history?.map((e) => e.toJson()).toList(),
    };
  }

  late final Map<String, dynamic> _json;

  static const SchemanticType<ChatRequest> $schema = _ChatRequestTypeFactory();

  String get message {
    return _json['message'] as String;
  }

  set message(String value) {
    _json['message'] = value;
  }

  List<ChatMessageInput>? get history {
    return (_json['history'] as List?)
        ?.map((e) => ChatMessageInput.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  set history(List<ChatMessageInput>? value) {
    if (value == null) {
      _json.remove('history');
    } else {
      _json['history'] = value.toList();
    }
  }

  @override
  String toString() {
    return _json.toString();
  }

  Map<String, dynamic> toJson() {
    return _json;
  }
}

base class _ChatRequestTypeFactory extends SchemanticType<ChatRequest> {
  const _ChatRequestTypeFactory();

  @override
  ChatRequest parse(Object? json) {
    return ChatRequest._(json as Map<String, dynamic>);
  }

  @override
  JsonSchemaMetadata get schemaMetadata => JsonSchemaMetadata(
    name: 'ChatRequest',
    definition: $Schema
        .object(
          properties: {
            'message': $Schema.string(),
            'history': $Schema.list(
              items: $Schema.fromMap({'\$ref': r'#/$defs/ChatMessageInput'}),
            ),
          },
          required: ['message'],
          description: 'Chat request with message and history',
        )
        .value,
    dependencies: [ChatMessageInput.$schema],
  );
}
