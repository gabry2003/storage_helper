import 'package:storage_helper_gen/exceptions/storage_helper_exception.dart';

/// Exception for null element
class StorageHelperNullException extends StorageHelperException {
  /// Name of element
  late String elName;

  StorageHelperNullException(elName) : super("$elName cannot be null!");
}