// Dart imports:
import 'dart:convert';

// Package imports:
import 'package:dart_qvariant/dart_qvariant.dart';

// Project imports:
import 'package:dart_qjson/src/json_list.dart';

/// A Qt-style immutable JSON object wrapper for Dart.
/// 
/// Provides methods to parse a JSON string into a map, access primitive values
/// as `Variant`, and retrieve nested `JsonObject` or `JsonList` instances.
///
/// Example:
/// ```dart
/// final jsonString = '{"user": {"id": 1, "name": "Alice"}, "tags": ["dart", "qt"]}';
/// final jsonObject = JsonObject.fromJsonString(jsonString);
///
/// // Access a primitive nested inside "user":
/// final userObject = jsonObject.getObject("user");
/// final idVariant = userObject.get("id");
/// print(idVariant.toInt()); // prints: 1
///
/// // Access a nested list:
/// final tagsList = jsonObject.getList("tags");
/// print(tagsList.get(0).toText()); // prints: dart
/// ```
class JsonObject {
  /// Underlying immutable map holding JSON key-value pairs.
  final Map<String, dynamic> _data;

  /// Returns an immutable copy of the underlying map.
  /// Example: `jsonObject.data` yields a `Map<String, dynamic>` that cannot be modified.
  Map<String, dynamic> get data => Map.unmodifiable(_data);

  /// Parses [jsonString] into a JsonObject.
  ///
  /// Throws [ArgumentError] if [jsonString] is `null`.
  /// Throws [FormatException] if the string is not valid JSON or does not decode to a Map.
  ///
  /// Example:
  /// ```dart
  /// final jsonString = '{"key": "value"}';
  /// final obj = JsonObject.fromJsonString(jsonString);
  /// print(obj.get("key").toText()); // prints: value
  /// ```
  factory JsonObject.fromJsonString(final String? jsonString) {
    if (jsonString == null) {
      throw ArgumentError.notNull('jsonString');
    }

    try {
      final dynamic decoded = jsonDecode(jsonString);
      if (decoded is! Map) {
        // The decoded JSON is not a Map, so throw a FormatException.
        throw FormatException(
          'Decoded JSON is not a Map, actual type: ${decoded.runtimeType}',
          jsonString,
        );
      }
      // Create a new JsonObject from the decoded Map.
      return JsonObject(Map<String, dynamic>.from(decoded));
    } on FormatException catch (e) {
      // Re-throw with additional context about invalid format.
      throw FormatException('Invalid JSON format: ${e.message}', jsonString);
    }
  }

  /// Main constructor that accepts a Dart [Map<String, dynamic>].
  /// Example: `JsonObject({"a": 1, "b": 2})`.
  const JsonObject(this._data);

  /// Constructs an empty JsonObject.
  /// Example: `JsonObject.empty()` results in an object with no keys.
  const JsonObject.empty() : _data = const {};

  /// Returns `true` if the object has no key-value pairs.
  /// Example: `JsonObject.empty().isEmpty` // true
  bool get isEmpty => _data.isEmpty;

  /// Returns `true` if the object has at least one key-value pair.
  /// Example: `JsonObject({"k": "v"}).isNotEmpty` // true
  bool get isNotEmpty => _data.isNotEmpty;

  /// Returns a list of all keys in the JSON object.
  /// Example: `jsonObject.keys` // ["user", "tags"]
  List<String> get keys => _data.keys.toList();

  /// Returns an immutable JSON-compatible map representation.
  /// Example: `jsonObject.toJson` yields a `Map<String, dynamic>` copy.
  Map<String, dynamic> get toJson => Map.unmodifiable(_data);

  /// Returns a minified JSON string of the underlying object.
  /// Example: `JsonObject({"a":1}).toJsonString` // "{\"a\":1}"
  String get toJsonString => jsonEncode(_data);

  /// Retrieves a primitive value at [key] wrapped in `Variant`.
  ///
  /// Throws [UnsupportedError] if the value at [key] is a Map (use `getObject`)
  /// or a List (use `getList`) instead.
  ///
  /// Example:
  /// ```dart
  /// final obj = JsonObject({"num": 42});
  /// final variant = obj.get("num");
  /// print(variant.toInt()); // prints: 42
  /// ```
  Variant get(final String key) {
    final dynamic value = _data[key];

    if (value is Map) {
      throw UnsupportedError(
        'Value for key "$key" is a Map; use getObject("$key") instead.',
      );
    }

    if (value is List) {
      throw UnsupportedError(
        'Value for key "$key" is a List; use getList("$key") instead.',
      );
    }

    return Variant(value);
  }

  /// Retrieves a nested `JsonObject` at [key].
  ///
  /// If the value is `null`, returns `JsonObject.empty()`.
  /// Throws [UnsupportedError] if the value is not a Map.
  ///
  /// Example:
  /// ```dart
  /// final obj = JsonObject({"user": {"id":1}});
  /// final user = obj.getObject("user");
  /// print(user.get("id").toInt()); // prints: 1
  /// ```
  JsonObject getObject(final String key) {
    final dynamic value = _data[key];

    if (value == null) {
      return JsonObject.empty();
    }

    if (value is Map) {
      return JsonObject(Map<String, dynamic>.from(value));
    }

    throw UnsupportedError(
      'Expected Map for key "$key", but got ${value.runtimeType}.',
    );
  }

  /// Retrieves a nested `JsonList` at [key].
  ///
  /// If the value is `null`, returns `JsonList.empty()`.
  /// Throws [UnsupportedError] if the value is not a List.
  ///
  /// Example:
  /// ```dart
  /// final obj = JsonObject({"tags": ["dart", "qt"]});
  /// final tags = obj.getList("tags");
  /// print(tags.get(0).toText()); // prints: dart
  /// ```
  JsonList getList(final String key) {
    final dynamic value = _data[key];

    if (value == null) {
      return JsonList.empty();
    }

    if (value is List) {
      return JsonList(value);
    }

    throw UnsupportedError(
      'Expected List for key "$key", but got ${value.runtimeType}.',
    );
  }

  /// Returns `true` if the object contains the given [key].
  /// Example: `jsonObject.containsKey("user")` // true if "user" exists
  bool containsKey(final String key) => _data.containsKey(key);
}
