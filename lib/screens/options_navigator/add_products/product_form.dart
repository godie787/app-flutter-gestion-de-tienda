import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart'; // Importar para seleccionar imágenes
import 'package:firebase_storage/firebase_storage.dart'; // Importar Firebase Storage
import '../../../services/database_service.dart';

void showProductForm(BuildContext context, Map<String, dynamic> product,
    int index, Function(Map<String, dynamic>) onSave) {
  TextEditingController nameController =
      TextEditingController(text: product['name']);
  TextEditingController idController =
      TextEditingController(text: product['id']);
  TextEditingController netPriceController =
      TextEditingController(text: product['netPrice'].toString());
  TextEditingController salePriceController =
      TextEditingController(text: product['salePrice'].toString());
  TextEditingController descriptionController =
      TextEditingController(text: product['description'] ?? '');

  String? selectedCategory = product['categoryId'];
  String? selectedSubcategory = product['subcategoryId'];
  String? selectedSubsubcategory = product['subsubcategoryId'];
  String? selectedState = product['state'] ?? 'Activo';

  // Lista de URLs de las imágenes ya subidas
  List<String> uploadedImageUrls = List<String>.from(product['images'] ?? []);

  bool isUploadingImage = false; // Controla el estado de carga de la imagen

  List<Map<String, dynamic>> subcategories = [];
  List<Map<String, dynamic>> subsubcategories = [];

  final DatabaseService _databaseService = DatabaseService();
  final ImagePicker _picker = ImagePicker(); // Inicializa ImagePicker

  final Map<String, IconData> categoryIcons = {
    'Ropa': Icons.checkroom,
    'Accesorios': Icons.watch,
    'Zapatos': Icons.shopping_bag,
  };

  final Map<String, IconData> stateIcons = {
    'Activo': Icons.circle,
    'Vendido': Icons.check_circle,
    'En revisión': Icons.warning_amber,
  };

  final Map<String, Color> stateColors = {
    'Activo': Colors.green,
    'Vendido': Colors.red,
    'En revisión': Colors.orange,
  };

  Future<void> _scanBarcode(TextEditingController idController) async {
    String barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
        '#ff6666', 'Cancelar', true, ScanMode.BARCODE);
    if (barcodeScanRes != '-1') {
      idController.text = barcodeScanRes;
      product['id'] = barcodeScanRes;
    }
  }

  Future<String?> _uploadImageToFirebase(File imageFile, String productId) async {
    try {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('products/$productId/${DateTime.now().millisecondsSinceEpoch}.jpg');

      // Configurar los metadatos con Cache-Control
      final SettableMetadata metadata = SettableMetadata(
        cacheControl: 'public, max-age=31536000', // 1 año de caché
      );

      // Sube el archivo con los metadatos de Cache-Control
      final uploadTask = await storageRef.putFile(imageFile, metadata);
      final downloadUrl = await uploadTask.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      debugPrint('Error al cargar imagen: $e');
      return null;
    }
  }


  // Permitir seleccionar múltiples imágenes a la vez
  Future<void> _pickImages(StateSetter setState) async {
    final pickedFiles = await _picker.pickMultiImage();
    if (pickedFiles != null && uploadedImageUrls.length + pickedFiles.length <= 3) {
      for (var pickedFile in pickedFiles) {
        File imageFile = File(pickedFile.path);
        
        // Aquí pasamos el id del producto (idController.text) en lugar de setState
        String? uploadedUrl = await _uploadImageToFirebase(imageFile, idController.text); 
        
        if (uploadedUrl != null) {
          setState(() {
            uploadedImageUrls.add(uploadedUrl); // Agregar URL a la lista
          });
        }
      }
    }
  }


  Future<void> _loadSubcategories() async {
    if (selectedCategory != null) {
      subcategories =
          await _databaseService.getSubcategories(selectedCategory!);
      if (selectedSubcategory != null &&
          !subcategories.any((s) => s['id'] == selectedSubcategory)) {
        selectedSubcategory = null;
      }
    }
  }

  Future<void> _loadSubsubcategories() async {
    if (selectedCategory != null && selectedSubcategory != null) {
      subsubcategories = await _databaseService.getSubsubcategories(
          selectedCategory!, selectedSubcategory!);
      if (selectedSubsubcategory != null &&
          !subsubcategories.any((s) => s['id'] == selectedSubsubcategory)) {
        selectedSubsubcategory = null;
      }
    }
  }

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
            child: Container(
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(
                          Icons.edit,
                          size: 60,
                          color: Colors.teal,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Agregar detalles del producto',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal,
                      ),
                    ),
                    const SizedBox(height: 10),
                    
                    // Mostrar imágenes seleccionadas
                    if (uploadedImageUrls.isNotEmpty)
                      Wrap(
                        spacing: 10,
                        children: uploadedImageUrls.map((imageUrl) {
                          return Stack(
                            alignment: Alignment.topRight,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: Image.network(
                                  imageUrl,
                                  height: 100,
                                  width: 100,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  setState(() {
                                    uploadedImageUrls.remove(imageUrl); // Eliminar imagen
                                  });
                                },
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    
                    const SizedBox(height: 10),
                    
                    // Botón mejorado para seleccionar múltiples imágenes
                    ElevatedButton.icon(
                      onPressed: () => _pickImages(setState),
                      icon: const Icon(Icons.image),
                      label: const Text('Seleccionar Imágenes (máx 3)'),
                    ),

                    const SizedBox(height: 10),

                    if (isUploadingImage) // Mostrar el indicador de carga mientras se suben las imágenes
                      const Center(
                        child: CircularProgressIndicator(),
                      ),
                    
                    TextField(
                      controller: descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Descripción del Producto',
                      ),
                      maxLines: 1, // Permite texto de varias líneas
                    ),
                    const SizedBox(height: 10),
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
                          onPressed: () => _scanBarcode(idController),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 10),
                    
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Nombre del Producto',
                      ),
                    ),
                    
                    const SizedBox(height: 10),
                    
                    TextField(
                      controller: netPriceController,
                      decoration: const InputDecoration(
                        labelText: 'Precio Costo',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    
                    const SizedBox(height: 10),
                    
                    TextField(
                      controller: salePriceController,
                      decoration: const InputDecoration(
                        labelText: 'Precio de Venta',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    
                    const SizedBox(height: 10),

                    FutureBuilder<List<Map<String, dynamic>>>(
                      future: _databaseService.getCategories(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        }
                        if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        }
                        if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return const Text('No hay categorías disponibles');
                        }
                        final categories = snapshot.data!;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            DropdownButton<String>(
                              value: categories.any((category) =>
                                      category['id'] == selectedCategory)
                                  ? selectedCategory
                                  : null,
                              hint: const Text('Selecciona una categoría'),
                              icon: const Icon(Icons.arrow_drop_down),
                              isExpanded: true,
                              dropdownColor: Colors.white,
                              underline: Container(
                                height: 2,
                                color: Colors.deepPurpleAccent,
                              ),
                              items: categories.map((category) {
                                return DropdownMenuItem<String>(
                                  value: category['id'],
                                  child: Row(
                                    children: [
                                      Icon(
                                        categoryIcons[category['name']] ?? Icons.category,
                                        color: Colors.deepPurpleAccent,
                                      ),
                                      const SizedBox(width: 10),
                                      Text(category['name'], style: const TextStyle(color: Colors.black)),
                                    ],
                                  ),
                                );
                              }).toList(),
                              onChanged: (value) async {
                                setState(() {
                                  selectedCategory = value;
                                  selectedSubcategory = null;
                                  selectedSubsubcategory = null;
                                });

                                await _loadSubcategories();

                                setState(() {});

                                product['categoryId'] = selectedCategory;
                                product['subcategoryId'] = selectedSubcategory;
                                product['subsubcategoryId'] = selectedSubsubcategory;
                              },
                            ),
                            
                            if (selectedCategory != null)
                              FutureBuilder<void>(
                                future: _loadSubcategories(),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState == ConnectionState.waiting) {
                                    return const CircularProgressIndicator();
                                  }
                                  return DropdownButton<String>(
                                    value: subcategories.any((subcategory) => subcategory['id'] == selectedSubcategory)
                                        ? selectedSubcategory
                                        : null,
                                    hint: const Text('Selecciona una subcategoría'),
                                    icon: const Icon(Icons.arrow_drop_down),
                                    isExpanded: true,
                                    dropdownColor: Colors.white,
                                    underline: Container(
                                      height: 2,
                                      color: Colors.deepPurpleAccent,
                                    ),
                                    items: subcategories.map((subcategory) {
                                      return DropdownMenuItem<String>(
                                        value: subcategory['id'],
                                        child: Row(
                                          children: [
                                            Icon(Icons.subdirectory_arrow_right, color: Colors.deepPurpleAccent),
                                            const SizedBox(width: 10),
                                            Text(subcategory['name'], style: const TextStyle(color: Colors.black)),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (value) async {
                                      setState(() {
                                        selectedSubcategory = value;
                                        selectedSubsubcategory = null;
                                      });

                                      await _loadSubsubcategories();

                                      setState(() {});

                                      product['subcategoryId'] = selectedSubcategory;
                                      product['subsubcategoryId'] = selectedSubsubcategory;
                                    },
                                  );
                                },
                              ),
                          ],
                        );
                      },
                    ),
                    
                    const SizedBox(height: 20),

                    // Selección de estado del producto
                    DropdownButton<String>(
                      value: selectedState,
                      hint: const Text('Selecciona un estado'),
                      icon: const Icon(Icons.arrow_drop_down),
                      isExpanded: true,
                      dropdownColor: Colors.white,
                      underline: Container(
                        height: 2,
                        color: Colors.deepPurpleAccent,
                      ),
                      items: stateIcons.keys.map((state) {
                        return DropdownMenuItem<String>(
                          value: state,
                          child: Row(
                            children: [
                              Icon(
                                stateIcons[state],
                                color: stateColors[state],
                              ),
                              const SizedBox(width: 10),
                              Text(state, style: const TextStyle(color: Colors.black)),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedState = value;
                        });

                        product['state'] = selectedState;
                      },
                    ),

                    const SizedBox(height: 20),
                    
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[200],
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                          child: const Text('Cancelar'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            onSave({
                              'id': idController.text,
                              'name': nameController.text,
                              'netPrice': double.tryParse(netPriceController.text) ?? 0,
                              'salePrice': double.tryParse(salePriceController.text) ?? 0,
                              'description': descriptionController.text, // Incluir descripción
                              'categoryId': selectedCategory,
                              'subcategoryId': selectedSubcategory,
                              'subsubcategoryId': selectedSubsubcategory,
                              'state': selectedState,
                              'createdAt': Timestamp.now(),
                              'images': uploadedImageUrls, // Pasa las URLs de las imágenes
                            });
                            Navigator.of(context).pop();
                          },
                          child: const Text('Guardar'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    },
  );
}
