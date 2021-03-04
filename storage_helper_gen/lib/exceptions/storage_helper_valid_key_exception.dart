import 'package:storage_helper_gen/exceptions/storage_helper_exception.dart';

/// Exception for not valid key
class StorageHelperValidKeyException extends StorageHelperException {
  /// Key which is not valid
  String key;

  StorageHelperValidKeyException(key) : super("Not valid key, \"$key\" is not valid");
}