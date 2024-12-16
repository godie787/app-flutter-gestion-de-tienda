import 'dart:io';
import 'package:flutter/material.dart';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '/services/database_service.dart'; // Asegúrate de tener tu servicio de base de datos aquí

class ImportProductsScreen extends StatefulWidget {
  const ImportProductsScreen({Key? key}) : super(key: key);

  @override
  _ImportProductsScreenState createState() => _ImportProductsScreenState();
}

class _ImportProductsScreenState extends State<ImportProductsScreen> {
  final DatabaseService _databaseService = DatabaseService();
  bool _isLoading = false;
  List<Map<String, dynamic>> _importedProducts = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Importar Productos desde Excel"),
      ),
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: _importExcel,
                    child: const Text("Seleccionar Archivo Excel"),
                  ),
                  if (_importedProducts.isNotEmpty)
                    ..._importedProducts.map((product) => ListTile(
                          title: Text(product['name']),
                          subtitle: Text(
                              "ID: ${product['id']}, Precio: ${product['netPrice']}"),
                        )),
                  if (_importedProducts.isNotEmpty)
                    ElevatedButton(
                      onPressed: _saveImportedProducts,
                      child: const Text("Guardar Productos en Firebase"),
                    )
                ],
              ),
      ),
    );
  }

  Future<void> _importExcel() async {
  try {
    setState(() {
      _isLoading = true;
    });

    // Seleccionar el archivo Excel
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
    );

    if (result != null) {
      File file = File(result.files.single.path!);
      var bytes = file.readAsBytesSync();
      var excel = Excel.decodeBytes(bytes);

      List<Map<String, dynamic>> products = [];

      // Leer los productos desde la primera hoja del Excel
      for (var table in excel.tables.keys) {
        var sheet = excel.tables[table];

        if (sheet != null) {
          for (var row in sheet.rows.skip(1)) {
            products.add({
              'name': row[0]?.value.toString() ?? '',  // Convertir el valor a String
              'id': row[1]?.value.toString() ?? '',    // Convertir el valor a String
              'netPrice': row[2]?.value ?? 0,
              'salePrice': row[3]?.value ?? 0,
              'categoryId': row[4]?.value.toString() ?? null,  // Convertir el valor a String
              'subcategoryId': row[5]?.value.toString() ?? null,  // Convertir el valor a String
              'subsubcategoryId': row[6]?.value.toString() ?? null,  // Convertir el valor a String
              'state': 'Activo', // Estado por defecto
              'createdAt': Timestamp.now(),
            });
          }
        }
      }

      setState(() {
        _importedProducts = products;
        _isLoading = false;
      });
    }
  } catch (e) {
    debugPrint('Error al importar el archivo Excel: $e');
    setState(() {
      _isLoading = false;
    });
  }
}


  Future<void> _saveImportedProducts() async {
    setState(() {
      _isLoading = true;
    });

    try {
      for (var product in _importedProducts) {
        bool idExists =
            await _databaseService.checkIfProductIdExists(product['id']);

        if (!idExists) {
          await _databaseService.addProduct(product);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('El ID ${product['id']} ya está en uso.'),
          ));
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Productos guardados con éxito.'),
      ));
    } catch (e) {
      debugPrint('Error al guardar productos en Firebase: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
