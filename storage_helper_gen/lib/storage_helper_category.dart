import 'package:storage_helper_gen/storage_helper_element.dart';

/// StorageHelper'scategory, to be inserted into the model
/// Each category is identified by the [key]
/// Each category can have multiple sub-categories and to do this in each category the [parent] can be inserted to indicate that she is the daughter of that [parent].
/// The category can also have a [description], which will be a list of strings, where each element is a line of the description.
/// The description is then inserted into the comments in the generated code.
/// Each category is composed of the [elements], that is a list of objects that describe all the keys, data types etc ... used on FlutterSecureStorage.
/// **optional**
/// In a category you can add a piece of custom code, called [addSource], which will be added to the class inside the generated code
class StorageHelperCategory {
  /// If the [parent] is not entered and is not the parent category, all categories are children of the parent category.
  final String parent;
  /// If the [key] is not entered, it is identified as the main category.
  /// Obviously there can only be one category without [key] because there can only be one main category.
  /// Obviously there cannot be multiple categories with the same [key].
  final String key;
  /// Category's description, each item is a description line (optional)
  final List<String> description;
  /// Optional code to add
  final String addSource;
  /// A list of objects that describe all the keys, data types etc ... used on FlutterSecureStorage.
  /// Watch also [StorageHelperElement]
  final List<StorageHelperElement> elements;

  /// Constructor, accepts all attributes as parameters
  const StorageHelperCategory({this.parent, this.key, this.description, this.addSource, this.elements});

  /// Returns the attributes of the object as a Map
  /// Useful for printing the entire object in a single call
  Map<String, dynamic> get toMap => {
    "parent": parent,
    "key": key,
    "description": description,
    "addSource": addSource,
    "elements": elements.map(
            (StorageHelperElement element) => element?.toMap
    )
  };
}