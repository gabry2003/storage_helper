import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';
import 'package:storage_helper_gen/exceptions/storage_helper_duplicate_exception.dart';
import 'package:storage_helper_gen/exceptions/storage_helper_null_exception.dart';
import 'package:storage_helper_gen/exceptions/storage_helper_valid_key_exception.dart';
import 'package:storage_helper_gen/storage_helper_builder.dart';
import 'package:storage_helper_gen/storage_helper_category.dart';
import 'package:storage_helper_gen/storage_helper_category_child.dart';
import 'package:storage_helper_gen/storage_helper_element.dart';
import 'package:storage_helper_gen/utils/storage_helper_gen_converter.dart';
import 'package:storage_helper_gen/utils/storage_helper_log.dart';
import 'package:storage_helper_gen/storage_helper_model.dart';

import 'exceptions/storage_helper_exception.dart';

/// StorageHelper's generator
class StorageHelperGenerator extends GeneratorForAnnotation<StorageHelperBuilder> {
  /// Converter from DartObject
  StorageHelperGenConverter converter = new StorageHelperGenConverter();
  /// Sub-categories
  List<StorageHelperCategoryChild> sottocategorie = [];
  /// List of all categories keys
  /// It is used to check that there are no categories with the same key
  List<String> categoriesKeys = [];
  /// Sub-categories example
  String subCategoriesExample = "";
  /// Get code example
  String getExample = "";
  /// Set code example
  String setExample = "";
  /// Delete code example
  String deleteExample = "";
  /// Number of categories without key
  /// Only one can be and it is the main one
  int countAnonymous = 0;

  /// Returns the [text] with the first character uppercase
  String upperFirst(String text) => "${text[0].toUpperCase()}${text.substring(1)}";
  /// Returns the [text] converted from camelCase to Delimiter-separated words in UpperCase
  String constantName(String text) => text.replaceAllMapped(RegExp(r'(?<=[a-z])[A-Z]'), (Match m) => ('_' + m.group(0))).toUpperCase();

  /// Return `true` if the [key] is in a valid format to be inserted into the code
  /// Otherwise it returns `false`
  bool validKey(String key) {
    // The key cannot start with a number
    // Cannot contain spaces
    // Cannot contain special characters
    // Cannot start with an underscore
    if(key == null) return false;

    if(key[0] == "_") return false;

    return new RegExp(r"^[a-zA-Z_$][a-zA-Z_$0-9]*$",
      caseSensitive: true,
      multiLine: false,
    ).hasMatch(key);
  }

  /// Check the validity of the [code] for the default value
  /// If it is valid, return the [code]
  /// Otherwise throw an exception to tell the user to enter a valid default value for the key "[key]"
  // ignore: missing_return
  String validateDefaultValue(String code, String key) {
    Function eccezione = () {
      throw new FormatException("Please insert a valid default value for key \"$key\"");
    };

    if((code ?? "") == "") eccezione();

    if(code.trim()[code.length - 1] != ";") {
      return code;
    }else {
      eccezione();
    }
  }

  /// It is used to transform the [code] into a comment by adding a [space] in each line (optional)
  String addDartComment(String code, [String space = ""]) {
    if(code == "") return code; // If there is no piece of code I return the string as it is

    // For each line of the code to be commented I add it in the code to be returned in the form of dart-doc comment
    List<String> codeSplit = code.split("\n");

    String returnCode = "\n$space/// ``` dart";
    for(String el in codeSplit) returnCode += "\n$space/// $el";
    returnCode += "\n$space/// ```";

    return returnCode;
  }

  /// Create the class of a category
  String createClass(int index, StorageHelperCategory category) {
    /// List of all elements keys
    /// It is used to check that there are no elements with the same key
    List<String> elementsKeys = [];

    String className = "StorageHelper";
    String objName = "storageHelper";

    if(category.key != null) {  // Se è presente la chiave della categoria
      if(category.parent != null) objName += ".${category.parent}";
      objName += ".${category.key}";

      className += upperFirst(category.key);

      subCategoriesExample += "$className ${category.key} = new $className(storageModel);  // First method\n"
          "$className ${category.key}2 = ${category.parent != null ? category.parent : "storageHelper"}.${category.key}; // Second method";

      String attributesCode = "\n    // Use this attribute to access to sub-category ${category.key}";
      if((category.description?.length ?? 0) > 0) for(String desc in category.description) attributesCode += "\n    /// $desc";
      attributesCode += "\n    $className ${category.key};";

      sottocategorie.add(StorageHelperCategoryChild(
          parentKey: category.parent,
          code: attributesCode,
          constructorCode: "\n        ${category.key} = new $className(model);        // Initialize object"
      ));
    }else {
      if(countAnonymous > 0) throw new StorageHelperException("There can only be one category without a key and it is the main one");

      countAnonymous++;
    }

    setExample += "await $objName.setVariable(\"ciao\");";
    deleteExample += "await $objName.deleteVariable(); // First method\n"
        "await $objName.setVariable(null);  //  Second method";
    getExample += "String variable = await $objName.variable;  // First method\n"
        "String variable2 = await $objName.getVariable();  // Secondo method\n"
        "String variable3 = $objName.variable; // Third method, valid only for element who is initializated on init";

    List<StorageHelperElement> elements = category.elements;

    String code = "";
    if((category.description?.length ?? 0) > 0) for(String desc in category.description) code += "\n/// $desc";
    code += """\nclass $className extends StorageHelperBase {""";
    String getSet = "\n";
    String statics = "";
    String attributes = "{{sottoCategorie${index.toString()}}}";
    String init = "\n    /// You can call this method to initialize accessible elements even without asynchronous methods\n"
        "    Future<void> init() async {";

    for(StorageHelperElement element in elements) {
      if(element == null) throw new StorageHelperNullException("elements");
      if(!validKey(element.key)) throw new StorageHelperValidKeyException(element.key);

      // I check that there is no elemnets with this key
      if(elementsKeys.contains(element.key)) throw new StorageHelperDuplicateException("elements");
      elementsKeys.add(element.key);  // Add element's key to list

      String staticName = element.staticKey ?? constantName(element.key);
      String nameForGet = staticName;
      for(int i = 0;i < (element.concateneKeys?.length ?? 0);i++) {
        nameForGet += " + ${element.concateneKeys[i]}";
      }

      String variableType = "dynamic";

      String getKey = element.getKey ?? element.key;
      String firstUpper = upperFirst(getKey);
      String type;
      String defaultValue;

      if(element.type is String) { // Se l'elemento ha un tipo personalizzato
        variableType = element.type;
        type = "\"${element.type}\"";
        element.defaultValue != null ? defaultValue = validateDefaultValue(element.defaultValue, element.key) : defaultValue = "null";
      }else {
        type = element.type.toString();
        if(element.defaultIsCode ?? false) { // Se il valore di default è un pezzo di codice
          element.defaultValue != null ? defaultValue = validateDefaultValue(element.defaultValue, element.key) : defaultValue = "null";
        }else {
          defaultValue = element.defaultValue?.toString();

          switch(type) {
            case "StorageHelperType.String":
            case "StorageHelperType.DateTime":
              if(defaultValue != null && defaultValue != "null") defaultValue = "\"\"\"$defaultValue\"\"\"";
              break;
          }

          switch(type) {
            case "StorageHelperType.String":
              variableType = "String";
              break;
            case "StorageHelperType.DateTime":
              variableType = "DateTime";
              break;
            case "StorageHelperType.int":
              variableType = "int";
              break;
            case "StorageHelperType.double":
              variableType = "double";
              break;
            case "StorageHelperType.bool":
              variableType = "bool";
              break;
          }
        }
      }

      String getCode = "await get<$variableType>($nameForGet, $defaultValue);";
      String setCode = "await set<$variableType>($nameForGet, ${element.key});";

      if((element.description?.length ?? 0) > 0) for(String desc in element.description) statics += "\n    /// $desc";
      statics += "\n    static const String $staticName = \"${element.key}\";";

      getSet += "\n\n    // Getter and setter for the key \"${element.key}\"";
      if(element.onInit) {
        if((element.description?.length ?? 0) > 0) for(String desc in element.description) attributes += "\n    /// $desc";
        attributes += "\n    $variableType $getKey = $defaultValue;  // Attribute to take the key value without making an asynchronous call";
        init += "\n        ${element.key} = await get$firstUpper();  // Initially put the value inside the attribute";
      }else {
        getSet += "\n\n    /// Return value of ${element.key}\n"
            "    /// Return a variable of type \"$variableType\"\n"
            "    /// ```dart\n"
            "    /// $variableType $getKey = await $objName.${element.key};\n"
            "    /// ```\n"
            "    Future<$variableType> get $getKey async => $getCode";
      }
      getSet += "\n\n    /// Return value of ${element.key}\n"
          "    /// Return a variable of type \"$variableType\"\n"
          "    /// ```dart\n"
          "    /// $variableType ${element.key} = await $objName.get$firstUpper();\n"
          "    /// ```\n"
          "    Future<$variableType> get$firstUpper() async => $getCode"
          "\n\n    /// Insert a value into key \"${element.key}\"\n"
          "    /// Require variable ${element.key} of type \"${variableType}\"\n"
          "    Future<bool> set$firstUpper($variableType ${element.key}) async => $setCode"
          "\n\n    /// Delete key \"${element.key}\"\n"
          "    /// ```dart\n"
          "    /// await storageHelper.delete$firstUpper();\n"
          "    /// ```\n"
          "    Future<bool> delete$firstUpper() async => await set$firstUpper(null);";
    }

    init += "\n    }";

    code += "\n    // Static attributes with the names of the keys so that they can also be accessed from the outside";
    code += statics;

    code += "\n \n";

    code += attributes;

    code += "\n    /// Model from storage_helper.dart\n"
        "    StorageHelperModel model;\n\n"
        "$className(this.model) : super(model){{costruttore${index.toString()}}}";

    code += getSet;

    code += "\n    /// Delete all elements\n"
        "    Future<void> deleteAll() async {\n"
        "        log(\"Elimino tutto...\");\n"
        "        await storage.deleteAll();\n"
        "    }";

    if(category.addSource != null) code += "\n    // Additional code\n${category.addSource}";

    code += init;

    code += "\n}";

    return code;
  }

  @override
  generateForAnnotatedElement(
      Element element, ConstantReader annotation, BuildStep buildStep) {
    storageHelperLog("start...");

    String code = """/// Author: Gabriele Princiotta
/// This file was automatically generated by StorageHelperGenerator
/// How to use:
/// - import storage_helper.dart into file where you want to use it
/// - create a variable of type StorageHelper and pass model to constructor
/// `StorageHelper storageHelper = new StorageHelper(storageModel)`
/// - access to subcategories:
///   - to access a subcategory call the attribute inside the parent category or create a variable of type StorageHelper\$key in camelCase where \$key is the key of category
///   - once you have accessed a subcategory you can use the same methods of any category{{sub-categories-example}}
/// - the same thing can be done with all categories, only the class name changes
/// - each element can be accessed using dart's getter or using the get method in camelCase{{get-example}}
/// - to edit element's content call the set method in camelCase{{set-example}}
/// - to delete element's content call the delete method in camelCase{{delete-example}}

part of 'storage_helper.dart';
""";

    StorageHelperModel model = converter.convert<StorageHelperModel>(annotation.read('model').objectValue);

    if(model == null) throw new StorageHelperNullException("model");

    // Decomment for print model
    // Use in test
    // log("Model:");
    // print(model.toMap);

    for(int i = 0;i < model.categories.length;i++) { // Add a class for each category
      if(model.categories[i] == null) throw new StorageHelperNullException("category");
      if(!validKey(model.categories[i].key)) new StorageHelperValidKeyException(model.categories[i].key);
      // I check that there is no category with this key
      if(categoriesKeys.contains(model.categories[i].key)) throw new StorageHelperDuplicateException("categories");
      categoriesKeys.add(model.categories[i].key);  // Add category's key to list
      code += "\n${createClass(i, model.categories[i])}";
    }

    // Per ogni categoria inserisco gli attributi per le sottocategorie e i costruttori
    for(int i = 0;i < model.categories.length;i++) {
      String replace1 = "";
      String from1 = "{{sottoCategorie${i.toString()}}}";
      String replace2 = "";
      String from2 = "{{costruttore${i.toString()}}}";

      try {
        int count = 0;
        replace2 += " {\n";

        for(StorageHelperCategoryChild child in sottocategorie.where(
                (StorageHelperCategoryChild child) => child.parentKey == model.categories[i].key
        ).toList()) {
          if(child.code != null) replace1 += "\n${child.code}";
          if(child.constructorCode != null) replace2 += child.constructorCode;

          count++;
        }

        replace2 += "\n    }";

        if(count == 0) replace2 = "";
      } catch(e, stacktrace) {
        print(e);
        print(stacktrace);
      }

      if(replace2 == "") replace2 = ";";

      code = code.replaceAll(from1, replace1);
      code = code.replaceAll(from2, replace2);
    }

    code = code.replaceAll("{{sub-categories-example}}", addDartComment(subCategoriesExample, "    "));
    code = code.replaceAll("{{get-example}}", addDartComment(getExample));
    code = code.replaceAll("{{set-example}}", addDartComment(setExample));
    code = code.replaceAll("{{delete-example}}", addDartComment(deleteExample));

    storageHelperLog("end!");

    // Decomment for print code
    // Use in test
    // print(code);

    return code;
  }
}