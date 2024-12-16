import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Importar shared_preferences
import '/services/database_service.dart';
import '../add_products/product_form.dart'; // Importa el nuevo archivo para el formulario
import 'dart:convert'; // Importar para codificar y decodificar JSON
import 'dart:io'; // Importar para manejar archivos de imagen
import 'package:image_picker/image_picker.dart'; // Importar para seleccionar imágenes
import 'package:firebase_storage/firebase_storage.dart'; // Importar Firebase Storage

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
      'categoryId': null,
      'subcategoryId': null,
      'subsubcategoryId': null,
      'state': 'Activo',
      'image': null, // Campo para imagen
      'createdAt': Timestamp.now(),
    }
  ];

  final DatabaseService _databaseService = DatabaseService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadProductsFromLocalStorage(); // Cargar productos desde almacenamiento local
  }

  // Guardar productos en almacenamiento local
  Future<void> _saveProductsToLocalStorage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> encodedProducts = products.map((product) {
      product['createdAt'] = product['createdAt'].millisecondsSinceEpoch;
      return jsonEncode(product);
    }).toList();
    await prefs.setStringList('products', encodedProducts);
  }

  // Cargar productos desde almacenamiento local
  Future<void> _loadProductsFromLocalStorage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? encodedProducts = prefs.getStringList('products');
    if (encodedProducts != null) {
      setState(() {
        products = encodedProducts.map((product) {
          Map<String, dynamic> decodedProduct = jsonDecode(product);
          decodedProduct['createdAt'] = Timestamp.fromMillisecondsSinceEpoch(
              decodedProduct['createdAt']);
          return decodedProduct;
        }).toList();
      });
    }
  }

  // Método para subir la imagen a Firebase Storage y obtener la URL
  Future<String?> _uploadImageToFirebase(File imageFile, String productId) async {
    try {
      final storageRef =
          FirebaseStorage.instance.ref().child('products/$productId.jpg');
      final uploadTask = await storageRef.putFile(imageFile);
      final downloadUrl = await uploadTask.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      debugPrint('Error al cargar imagen: $e');
      return null;
    }
  }

  void _addNewProductField() {
    setState(() {
      products.add({
        'name': '',
        'id': '',
        'netPrice': 0,
        'salePrice': 0,
        'categoryId': null,
        'subcategoryId': null,
        'subsubcategoryId': null,
        'state': 'Activo',
        'image': null, // Campo para imagen
        'createdAt': Timestamp.now(),
      });
    });
    _saveProductsToLocalStorage(); // Guardar después de agregar un producto
  }

  void _removeProductField(int index) {
    setState(() {
      products.removeAt(index);
    });
    _saveProductsToLocalStorage(); // Guardar después de eliminar un producto
  }

  Future<void> _saveProducts() async {
    setState(() {
      _isLoading = true;
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    try {
      for (var product in products) {
        // Verificar si el ID del producto ya existe
        bool idExists = await _databaseService.checkIfProductIdExists(product['id']);

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

        // Si hay imágenes seleccionadas, súbelas a Firebase Storage
        if (product['imageFiles'] != null && product['imageFiles'].isNotEmpty) {
          List<String> imageUrls = [];
          for (var imageFile in product['imageFiles']) {
            String? imageUrl = await _uploadImageToFirebase(File(imageFile.path), product['id']);
            if (imageUrl != null) {
              imageUrls.add(imageUrl);
            }
          }
          product['images'] = imageUrls; // Guardar las URLs de las imágenes en la lista
        }

        // Elimina el campo temporal 'imageFiles' antes de guardar en Firestore
        product.remove('imageFiles');

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
            'categoryId': null,
            'subcategoryId': null,
            'subsubcategoryId': null,
            'state': 'Activo',
            'images': [], // Cambiado de 'image' a 'images'
            'createdAt': Timestamp.now(),
          }
        ];
      });

      await _saveProductsToLocalStorage(); // Limpiar el almacenamiento local después de guardar
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
                                _saveProductsToLocalStorage(); // Guardar después de actualizar un producto
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
                  onPressed: _isLoading
                      ? null
                      : _saveProducts, // Deshabilitar mientras carga
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  child: const Text('Agregar Productos',
                      style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
