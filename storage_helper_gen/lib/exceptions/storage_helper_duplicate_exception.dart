import 'package:storage_helper_gen/exceptions/storage_helper_exception.dart';

/// Exception for duplicates key
class StorageHelperDuplicateException extends StorageHelperException {
  /// Type of duplicates key
  /// Es.
  /// "elements"
  late String type;

  StorageHelperDuplicateException(type) : super("There cannot be multiple $type with same key!");
}