import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../services/database_service.dart';

class SellProductScreen extends StatefulWidget {
  const SellProductScreen({Key? key}) : super(key: key);

  @override
  SellProductScreenState createState() => SellProductScreenState();
}

class SellProductScreenState extends State<SellProductScreen>
    with TickerProviderStateMixin {
  final List<Map<String, dynamic>> _products = [];
  final DatabaseService _databaseService = DatabaseService();
  bool _isLoading = false;

  void _addNewProductField() {
    setState(() {
      _products.add({
        'idController': TextEditingController(),
        'nameController': TextEditingController(),
        'netPriceController': TextEditingController(),
        'salePriceController': TextEditingController(),
        'state': 'Activo',
      });
    });
  }

  void _removeProductField(int index) {
    setState(() {
      _products.removeAt(index);
    });
  }

  Future<void> _scanBarcode(int index) async {
  String barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
      '#ff6666', 'Cancelar', true, ScanMode.BARCODE);
  if (barcodeScanRes != '-1') {
    // Verificar si el producto ya está en la lista o si su estado es 'Vendido'
    bool productAlreadyAdded = _products.any((product) =>
        product['idController'].text == barcodeScanRes);

    if (productAlreadyAdded) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('El producto ya está en la lista.'),
        ),
      );
      return;
    }

    // Si no está en la lista, procedemos a buscar sus detalles y agregarlo
    _fetchProductDetails(index, barcodeScanRes);
  }
}


  Future<void> _fetchProductDetails(int index, String productId) async {
  setState(() {
    _isLoading = true;
  });

  try {
    // Verificar si el producto ya fue agregado
    bool productAlreadyAdded = _products.any((product) => 
      product['idController'].text == productId
    );

    if (productAlreadyAdded) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('El producto ya está en la lista.'),
        ),
      );
      setState(() {
        _isLoading = false;
        _products[index]['idController'].clear(); // Limpiar el campo ID
      });
      return;
    }

    var productData = await _databaseService.getProductById(productId);

    if (productData != null) {
      if (productData['state'] == 'Vendido') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Este producto ya ha sido vendido.'),
          ),
        );
        setState(() {
          _isLoading = false;
          _products[index]['idController'].clear(); // Limpiar el campo ID
        });
        return;
      }

      setState(() {
        _products[index]['idController'].text = productId; // Asignar el ID solo si es válido
        _products[index]['nameController'].text = productData['name'] ?? '';
        _products[index]['netPriceController'].text =
            productData['netPrice'].toString();
        _products[index]['salePriceController'].text =
            productData['salePrice'].toString();
        _products[index]['state'] = productData['state'] ?? 'Activo';
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Producto no encontrado.'),
        ),
      );
      setState(() {
        _products[index]['idController'].clear(); // Limpiar el campo ID si no se encuentra
      });
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error al buscar el producto: $e'),
      ),
    );
  } finally {
    setState(() {
      _isLoading = false;
    });
  }
}

  void _showSaleDetails() {
  if (!_areProductsValid()) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Por favor, complete todos los campos de los productos antes de procesar la venta.'),
      ),
    );
    return;
  }

  double total = _products.fold(0, (sum, item) {
    return sum + (double.tryParse(item['salePriceController'].text) ?? 0);
  });

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Detalle de la Venta'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ..._products.map((product) {
                return ListTile(
                  title: Text(product['nameController'].text),
                  subtitle: Text('Precio: \$${product['salePriceController'].text}'),
                );
              }).toList(),
              const Divider(),
              ListTile(
                title: const Text(
                  'Total:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                trailing: Text(
                  '\$$total',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              setState(() {
                _isLoading = true;
              });

              await _databaseService.processSale(_products);

              setState(() {
                _isLoading = false;
                _products.clear(); // Limpiar la lista de productos
              });

              Navigator.of(context).pop(); // Cerrar el popup después de procesar la venta

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Venta procesada exitosamente.'),
                ),
              );
            },
            child: const Text('Procesar Venta'),
          ),
        ],
      );
    },
  );
}

bool _areProductsValid() {
  for (var product in _products) {
    if (product['idController'].text.isEmpty ||
        product['nameController'].text.isEmpty ||
        product['netPriceController'].text.isEmpty ||
        product['salePriceController'].text.isEmpty) {
      return false;
    }
  }
  return true;
}




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: const Text('Vender Producto'),
        backgroundColor: Colors.teal,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ..._products.map((product) {
                    int index = _products.indexOf(product);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Dismissible(
                        key: UniqueKey(),
                        direction: DismissDirection.endToStart,
                        onDismissed: (direction) {
                          _removeProductField(index);
                        },
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          color: Colors.green, // Cambiado a verde
                          child: const Icon(
                            Icons.delete,
                            color: Colors.white,
                          ),
                        ),
                        child: Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: ExpansionTile(
                            title: Text(
                              product['nameController'].text.isEmpty
                                  ? 'Producto ${index + 1}'
                                  : product['nameController'].text,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600),
                            ),
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(15.0),
                                child: Column(
                                  children: [
                                    TextField(
                                      controller: product['idController'],
                                      decoration: InputDecoration(
                                        labelText: 'ID del Producto',
                                        suffixIcon: IconButton(
                                          icon: const Icon(
                                              Icons.qr_code_scanner),
                                          onPressed: () => _scanBarcode(index),
                                        ),
                                      ),
                                      onSubmitted: (value) =>
                                          _fetchProductDetails(index, value),
                                    ),
                                    const SizedBox(height: 10),
                                    TextField(
                                      controller: product['nameController'],
                                      decoration: const InputDecoration(
                                          labelText: 'Nombre del Producto'),
                                      readOnly: true,
                                    ),
                                    TextField(
                                      controller:
                                          product['netPriceController'],
                                      decoration: const InputDecoration(
                                          labelText: 'Precio Costo'),
                                      keyboardType: TextInputType.number,
                                      readOnly: true,
                                    ),
                                    TextField(
                                      controller:
                                          product['salePriceController'],
                                      decoration: const InputDecoration(
                                          labelText: 'Precio de Venta'),
                                      keyboardType: TextInputType.number,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 40, // Ajustado para estar más abajo
            right: 20,
            child: FloatingActionButton(
              onPressed: _addNewProductField,
              backgroundColor: Colors.teal,
              child: const Icon(Icons.add),
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: ElevatedButton(
          onPressed: _isLoading ? null : _showSaleDetails,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.teal,
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30), // Aumentar padding horizontal para hacer el botón más largo
            foregroundColor: Colors.white, // Color del texto
          ),
          child: _isLoading
              ? const CircularProgressIndicator(
                  color: Colors.white,
                )
              : const Text('Ver detalle venta'),
        ),
      ),
    );
  }
}
