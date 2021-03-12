/// Element to be inserted into a category
/// It is used to make StorageHelper understand the methods and the possible attribute to insert in the generated class
/// Pass the type `T` which indicates the type of element
/// `T` can only be` StorageHelperType` or `String`
/// If it uses a custom type defined in the model map enter the key to get it in the model (String)
class StorageHelperElement<T> {
  /// Identification key of the element
  /// Obviously each element must have a [key]
  /// Obviously there cannot be more elements with the same [key]
  final String key;
  /// Key to insert in the static variable (optional)
  /// If not entered it will be the key from camelCase to Delimiter-separated to UpperCase
  final String? staticKey;
  /// Attribute name for getters and setters (optional)
  /// To be entered if you want to use a name other than the key
  final String? getKey;
  /// Keys to concatenate in getters and setters
  /// To be used if in the gets and sets you want to concatenate the key with the keys of elements inserted in the init
  final List<String?>? concateneKeys;
  /// Data type of the element
  /// This is for StorageHelper to figure out how to do the conversions
  /// Can be of type `StorageHelperType` or` String`
  final T type;
  /// If the element is to be inserted as an attribute and is to be initialized in the init method
  /// It can be useful in case you want to access that element without making an asynchronous call, but initializing all attributes in one call
  final bool? onInit;
  /// Element description, each element of the list is a description line (optional)
  final List<String?>? description;
  /// Default value of the element (optional)
  /// On elements with custom type or if [defaultIsCode] is true a piece of code (string) must be inserted here to create the object
  /// Es.
  /// ``` dart
  /// new MyClass(55)
  /// ```
  /// The piece of code must not be empty and must not end with ";"
  final dynamic? defaultValue;
  /// If the default is a piece of code
  final bool? defaultIsCode;
  /// It is used when this specific element (of type DateTime) must have a different date format
  final String? dateFormat;

  /// Constructor, accepts all attributes as parameters
  const StorageHelperElement({required this.key, this.staticKey, this.getKey, this.concateneKeys, required this.type, this.onInit=false, this.description, this.defaultValue, this.defaultIsCode=false, this.dateFormat});

  /// Returns the attributes of the object as a Map
  /// Useful for printing the entire object in a single call
  Map<String, dynamic> get toMap => {
    "key": key,
    "staticKey": staticKey,
    "getKey": getKey,
    "concateneKeys": concateneKeys,
    "type": type,
    "onInit": onInit,
    "description": description,
    "defaultValue": defaultValue,
    "defaultIsCode": defaultIsCode,
    "dateFormat": dateFormat
  };
}