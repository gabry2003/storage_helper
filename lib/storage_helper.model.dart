import 'package:flutter/cupertino.dart';
import 'package:storage_helper/storage_helper_custom_type.dart';
import 'package:storage_helper/storage_helper_element.dart';

class StorageHelperModel {
  final List<StorageHelperElement> elements;
  final Map<String, StorageHelperCustomType> customTypes;
  final bool log;
  final String dateFormat;

  StorageHelperModel({@required this.elements, this.customTypes, this.log=true, this.dateFormat="yyyy-MM-dd"});

  StorageHelperCustomType getType(String key) => customTypes[key];
}