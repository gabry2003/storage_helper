import 'package:storage_helper_gen/storage_helper_model.dart';

/// Annotation to be interpreted from generator
/// Es. of code
/// ``` dart
/// @StorageHelperBuilder(storageModel)
/// StorageHelperModel storageModel = StorageHelperModel(...)
/// ```
class StorageHelperBuilder {
  /// StorageHelper's model
  final StorageHelperModel model;

  /// Constructor, it takes [model] as parameter
  const StorageHelperBuilder(this.model);
}