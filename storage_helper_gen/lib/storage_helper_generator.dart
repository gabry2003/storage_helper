import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/constant/value.dart';
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';
import 'package:storage_helper_gen/storage_helper_builder.dart';
import 'package:storage_helper_gen/storage_helper_category.dart';
import 'package:storage_helper_gen/storage_helper_category_child.dart';
import 'package:storage_helper_gen/storage_helper_element.dart';
import 'package:storage_helper_gen/storage_helper_gen_converter.dart';
import 'package:storage_helper_gen/storage_helper_model.dart';

class StorageHelperGenerator extends GeneratorForAnnotation<StorageHelperBuilder> {
  StorageHelperGenConverter converter = new StorageHelperGenConverter();
  /// Sotto categorie
  List<StorageHelperCategoryChild> categoriesAttributes = [];
  /// Esempi per le sotto categorie
  String subCategoriesExample = "";
  /// Esempi per i get
  String getExample = "";
  /// Esempi per i set
  String setExample = "";
  /// Esempi per i delete
  String deleteExample = "";
  /// Numero di categorie senza chiave
  int countAnonymous = 0;

  void log(String msg) {
    print(DateTime.now().toString());
    print("[STORAGE_HELPER_GENERATOR] $msg");
  }

  StorageHelperModel getModel(DartObject obj) => StorageHelperModel(
      categories: converter.getList<StorageHelperCategory>(converter.getListValue(obj, "categories")),
      log: converter.getBoolValue(obj, "log"),
      dateFormat: converter.getStringValue(obj, "dateFormat")
  );

  String upperFirst(String text) => "${text[0].toUpperCase()}${text.substring(1)}";
  String constantName(String text) => text.replaceAllMapped(RegExp(r'(?<=[a-z])[A-Z]'), (Match m) => ('_' + m.group(0))).toUpperCase();

  bool validKey(String key) {
    return (key ?? "") != "";
  }

  String createClass(int index, StorageHelperCategory category) {
    String className = "StorageHelper";
    String objName = "storageHelper";

    if(category.key != null) {  // Se è presente la chiave della categoria
      if(category.parent != null) objName += ".${category.parent}";
      objName += ".${category.key}";

      className += upperFirst(category.key);

      subCategoriesExample += "\n///    ```dart\n/// $className ${category.key} = new $className(storageModel);`\n///    `$className ${category.key}2 = ${category.parent != null ? category.parent : "storageHelper"}.${category.key};\n///    ```";

      String attributesCode = "\n    // Use this attribute to access to sub-category ${category.key}";
      if((category.description?.length ?? 0) > 0) for(String desc in category.description) attributesCode += "\n    /// $desc";
      attributesCode += "\n    $className ${category.key};";

      categoriesAttributes.add(StorageHelperCategoryChild(
          parent: category.parent,
          code: attributesCode,
          constructor: "\n        ${category.key} = new $className(model);        // Initialize object"
      ));
    }else {
      if(countAnonymous > 0) throw new Exception("Insert a key for the category");

      countAnonymous++;
    }

    setExample += "\n/// ```dart\n/// await $objName.setVariable(\"ciao\");\n/// ```";
    deleteExample += "\n/// ```dart\n/// await $objName.deleteVariable(); // First method\n/// await $objName.setVariable(null);  //  Second method\n/// ```";
    getExample += "\n/// ```dart\n/// String variable = await $objName.variable;  // First method\n/// String variable2 = $objName.getVariable();  // Secondo method\n/// String $objName.variable; // Third method, valid only for element who is initializated on init\n/// ```";

    List<StorageHelperElement> elementi = category.elements;

    String code = "";
    if((category.description?.length ?? 0) > 0) for(String desc in category.description) code += "\n/// $desc";
    code += """\nclass $className extends StorageHelperBase {""";
    String getSet = "\n";
    String statics = "";
    String attributes = "{{sottoCategorie${index.toString()}}}";
    String init = "\n    /// You can call this method to initialize accessible elements even without asynchronous methods\n    Future<void> init() async {";

    for(StorageHelperElement elemento in elementi) {
      if(elemento == null) throw new Exception("Elements cannot be null!");
      if(!validKey(elemento.key)) throw new Exception("Not valid key!");

      String staticName = elemento.staticKey ?? constantName(elemento.key);
      String nameForGet = staticName;
      for(int i = 0;i < (elemento.concateneKeys?.length ?? 0);i++) {
        nameForGet += " + ${elemento.concateneKeys[i]}";
      }

      String variableType = "var";

      String firstUpper = upperFirst(elemento.key);
      String type;
      String defaultValue;

      if(elemento.type is String) { // Se l'elemento ha un tipo personalizzato
        type = "\"${elemento.type}\"";
        elemento.defaultValue != null ? defaultValue = elemento.defaultValue : defaultValue = "null";
        variableType = "type";
      }else {
        type = elemento.type.toString();
        defaultValue = elemento.defaultValue?.toString();

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

      String getCode = "await get($type, $nameForGet, $defaultValue);";
      String setCode = "await set($type, $nameForGet, val);";

      if((elemento.description?.length ?? 0) > 0) for(String desc in elemento.description) statics += "\n    /// $desc";
      statics += "\n    static const String $staticName = \"${elemento.key}\";";

      getSet += "\n\n    // Getter and setter for the key ${elemento.key}";
      if(elemento.onInit) {
        if((elemento.description?.length ?? 0) > 0) for(String desc in elemento.description) attributes += "\n    /// $desc";
        attributes += "\n    $variableType ${elemento.key} = $defaultValue;  // Attribute to take the key value without making an asynchronous call";
        init += "\n        ${elemento.key} = await get$firstUpper();  // Initially put the value inside the attribute";
      }else {
        getSet += "\n\n    /// Return key's value ${elemento.key}\n    /// await $objName.${elemento.key} return value \n    Future<$variableType> get ${elemento.key} async => $getCode";
      }
      getSet += "\n\n    /// Return key's value ${elemento.key}\n    /// await $objName.get$firstUpper() return value \n    Future<$variableType> get$firstUpper() async => $getCode";
      getSet += """\n\n    /// Insert a value into key \"${elemento.key}\"\n    Future<void> set$firstUpper($variableType val) async {
      $setCode
    }""";
      getSet += """\n\n    /// Delete key \"${elemento.key}\"\n    /// await storageHelper.delete$firstUpper() delete element\n    Future<void> delete$firstUpper() async {
      await set$firstUpper(null);
    }""";
    }

    init += "\n    }";

    code += "\n    // Static attributes with the names of the keys so that they can also be accessed from the outside";
    code += statics;

    code += "\n \n";

    code += attributes;

    code += """\n
    /// Model from storage_helper.dart
    StorageHelperModel model;
    
    $className(this.model) : super(model){{costruttore${index.toString()}}}""";

    code += getSet;

    code += """
    /// Delete all elements
    Future<void> deleteAll() async {
        log("Elimino tutto...");
        await storage.deleteAll();
    }
""";

    if(category.addSource != null) {
      code += "\n    // Additional code\n${category.addSource}";
    }

    code += init;

    code += "\n}";

    return code;
  }

  @override
  generateForAnnotatedElement(
      Element element, ConstantReader annotation, BuildStep buildStep) {
    log("start...");

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

    StorageHelperModel model = getModel(annotation.read('model').objectValue);

    // Decomment for print model
    // Use in test
    // log("Model:");
    // print(model.toMap);

    for(int i = 0;i < model.categories.length;i++) { // Per ogni categoria aggiungo la classe
      if(model.categories[i] == null) throw new Exception("Insert all categories!");
      code += "\n${createClass(i, model.categories[i])}";
    }

    // Per ogni categoria inserisco gli attributi per le sottocategorie
    for(int i = 0;i < model.categories.length;i++) {
      String replace1 = "";
      String from1 = "{{sottoCategorie${i.toString()}}}";
      String replace2 = "";
      String from2 = "{{costruttore${i.toString()}}}";

      try {
        int count = 0;
        replace2 += " {\n";

        for(StorageHelperCategoryChild child in categoriesAttributes.where(
                (StorageHelperCategoryChild child) => child.parent == model.categories[i].key
        ).toList()) {
          if(child.code != null) replace1 += "\n${child.code}";
          if(child.constructor != null) replace2 += child.constructor;

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

    code = code.replaceAll("{{sub-categories-example}}", subCategoriesExample);
    code = code.replaceAll("{{get-example}}", getExample);
    code = code.replaceAll("{{set-example}}", setExample);
    code = code.replaceAll("{{delete-example}}", deleteExample);

    log("end!");

    // Decomment for print code
    // Use in test
    // print(code);

    return code;
  }
}