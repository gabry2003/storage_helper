import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/constant/value.dart';
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';
import 'package:storage_helper_gen/storage_helper_builder.dart';
import 'package:storage_helper_gen/storage_helper_category.dart';
import 'package:storage_helper_gen/storage_helper_category_child.dart';
import 'package:storage_helper_gen/storage_helper_custom_type.dart';
import 'package:storage_helper_gen/storage_helper_element.dart';
import 'package:storage_helper_gen/storage_helper_gen_converter.dart';
import 'package:storage_helper_gen/storage_helper_model.dart';

class StorageHelperGenerator extends GeneratorForAnnotation<StorageHelperBuilder> {
  StorageHelperGenConverter converter = new StorageHelperGenConverter();
  /// Tipi personalizzati
  Map<String, StorageHelperCustomType> customTypes;
  /// Sotto categorie
  List<StorageHelperCategoryChild> categoriesAttributes;
  /// Numero di categorie senza chiave
  int countAnonymous = 0;

  void log(String msg) {
    print(DateTime.now().toString());
    print("[STORAGE_HELPER_GENERATOR] $msg");
  }

  StorageHelperModel getModel(DartObject obj) => converter.convert<StorageHelperModel>(obj);

  String upperFirst(String text) => "${text[0].toUpperCase()}${text.substring(1)}";
  String constantName(String text) => text.replaceAllMapped(RegExp(r'(?<=[a-z])[A-Z]'), (Match m) => ('_' + m.group(0))).toUpperCase();

  String createClass(int index, StorageHelperCategory category) {
    String className = "StorageHelper";
    if(category.key != null) {  // Se è presente la chiave della categoria
      className += upperFirst(category.key);

      String attributesCode = "\n    // Use this attribute to access to sub-category ${category.key}";
      if((category.description?.length ?? 0) > 0) for(String desc in category.description) attributesCode += "\n    // $desc";
      attributesCode += "\n    $className ${category.key} = new $className(model: model);";

      categoriesAttributes.add(StorageHelperCategoryChild(
          parent: category.parent,
          code: attributesCode
      ));
    }else {
      if(countAnonymous > 0) throw new Exception("Insert a key for the category");

      countAnonymous++;
    }

    List<StorageHelperElement> elementi = category.elements;

    String code = "";
    if(category.description != "") code += "/// ${category.description}";
    code += """class $className extends StorageHelperBase {""";
    String getSet = "\n";
    String statics = "";
    String attributes = "{{sottoCategorie${index.toString()}}";
    String init = "\n    /// You can call this method to initialize accessible elements even without asynchronous methods\n    Future<void> init() async {";

    for(StorageHelperElement elemento in elementi) {
      if((elemento.key ?? "") == "") throw new Exception("Chiave dell'elemento non valida!");

      String staticName = elemento.staticKey ?? constantName(elemento.key);
      String nameForGet = staticName;
      for(int i = 0;i < (elemento.concateneKeys?.length ?? 0);i++) {
        nameForGet += " + ${elemento.concateneKeys[i]}";
      }

      String firstUpper = upperFirst(elemento.key);
      String type;
      String defaultValue;

      if(elemento.type is String) { // Se l'elemento ha un tipo personalizzato
        // Controllo che la funzione ci sia
        try {
          if(customTypes[elemento.key].convert == null) throw new Exception();
        } catch(e) {
          log("Non-convertible item \"${elemento.key}\", skip!");
          continue;
        }

        type = "\"${elemento.type}\"";
        defaultValue = customTypes[elemento.key].convert(elemento.defaultValue);
      }else {
        type = elemento.type.toString();
        defaultValue = elemento.defaultValue.toString();
      }

      if(defaultValue != null && defaultValue != "null") defaultValue = "\"$defaultValue\"";

      String getCode = "await get($type, $nameForGet, $defaultValue);";
      String setCode = "await set($type, $nameForGet, val);";

      if((elemento.description?.length ?? 0) > 0) for(String desc in elemento.description) statics += "\n    // $desc";
      statics += "\n    static const String $staticName = \"${elemento.key}\";";

      getSet += "\n    // Getter and setter for the key ${elemento.key}";
      if(elemento.onInit) {
        attributes = "\n    dynamic ${elemento.key} = $defaultValue;  // Attribute to take the key value without making an asynchronous call";
        init += "\n    ${elemento.key} = await get$firstUpper();  // I initially put the value inside the attribute";
      }else {
        getSet += "\n    /// Return key's value ${elemento.key}\n    /// await storageHelper.${elemento.key} return value \n    Future<dynamic> get ${elemento.key} async => $getCode";
      }
      getSet += "\n    /// Return key's value ${elemento.key}\n    /// await storageHelper.get$firstUpper() return value \n    Future<dynamic> get$firstUpper() async => $getCode";
      getSet += """\n    /// Insert a value into key \"${elemento.key}\"\n    Future<void> set$firstUpper(dynamic val) async {
      $setCode
}""";
      getSet += """\n    /// Delete key \"${elemento.key}\"\n    /// await storageHelper.delete$firstUpper() delete element    Future<void> delete$firstUpper() async {
      await set$firstUpper(null);
}""";
    }

    init += "\n    }";

    code += "\n    // Static attributes with the names of the keys so that they can also be accessed from the outside";
    code += statics;

    code += "\n \n";

    code += attributes;

    code += """
    /// Model from storage_helper.dart
    StorageHelperModel model;
    
    StorageHelper({@required this.model}) : super(
        model: model
    );""";

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
    ///
    code += """
}""";

    return code;
  }

  @override
  generateForAnnotatedElement(
      Element element, ConstantReader annotation, BuildStep buildStep) {
    log("start...");

    String code = """/// Author: Gabriele Princiotta
    
part of 'storage_helper.dart';
""";

    StorageHelperModel model = getModel(annotation.read('model').objectValue);

    log("Model:");
    print(model.toMap);

    for(int i = 0;i < model.categories.length;i++) { // Per ogni categoria aggiungo la classe
      StorageHelperCategory category = model.categories[i];
      code += "\n${createClass(i, category)}";
    }

    // Per ogni categoria inserisco gli attributi per le sottocategorie
    for(int i = 0;i < model.categories.length;i++) {
      String replace = "";
      String from = "{{sottoCategorie${i.toString()}}";

      try {
        replace = categoriesAttributes.where(
                (StorageHelperCategoryChild child) => child.parent == model.categories[i].key
        ).toList()[0].code;
      } catch(e) {}

      code = code.replaceAll(from, replace);
    }

    log("end!");

    return code;
  }
}