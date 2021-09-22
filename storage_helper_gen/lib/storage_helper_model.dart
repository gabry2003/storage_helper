import 'package:storage_helper_gen/storage_helper_category.dart';
import 'package:storage_helper_gen/storage_helper_custom_type.dart';

/// This is fundamental to StorageHelper, this is where it all starts
/// This is to make the generator understand how to create the classes
/// It gives the information to each class for the date format, to know whether or not to log the operations on the screen and (**important**) to convert from string to custom types and vice versa
/// Even more important is to specify that it is passed to the constructor of the generated class to work
///
/// Es.
///
/// ``` dart
/// // storage_helper.dart
///
/// @StorageHelperBuilder(storageModel)
/// StorageHelperModel storageModel = StorageModel(
///   categories: [
///     StorageHelperCategory(
///       elements: [
///         StorageHelperElement<StorageHelperType>(key: "firstTime", type: StorageHelperType.bool, description: "It is used to know if this is the first time the app has been opened")
///       ]
///     ),
///     StorageHelperCategory(  // Child of main category
///       key: "userInfo",
///       elements: [
///         StorageHelperElement<StorageHelperType>(key: "name", type: StorageHelperType.String, description: "User name entered in settings")
///       ]
///     ),
///     StorageHelperCategory(  // Child of category "userInfo",
///       parent: "userInfo",
///       key: "generalInfo",
///       elements: [
///         StorageHelperElement<StorageHelperType>(key: "height", type: StorageHelperType.double, description: "User height entered in settings")
///       ]
///     )
///   ]
/// );
/// ```
///
/// ``` dart
/// // page.dart
///
/// import 'storage_helper.dart';
///
/// void main() async {
///   StorageHelper storageHelper = new StorageHelper(storageModel);
///
///   StorageHelperUserInfo userInfo = new StorageHelperUserInfo(storageModel); // Method 1
///   userInfo = storageHelper.userInfo;  // Method 2
///
///   StorageHelperGeneralInfo generalInfo = new StorageHelperGeneralInfo(storageModel); // Method 1
///   generalInfo = userInfo.generalInfo; // Method 2
///   generalInfo = storageHelper.userInfo.generalInfo; // Method 3
///
///   // Principal category
///   bool firstTime = await storageHelper.firstTime; // Method 1
///   firstTime = await storageHelper.getFirstTime(); // Method 2
///
///   // Sub category
///   String name = await userInfo.name; // Method 1
///   name = await userInfo.getName(); // Method 2
///   name = await storageHelper.userInfo.name;  // Method 3
///   name = await storageHelper.userInfo.getName();  // Method 4
///
///   // Sub sub category
///   double height = await generalInfo.height; // Method 1
///   height = await generalInfo.getHeight(); // Method 2
///   height = await userInfo.generalInfo.height; // method 3
///   height = await userInfo.generalInfo.getHeight();  // Method 4
///   height = await storageHelper.userInfo.generalInfo.height(); // Method 5
///   height = await storageHelper.userInfo.generalInfo.getHeight();  // Method 6
///
///   // ecc...
/// }
/// ```
///
/// As you can see there are more ways to access the same information and the further down the category tree, the more methods there are, you decide which one you like best :)
/// The same is true for the set method
class StorageHelperModel {
  /// Item Category List, See Also [StorageHelperCategory]
  /// Es.
  /// ``` dart
  /// @StorageHelperBuilder(storageModel)
  /// StorageHelperModel storageModel = StorageHelperModel(
  ///   // Previous code for constructor
  ///   categories: [
  ///     StorageHelperCategory(...)
  ///   ]
  ///   // Next code for constructor
  /// );
  /// ```
  final List<StorageHelperCategory?> categories;
  /// Map containing custom types that are used by elements
  /// Each key identifies the type and then the key present in this Map must be inserted as a type in the element
  /// Es.
  ///
  /// ``` dart
  /// @StorageHelperBuilder(storageModel)
  /// StorageHelperModel storageModel = StorageHelperModel(
  ///   // Previous code for constructor
  ///   customTypes: {
  ///     "MyClass": StorageHelperCustomType(...)
  ///   }
  ///   // Next code for constructor
  /// );
  /// ```
  ///
  /// See also [StorageHelperCustomType]
  final Map<String, StorageHelperCustomType>? customTypes;
  /// Whether to log on the screen of the operations of writing, reading, deleting
  final bool? log;
  /// If use secure on saving data
  final bool secure;
  /// Date format, default is yyyy-MM-dd
  final String? dateFormat;

  /// Constructor, accepts all attributes as parameters
  const StorageHelperModel({required this.categories, this.customTypes, this.log=true, this.secure = true, this.dateFormat="yyyy-MM-dd"});

  /// Given the [key] of the custom type, it returns the custom type from the Map, if present
  StorageHelperCustomType? getType(String key) {
    try {
      return customTypes?[key];
    } catch(e) {
      return null;
    }
  }

  /// Returns the attributes of the object as a Map
  /// Useful for printing the entire object in a single call
  Map<String, dynamic> get toMap => {
    "categories": categories.map(
        (StorageHelperCategory? category) => category?.toMap
    ).toList(),
    "customTypes": customTypes,
    "log": log,
    "dateFormat": dateFormat
  };
}