/// It is to save the code to add to add the subcategories as attributes
/// [parentKey] indicates in which category to add the code
/// [code] is the code to add into the class
/// [constructorCode] is the code to add inside the constructor of the class
class StorageHelperCategoryChild {
  /// Parent's key
  final String parentKey;
  /// Code to insert
  final String? code;
  /// code to insert in the constructor
  final String? constructorCode;
  /// code to insert in the init method
  final String? onInit;
  /// code to insert in toMap method
  final String? toMap;

  /// Constructor, accepts all attributes as parameters
  const StorageHelperCategoryChild({required this.parentKey, this.code, this.constructorCode, this.onInit, this.toMap});
}