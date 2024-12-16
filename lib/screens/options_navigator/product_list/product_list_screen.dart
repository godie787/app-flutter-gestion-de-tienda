import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../../services/database_service.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({Key? key}) : super(key: key);

  @override
  _ProductListScreenState createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final TextEditingController searchController = TextEditingController();
  List<Map<String, dynamic>> products = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() {
      isLoading = true;
    });

    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('Productos').get();
      products = querySnapshot.docs
          .map((doc) =>
              {...(doc.data() as Map<String, dynamic>), 'docId': doc.id})
          .toList();
    } catch (e) {
      debugPrint('Error al cargar productos: $e');
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<void> _updateProduct(
      String docId, Map<String, dynamic> updatedData) async {
    try {
      await FirebaseFirestore.instance
          .collection('Productos')
          .doc(docId)
          .update(updatedData);
      debugPrint('Producto actualizado exitosamente');
    } catch (e) {
      debugPrint('Error al actualizar producto: $e');
    }
  }

  Future<void> _deleteProduct(String docId) async {
    try {
      await FirebaseFirestore.instance
          .collection('Productos')
          .doc(docId)
          .delete();
      setState(() {
        products.removeWhere((product) => product['docId'] == docId);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Producto eliminado exitosamente'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      debugPrint('Error al eliminar producto: $e');
    }
  }

  void _confirmDeleteProduct(String docId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Eliminar Producto'),
          content: const Text(
              '¿Estás seguro de que deseas eliminar este producto? Esta acción no se puede deshacer.'),
          actions: [
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Eliminar'),
              onPressed: () {
                _deleteProduct(docId);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Campo de búsqueda
            TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Buscar producto por código',
                prefixIcon: Icon(Icons.search, color: Colors.teal),

                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(25.0), // Bordes más redondeados
                  borderSide: BorderSide.none, // Sin borde visible
                ),
                filled: true,
                fillColor: Colors.grey[300], // Fondo gris claro
                contentPadding: const EdgeInsets.symmetric(
                    vertical: 15.0, horizontal: 20.0),
                hintStyle: const TextStyle(color: Colors.grey), // Texto en gris
              ),
              style: const TextStyle(
                  color: Colors.grey), // Estilo del texto ingresado
              onChanged: (value) {
                setState(() {}); // Actualiza la lista cuando el texto cambia
              },
            ),

            const SizedBox(height: 20),

            // ListView de productos
            Expanded(
              child: RefreshIndicator(
                onRefresh: _loadProducts,
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.builder(
                        itemCount: products.length,
                        itemBuilder: (context, index) {
                          final product = products[index];
                          if (searchController.text.isNotEmpty &&
                              !product['id'].toLowerCase().contains(
                                  searchController.text.toLowerCase())) {
                            return const SizedBox();
                          }
                          return Card(
                            elevation: 4,
                            margin: const EdgeInsets.symmetric(vertical: 10.0),
                            child: ListTile(
                              leading: product['images'] != null &&
                                      product['images'].isNotEmpty
                                  ? Image.network(
                                      product['images'][0],
                                      width: 50,
                                      height: 50,
                                      fit: BoxFit.cover,
                                    )
                                  : const Icon(Icons.image_not_supported),
                              title: Text(product['name'] ?? 'Sin nombre'),
                              subtitle: Text(
                                  'Precio: \$${product['salePrice'] ?? 'N/A'}'),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text('Código: ${product['id'] ?? 'N/A'}'),
                                  Text(
                                    product['state'] ?? 'Desconocido',
                                    style: TextStyle(
                                      color: product['state'] == 'Activo'
                                          ? Colors.green
                                          : Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                              onTap: () {
                                _showEditProductPopup(context, product, index,
                                    (updatedProduct) async {
                                  await _updateProduct(
                                      product['docId'], updatedProduct);
                                  products[index] = updatedProduct;
                                  setState(() {});
                                });
                              },
                              onLongPress: () {
                                _confirmDeleteProduct(product['docId']);
                              },
                            ),
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditProductPopup(BuildContext context, Map<String, dynamic> product,
      int index, Function(Map<String, dynamic>) onSave) {
    showProductForm(context, product, index, onSave);
  }
}

void showProductForm(BuildContext context, Map<String, dynamic> product,
    int index, Function(Map<String, dynamic>) onSave) {
  void _showSuccessMessage(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Producto actualizado exitosamente'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  // Controllers
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

  List<String> uploadedImageUrls = List<String>.from(product['images'] ?? []);

  final ImagePicker _picker = ImagePicker();
  final DatabaseService _databaseService = DatabaseService();

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

  List<Map<String, dynamic>> subcategories = [];
  List<Map<String, dynamic>> subsubcategories = [];

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
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Editar Producto',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal,
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (uploadedImageUrls.isNotEmpty)
                      Wrap(
                        spacing: 10,
                        children: uploadedImageUrls.map((imageUrl) {
                          return Stack(
                            children: [
                              Image.network(
                                imageUrl,
                                height: 100,
                                width: 100,
                                fit: BoxFit.cover,
                              ),
                              IconButton(
                                icon:
                                    const Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  setState(() {
                                    uploadedImageUrls.remove(imageUrl);
                                  });
                                },
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ElevatedButton.icon(
                      onPressed: () async {
                        final pickedFiles = await _picker.pickMultiImage();
                        if (pickedFiles != null) {
                          setState(() {
                            uploadedImageUrls
                                .addAll(pickedFiles.map((e) => e.path));
                          });
                        }
                      },
                      icon: const Icon(Icons.image),
                      label: const Text('Seleccionar Imágenes'),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Descripción del Producto',
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: idController,
                            decoration: const InputDecoration(
                              labelText: 'Código del Producto',
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
                    // Categoría
                    FutureBuilder<List<Map<String, dynamic>>>(
                      future: _databaseService.getCategories(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
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
                          children: [
                            DropdownButton<String>(
                              value: selectedCategory,
                              hint: const Text('Selecciona una categoría'),
                              isExpanded: true,
                              items: categories.map((category) {
                                return DropdownMenuItem<String>(
                                  value: category['id'],
                                  child: Text(category['name']),
                                );
                              }).toList(),
                              onChanged: (value) async {
                                setState(() {
                                  selectedCategory = value;
                                  selectedSubcategory = null;
                                  selectedSubsubcategory = null;
                                });
                                await _loadSubcategories();
                              },
                            ),
                            if (selectedCategory != null)
                              FutureBuilder<void>(
                                future: _loadSubcategories(),
                                builder: (context, snapshot) {
                                  return DropdownButton<String>(
                                    value: selectedSubcategory,
                                    hint: const Text(
                                        'Selecciona una subcategoría'),
                                    isExpanded: true,
                                    items: subcategories.map((subcategory) {
                                      return DropdownMenuItem<String>(
                                        value: subcategory['id'],
                                        child: Text(subcategory['name']),
                                      );
                                    }).toList(),
                                    onChanged: (value) async {
                                      setState(() {
                                        selectedSubcategory = value;
                                        selectedSubsubcategory = null;
                                      });
                                      await _loadSubsubcategories();
                                    },
                                  );
                                },
                              ),
                            if (selectedSubcategory != null)
                              FutureBuilder<void>(
                                future: _loadSubsubcategories(),
                                builder: (context, snapshot) {
                                  return DropdownButton<String>(
                                    value: selectedSubsubcategory,
                                    hint: const Text(
                                        'Selecciona una subsubcategoría'),
                                    isExpanded: true,
                                    items:
                                        subsubcategories.map((subsubcategory) {
                                      return DropdownMenuItem<String>(
                                        value: subsubcategory['id'],
                                        child: Text(subsubcategory['name']),
                                      );
                                    }).toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        selectedSubsubcategory = value;
                                      });
                                    },
                                  );
                                },
                              ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 10),
                    // Estado
                    DropdownButton<String>(
                      value: selectedState,
                      hint: const Text('Selecciona un estado'),
                      isExpanded: true,
                      items: stateIcons.keys.map((state) {
                        return DropdownMenuItem<String>(
                          value: state,
                          child: Row(
                            children: [
                              Icon(stateIcons[state],
                                  color: stateColors[state]),
                              const SizedBox(width: 10),
                              Text(state),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedState = value;
                        });
                      },
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        onSave({
                          'name': nameController.text,
                          'netPrice':
                              double.tryParse(netPriceController.text) ?? 0,
                          'salePrice':
                              double.tryParse(salePriceController.text) ?? 0,
                          'description': descriptionController.text,
                          'categoryId': selectedCategory,
                          'subcategoryId': selectedSubcategory,
                          'subsubcategoryId': selectedSubsubcategory,
                          'state': selectedState,
                          'id': idController.text,
                          'images': uploadedImageUrls,
                        });

                        _showSuccessMessage(context);

                        Navigator.of(context).pop();
                      },
                      child: const Text('Guardar'),
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

Future<void> _scanBarcode(TextEditingController idController) async {
  String barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
      '#ff6666', 'Cancelar', true, ScanMode.BARCODE);
  if (barcodeScanRes != '-1') {
    idController.text = barcodeScanRes;
  }
}
