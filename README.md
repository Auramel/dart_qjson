dart\_qjson
===========

A Qt-style immutable JSON handling library for Dart.  
Provides two primary classes—`JsonObject` and `JsonList`—that wrap Dart’s built-in JSON structures in an immutable, type-safe API. Both classes expose convenient methods for parsing JSON strings, accessing nested values as `Variant` (from `dart_qvariant`), and retrieving sub-objects or sub-lists without direct mutation.

* * *

Features
--------

*   **Immutable data**  
    Internally wraps a `Map<String, dynamic>` or `List<dynamic>` and exposes only unmodifiable views. Once created, contents cannot be changed.
*   **Type-safe retrieval**  
    Primitive values (string, int, double, bool, etc.) are returned as `Variant`, preserving runtime type checks. Nested objects/lists are returned as `JsonObject`/`JsonList`.
*   **Clear exceptions**
    *   Throws `ArgumentError` if a `null` JSON string is passed to a factory.
    *   Throws `FormatException` if parsing fails or the decoded JSON is not the expected shape.
    *   Throws `UnsupportedError` when attempting to retrieve a nested structure with the wrong method (e.g., calling `get` on a `Map`).
    *   Throws `RangeError` when an index is out of bounds in `JsonList`.
*   **Convenient API**
    *   `JsonObject.fromJsonString(String)` → parse a JSON object string.
    *   `JsonList.fromJsonString(String)` → parse a JSON array string.
    *   `get(key)` / `get(index)` → return a `Variant` for primitive values.
    *   `getObject(key)` / `getObject(index)` → return a nested `JsonObject`.
    *   `getList(key)` / `getList(index)` → return a nested `JsonList`.
    *   Properties: `isEmpty`, `isNotEmpty`, `keys`, `length`, `toJson`, `toJsonString`, `containsKey`, `containsIndex`.

Usage
-----

### JsonObject

Wraps a JSON object (`Map<String, dynamic>`) in an immutable API.

#### Parsing from a JSON string

    final jsonString = '''
    {
      "user": {
        "id": 1,
        "name": "Alice",
        "active": true
      },
      "tags": ["dart", "qt", "json"]
    }
    ''';
    
    final obj = JsonObject.fromJsonString(jsonString);
    

**Behavior:**  

*   If `jsonString` is `null`, an `ArgumentError` is thrown.
*   If `jsonString` is not valid JSON or does not decode to a `Map`, a `FormatException` is thrown.

#### Accessing primitive values

    // Retrieve a nested object first
    final userObj = obj.getObject("user");
    
    // Get an integer (wrapped in Variant)
    final idVariant = userObj.get("id");
    print(idVariant.toInt()); // prints: 1
    
    // Get a boolean
    final activeVariant = userObj.get("active");
    print(activeVariant.toBoolean()); // prints: true
    
    // Get a string
    final nameVariant = userObj.get("name");
    print(nameVariant.toString()); // prints: Alice
    

If you accidentally call `get("user")` instead of `getObject("user")`, it throws:  
`UnsupportedError: Value for key "user" is a Map; use getObject("user") instead.`

#### Accessing nested lists

    final tagsList = obj.getList("tags");
    
    // Retrieve a primitive from the list:
    final firstTag = tagsList.get(0).toString();
    print(firstTag); // prints: dart
    

If you call `obj.get("tags")`, it throws:  
`UnsupportedError: Value for key "tags" is a List; use getList("tags") instead.`

#### Other properties and methods

    // Check for key existence
    print(obj.containsKey("user")); // true
    print(obj.containsKey("missing")); // false
    
    // Retrieve all keys
    print(obj.keys); // ["user", "tags"]
    
    // Get a plain, immutable Dart Map
    final nativeMap = obj.toJson;
    // nativeMap is a Map that cannot be modified
    
    // Get a JSON string (minified)
    print(obj.toJsonString); // {"user":{"id":1,"name":"Alice","active":true},"tags":["dart","qt","json"]}
    

### JsonList

Wraps a JSON array (`List<dynamic>`) in an immutable API.

#### Parsing from a JSON string

    final jsonArray = '''
    [
      {"id": 100, "name": "ItemA"},
      {"id": 101, "name": "ItemB"},
      42,
      "hello"
    ]
    ''';
    
    final list = JsonList.fromJsonString(jsonArray);
    

**Behavior:**  

*   Throws `ArgumentError` if the string is `null`.
*   Throws `FormatException` if it is not valid JSON or not a `List`.

#### Accessing primitives

    // At index 2, there is the integer 42
    final numberVariant = list.get(2);
    print(numberVariant.toInt()); // prints: 42
    
    // At index 3, there is the string "hello"
    final textVariant = list.get(3);
    print(textVariant.toString()); // prints: hello
    

If you call `list.get(0)` but the item at index 0 is an object or list, you’ll see:  
`UnsupportedError: Value at index 0 is a Map; use getObject(0) instead.`

#### Accessing nested JsonObject / JsonList

    // Index 0 holds an object
    final firstObj = list.getObject(0);
    print(firstObj.get("id").toInt()); // prints: 100
    
    // A nested list example:
    final nestedListJson = '[[1, 2, 3], ["a", "b"], null]';
    final nestedList = JsonList.fromJsonString(nestedListJson);
    
    final inner = nestedList.getList(0);
    print(inner.get(1).toInt()); // prints: 2
    
    // If the element is null:
    final maybeEmpty = nestedList.getList(2);
    print(maybeEmpty.isEmpty); // true
    

#### Other properties and methods

    // Get length:
    print(list.length); // e.g. 4
    
    // Check if index exists:
    print(list.contains(3)); // true
    print(list.contains(5)); // false
    
    // Get a Dart List copy:
    final nativeList = list.toJson;
    // nativeList is a List that cannot be modified
    
    // Get JSON string:
    print(list.toJsonString); // [{"id":100,"name":"ItemA"},{"id":101,"name":"ItemB"},42,"hello"]
    

* * *