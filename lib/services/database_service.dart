import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Obtener el estado de la caja (abierta o cerrada)

  Future<List<Map<String, dynamic>>> getDailyReportsByDate(DateTime date) async {
    try {
      // Ajustar las fechas para buscar informes solo del día especificado
      DateTime startDate = DateTime(date.year, date.month, date.day);
      DateTime endDate = startDate.add(const Duration(days: 1));

      QuerySnapshot cajaSnapshot = await _firestore
          .collection('Caja')
          .where('status', isEqualTo: 'closed')
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .orderBy('date', descending: true)
          .get();

      if (cajaSnapshot.docs.isEmpty) {
        print('No se encontraron informes de caja cerrada para la fecha especificada.');
        return [];
      }

      List<Map<String, dynamic>> reports = [];

      for (var cajaDoc in cajaSnapshot.docs) {
        var cajaData = cajaDoc.data() as Map<String, dynamic>;
        Timestamp openTime = cajaData['openTime'];
        Timestamp closeTime = cajaData['closeTime'];

        QuerySnapshot ventasSnapshot = await _firestore
            .collection('Ventas')
            .where('createdAt', isGreaterThanOrEqualTo: openTime)
            .where('createdAt', isLessThanOrEqualTo: closeTime)
            .get();

        double totalVentas = 0;
        double totalCosto = 0;
        int cantidadProductosVendidos = 0;
        int cantidadVentasRealizadas = ventasSnapshot.docs.length;

        List<Map<String, dynamic>> detallesVentas = [];

        for (var ventaDoc in ventasSnapshot.docs) {
          var ventaData = ventaDoc.data() as Map<String, dynamic>;
          totalVentas += ventaData['total'];

          QuerySnapshot productosVendidosSnapshot =
              await ventaDoc.reference.collection('ProductosVendidos').get();

          cantidadProductosVendidos += productosVendidosSnapshot.size;

          for (var productoDoc in productosVendidosSnapshot.docs) {
            var productoData = productoDoc.data() as Map<String, dynamic>;
            totalCosto += productoData['costPrice'] ?? 0;
            detallesVentas.add({
              'productName': productoData['name'],
              'amount': productoData['salePrice'],
              'vendedor': ventaData['userId'],
            });
          }
        }

        double totalGanancias = totalVentas - totalCosto;

        reports.add({
          'openTime': openTime.toDate(),
          'closeTime': closeTime.toDate(),
          'totalVentas': totalVentas,
          'totalCosto': totalCosto,
          'totalGanancias': totalGanancias,
          'cantidadProductosVendidos': cantidadProductosVendidos,
          'cantidadVentasRealizadas': cantidadVentasRealizadas,
          'detallesVentas': detallesVentas,
        });
      }

      return reports;
    } catch (e) {
      print('Error al obtener informes diarios: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getDailyReportsByDay(DateTime date) async {
  try {
    // Convertir la fecha proporcionada a un rango de tiempo de 24 horas
    DateTime startOfDay = DateTime(date.year, date.month, date.day, 0, 0, 0);
    DateTime endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

    QuerySnapshot cajaSnapshot = await _firestore
        .collection('Caja')
        .where('status', isEqualTo: 'closed')
        .where('closeTime', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('closeTime', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
        .orderBy('closeTime', descending: false)
        .get();

    if (cajaSnapshot.docs.isEmpty) {
      print('No se encontraron informes de caja cerrada para la fecha especificada.');
      return [];
    }

    List<Map<String, dynamic>> reports = [];

    for (var cajaDoc in cajaSnapshot.docs) {
      var cajaData = cajaDoc.data() as Map<String, dynamic>;
      Timestamp openTime = cajaData['openTime'];
      Timestamp closeTime = cajaData['closeTime'];

      QuerySnapshot ventasSnapshot = await _firestore
          .collection('Ventas')
          .where('createdAt', isGreaterThanOrEqualTo: openTime)
          .where('createdAt', isLessThanOrEqualTo: closeTime)
          .get();

      double totalVentas = 0;
      double totalCosto = 0;
      int cantidadProductosVendidos = 0;
      int cantidadVentasRealizadas = ventasSnapshot.docs.length;

      List<Map<String, dynamic>> detallesVentas = [];

      for (var doc in ventasSnapshot.docs) {
        var ventaData = doc.data() as Map<String, dynamic>;
        totalVentas += ventaData['total'];

        QuerySnapshot productosVendidosSnapshot =
            await doc.reference.collection('ProductosVendidos').get();

        cantidadProductosVendidos += productosVendidosSnapshot.size;

        for (var productoDoc in productosVendidosSnapshot.docs) {
          var productoData = productoDoc.data() as Map<String, dynamic>;
          totalCosto += productoData['costPrice'] ?? 0;
          detallesVentas.add({
            'productName': productoData['name'],
            'amount': productoData['salePrice'],
            'vendedor': ventaData['userId'],
          });
        }
      }

      double totalGanancias = totalVentas - totalCosto;

      reports.add({
        'date': cajaData['date'],  // O la fecha de cierre para mostrar correctamente
        'totalVentas': totalVentas,
        'totalCosto': totalCosto,
        'totalGanancias': totalGanancias,
        'cantidadProductosVendidos': cantidadProductosVendidos,
        'cantidadVentasRealizadas': cantidadVentasRealizadas,
        'detallesVentas': detallesVentas,
        'openTime': openTime.toDate(),
        'closeTime': closeTime.toDate(),
      });
    }

    return reports;
  } catch (e) {
    print('Error al obtener informes diarios: $e');
    return [];
  }
}


  Future<bool> getCajaStatus() async {
    var cajaSnapshot = await _firestore
        .collection('Caja')
        .orderBy('date', descending: true)
        .limit(1)
        .get();

    if (cajaSnapshot.docs.isNotEmpty) {
      var cajaData = cajaSnapshot.docs.first.data() as Map<String, dynamic>;
      return cajaData['status'] == 'open';
    }
    return false;
  }

  Future<Map<String, dynamic>?> getProductosVendidosDelDia() async {
  try {
    // Obtener la fecha de hoy desde las 00:00 hasta las 23:59
    DateTime now = DateTime.now();
    DateTime startOfDay = DateTime(now.year, now.month, now.day, 0, 0, 0);
    DateTime endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

    // Consultar las ventas realizadas durante el día
    QuerySnapshot ventasSnapshot = await _firestore
        .collection('Ventas')
        .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
        .get();

    List<Map<String, dynamic>> productosVendidos = [];
    double totalSales = 0;
    int totalProductsSold = 0;
    int totalSalesCount = ventasSnapshot.docs.length;

    for (var doc in ventasSnapshot.docs) {
      var ventaData = doc.data() as Map<String, dynamic>;
      print('Venta encontrada: $ventaData');

      QuerySnapshot productosSnapshot =
          await doc.reference.collection('ProductosVendidos').get();

      for (var productoDoc in productosSnapshot.docs) {
        var productoData = productoDoc.data() as Map<String, dynamic>;
        print('Producto vendido encontrado: $productoData');

        productosVendidos.add({
          'productName': productoData['name'],
          'salePrice': productoData['salePrice'],
          'quantity': 1,
          'vendedor': ventaData['userId'], // Suponiendo que guardas el userId
        });

        totalSales += productoData['salePrice'];
        totalProductsSold++;
      }
    }

    print('Productos vendidos del día: $productosVendidos');
    return {
      'productosVendidos': productosVendidos,
      'totalSales': totalSales,
      'totalProductsSold': totalProductsSold,
      'totalSalesCount': totalSalesCount,
    };
  } catch (e) {
    print('Error al obtener productos vendidos: $e');
    return null;
  }
}


  // Método para generar el informe diario
  Future<Map<String, dynamic>?> generateDailyReport() async {
    try {
      // Obtener el estado actual de la caja (último cierre)
      QuerySnapshot cajaSnapshot = await _firestore
          .collection('Caja')
          .where('status', isEqualTo: 'closed')
          .orderBy('date', descending: true)
          .limit(1)
          .get();

      if (cajaSnapshot.docs.isEmpty) {
        print('No se encontró un cierre de caja reciente.');
        return null;
      }

      var cajaData = cajaSnapshot.docs.first.data() as Map<String, dynamic>;
      Timestamp openTime = cajaData['openTime'];
      Timestamp closeTime = cajaData['closeTime'];

      // Consultar las ventas realizadas en el periodo de la caja abierta
      QuerySnapshot ventasSnapshot = await _firestore
          .collection('Ventas')
          .where('createdAt', isGreaterThanOrEqualTo: openTime)
          .where('createdAt', isLessThanOrEqualTo: closeTime)
          .get();

      double totalVentas = 0;
      double totalCosto = 0;
      int cantidadProductosVendidos = 0;
      int cantidadVentasRealizadas = ventasSnapshot.docs.length;

      List<Map<String, dynamic>> detallesVentas = [];

      for (var doc in ventasSnapshot.docs) {
        var ventaData = doc.data() as Map<String, dynamic>;
        totalVentas += ventaData['total'];

        QuerySnapshot productosVendidosSnapshot =
            await doc.reference.collection('ProductosVendidos').get();

        cantidadProductosVendidos += productosVendidosSnapshot.size;

        for (var productoDoc in productosVendidosSnapshot.docs) {
          var productoData = productoDoc.data() as Map<String, dynamic>;
          totalCosto += productoData['costPrice'] ?? 0;
          detallesVentas.add({
            'productName': productoData['name'],
            'amount': productoData['salePrice'],
            'vendedor': ventaData['userId'],
          });
        }
      }

      double totalGanancias = totalVentas - totalCosto;

      // Datos del informe diario
      Map<String, dynamic> reportData = {
        'date': DateTime.now(),
        'totalVentas': totalVentas,
        'totalCosto': totalCosto,
        'totalGanancias': totalGanancias,
        'cantidadProductosVendidos': cantidadProductosVendidos,
        'cantidadVentasRealizadas': cantidadVentasRealizadas,
        'detallesVentas': detallesVentas,
      };

      return reportData;
    } catch (e) {
      print('Error al generar el informe diario: $e');
      return null;
    }
  }

  // Función para abrir caja
  // Abrir la caja y guardar el estado en Firestore
  Future<void> openCaja() async {
    try {
      await _firestore.collection('Caja').add({
        'date': Timestamp.now(), // Fecha y hora actuales
        'openTime': Timestamp.now(), // Hora de apertura
        'status': 'open', // Estado de la caja
        'userId': FirebaseAuth.instance.currentUser!.uid, // ID del usuario
      });

      debugPrint('Caja abierta exitosamente.');
    } catch (e) {
      debugPrint('Error al abrir caja: $e');
    }
  }

  // Función para cerrar caja
  Future<void> closeCaja() async {
    try {
      QuerySnapshot cajaQuery = await _firestore
          .collection('Caja')
          .where('status', isEqualTo: 'open')
          .orderBy('date', descending: true)
          .limit(1)
          .get();

      if (cajaQuery.docs.isNotEmpty) {
        DocumentReference cajaRef = cajaQuery.docs.first.reference;
        await cajaRef.update({
          'closeTime': Timestamp.now(), // Hora de cierre
          'status': 'closed', // Estado de la caja
        });

        debugPrint('Caja cerrada exitosamente.');
      } else {
        debugPrint('No se encontró una caja abierta para cerrar.');
      }
    } catch (e) {
      debugPrint('Error al cerrar caja: $e');
    }
  }

  Future<void> createVenta(
      List<Map<String, dynamic>> productos, double total, String userId) async {
    try {
      // Crear un documento en la colección "Ventas" con el ID del usuario, total y fecha de creación
      DocumentReference ventaRef = await _firestore.collection('Ventas').add({
        'userId': userId, // ID del usuario que realizó la venta
        'total': total, // Total de la venta
        'createdAt': Timestamp.now(), // Fecha y hora de la venta
      });

      // Para cada producto en la lista, agregar un documento en la subcolección "ProductosVendidos"
      for (var producto in productos) {
        print(
            'Agregando producto a la venta: ${producto['nameController'].text}'); // Debug
        await ventaRef.collection('ProductosVendidos').add({
          'productId': producto['idController'].text, // ID del producto
          'name': producto['nameController'].text, // Nombre del producto
          'salePrice': double.tryParse(producto['salePriceController'].text) ??
              0, // Precio de venta
        });
      }

      print('Venta creada y productos asociados exitosamente.');
    } catch (e) {
      print('Error al crear la venta: $e');
    }
  }

  Future<void> processSale(List<Map<String, dynamic>> products) async {
    try {
      // Primero actualizamos los productos
      for (var product in products) {
        QuerySnapshot querySnapshot = await _firestore
            .collection('Productos')
            .where('id', isEqualTo: product['idController'].text)
            .limit(1)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          DocumentReference documentReference =
              querySnapshot.docs.first.reference;
          await documentReference.update({
            'salePrice':
                double.tryParse(product['salePriceController'].text) ?? 0,
            'state': 'Vendido',
          });
          print('Producto actualizado exitosamente.');
        } else {
          print('Producto no encontrado.');
        }
      }

      // Luego, obtenemos el total de la venta
      double total = products.fold(0, (sum, item) {
        return sum + (double.tryParse(item['salePriceController'].text) ?? 0);
      });

      // Obtenemos el ID del usuario actual
      String userId = FirebaseAuth.instance.currentUser!.uid;

      // Finalmente, creamos la venta y asociamos los productos a la venta
      await createVenta(products, total, userId);
      print('Venta creada y productos asociados exitosamente.');
    } catch (e) {
      print('Error al procesar la venta: $e');
    }
  }

  Future<Map<String, dynamic>?> getProductById(String productId) async {
    try {
      // Limpia cualquier espacio en blanco adicional
      productId = productId.trim();

      QuerySnapshot querySnapshot = await _firestore
          .collection('Productos')
          .where('id', isEqualTo: productId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return querySnapshot.docs.first.data() as Map<String, dynamic>;
      } else {
        return null;
      }
    } catch (e) {
      print('Error al obtener el producto: $e');
      return null;
    }
  }


  Future<void> updateProduct(
      String productId, double salePrice, String state) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('Productos')
          .where('id', isEqualTo: productId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        DocumentReference documentReference =
            querySnapshot.docs.first.reference;
        await documentReference.update({
          'salePrice': salePrice,
          'state': state,
        });
        print('Producto actualizado exitosamente.');
      } else {
        print('Producto no encontrado.');
      }
    } catch (e) {
      print('Error al actualizar el producto: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getCategories() async {
    try {
      final querySnapshot =
          await FirebaseFirestore.instance.collection('Categorias').get();
      return querySnapshot.docs.map((doc) {
        return {
          'id': doc.id, // El ID del documento como el ID de la categoría
          'name': doc.data()['name'] ??
              'Nombre no disponible', // Nombre de la categoría
        };
      }).toList();
    } catch (e) {
      print('Error al obtener categorías: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getSubcategories(String categoryId) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('Categorias')
          .doc(categoryId)
          .collection('Subcategorias')
          .get();

      return snapshot.docs.map((doc) {
        return {
          'id': doc.id, // Usa el ID del documento como el ID de la subcategoría
          'name': doc.data()['name'] ??
              'Nombre no disponible', // Asegúrate de manejar posibles valores nulos
        };
      }).toList();
    } catch (e) {
      debugPrint('Error al obtener subcategorías: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getSubsubcategories(
      String categoryId, String subcategoryId) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('Categorias')
          .doc(categoryId)
          .collection('Subcategorias')
          .doc(subcategoryId)
          .collection('Subcategorias')
          .get();

      // Debug: Verificar que estamos obteniendo documentos
      debugPrint(
          'Obteniendo sub-subcategorías para: $subcategoryId en $categoryId');
      debugPrint('Documentos obtenidos: ${snapshot.docs.length}');

      return snapshot.docs.map((doc) {
        final data = doc.data();
        debugPrint(
            'Sub-subcategoría encontrada: ${doc.id}, ${data['name']}'); // Añadir debug para ver cada documento
        return {
          'id': doc
              .id, // Usa el ID del documento como el ID de la sub-subcategoría
          'name': data['name'] ??
              'Nombre no disponible', // Asegúrate de manejar posibles valores nulos
        };
      }).toList();
    } catch (e) {
      debugPrint('Error al obtener sub-subcategorías: $e');
      return [];
    }
  }

  Future<void> addProduct(Map<String, dynamic> productData) async {
    try {
      await _firestore.collection('Productos').add({
        'id': productData['id'],
        'name': productData['name'],
        'netPrice': productData['netPrice'],
        'salePrice': productData['salePrice'],
        'description': productData['description'], // Agregar el campo descripción
        'categoryId': productData['categoryId'],
        'subcategoryId': productData['subcategoryId'],
        'subsubcategoryId': productData['subsubcategoryId'],
        'createdAt': productData['createdAt'],
        'state': productData['state'],
        'images': productData['images'],
      });

      debugPrint('Producto agregado exitosamente');
    } catch (e) {
      debugPrint('Error al agregar el producto: $e');
    }
  }




  Future<bool> checkIfProductIdExists(String productId) async {
    try {
      final querySnapshot = await _firestore
          .collection('Productos')
          .where('id', isEqualTo: productId)
          .get();

      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      debugPrint('Error al verificar el ID del producto: $e');
      return false; // En caso de error, asumimos que el ID no existe para evitar bloqueos
    }
  }

  Future<void> createCategories() async {
    CollectionReference categories =
        FirebaseFirestore.instance.collection('Categorias');

    // Ropa
    await categories.doc('Ropa').set({'name': 'Ropa'});
    await categories
        .doc('Ropa')
        .collection('Subcategorias')
        .doc('Ropa de Mujer')
        .set({'name': 'Ropa de Mujer'});
    await categories
        .doc('Ropa')
        .collection('Subcategorias')
        .doc('Ropa de Mujer')
        .collection('Subcategorias')
        .doc('Vestidos')
        .set({'name': 'Vestidos'});
    await categories
        .doc('Ropa')
        .collection('Subcategorias')
        .doc('Ropa de Mujer')
        .collection('Subcategorias')
        .doc('Blusas y Camisas')
        .set({'name': 'Blusas y Camisas'});
    await categories
        .doc('Ropa')
        .collection('Subcategorias')
        .doc('Ropa de Mujer')
        .collection('Subcategorias')
        .doc('Faldas')
        .set({'name': 'Faldas'});
    await categories
        .doc('Ropa')
        .collection('Subcategorias')
        .doc('Ropa de Mujer')
        .collection('Subcategorias')
        .doc('Pantalones y Jeans')
        .set({'name': 'Pantalones y Jeans'});
    await categories
        .doc('Ropa')
        .collection('Subcategorias')
        .doc('Ropa de Mujer')
        .collection('Subcategorias')
        .doc('Ropa de Noche')
        .set({'name': 'Ropa de Noche'});
    await categories
        .doc('Ropa')
        .collection('Subcategorias')
        .doc('Ropa de Mujer')
        .collection('Subcategorias')
        .doc('Ropa Deportiva')
        .set({'name': 'Ropa Deportiva'});
    await categories
        .doc('Ropa')
        .collection('Subcategorias')
        .doc('Ropa de Mujer')
        .collection('Subcategorias')
        .doc('Ropa Interior y Lencería')
        .set({'name': 'Ropa Interior y Lencería'});

    await categories
        .doc('Ropa')
        .collection('Subcategorias')
        .doc('Ropa de Hombre')
        .set({'name': 'Ropa de Hombre'});
    await categories
        .doc('Ropa')
        .collection('Subcategorias')
        .doc('Ropa de Hombre')
        .collection('Subcategorias')
        .doc('Camisas')
        .set({'name': 'Camisas'});
    await categories
        .doc('Ropa')
        .collection('Subcategorias')
        .doc('Ropa de Hombre')
        .collection('Subcategorias')
        .doc('Pantalones y Jeans')
        .set({'name': 'Pantalones y Jeans'});
    await categories
        .doc('Ropa')
        .collection('Subcategorias')
        .doc('Ropa de Hombre')
        .collection('Subcategorias')
        .doc('Polos y Camisetas')
        .set({'name': 'Polos y Camisetas'});
    await categories
        .doc('Ropa')
        .collection('Subcategorias')
        .doc('Ropa de Hombre')
        .collection('Subcategorias')
        .doc('Ropa Formal')
        .set({'name': 'Ropa Formal'});
    await categories
        .doc('Ropa')
        .collection('Subcategorias')
        .doc('Ropa de Hombre')
        .collection('Subcategorias')
        .doc('Ropa Deportiva')
        .set({'name': 'Ropa Deportiva'});
    await categories
        .doc('Ropa')
        .collection('Subcategorias')
        .doc('Ropa de Hombre')
        .collection('Subcategorias')
        .doc('Ropa Interior')
        .set({'name': 'Ropa Interior'});

    await categories
        .doc('Ropa')
        .collection('Subcategorias')
        .doc('Ropa de Niños')
        .set({'name': 'Ropa de Niños'});
    await categories
        .doc('Ropa')
        .collection('Subcategorias')
        .doc('Ropa de Niños')
        .collection('Subcategorias')
        .doc('Ropa de Bebé')
        .set({'name': 'Ropa de Bebé'});
    await categories
        .doc('Ropa')
        .collection('Subcategorias')
        .doc('Ropa de Niños')
        .collection('Subcategorias')
        .doc('Ropa de Niñas')
        .set({'name': 'Ropa de Niñas'});
    await categories
        .doc('Ropa')
        .collection('Subcategorias')
        .doc('Ropa de Niños')
        .collection('Subcategorias')
        .doc('Ropa de Niños')
        .set({'name': 'Ropa de Niños'});

    await categories
        .doc('Ropa')
        .collection('Subcategorias')
        .doc('Abrigos y Chaquetas')
        .set({'name': 'Abrigos y Chaquetas'});
    await categories
        .doc('Ropa')
        .collection('Subcategorias')
        .doc('Abrigos y Chaquetas')
        .collection('Subcategorias')
        .doc('Chaquetas')
        .set({'name': 'Chaquetas'});
    await categories
        .doc('Ropa')
        .collection('Subcategorias')
        .doc('Abrigos y Chaquetas')
        .collection('Subcategorias')
        .doc('Abrigos')
        .set({'name': 'Abrigos'});
    await categories
        .doc('Ropa')
        .collection('Subcategorias')
        .doc('Abrigos y Chaquetas')
        .collection('Subcategorias')
        .doc('Chompas')
        .set({'name': 'Chompas'});

    await categories
        .doc('Ropa')
        .collection('Subcategorias')
        .doc('Ropa de Baño')
        .set({'name': 'Ropa de Baño'});
    await categories
        .doc('Ropa')
        .collection('Subcategorias')
        .doc('Ropa de Baño')
        .collection('Subcategorias')
        .doc('Trajes de Baño de Mujer')
        .set({'name': 'Trajes de Baño de Mujer'});
    await categories
        .doc('Ropa')
        .collection('Subcategorias')
        .doc('Ropa de Baño')
        .collection('Subcategorias')
        .doc('Trajes de Baño Hombre')
        .set({'name': 'Trajes de Baño Hombre'});
    await categories
        .doc('Ropa')
        .collection('Subcategorias')
        .doc('Ropa de Baño')
        .collection('Subcategorias')
        .doc('Trajes de Baño de Niños')
        .set({'name': 'Trajes de Baño de Niños'});
    await categories
        .doc('Ropa')
        .collection('Subcategorias')
        .doc('Ropa de Baño')
        .collection('Subcategorias')
        .doc('Bikinis')
        .set({'name': 'Bikinis'});
    await categories
        .doc('Ropa')
        .collection('Subcategorias')
        .doc('Ropa de Baño')
        .collection('Subcategorias')
        .doc('Accesorios de Playa')
        .set({'name': 'Accesorios de Playa'});

    // Accesorios
    await categories.doc('Accesorios').set({'name': 'Accesorios'});
    await categories
        .doc('Accesorios')
        .collection('Subcategorias')
        .doc('Bolsos y Carteras')
        .set({'name': 'Bolsos y Carteras'});
    await categories
        .doc('Accesorios')
        .collection('Subcategorias')
        .doc('Sombreros y Gorros')
        .set({'name': 'Sombreros y Gorros'});
    await categories
        .doc('Accesorios')
        .collection('Subcategorias')
        .doc('Bufandas y Chalinas')
        .set({'name': 'Bufandas y Chalinas'});
    await categories
        .doc('Accesorios')
        .collection('Subcategorias')
        .doc('Joyas y Bisutería')
        .set({'name': 'Joyas y Bisutería'});
    await categories
        .doc('Accesorios')
        .collection('Subcategorias')
        .doc('Cinturones')
        .set({'name': 'Cinturones'});
    await categories
        .doc('Accesorios')
        .collection('Subcategorias')
        .doc('Relojes')
        .set({'name': 'Relojes'});
    await categories
        .doc('Accesorios')
        .collection('Subcategorias')
        .doc('Accesorios Deportivos')
        .set({'name': 'Accesorios Deportivos'});

    // Zapatos
    await categories.doc('Zapatos').set({'name': 'Zapatos'});
    await categories
        .doc('Zapatos')
        .collection('Subcategorias')
        .doc('Zapatos de Mujer')
        .set({'name': 'Zapatos de Mujer'});
    await categories
        .doc('Zapatos')
        .collection('Subcategorias')
        .doc('Zapatos de Hombre')
        .set({'name': 'Zapatos de Hombre'});
    await categories
        .doc('Zapatos')
        .collection('Subcategorias')
        .doc('Zapatos de Niños')
        .set({'name': 'Zapatos de Niños'});
    await categories
        .doc('Zapatos')
        .collection('Subcategorias')
        .doc('Sandalias')
        .set({'name': 'Sandalias'});
    await categories
        .doc('Zapatos')
        .collection('Subcategorias')
        .doc('Botas')
        .set({'name': 'Botas'});
    await categories
        .doc('Zapatos')
        .collection('Subcategorias')
        .doc('Calzado Deportivo')
        .set({'name': 'Calzado Deportivo'});
  }

  Future<void> createProductsCollection() async {
  CollectionReference products = _firestore.collection('Productos');

  // Ejemplo de producto con los campos correctos, incluyendo la URL de la imagen
  await products.add({
    'categoryId': 'Accesorios', 
    'createdAt': Timestamp.now(), 
    'id': '192194040006', 
    'name': 'Cintillo 1',
    'netPrice': 700, 
    'salePrice': 2000, 
    'state': 'Activo',
    'subcategoryId': 'Joyas y Bisutería', 
    'subsubcategoryId': null, 
    'image': 'URL_DE_LA_IMAGEN', // Agregar el campo de imagen
  });

  debugPrint("Producto agregado exitosamente");
}



  Future<void> createRoles() async {
    await FirebaseFirestore.instance.collection('Roles').doc('1').set({
      'name': 'superuser',
    });

    await FirebaseFirestore.instance.collection('Roles').doc('2').set({
      'name': 'vendedor',
    });

    debugPrint("Roles creados exitosamente");
  }

  Future<void> registerUser() async {
    try {
      // Crear usuario en Firebase Authentication
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: "diego.jorqueras@usm.cl",
        password: "123456",
      );

      // Obtener el UID del usuario creado
      String uid = userCredential.user!.uid;

      // Almacenar información adicional en Firestore
      await FirebaseFirestore.instance.collection('Users').doc(uid).set({
        'name': 'Diego',
        'email': 'diegomatiasjorquera@gmail.com',
        'roleId': '1', // Referencia al rol de superuser
      });

      debugPrint("Usuario registrado exitosamente");
    } catch (e) {
      debugPrint("Error al registrar usuario: $e");
    }
  }
}