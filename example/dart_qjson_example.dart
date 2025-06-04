import 'package:dart_qjson/dart_qjson.dart';
import 'package:dart_qvariant/dart_qvariant.dart';

void main() {
  // Example 1: Parsing JsonObject
  const userJson = '''
  {
    "user": {
      "id": 42,
      "name": "Alice",
      "active": true,
      "balance": 123.45,
      "signupDate": "2024-01-01T12:00:00"
    },
    "tags": ["dart", "qt", "json"],
    "nestedList": [
      {"key": "value"},
      [1, 2, 3],
      null
    ]
  }
  ''';

  // Parse into JsonObject
  final jsonObject = JsonObject.fromJsonString(userJson);

  // Access primitive values inside "user" object
  final userObj = jsonObject.getObject('user');
  final idVariant = userObj.get('id');
  print('User ID: ${idVariant.toInt()}');           // prints: User ID: 42

  final nameVariant = userObj.get('name');
  print('User Name: ${nameVariant.toString()}');     // prints: User Name: Alice

  final activeVariant = userObj.get('active');
  print('Is Active: ${activeVariant.toBoolean()}');  // prints: Is Active: true

  final balanceVariant = userObj.get('balance');
  print('Balance: ${balanceVariant.toDouble()}');    // prints: Balance: 123.45

  // Parse signupDate into DateTime
  final dateVariant = userObj.get('signupDate');
  final signupDate = dateVariant.toDateTime();
  print('Signup Date (ISO): ${signupDate?.toIso8601String()}'); 
  // prints: Signup Date (ISO): 2024-01-01T12:00:00.000

  // Access a JsonList stored under "tags"
  final tagsList = jsonObject.getList('tags');
  print('Tags count: ${tagsList.length}');            // prints: Tags count: 3
  print('First tag: ${tagsList.get(0).toString()}');   // prints: First tag: dart

  // Show full JSON as native Map
  final nativeMap = jsonObject.toJson;
  print('Native Map: $nativeMap');
  // prints: Native Map: {user: {id: 42, name: Alice, active: true, balance: 123.45, signupDate: 2024-01-01T12:00:00}, tags: [dart, qt, json], nestedList: [{key: value}, [1, 2, 3], null]}

  // Example 2: Parsing JsonList directly
  const listJson = '''
  [
    {"id": 1, "title": "First"},
    {"id": 2, "title": "Second"},
    99,
    "hello world",
    [10, 20, 30]
  ]
  ''';

  final jsonList = JsonList.fromJsonString(listJson);

  // Access first element as JsonObject
  final firstItem = jsonList.getObject(0);
  print("First item ID: ${firstItem.get("id").toInt()}");         // prints: First item ID: 1
  print("First item title: ${firstItem.get("title").toString()}"); // prints: First item title: First

  // Access third element as primitive Variant (99)
  final numberVariant = jsonList.get(2);
  print('Number: ${numberVariant.toInt()}');                       // prints: Number: 99

  // Access fourth element as string
  final textVariant = jsonList.get(3);
  print('Text: ${textVariant.toString()}');                         // prints: Text: hello world

  // Access nested list at index 4
  final nested = jsonList.getList(4);
  print('Nested list length: ${nested.length}');                    // prints: Nested list length: 3
  print('Nested[1]: ${nested.get(1).toInt()}');                      // prints: Nested[1]: 20

  // Demonstrate toNumericString on a Variant
  final numericVariant = Variant('3.141590');
  print('Rounded numeric string: ${numericVariant.toNumericString(roundCount: 3)}'); 
  // prints: Rounded numeric string: 3.142

  // Iterate through entire JsonList and print each Variant-or-structure
  for (var i = 0; i < jsonList.length; i++) {
    final element = jsonList.get(i);
    print('Element[$i] as Variant: ${element.toString()}');
  }
  // Note: if an element is Map or List, calling get(i) will throw UnsupportedError.
  // In that case, use getObject(i) or getList(i) to handle nested structures.
}
