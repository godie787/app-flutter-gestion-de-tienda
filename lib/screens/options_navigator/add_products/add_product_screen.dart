import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '/services/database_service.dart';
import '../add_products/product_form.dart'; // Importa el nuevo archivo para el formulario

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({Key? key}) : super(key: key);

  @override
  AddProductScreenState createState() => AddProductScreenState();
}

class AddProductScreenState extends State<AddProductScreen> {
  List<Map<String, dynamic>> products = [
    {
      'name': '',
      'id': '',
      'netPrice': 0,
      'salePrice': 0,
      'categoryId': null, // Agregado
      'subcategoryId': null, // Agregado
      'subsubcategoryId': null, // Agregado
      'state': 'Activo', // Agregado
      'createdAt': Timestamp.now(),
    }
  ];

  final DatabaseService _databaseService = DatabaseService();
  bool _isLoading = false;

  void _addNewProductField() {
    setState(() {
      products.add({
        'name': '',
        'id': '',
        'netPrice': 0,
        'salePrice': 0,
        'categoryId': null, // Agregado
        'subcategoryId': null, // Agregado
        'subsubcategoryId': null, // Agregado
        'state': 'Activo', // Agregado
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
    setState(() {
      _isLoading = true;
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    try {
      for (var product in products) {
        // Imprimir los datos antes de guardarlos
        print('Guardando producto: $product');

        // Verificar si el ID del producto ya existe
        bool idExists =
            await _databaseService.checkIfProductIdExists(product['id']);

        if (idExists) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('El ID ${product['id']} ya está en uso.'),
              ),
            );
          }
          return;
        }

        await _databaseService.addProduct(product);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Producto/s guardado/s con éxito.'),
          ),
        );
      }

      // Limpiar el formulario
      setState(() {
        products = [
          {
            'name': '',
            'id': '',
            'netPrice': 0,
            'salePrice': 0,
            'categoryId': null, // Agregado
            'subcategoryId': null, // Agregado
            'subsubcategoryId': null, // Agregado
            'state': 'Activo', // Agregado
            'createdAt': Timestamp.now(),
          }
        ];
      });
    } catch (e) {
      debugPrint('Error al agregar el producto: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
      Navigator.of(context).pop(); // Cierra el diálogo de carga
    }
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
                  offset: const Offset(0, 3),
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
                            onTap: () => showProductForm(
                              context,
                              product,
                              index,
                              (updatedProduct) {
                                setState(() {
                                  products[index] = updatedProduct;
                                });
                              },
                            ),
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
                  onPressed: _isLoading ? null : _saveProducts, // Deshabilitar mientras carga
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
