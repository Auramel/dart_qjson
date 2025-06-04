import 'dart:convert';

import 'package:test/test.dart';
import 'package:dart_qjson/src/json_object.dart';

void main() {
  group('JsonObject', () {
    test('parses valid JSON string and retrieves values', () {
      const jsonString = '{"user": {"id": 1, "name": "Alice", "active": true}, "tags": ["dart", "qt"]}';
      final jsonObject = JsonObject.fromJsonString(jsonString);

      print('JSON');
      print(jsonString);

      // Expected: JSON object contains keys "user" and "tags"
      final isEmptyActual = jsonObject.isEmpty;
      final isEmptyExpected = false;
      print('isEmpty - expected: $isEmptyExpected, actual: $isEmptyActual');
      expect(isEmptyActual, equals(isEmptyExpected));

      final containsUserActual = jsonObject.containsKey('user');
      final containsUserExpected = true;
      print('containsKey("user") - expected: $containsUserExpected, actual: $containsUserActual');
      expect(containsUserActual, equals(containsUserExpected));

      final containsTagsActual = jsonObject.containsKey('tags');
      final containsTagsExpected = true;
      print('containsKey("tags") - expected: $containsTagsExpected, actual: $containsTagsActual');
      expect(containsTagsActual, equals(containsTagsExpected));

      // Retrieve nested object "user"
      final userObject = jsonObject.getObject('user');
      final idVariant = userObject.get('id');
      final idActual = idVariant.toInt();
      final idExpected = 1;
      print('user.id - expected: $idExpected, actual: $idActual');
      expect(idActual, equals(idExpected));

      final nameVariant = userObject.get('name');
      final nameActual = nameVariant.toString();
      final nameExpected = 'Alice';
      print('user.name - expected: "$nameExpected", actual: "$nameActual"');
      expect(nameActual, equals(nameExpected));

      final activeVariant = userObject.get('active');
      final activeActual = activeVariant.toBoolean();
      final activeExpected = true;
      print('user.active - expected: $activeExpected, actual: $activeActual');
      expect(activeActual, equals(activeExpected));

      // Retrieve "tags" as JsonList
      final tagsList = jsonObject.getList('tags');
      final tagsLengthActual = tagsList.length;
      final tagsLengthExpected = 2;
      print('tags.length - expected: $tagsLengthExpected, actual: $tagsLengthActual');
      expect(tagsLengthActual, equals(tagsLengthExpected));

      final firstTagActual = tagsList.get(0).toString();
      final firstTagExpected = 'dart';
      print('tags[0] - expected: "$firstTagExpected", actual: "$firstTagActual"');
      expect(firstTagActual, equals(firstTagExpected));
    });

    test('toJson and toJsonString return correct representations', () {
      const jsonString = '{"a": 10, "b": [1, 2], "c": {"nested": "value"}}';
      final jsonObject = JsonObject.fromJsonString(jsonString);

      final nativeMap = jsonObject.toJson;
      print('toJson["a"] - expected: 10, actual: ${nativeMap["a"]}');
      expect(nativeMap['a'], equals(10));

      print('toJson["b"] - expected: [1, 2], actual: ${nativeMap["b"]}');
      expect(nativeMap['b'], equals([1, 2]));

      print('toJson["c"] - expected: {"nested": "value"}, actual: ${nativeMap["c"]}');
      expect(nativeMap['c'], equals({'nested': 'value'}));

      final minified = jsonObject.toJsonString;
      final reparsed = jsonDecode(minified) as Map<String, dynamic>;
      print('toJsonString reparsed["a"] - expected: 10, actual: ${reparsed["a"]}');
      expect(reparsed['a'], equals(10));

      print('toJsonString reparsed["b"] - expected: [1, 2], actual: ${reparsed["b"]}');
      expect(reparsed['b'], equals([1, 2]));

      print('toJsonString reparsed["c"] - expected: {"nested": "value"}, actual: ${reparsed["c"]}');
      expect(reparsed['c'], equals({'nested': 'value'}));
    });

    test('get throws UnsupportedError on wrong type usage', () {
      const jsonString = '{"obj": {"key": 5}, "arr": [1, 2, 3]}';
      final jsonObject = JsonObject.fromJsonString(jsonString);

      print('Expecting get("obj") to throw UnsupportedError');
      expect(
        () => jsonObject.get('obj'),
        throwsA(isA<UnsupportedError>()),
      );

      print('Expecting get("arr") to throw UnsupportedError');
      expect(
        () => jsonObject.get('arr'),
        throwsA(isA<UnsupportedError>()),
      );
    });

    test('getObject returns empty on null and throws on wrong type', () {
      const jsonString = '{"maybeNull": null, "notObj": 123}';
      final jsonObject = JsonObject.fromJsonString(jsonString);

      final emptyObj = jsonObject.getObject('maybeNull');
      print('getObject("maybeNull").isEmpty - expected: true, actual: ${emptyObj.isEmpty}');
      expect(emptyObj.isEmpty, isTrue);

      print('Expecting getObject("notObj") to throw UnsupportedError');
      expect(
        () => jsonObject.getObject('notObj'),
        throwsA(isA<UnsupportedError>()),
      );
    });

    test('getList returns empty on null and throws on wrong type', () {
      const jsonString = '{"maybeNull": null, "notList": "text"}';
      final jsonObject = JsonObject.fromJsonString(jsonString);

      final emptyList = jsonObject.getList('maybeNull');
      print('getList("maybeNull").isEmpty - expected: true, actual: ${emptyList.isEmpty}');
      expect(emptyList.isEmpty, isTrue);

      print('Expecting getList("notList") to throw UnsupportedError');
      expect(
        () => jsonObject.getList('notList'),
        throwsA(isA<UnsupportedError>()),
      );
    });

    test('fromJsonString throws on null or invalid JSON', () {
      print('Expecting fromJsonString(null) to throw ArgumentError');
      expect(
        () => JsonObject.fromJsonString(null),
        throwsA(isA<ArgumentError>()),
      );

      print('Expecting fromJsonString("not a json") to throw FormatException');
      expect(
        () => JsonObject.fromJsonString('not a json'),
        throwsA(isA<FormatException>()),
      );

      print('Expecting fromJsonString("[\\"a\\", \\"b\\"]") to throw FormatException');
      expect(
        () => JsonObject.fromJsonString('["a", "b"]'),
        throwsA(isA<FormatException>()),
      );
    });
  });
}
