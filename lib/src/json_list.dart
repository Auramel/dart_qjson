// Dart imports:
import 'dart:convert';

// Package imports:
import 'package:dart_qvariant/dart_qvariant.dart';

// Project imports:
import 'package:dart_qjson/src/json_object.dart';

/// A Qt-style immutable JSON list wrapper for Dart.
///
/// Provides methods to parse a JSON string into a list, access primitive values
/// as `Variant`, and retrieve nested `JsonObject` or `JsonList` instances.
///
/// Example:
/// ```dart
/// // Parsing a JSON array with mixed types:
/// final jsonString = '[{"name":"Alice"}, [1,2,3], 42, "hello"]';
/// final jsonList = JsonList.fromJsonString(jsonString);
///
/// // Access a primitive:
/// final numberVariant = jsonList.get(2); // Variant containing 42
/// print(numberVariant.toInt()); // prints: 42
///
/// // Access a nested object:
/// final firstObj = jsonList.getObject(0);
/// print(firstObj.get("name").toText()); // prints: Alice
///
/// // Access a nested list:
/// final nestedList = jsonList.getList(1);
/// print(nestedList.length); // prints: 3
/// ```
class JsonList {
  final List<dynamic> _data;

  /// Returns an immutable copy of the underlying list.
  /// Example: `jsonList.data` yields a `List<dynamic>` that cannot be modified.
  List<dynamic> get data => List.unmodifiable(_data);

  /// Parses [jsonString] into a `JsonList`.
  ///
  /// Throws [ArgumentError] if [jsonString] is `null`.
  /// Throws [FormatException] if the string is not valid JSON or does not decode to a List.
  ///
  /// Example:
  /// ```dart
  /// final jsonString = '["apple", "banana", "cherry"]';
  /// final fruitList = JsonList.fromJsonString(jsonString);
  /// print(fruitList.length); // prints: 3
  /// ```
  factory JsonList.fromJsonString(final String? jsonString) {
    if (jsonString == null) {
      throw ArgumentError.notNull('jsonString');
    }

    try {
      final dynamic decoded = jsonDecode(jsonString);
      if (decoded is! List) {
        throw FormatException(
          'Decoded JSON is not a List, actual type: ${decoded.runtimeType}',
          jsonString,
        );
      }
      return JsonList(List<dynamic>.from(decoded));
    } on FormatException catch (e) {
      throw FormatException('Invalid JSON format: ${e.message}', jsonString);
    }
  }

  /// Main constructor accepting a Dart `List<dynamic>`.
  /// Example: `JsonList([1, 2, 3])`.
  const JsonList(this._data);

  /// Creates an empty `JsonList`.
  /// Example: `JsonList.empty()` results in a list with zero elements.
  const JsonList.empty() : _data = const [];

  /// Returns the number of elements in the list.
  /// Example: `jsonList.length`.
  int get length => _data.length;

  /// Returns `true` if the list has no elements.
  /// Example: `JsonList.empty().isEmpty` // true
  bool get isEmpty => _data.isEmpty;

  /// Returns `true` if the list has at least one element.
  /// Example: `JsonList([1]).isNotEmpty` // true
  bool get isNotEmpty => _data.isNotEmpty;

  /// Returns an immutable Dart `List<dynamic>` representation.
  /// Example: `jsonList.toJson` yields a `List<dynamic>` copy.
  List<dynamic> get toJson => List.unmodifiable(_data);

  /// Returns a minified JSON string of the underlying list.
  /// Example: `JsonList([1,2,3]).toJsonString` // "[1,2,3]"
  String get toJsonString => jsonEncode(_data);

  /// Returns `true` if [index] is within valid bounds `[0..length-1]`.
  /// Example: `jsonList.contains(0)` // true if at least one element exists
  bool contains(final int index) => index >= 0 && index < _data.length;

  /// Retrieves a primitive value at [index] wrapped in `Variant`.
  ///
  /// Throws [RangeError] if [index] is out of bounds.
  /// Throws [UnsupportedError] if the value at [index] is a `Map` or a `List`.
  ///
  /// Example:
  /// ```dart
  /// final jsonList = JsonList([10, "text", true]);
  /// final variant = jsonList.get(1);
  /// print(variant.toText()); // prints: text
  /// ```
  Variant? get(final int index) {
    if (!contains(index)) {
      throw RangeError.index(index, _data, 'index');
    }

    final dynamic value = _data[index];

    if (value == null) {
      return null;
    }

    if (value is Map) {
      throw UnsupportedError('Value at index $index is a Map; use getObject("$index") instead.');
    }

    if (value is List) {
      throw UnsupportedError('Value at index $index is a List; use getList("$index") instead.');
    }

    return Variant(value);
  }

  /// Retrieves a nested `JsonObject` at [index].
  ///
  /// If the element is `null`, returns `JsonObject.empty()`.
  /// Throws [RangeError] if [index] is out of bounds.
  /// Throws [UnsupportedError] if the value is not a `Map`.
  ///
  /// Example:
  /// ```dart
  /// final jsonString = '[{"id":1}, null]';
  /// final jsonList = JsonList.fromJsonString(jsonString);
  /// final obj = jsonList.getObject(0);
  /// print(obj.get("id").toInt()); // prints: 1
  /// final emptyObj = jsonList.getObject(1);
  /// print(emptyObj.isEmpty); // prints: true
  /// ```
  JsonObject? getObject(final int index) {
    if (!contains(index)) {
      throw RangeError.index(index, _data, 'index');
    }

    final dynamic value = _data[index];

    if (value == null) {
      return null;
    }

    if (value is Map) {
      return JsonObject(Map<String, dynamic>.from(value));
    }

    throw UnsupportedError('Expected Map at index $index, but got ${value.runtimeType}.');
  }

  /// Retrieves a nested `JsonList` at [index].
  ///
  /// If the element is `null`, returns `JsonList.empty()`.
  /// Throws [RangeError] if [index] is out of bounds.
  /// Throws [UnsupportedError] if the value is not a `List`.
  ///
  /// Example:
  /// ```dart
  /// final nestedJson = '[[1,2],[3,4], null]';
  /// final jsonList = JsonList.fromJsonString(nestedJson);
  /// final firstNested = jsonList.getList(0);
  /// print(firstNested.get(1).toInt()); // prints: 2
  /// final emptyNested = jsonList.getList(2);
  /// print(emptyNested.isEmpty); // prints: true
  /// ```
  JsonList? getList(final int index) {
    if (!contains(index)) {
      throw RangeError.index(index, _data, 'index');
    }

    final dynamic value = _data[index];

    if (value == null) {
      return null;
    }

    if (value is List) {
      return JsonList(List<dynamic>.from(value));
    }

    throw UnsupportedError('Expected List at index $index, but got ${value.runtimeType}.');
  }
}
