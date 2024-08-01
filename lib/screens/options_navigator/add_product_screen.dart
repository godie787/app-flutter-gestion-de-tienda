import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '/services/database_service.dart';
import '/services/categories.dart'; // Asegúrate de usar la ruta correcta

class AddProductScreen extends StatefulWidget {
  @override
  _AddProductScreenState createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  List<Map<String, dynamic>> products = [
    {
      'name': '',
      'id': '',
      'netPrice': 0,
      'salePrice': 0,
      'category': '',
      'description': '',
      'createdAt': Timestamp.now()
    }
  ];

  final DatabaseService _databaseService = DatabaseService();

  Future<void> _scanBarcode(TextEditingController idController, int index) async {
    String barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
        '#ff6666', 'Cancelar', true, ScanMode.BARCODE);
    if (barcodeScanRes != '-1') {
      setState(() {
        idController.text = barcodeScanRes;
        products[index]['id'] = barcodeScanRes;
      });
    }
  }

  void _showProductForm(int index) {
  TextEditingController nameController =
      TextEditingController(text: products[index]['name']);
  TextEditingController idController =
      TextEditingController(text: products[index]['id']);
  TextEditingController netPriceController = TextEditingController(
      text: products[index]['netPrice'].toString());
  TextEditingController salePriceController = TextEditingController(
      text: products[index]['salePrice'].toString());
  TextEditingController descriptionController = TextEditingController(
      text: products[index]['description']);

  String selectedCategory = products[index]['idCategoria'] ?? '';

  void _selectCategory() async {
    String? category = await _showCategoryPicker(context);
    if (category != null) {
      setState(() {
        selectedCategory = category;
      });
      
      if (selectedCategory.isNotEmpty) {
        print("Categoría seleccionada: $selectedCategory");
      } else {
        print("Error: No se seleccionó ninguna categoría");
      }
    } else {
      print("Error: La selección de categoría falló o fue cancelada");
    }
  }

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Agregar detalles del producto'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: idController,
                      decoration: const InputDecoration(
                        labelText: 'ID del Producto',
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.qr_code_scanner),
                    onPressed: () => _scanBarcode(idController, index),
                  ),
                ],
              ),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Nombre del Producto'),
              ),
              TextField(
                controller: netPriceController,
                decoration: const InputDecoration(labelText: 'Precio Costo'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: salePriceController,
                decoration: const InputDecoration(labelText: 'Precio de Venta'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Descripción'),
                maxLines: 3,
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Text(
                    selectedCategory.isEmpty ? 'Seleccionar Categoría' : selectedCategory,
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                  IconButton(
                    icon: const Icon(Icons.arrow_drop_down),
                    onPressed: _selectCategory,
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                products[index] = {
                  'id': idController.text,
                  'name': nameController.text,
                  'netPrice': double.tryParse(netPriceController.text) ?? 0,
                  'salePrice': double.tryParse(salePriceController.text) ?? 0,
                  'description': descriptionController.text,
                  'idCategoria': selectedCategory.isNotEmpty ? selectedCategory : '',
                  'createdAt': Timestamp.now(),
                };
              });
              Navigator.of(context).pop();
            },
            child: const Text('Guardar'),
          ),
        ],
      );
    },
  );
}





  Future<String?> _showCategoryPicker(BuildContext context) async {
  String? selectedCategory;
  await showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Selecciona una categoría'),
        content: SingleChildScrollView(
          child: Column(
            children: _buildCategoryList(categories),
          ),
        ),
      );
    },
  );
  return selectedCategory;
}


  List<Widget> _buildCategoryList(Map<String, dynamic> categories, {int level = 0}) {
    List<Widget> categoryList = [];

    categories.forEach((category, subcategories) {
      if (subcategories is Map<String, dynamic>) {
        categoryList.add(
          ExpansionTile(
            title: Padding(
              padding: EdgeInsets.only(left: level * 16.0),
              child: Text(category),
            ),
            children: _buildCategoryList(subcategories, level: level + 1),
          ),
        );
      } else if (subcategories is List<dynamic>) {
        categoryList.add(
          ExpansionTile(
            title: Padding(
              padding: EdgeInsets.only(left: level * 16.0),
              child: Text(category),
            ),
            children: subcategories.map<Widget>((subCategory) {
              return ListTile(
                title: Padding(
                  padding: EdgeInsets.only(left: (level + 1) * 16.0),
                  child: Text(subCategory.toString()),
                ),
                onTap: () {
                  Navigator.of(context).pop(subCategory.toString());
                },
              );
            }).toList(),
          ),
        );
      }
    });

    return categoryList;
  }


  void _addNewProductField() {
    setState(() {
      products.add({
        'name': '',
        'id': '',
        'netPrice': 0.0,
        'salePrice': 0.0,
        'description': '',
        'category': '',
        'createdAt': Timestamp.now(),
      });
    });
  }

  void _removeProductField(int index) {
    setState(() {
      products.removeAt(index);
    });
  }

  Future<void> _saveProducts() async {
    for (var product in products) {
      // Verificar si el ID del producto ya existe
      bool idExists = await _databaseService.checkIfProductIdExists(product['id']);
      
      if (idExists) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('El ID ${product['id']} ya está en uso.')),
        );
        return;
      }

      await _databaseService.addProduct(product);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Producto/s guardado/s con éxito')),
    );

    // Limpiar el formulario
    setState(() {
      products = [
        {
          'name': '',
          'id': '',
          'netPrice': 0,
          'salePrice': 0,
          'category': '',
          'description': '',
          'createdAt': Timestamp.now()
        }
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 5,
                  blurRadius: 7,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Agregar productos',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Column(
                  children: products.map((product) {
                    int index = products.indexOf(product);
                    return Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => _showProductForm(index),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 15, horizontal: 20),
                              margin: const EdgeInsets.symmetric(vertical: 5),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.teal),
                              ),
                              child: Text(
                                product['name'].isEmpty
                                    ? 'Ingresa un producto...'
                                    : product['name'],
                                style: TextStyle(color: Colors.grey[700]),
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: _addNewProductField,
                        ),
                        if (index != 0)
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _removeProductField(index),
                          ),
                      ],
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _saveProducts,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  child: const Text('Agregar Productos'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
