/// Function that converts from string to `T`
/// Returns an object of type `T` once the [value] parameter of type` String` is taken
typedef T StorageHelperCustomFromStringFunction<T>(String? value);
/// Function that converts from string to `T`
/// Return a string once the [value] parameter of type `T` is taken
typedef String? StorageHelperCustomToStringFunction<T>(T value);

/// This is to make StorageHelper understand how to convert the object to a string and vice versa
class StorageHelperCustomType<T> {
  /// Function that converts string to `T`
  final StorageHelperCustomFromStringFunction<T> convertFromString;
  /// Function that converts `T` to string
  final StorageHelperCustomToStringFunction<T> convertToString;

  /// Constructor, accepts all attributes as parameters
  const StorageHelperCustomType({required this.convertFromString, required this.convertToString});
}