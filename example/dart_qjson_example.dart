import 'package:dart_qjson/dart_qjson.dart';

void main() {
  // A JSON string with nested objects and arrays
  final jsonString = '''
  {
    "user": {
      "id": 1,
      "name": "Alice",
      "isActive": true
    },
    "tags": ["dart", "flutter", "qt"],
    "score": 42.5,
    "metadata": null
  }
  ''';

  // Parse the JSON string into a JsonObject
  final jsonObject = JsonObject.fromJsonString(jsonString);

  // Access a nested object
  final user = jsonObject.getObject('user');
  print("User ID: ${user?.get("id")?.toInt()}");        // 1
  print("User Name: ${user?.get("name")?.toText()}");    // Alice
  print("Is Active: ${user?.get("isActive")?.toBoolean()}"); // true

  // Access a nested list
  final tags = jsonObject.getList('tags');
  for (var i = 0; i < (tags?.length ?? 0); i++) {
    print('Tag $i: ${tags?.get(i)?.toText()}');
  }

  // Access a primitive value
  final score = jsonObject.get('score');
  print('Score: ${score?.toDouble()}'); // 42.5

  // Check for null
  final metadata = jsonObject.get('metadata');
  print('Metadata is null: ${metadata == null}'); // true

  // Convert back to JSON string
  final jsonOut = jsonObject.toJsonString;
  print('Serialized JSON: $jsonOut');
}
