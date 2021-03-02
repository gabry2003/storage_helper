import 'package:storage_helper_gen/storage_helper_category.dart';
import 'package:storage_helper_gen/storage_helper_custom_type.dart';

class StorageHelperModel {
  final List<StorageHelperCategory> categories;
  final Map<String, StorageHelperCustomType> customTypes;
  final bool log;
  final String dateFormat;

  const StorageHelperModel({this.categories, this.customTypes, this.log=true, this.dateFormat="yyyy-MM-dd"});

  StorageHelperCustomType getType(String key) => customTypes[key];

  Map<String, dynamic> get toMap => {
    "categories": categories.map(
        (StorageHelperCategory category) => category?.toMap
    ).toList(),
    "customTypes": customTypes,
    "log": log,
    "dateFormat": dateFormat
  };
}