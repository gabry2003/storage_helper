// ignore: import_of_legacy_library_into_null_safe
import 'dart:async';

// ignore: import_of_legacy_library_into_null_safe
import 'package:analyzer/dart/element/element.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:build/build.dart';
// ignore: import_of_legacy_library_into_null_safe
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
class StorageHelperGenerator
    extends GeneratorForAnnotation<StorageHelperBuilder> {
  /// Converter from DartObject
  StorageHelperGenConverter converter = new StorageHelperGenConverter();

  /// Sub-categories
  List<StorageHelperCategoryChild> sottocategorie = [];

  /// List of all categories keys
  /// It is used to check that there are no categories with the same key
  List<String?> categoriesKeys = [];

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
  String upperFirst(String text) =>
      "${text[0].toUpperCase()}${text.substring(1)}";

  /// Returns the [text] converted from camelCase to Delimiter-separated words in UpperCase
  String constantName(String text) => text
      .replaceAllMapped(RegExp(r'(?<=[a-z])[A-Z]'),
          (Match m) => ("_" + (m.group(0) as String)))
      .toUpperCase();

  /// Return `true` if the [key] is in a valid format to be inserted into the code
  /// Otherwise it returns `false`
  bool validKey(String? key) {
    // The key cannot start with a number
    // Cannot contain spaces
    // Cannot contain special characters
    // Cannot start with an underscore
    if (key == null) return false;

    if (key[0] == "_") return false;

    return new RegExp(
      r"^[a-zA-Z_$][a-zA-Z_$0-9]*$",
      caseSensitive: true,
      multiLine: false,
    ).hasMatch(key);
  }

  /// Check the validity of the [code] for the default value
  /// If it is valid, return the [code]
  /// Otherwise throw an exception to tell the user to enter a valid default value for the key "[key]"
  // ignore: missing_return
  String? validateDefaultValue(String? code, String key) {
    Function eccezione = () {
      throw new FormatException(
          "Please insert a valid default value for key \"$key\"");
    };

    if ((code ?? "") == "") eccezione();

    if (code?.trim()[code.length - 1] != ";") {
      return code;
    } else {
      eccezione();
    }
  }

  /// It is used to transform the [code] into a comment by adding a [space] in each line (optional)
  String addDartComment(String code, [String space = ""]) {
    if (code == "")
      return code; // If there is no piece of code I return the string as it is

    // For each line of the code to be commented I add it in the code to be returned in the form of dart-doc comment
    List<String> codeSplit = code.split("\n");

    String returnCode = "\n$space/// ``` dart";
    for (String el in codeSplit) returnCode += "\n$space/// $el";
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

    String gettersAndSetters = "\n\n    // Getters and setters\n"
        "    // ignore: unnecessary_getters_setters\n"
        "    StorageHelperModel get model => _model;\n"
        "    // ignore: unnecessary_getters_setters\n"
        "    set model(StorageHelperModel model) {\n"
        "        _model = model;\n"
        "    }";

    if (category.key != null) {
      // Se è presente la chiave della categoria
      if (category.parent != null) objName += ".${category.parent}";
      objName += ".${category.key}";

      className += upperFirst(category.key!);

      subCategoriesExample +=
          "$className ${category.key} = new $className(storageModel);  // First method\n"
          "$className ${category.key}2 = ${category.parent != null ? category.parent : "storageHelper"}.${category.key}; // Second method";

      String attributesCode =
          "\n    // Use this attribute to access to sub-category ${category.key}";
      if ((category.description?.length ?? 0) > 0)
        for (String? desc in category.description!)
          attributesCode += "\n    /// $desc";
      attributesCode += "\n    late $className _${category.key};";

      sottocategorie.add(StorageHelperCategoryChild(
          parentKey: category.parent as String,
          code: attributesCode,
          constructorCode:
              "\n        ${category.key} = new $className(model);        // Initialize object",
          onInit:
              "\n        log([\"\"\"Initialize $className...\"\"\"]);\n        await ${category.key}.init();",
          toMap: "\n        \"${category.key}\": await ${category.key}.toMap,",
          gettersAndSetters: "\n    // ignore: unnecessary_getters_setters\n"
              "    $className get ${category.key} => _${category.key};\n\n"
              "    // ignore: unnecessary_getters_setters\n"
              "    set ${category.key}($className ${category.key}) {\n"
              "        _${category.key} = ${category.key};\n"
              "    }",
          deleteAll: "\n    await ${category.key}.deleteAll();"));
    } else {
      if (countAnonymous > 0)
        throw new StorageHelperException(
            "There can only be one category without a key and it is the main one");

      countAnonymous++;
    }

    setExample += "await $objName.setVariable(\"ciao\");";
    deleteExample += "await $objName.deleteVariable(); // First method\n"
        "await $objName.setVariable(null);  //  Second method";
    getExample +=
        "String variable = await $objName.variable;  // First method\n"
        "String variable2 = await $objName.getVariable();  // Secondo method\n"
        "String variable3 = $objName.variable; // Third method, valid only for element who is initializated on init";

    List<StorageHelperElement?>? elements = category.elements!;

    String code = "";
    if ((category.description?.length ?? 0) > 0)
      for (String? desc in category.description!) code += "\n/// $desc";
    code += """\nclass $className extends StorageHelperBase {""";

    String getSet = "\n";
    String statics = "";
    String attributes = "{{sottoCategorie${index.toString()}}}";
    String init =
        "\n    /// You can call this method to initialize accessible elements even without asynchronous methods\n"
        "    Future<void> init() async {{{onInit${index.toString()}}}";
    String toMap =
        "\n    /// You can call this method to get all elements by key\n"
        "    Future<Map> get toMap async => {";
    String deleteAllCode = "";

    for (StorageHelperElement? element in elements) {
      if (element != null) {
        if (!validKey(element.key))
          throw new StorageHelperValidKeyException(element.key);

        // I check that there is no elemnets with this key
        if (elementsKeys.contains(element.key))
          throw new StorageHelperDuplicateException("elements");
        elementsKeys.add(element.key); // Add element's key to list

        String staticName = element.staticKey ?? constantName(element.key);
        String nameForGet = staticName;
        String deleteAllArguments = "";
        String deleteAllCondition = "";

        // Add the keys
        for (int i = 0; i < (element.concateneKeys?.length ?? 0); i++) {
          // Ogni chiave da concatenare può essere presa da un padre o no in base al fatto che contiene il punto o no
          String? nomeChiave = element.concateneKeys?[i];
          String? nomeChiavePulito;
          String? nomeChiaveForGet = "";

          if (nomeChiave?.contains(".") ?? false) {
            // Se la chiave contiene il punto
            // Divido la stringa in base al punto e prendo l'ultima parte
            List<String>? splitNomeChiave = nomeChiave?.split(".");
            nomeChiavePulito = splitNomeChiave?[1];

            // Per il get devo chiamare una funzione e prendere il valore
            nomeChiaveForGet = """await (() async  {
  StorageHelper${upperFirst(splitNomeChiave?[0] ?? "")} storageHelper${upperFirst(splitNomeChiave?[0] ?? "")} = new StorageHelper${upperFirst(splitNomeChiave?[0] ?? "")}(this._model);
  await storageHelper${upperFirst(splitNomeChiave?[0] ?? "")}.init();
  return storageHelper${upperFirst(splitNomeChiave?[0] ?? "")}.$nomeChiavePulito;
})()""";
          } else {
            nomeChiavePulito = nomeChiave;
            nomeChiaveForGet = nomeChiave;
          }

          nameForGet += " + $nomeChiaveForGet";
          deleteAllCondition +=
              "\n                && ((($nomeChiavePulito ?? \"\") != \"\") ? key.contains($nomeChiavePulito as String) : true)";
          deleteAllArguments += "String? $nomeChiavePulito,";
        }

        String deleteAllArgumentsCode =
            deleteAllArguments != "" ? "\{$deleteAllArguments\}" : "";

        for (int i = 0;
            i < (element.concateneKeysFromArgument?.length ?? 0);
            i++)
          nameForGet += " + (${element.concateneKeysFromArgument?[i]} ?? \"\")";

        String variableTypeGet = "dynamic?";
        String variableTypeSet = "dynamic?";

        String getKey = element.getKey ?? element.key;
        String firstUpper = upperFirst(getKey);
        String type;
        String? defaultValue;
        String? dateFormat = element.dateFormat?.toString();

        if ((element.concateneKeys?.length ?? 0) == 0) {
          deleteAllCode += "\nawait delete$firstUpper();";
        } else {
          deleteAllCode += "\nawait deleteAll$firstUpper();";
        }

        if (element.type is String) {
          // If element has a custom type
          // if it has a custom type it has to do some conversions so it is nullable
          variableTypeGet = element.type + "?";
          variableTypeSet = variableTypeGet;
          type = "\"${element.type}\"";
          element.defaultValue != null
              ? defaultValue =
                  validateDefaultValue(element.defaultValue, element.key)!
              : defaultValue = "null";
        } else {
          type = element.type.toString();
          if (element.defaultIsCode ?? false) {
            // Se il valore di default è un pezzo di codice
            element.defaultValue != null
                ? defaultValue =
                    validateDefaultValue(element.defaultValue, element.key)!
                : defaultValue = "null";
          } else {
            defaultValue = element.defaultValue?.toString();

            switch (type) {
              case "StorageHelperType.String":
              case "StorageHelperType.DateTime":
              case "StorageHelperType.TimeOfDay":
                if (defaultValue != null && defaultValue != "null")
                  defaultValue = "\"\"\"$defaultValue\"\"\"";
                break;
            }

            switch (type) {
              case "StorageHelperType.String":
                variableTypeGet = "String";
                break;
              case "StorageHelperType.DateTime":
                variableTypeGet = "DateTime";
                break;
              case "StorageHelperType.TimeOfDay":
                variableTypeGet = "TimeOfDay";
                break;
              case "StorageHelperType.int":
                variableTypeGet = "int";
                break;
              case "StorageHelperType.double":
                variableTypeGet = "double";
                break;
              case "StorageHelperType.bool":
                variableTypeGet = "bool";
                break;
            }

            variableTypeSet = variableTypeGet + "?";

            // if it must return a date it must do a parse so it could go into the catch and return null, so it is nullable, same thing if it does not has a default value
            if (element.defaultValue == null ||
                variableTypeGet == "DateTime" ||
                variableTypeGet == "TimeOfDay") variableTypeGet += "?";
          }
        }

        String dateFormatCode =
            dateFormat != "null" && dateFormat != null && dateFormat != ""
                ? ", dateFormat: \"$dateFormat\""
                : "";
        String defaultValueCode = defaultValue != "null" && defaultValue != null
            ? ", defaultValue: $defaultValue"
            : "";

        String getCode =
            "await get<$variableTypeGet>($nameForGet$defaultValueCode$dateFormatCode);";
        String setCode =
            "await set<$variableTypeSet>($nameForGet, ${element.key}$dateFormatCode);";

        if ((element.description?.length ?? 0) > 0)
          for (String? desc in element.description!)
            statics += "\n    /// $desc";
        statics +=
            "\n    static const String $staticName = \"${category.key ?? ""}${element.key}\";";

        getSet += "\n\n    // Getter and setter for the key \"${element.key}\"";
        if (element.onInit ?? false) {
          if ((element.description?.length ?? 0) > 0)
            for (String? desc in element.description!)
              attributes += "\n    /// $desc";
          attributes += "\n    late $variableTypeGet _$getKey" +
              (defaultValue != "null" && defaultValue != null
                  ? " = $defaultValue"
                  : "") +
              ";  // Attribute to take the key value without making an asynchronous call";
          init +=
              "\n        ${element.key} = await get$firstUpper();  // Initially put the value inside the attribute";

          gettersAndSetters += "\n    // ignore: unnecessary_getters_setters\n";
          if ((element.description?.length ?? 0) > 0)
            for (String? desc in element.description!)
              attributes += "\n   /// $desc";
          gettersAndSetters += "    $variableTypeGet get $getKey => _$getKey;\n"
              "\n    // ignore: unnecessary_getters_setters\n"
              "    set $getKey($variableTypeGet $getKey) {\n"
              "        _$getKey = $getKey;\n"
              "    }";
        } else {
          if (!(element.onlyFunction ?? false)) {
            getSet += "\n\n    /// Return value of ${element.key}\n"
                "    /// Return a variable of type \"$variableTypeGet\"\n"
                "    /// ```dart\n"
                "    /// $variableTypeGet $getKey = await $objName.${element.key};\n"
                "    /// ```\n";
            // Load description of element
            if ((element.description?.length ?? 0) > 0)
              for (String? desc in element.description!)
                attributes += "\n    /// $desc";
            getSet +=
                "\n    Future<$variableTypeGet> get $getKey async => $getCode";
          }
        }

        String getArguments = "";
        String deleteArgumentsCode = "";

        for (int i = 0;
            i < (element.concateneKeysFromArgument?.length ?? 0);
            i++) {
          getArguments += "String? ${element.concateneKeysFromArgument?[i]}, ";
          deleteArgumentsCode +=
              ", ${element.concateneKeysFromArgument?[i]}: ${element.concateneKeysFromArgument?[i]}";
        }

        String getArgumentsCode = getArguments != "" ? "\{$getArguments\}" : "";
        String setArgumentsCode =
            getArguments != "" ? ", $getArgumentsCode" : "";

        // Get
        getSet += "\n\n    /// Return value of ${element.key}\n"
            "    /// Return a variable of type \"$variableTypeGet\"\n"
            "    /// ```dart\n"
            "    /// $variableTypeGet ${element.key} = await $objName.get$firstUpper();\n"
            "    /// ```\n";
        // Load description of element
        if ((element.description?.length ?? 0) > 0)
          for (String? desc in element.description!)
            attributes += "\n    /// $desc";
        getSet +=
            "\n    Future<$variableTypeGet> get$firstUpper($getArgumentsCode) async => $getCode";

        if ((element.concateneKeys?.length ?? 0) > 0 ||
            (element.concateneKeysFromArgument?.length ?? 0) > 0) {
          getSet +=
              "\n\n    /// Return all elements where key contains ${element.key}\n"
              "    /// Return a variable of type \"Map<String, $variableTypeGet>\"\n"
              "    /// ```dart\n"
              "    /// Map<String, $variableTypeGet> ${element.key}All = await $objName.getAll$firstUpper();\n"
              "    /// ```\n"
              "    /// \n"
              "    /// The optional named parameters can be used to filter the results based on a certain value you passed.\n"
              "    /// If you do not enter them or enter an empty string they are not counted\n";
          // Load description of element
          if ((element.description?.length ?? 0) > 0)
            for (String? desc in element.description!)
              attributes += "\n    /// $desc";
          getSet +=
              "    Future<Map<String, $variableTypeGet>> getAll$firstUpper($deleteAllArgumentsCode) async {\n"
              "        Map<String, $variableTypeGet> results = {};\n"
              "\n"
              "        List<String> keys = (await readAll()).keys.where(\n"
              "            (String key) => key.contains($staticName)$deleteAllCondition\n"
              "        ).toList();\n"
              "\n"
              "        for(String key in keys) results[key] = await get<$variableTypeGet>(key$defaultValueCode$dateFormatCode);\n"
              "\n"
              "        return results;\n"
              "    }\n";
        }

        // Set
        getSet +=
            "\n\n    /// Insert a value into element with key \"${element.key}\"\n"
            "    /// Require variable ${element.key} of type \"${variableTypeGet}\"\n";
        // Load description of element
        if ((element.description?.length ?? 0) > 0)
          for (String? desc in element.description!)
            attributes += "\n    /// $desc";
        getSet +=
            "    Future<bool> set$firstUpper($variableTypeSet ${element.key}$setArgumentsCode) async => $setCode";

        // Delete
        getSet += "\n\n    /// Delete key \"${element.key}\"\n"
            "    /// ```dart\n"
            "    /// await storageHelper.delete$firstUpper();\n"
            "    /// ```\n";
        // Load description of element
        if ((element.description?.length ?? 0) > 0)
          for (String? desc in element.description!)
            attributes += "\n    /// $desc";
        getSet +=
            "    Future<bool> delete$firstUpper($getArgumentsCode) async => await set$firstUpper(null$deleteArgumentsCode);";

        if ((element.concateneKeys?.length ?? 0) > 0 ||
            (element.concateneKeysFromArgument?.length ?? 0) > 0) {
          // If there are elements with concatene keys
          // Delete all
          getSet +=
              "\n\n    /// Delete all key which contain \"${element.key}\"\n"
              "    /// ```dart\n"
              "    /// await storageHelper.deleteAll$firstUpper();\n"
              "    /// ```\n";
          // Load description of element
          if ((element.description?.length ?? 0) > 0)
            for (String? desc in element.description!)
              attributes += "\n    /// $desc";
          getSet +=
              "    Future<List<bool>> deleteAll$firstUpper($deleteAllArgumentsCode) async => (await Future.wait((await readAll()).keys.where(\n"
              "            (String key) => key.contains($staticName)$deleteAllCondition\n"
              "        ).map("
              "            (String key) async => await set<$variableTypeSet>(key, null)\n"
              "        ))).toList();";
          toMap += "\n        \"${element.key}\": await getAll$firstUpper(),";
        } else {
          toMap += "\n        \"${element.key}\": await get$firstUpper(),";
        }
      } else {
        storageHelperLog("ELEMENT IS NULL");
      }
    }

    toMap += "{{toMap${index.toString()}}}\n    };";
    init += "\n    }";

    code +=
        "\n    // Static attributes with the names of the keys so that they can also be accessed from the outside";
    code += statics;

    code += "\n \n";

    code += attributes;

    code += "\n    /// Model from storage_helper.dart\n"
        "    StorageHelperModel _model;\n\n"
        "    $className(this._model) : super(_model){{costruttore${index.toString()}}}";

    code += getSet;

    code += "\n    /// Delete all elements\n"
        "    Future<void> deleteAll() async {\n"
        "        $deleteAllCode\n"
        "        {{deleteAll${index.toString()}}}"
        "    }";

    if (category.addSource != null)
      code += "\n    // Additional code\n${category.addSource}";

    code += init;

    code += gettersAndSetters;
    code += "{{gettersAndSetters${index.toString()}}}";

    code += toMap;

    code += "\n}";

    return code;
  }

  @override
  FutureOr<String> generateForAnnotatedElement(
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

""";

    try {
      StorageHelperModel? model = converter
          .convert<StorageHelperModel>(annotation.read("model").objectValue);

      if (model == null) throw new StorageHelperNullException("model");

      // Decomment for print model
      // Use in test
      // log("Model:");
      // print(model.toMap);

      for (int i = 0; i < model.categories.length; i++) {
        // Add a class for each category
        StorageHelperCategory? category = model.categories[i];
        if (category != null) {
          if (!validKey(category.key))
            new StorageHelperValidKeyException(category);
          // I check that there is no category with this key
          if (categoriesKeys.contains(category.key))
            throw new StorageHelperDuplicateException("categories");
          categoriesKeys.add(category.key); // Add category's key to list
          code += "\n${createClass(i, category)}";
        } else {
          storageHelperLog("CATEGORY IS NULL, INDEX \"$i\"");
        }
      }

      // Per ogni categoria inserisco gli attributi per le sottocategorie e i costruttori
      print("sottocategorie:");
      print(sottocategorie);
      for (int i = 0; i < model.categories.length; i++) {
        StorageHelperCategory? category = model.categories[i];

        if (category != null) {
          String replace1 = "";
          String from1 = "{{sottoCategorie${i.toString()}}}";
          String replace2 = "";
          String from2 = "{{costruttore${i.toString()}}}";
          String replace3 = "";
          String from3 = "{{onInit${i.toString()}}}";
          String replace4 = "";
          String from4 = "{{toMap${i.toString()}}}";
          String replace5 = "";
          String from5 = "{{gettersAndSetters${i.toString()}}}";
          String replace6 = "";
          String from6 = "{{deleteAll${i.toString()}}}";

          try {
            int count = 0;
            replace2 += " {\n";

            for (StorageHelperCategoryChild child in sottocategorie
                .where((StorageHelperCategoryChild child) =>
                    child.parentKey == category.key)
                .toList()) {
              if (child.code != null) replace1 += "\n${child.code}";
              if (child.constructorCode != null)
                replace2 += child.constructorCode as String;
              if (child.onInit != null) replace3 += child.onInit as String;
              if (child.toMap != null) replace4 += child.toMap as String;
              if (child.gettersAndSetters != null)
                replace5 += child.gettersAndSetters as String;
              if (child.deleteAll != null)
                replace6 += child.deleteAll as String;

              count++;
            }

            replace2 += "\n    }";

            if (count == 0) replace2 = "";
          } catch (e, stacktrace) {
            print(e);
            print(stacktrace);
          }

          if (replace2 == "") replace2 = ";";

          code = code.replaceAll(from1, replace1);
          code = code.replaceAll(from2, replace2);
          code = code.replaceAll(from3, replace3);
          code = code.replaceAll(from4, replace4);
          code = code.replaceAll(from5, replace5);
          code = code.replaceAll(from6, replace6);
        }
      }

      code = code.replaceAll("{{sub-categories-example}}",
          addDartComment(subCategoriesExample, "    "));
      code = code.replaceAll("{{get-example}}", addDartComment(getExample));
      code = code.replaceAll("{{set-example}}", addDartComment(setExample));
      code =
          code.replaceAll("{{delete-example}}", addDartComment(deleteExample));

      storageHelperLog("end!");

      // Decomment for print code
      // Use in test
      // print(code);
    } catch (e, stacktrace) {
      print(e);
      print(stacktrace);

      storageHelperLog("ERROR!!!");
    }

    return code;
  }
}
