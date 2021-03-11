// ignore: import_of_legacy_library_into_null_safe
import 'package:build/build.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:source_gen/source_gen.dart';
import 'package:storage_helper_gen/storage_helper_generator.dart';

Builder storageHelperBuilder(BuilderOptions options) => new SharedPartBuilder([new StorageHelperGenerator()], 'storage_helper');