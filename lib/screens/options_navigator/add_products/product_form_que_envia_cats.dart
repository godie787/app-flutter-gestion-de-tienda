






/*void showProductForm(BuildContext context, Map<String, dynamic> product,
    int index, Function(Map<String, dynamic>) onSave) {
  TextEditingController nameController =
      TextEditingController(text: product['name']);
  TextEditingController idController =
      TextEditingController(text: product['id']);
  TextEditingController netPriceController =
      TextEditingController(text: product['netPrice'].toString());
  TextEditingController salePriceController =
      TextEditingController(text: product['salePrice'].toString());

  String? selectedCategory = product['category'];
  String? selectedSubcategory = product['subcategory'];
  String? selectedSubsubcategory = product['subsubcategory'];

  List<Map<String, dynamic>> subcategories = [];
  List<Map<String, dynamic>> subsubcategories = [];

  final DatabaseService _databaseService = DatabaseService();

  final Map<String, IconData> categoryIcons = {
    'Ropa': Icons.checkroom,
    'Accesorios': Icons.watch,
    'Zapatos': Icons.shopping_bag,
  };

  Future<void> _scanBarcode(TextEditingController idController) async {
    String barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
        '#ff6666', 'Cancelar', true, ScanMode.BARCODE);
    if (barcodeScanRes != '-1') {
      idController.text = barcodeScanRes;
      product['id'] = barcodeScanRes;
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
          return AlertDialog(
            title: const Text('Agregar detalles del producto'),
            content: SingleChildScrollView(
              child: Wrap(
                spacing: 8.0,
                runSpacing: 4.0,
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
                        onPressed: () => _scanBarcode(idController),
                      ),
                    ],
                  ),
                  TextField(
                    controller: nameController,
                    decoration:
                        const InputDecoration(labelText: 'Nombre del Producto'),
                  ),
                  TextField(
                    controller: netPriceController,
                    decoration:
                        const InputDecoration(labelText: 'Precio Costo'),
                    keyboardType: TextInputType.number,
                  ),
                  TextField(
                    controller: salePriceController,
                    decoration:
                        const InputDecoration(labelText: 'Precio de Venta'),
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
                                      categoryIcons[category['name']] ??
                                          Icons.category,
                                      color: Colors.deepPurpleAccent,
                                    ),
                                    const SizedBox(width: 10),
                                    Text(category['name'],
                                        style: const TextStyle(
                                            color: Colors.black)),
                                  ],
                                ),
                              );
                            }).toList(),
                            onChanged: (value) async {
                              setState(() {
                                selectedCategory = value;
                                selectedSubcategory = null; // Reset subcategory
                                selectedSubsubcategory =
                                    null; // Reset subsubcategory
                              });

                              await _loadSubcategories();

                              setState(() {});

                              // Guarda la selección en el producto
                              product['categoryId'] = selectedCategory;
                              product['subcategoryId'] = selectedSubcategory;
                              product['subsubcategoryId'] =
                                  selectedSubsubcategory;
                            },
                          ),
                          if (selectedCategory != null)
                            FutureBuilder<void>(
                              future: _loadSubcategories(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const CircularProgressIndicator();
                                }
                                return DropdownButton<String>(
                                  value: subcategories.any((subcategory) =>
                                          subcategory['id'] ==
                                          selectedSubcategory)
                                      ? selectedSubcategory
                                      : null,
                                  hint:
                                      const Text('Selecciona una subcategoría'),
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
                                          Icon(Icons.subdirectory_arrow_right,
                                              color: Colors.deepPurpleAccent),
                                          const SizedBox(width: 10),
                                          Text(subcategory['name'],
                                              style: const TextStyle(
                                                  color: Colors.black)),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (value) async {
                                    setState(() {
                                      selectedSubcategory = value;
                                      selectedSubsubcategory =
                                          null; // Reset subsubcategory
                                    });

                                    await _loadSubsubcategories();

                                    setState(() {});

                                    // Guarda la selección en el producto
                                    product['subcategoryId'] =
                                        selectedSubcategory;
                                    product['subsubcategoryId'] =
                                        selectedSubsubcategory;
                                  },
                                );
                              },
                            ),
                          if (selectedSubcategory != null)
                            FutureBuilder<void>(
                              future: _loadSubsubcategories(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const CircularProgressIndicator();
                                }
                                return DropdownButton<String>(
                                  value: subsubcategories.any(
                                          (subsubcategory) =>
                                              subsubcategory['id'] ==
                                              selectedSubsubcategory)
                                      ? selectedSubsubcategory
                                      : null,
                                  hint: const Text(
                                      'Selecciona una sub-subcategoría'),
                                  icon: const Icon(Icons.arrow_drop_down),
                                  isExpanded: true,
                                  dropdownColor: Colors.white,
                                  underline: Container(
                                    height: 2,
                                    color: Colors.deepPurpleAccent,
                                  ),
                                  items: subsubcategories.map((subsubcategory) {
                                    return DropdownMenuItem<String>(
                                      value: subsubcategory['id'],
                                      child: Row(
                                        children: [
                                          Icon(Icons.subdirectory_arrow_right,
                                              color: Colors.deepPurpleAccent),
                                          const SizedBox(width: 10),
                                          Text(subsubcategory['name'],
                                              style: const TextStyle(
                                                  color: Colors.black)),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      selectedSubsubcategory = value;
                                    });

                                    // Guarda la selección en el producto
                                    product['subsubcategoryId'] =
                                        selectedSubsubcategory;
                                  },
                                );
                              },
                            ),
                        ],
                      );
                    },
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
                  onSave({
                    'id': idController.text,
                    'name': nameController.text,
                    'netPrice': double.tryParse(netPriceController.text) ?? 0,
                    'salePrice': double.tryParse(salePriceController.text) ?? 0,
                    'categoryId': selectedCategory,
                    'subcategoryId': selectedSubcategory,
                    'subsubcategoryId': selectedSubsubcategory,
                    'createdAt': Timestamp.now(),
                  });
                  Navigator.of(context).pop();
                },
                child: const Text('Guardar'),
              ),
            ],
          );
        },
      );
    },
  );
}*/
