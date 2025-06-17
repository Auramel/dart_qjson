dart\_qjson
===========

Immutable JSON wrapper for Dart with Qt-style API. Inspired by `QJsonObject` and `QJsonArray` from Qt. Designed to work with `Variant` types from [dart\_qvariant](https://pub.dev/packages/dart_qvariant).

* * *

Features
--------

*   Immutable `JsonObject` and `JsonList` wrappers
*   Safe access to values using `Variant`
*   Strong separation of primitives, lists, and objects
*   Supports parsing from JSON string
*   Converts back to Dart map/list or JSON string

* * *

Installation
------------

    dart pub add dart_qjson

* * *

Example (Dart)
--------------

    import 'package:dart_qjson/dart_qjson.dart';
    
    void main() {
      final jsonString = '''
      {
        "user": {
          "id": 1,
          "name": "Alice",
          "isActive": true
        },
        "tags": ["dart", "flutter"],
        "score": 42.5,
        "metadata": null
      }
      ''';
    
      final jsonObject = JsonObject.fromJsonString(jsonString);
    
      final user = jsonObject.getObject("user");
      print("User ID: ${user?.get("id")?.toInt()}");
      print("User Name: ${user?.get("name")?.toText()}");
    
      final tags = jsonObject.getList("tags");
      for (var i = 0; i < (tags?.length ?? 0); i++) {
        print("Tag $i: ${tags?.get(i)?.toText()}");
      }
    
      final score = jsonObject.get("score");
      print("Score: ${score?.toDouble()}");
    
      final metadata = jsonObject.get("metadata");
      print("Metadata is null: ${metadata == null}");
    
      print("Back to JSON: ${jsonObject.toJsonString}");
    }