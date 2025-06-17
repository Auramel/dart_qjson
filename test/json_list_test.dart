import 'dart:convert';

import 'package:test/test.dart';
import 'package:dart_qjson/src/json_list.dart';

void main() {
  group('JsonList', () {
    test('parses valid JSON array and retrieves values', () {
      const jsonArray = '[{"id": 1, "name": "A"}, {"id": 2, "name": "B"}, 100, "text"]';
      final jsonList = JsonList.fromJsonString(jsonArray);

      print('JSON');
      print(jsonArray);

      final lengthActual = jsonList.length;
      final lengthExpected = 4;
      print('length - expected: $lengthExpected, actual: $lengthActual');
      expect(lengthActual, equals(lengthExpected));

      final isEmptyActual = jsonList.isEmpty;
      final isEmptyExpected = false;
      print('isEmpty - expected: $isEmptyExpected, actual: $isEmptyActual');
      expect(isEmptyActual, equals(isEmptyExpected));

      final isNotEmptyActual = jsonList.isNotEmpty;
      final isNotEmptyExpected = true;
      print('isNotEmpty - expected: $isNotEmptyExpected, actual: $isNotEmptyActual');
      expect(isNotEmptyActual, equals(isNotEmptyExpected));

      // First element
      final firstObj = jsonList.getObject(0);
      final idVar = firstObj?.get('id');
      final idActual = idVar?.toInt();
      final idExpected = 1;
      print('firstObj.id - expected: $idExpected, actual: $idActual');
      expect(idActual, equals(idExpected));

      final nameVar = firstObj?.get('name');
      final nameActual = nameVar.toString();
      final nameExpected = 'A';
      print('firstObj.name - expected: "$nameExpected", actual: "$nameActual"');
      expect(nameActual, equals(nameExpected));

      // Second element
      final secondObj = jsonList.getObject(1);
      final secondIdActual = secondObj?.get('id')?.toInt();
      final secondIdExpected = 2;
      print('secondObj.id - expected: $secondIdExpected, actual: $secondIdActual');
      expect(secondIdActual, equals(secondIdExpected));

      // Third element
      final numVariant = jsonList.get(2);
      final numActual = numVariant?.toInt();
      final numExpected = 100;
      print('element[2] - expected: $numExpected, actual: $numActual');
      expect(numActual, equals(numExpected));

      // Fourth element
      final textVariant = jsonList.get(3);
      final textActual = textVariant.toString();
      final textExpected = 'text';
      print('element[3] - expected: "$textExpected", actual: "$textActual"');
      expect(textActual, equals(textExpected));
    });

    test('toJson and toJsonString return correct representations', () {
      const jsonArray = '[1, 2, {"k": "v"}]';
      final jsonList = JsonList.fromJsonString(jsonArray);

      final nativeList = jsonList.toJson;
      print('toJson[0] - expected: 1, actual: ${nativeList[0]}');
      expect(nativeList[0], equals(1));

      print('toJson[1] - expected: 2, actual: ${nativeList[1]}');
      expect(nativeList[1], equals(2));

      print('toJson[2] - expected: {"k":"v"}, actual: ${nativeList[2]}');
      expect(nativeList[2], equals({'k': 'v'}));

      final str = jsonList.toJsonString;
      final reparsed = jsonDecode(str) as List<dynamic>;
      print('toJsonString reparsed[0] - expected: 1, actual: ${reparsed[0]}');
      expect(reparsed[0], equals(1));

      print('toJsonString reparsed[1] - expected: 2, actual: ${reparsed[1]}');
      expect(reparsed[1], equals(2));

      print('toJsonString reparsed[2] - expected: {"k":"v"}, actual: ${reparsed[2]}');
      expect(reparsed[2], equals({'k': 'v'}));
    });

    test('get throws UnsupportedError on wrong type usage', () {
      const jsonArray = '[{"id": 1}, [10, 20], null]';
      final jsonList = JsonList.fromJsonString(jsonArray);

      print('Expecting get(0) to throw UnsupportedError');
      expect(
        () => jsonList.get(0),
        throwsA(isA<UnsupportedError>()),
      );

      print('Expecting get(1) to throw UnsupportedError');
      expect(
        () => jsonList.get(1),
        throwsA(isA<UnsupportedError>()),
      );
    });

    test('getObject returns empty on null and throws on wrong type', () {
      const jsonArray = '[null, 123]';
      final jsonList = JsonList.fromJsonString(jsonArray);

      final emptyObj = jsonList.getObject(0);
      print('getObject(0).isEmpty - expected: null, actual: ${emptyObj?.isEmpty}');
      expect(emptyObj?.isEmpty, isNull);

      print('Expecting getObject(1) to throw UnsupportedError');
      expect(
        () => jsonList.getObject(1),
        throwsA(isA<UnsupportedError>()),
      );
    });

    test('getList returns empty on null and throws on wrong type', () {
      const jsonArray = '[null, {"k": "v"}]';
      final jsonList = JsonList.fromJsonString(jsonArray);

      final emptyList = jsonList.getList(0);
      print('getList(0).isEmpty - expected: null, actual: ${emptyList?.isEmpty}');
      expect(emptyList?.isEmpty, isNull);

      print('Expecting getList(1) to throw UnsupportedError');
      expect(
        () => jsonList.getList(1),
        throwsA(isA<UnsupportedError>()),
      );
    });

    test('contains and index range', () {
      const jsonArray = '[0, 1, 2]';
      final jsonList = JsonList.fromJsonString(jsonArray);

      final contains0Actual = jsonList.contains(0);
      final contains0Expected = true;
      print('contains(0) - expected: $contains0Expected, actual: $contains0Actual');
      expect(contains0Actual, equals(contains0Expected));

      final contains2Actual = jsonList.contains(2);
      final contains2Expected = true;
      print('contains(2) - expected: $contains2Expected, actual: $contains2Actual');
      expect(contains2Actual, equals(contains2Expected));

      final contains3Actual = jsonList.contains(3);
      final contains3Expected = false;
      print('contains(3) - expected: $contains3Expected, actual: $contains3Actual');
      expect(contains3Actual, equals(contains3Expected));

      final containsNegActual = jsonList.contains(-1);
      final containsNegExpected = false;
      print('contains(-1) - expected: $containsNegExpected, actual: $containsNegActual');
      expect(containsNegActual, equals(containsNegExpected));

      print('Expecting get(3) to throw RangeError');
      expect(
        () => jsonList.get(3),
        throwsA(isA<RangeError>()),
      );
    });

    test('fromJsonString throws on null or invalid JSON', () {
      print('Expecting fromJsonString(null) to throw ArgumentError');
      expect(
        () => JsonList.fromJsonString(null),
        throwsA(isA<ArgumentError>()),
      );

      print('Expecting fromJsonString("not a json") to throw FormatException');
      expect(
        () => JsonList.fromJsonString('not a json'),
        throwsA(isA<FormatException>()),
      );

      print('Expecting fromJsonString("{\\"a\\": 1}") to throw FormatException');
      expect(
        () => JsonList.fromJsonString('{"a": 1}'),
        throwsA(isA<FormatException>()),
      );
    });
  });
}
