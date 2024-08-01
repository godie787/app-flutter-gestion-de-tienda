import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DatabaseService {

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addProduct(Map<String, dynamic> productData) async {
    try {
      // Guardar el producto en la colección de productos
      await _firestore.collection('Productos').add({
        'id': productData['id'],
        'name': productData['name'],
        'netPrice': productData['netPrice'],
        'salePrice': productData['salePrice'],
        'description': productData['description'],
        'idCategoria': productData['idCategoria'],
        'createdAt': productData['createdAt'],
      });

      print("Producto agregado exitosamente");
    } catch (e) {
      print("Error al agregar el producto: $e");
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
      print("Error al verificar el ID del producto: $e");
      return false; // En caso de error, asumimos que el ID no existe para evitar bloqueos
    }
  }


  Future<void> createCategories() async {
    CollectionReference categories = FirebaseFirestore.instance.collection('Categorias');

    // Ropa
    await categories.doc('Ropa').set({'name': 'Ropa'});
    await categories.doc('Ropa').collection('Subcategorias').doc('Ropa de Mujer').set({'name': 'Ropa de Mujer'});
    await categories.doc('Ropa').collection('Subcategorias').doc('Ropa de Mujer').collection('Subcategorias').doc('Vestidos').set({'name': 'Vestidos'});
    await categories.doc('Ropa').collection('Subcategorias').doc('Ropa de Mujer').collection('Subcategorias').doc('Blusas y Camisas').set({'name': 'Blusas y Camisas'});
    await categories.doc('Ropa').collection('Subcategorias').doc('Ropa de Mujer').collection('Subcategorias').doc('Faldas').set({'name': 'Faldas'});
    await categories.doc('Ropa').collection('Subcategorias').doc('Ropa de Mujer').collection('Subcategorias').doc('Pantalones y Jeans').set({'name': 'Pantalones y Jeans'});
    await categories.doc('Ropa').collection('Subcategorias').doc('Ropa de Mujer').collection('Subcategorias').doc('Ropa de Noche').set({'name': 'Ropa de Noche'});
    await categories.doc('Ropa').collection('Subcategorias').doc('Ropa de Mujer').collection('Subcategorias').doc('Ropa Deportiva').set({'name': 'Ropa Deportiva'});
    await categories.doc('Ropa').collection('Subcategorias').doc('Ropa de Mujer').collection('Subcategorias').doc('Ropa Interior y Lencería').set({'name': 'Ropa Interior y Lencería'});

    await categories.doc('Ropa').collection('Subcategorias').doc('Ropa de Hombre').set({'name': 'Ropa de Hombre'});
    await categories.doc('Ropa').collection('Subcategorias').doc('Ropa de Hombre').collection('Subcategorias').doc('Camisas').set({'name': 'Camisas'});
    await categories.doc('Ropa').collection('Subcategorias').doc('Ropa de Hombre').collection('Subcategorias').doc('Pantalones y Jeans').set({'name': 'Pantalones y Jeans'});
    await categories.doc('Ropa').collection('Subcategorias').doc('Ropa de Hombre').collection('Subcategorias').doc('Polos y Camisetas').set({'name': 'Polos y Camisetas'});
    await categories.doc('Ropa').collection('Subcategorias').doc('Ropa de Hombre').collection('Subcategorias').doc('Ropa Formal').set({'name': 'Ropa Formal'});
    await categories.doc('Ropa').collection('Subcategorias').doc('Ropa de Hombre').collection('Subcategorias').doc('Ropa Deportiva').set({'name': 'Ropa Deportiva'});
    await categories.doc('Ropa').collection('Subcategorias').doc('Ropa de Hombre').collection('Subcategorias').doc('Ropa Interior').set({'name': 'Ropa Interior'});

    await categories.doc('Ropa').collection('Subcategorias').doc('Ropa de Niños').set({'name': 'Ropa de Niños'});
    await categories.doc('Ropa').collection('Subcategorias').doc('Ropa de Niños').collection('Subcategorias').doc('Ropa de Bebé').set({'name': 'Ropa de Bebé'});
    await categories.doc('Ropa').collection('Subcategorias').doc('Ropa de Niños').collection('Subcategorias').doc('Ropa de Niñas').set({'name': 'Ropa de Niñas'});
    await categories.doc('Ropa').collection('Subcategorias').doc('Ropa de Niños').collection('Subcategorias').doc('Ropa de Niños').set({'name': 'Ropa de Niños'});

    await categories.doc('Ropa').collection('Subcategorias').doc('Abrigos y Chaquetas').set({'name': 'Abrigos y Chaquetas'});
    await categories.doc('Ropa').collection('Subcategorias').doc('Abrigos y Chaquetas').collection('Subcategorias').doc('Chaquetas').set({'name': 'Chaquetas'});
    await categories.doc('Ropa').collection('Subcategorias').doc('Abrigos y Chaquetas').collection('Subcategorias').doc('Abrigos').set({'name': 'Abrigos'});
    await categories.doc('Ropa').collection('Subcategorias').doc('Abrigos y Chaquetas').collection('Subcategorias').doc('Chompas').set({'name': 'Chompas'});

    await categories.doc('Ropa').collection('Subcategorias').doc('Ropa de Baño').set({'name': 'Ropa de Baño'});
    await categories.doc('Ropa').collection('Subcategorias').doc('Ropa de Baño').collection('Subcategorias').doc('Trajes de Baño de Mujer').set({'name': 'Trajes de Baño de Mujer'});
    await categories.doc('Ropa').collection('Subcategorias').doc('Ropa de Baño').collection('Subcategorias').doc('Trajes de Baño de Hombre').set({'name': 'Trajes de Baño de Hombre'});
    await categories.doc('Ropa').collection('Subcategorias').doc('Ropa de Baño').collection('Subcategorias').doc('Trajes de Baño de Niños').set({'name': 'Trajes de Baño de Niños'});
    await categories.doc('Ropa').collection('Subcategorias').doc('Ropa de Baño').collection('Subcategorias').doc('Bikinis').set({'name': 'Bikinis'});
    await categories.doc('Ropa').collection('Subcategorias').doc('Ropa de Baño').collection('Subcategorias').doc('Accesorios de Playa').set({'name': 'Accesorios de Playa'});

    // Accesorios
    await categories.doc('Accesorios').set({'name': 'Accesorios'});
    await categories.doc('Accesorios').collection('Subcategorias').doc('Bolsos y Carteras').set({'name': 'Bolsos y Carteras'});
    await categories.doc('Accesorios').collection('Subcategorias').doc('Sombreros y Gorros').set({'name': 'Sombreros y Gorros'});
    await categories.doc('Accesorios').collection('Subcategorias').doc('Bufandas y Chalinas').set({'name': 'Bufandas y Chalinas'});
    await categories.doc('Accesorios').collection('Subcategorias').doc('Joyas y Bisutería').set({'name': 'Joyas y Bisutería'});
    await categories.doc('Accesorios').collection('Subcategorias').doc('Cinturones').set({'name': 'Cinturones'});
    await categories.doc('Accesorios').collection('Subcategorias').doc('Relojes').set({'name': 'Relojes'});
    await categories.doc('Accesorios').collection('Subcategorias').doc('Accesorios Deportivos').set({'name': 'Accesorios Deportivos'});

    // Zapatos
    await categories.doc('Zapatos').set({'name': 'Zapatos'});
    await categories.doc('Zapatos').collection('Subcategorias').doc('Zapatos de Mujer').set({'name': 'Zapatos de Mujer'});
    await categories.doc('Zapatos').collection('Subcategorias').doc('Zapatos de Hombre').set({'name': 'Zapatos de Hombre'});
    await categories.doc('Zapatos').collection('Subcategorias').doc('Zapatos de Niños').set({'name': 'Zapatos de Niños'});
    await categories.doc('Zapatos').collection('Subcategorias').doc('Sandalias').set({'name': 'Sandalias'});
    await categories.doc('Zapatos').collection('Subcategorias').doc('Botas').set({'name': 'Botas'});
    await categories.doc('Zapatos').collection('Subcategorias').doc('Calzado Deportivo').set({'name': 'Calzado Deportivo'});
  }

  Future<void> createProductsCollection() async {
    CollectionReference products = FirebaseFirestore.instance.collection('Productos');

    // Crear un ejemplo de producto
    await products.add({
      'id': '001',
      'name': 'Producto de Ejemplo 2',
      'netPrice': 1000,
      'salePrice': 1500,
      'idCategoria': 'Zapatos de Mujer', // Asocia el producto a una categoría específica
    });

    await products.add({
      'id': '002',
      'name': 'Producto de Ejemplo',
      'netPrice': 5000,
      'salePrice': 5500,
      'idCategoria': 'Ropa de Hombre', // Asocia el producto a una categoría específica
    });

    print("Colección de productos creada exitosamente.");
  }
  

  Future<void> createRoles() async {
      await FirebaseFirestore.instance.collection('Roles').doc('1').set({
        'name': 'superuser',
      });

      await FirebaseFirestore.instance.collection('Roles').doc('2').set({
        'name': 'vendedor',
      });

      print("Roles creados exitosamente");
    }


    Future<void> registerUser() async {
      try {
        // Crear usuario en Firebase Authentication
        UserCredential userCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: "diego.jorqueras@usm.cl",
          password: "diegomatias",
        );

        // Obtener el UID del usuario creado
        String uid = userCredential.user!.uid;

        // Almacenar información adicional en Firestore
        await FirebaseFirestore.instance.collection('Users').doc(uid).set({
          'name': 'Diego',
          'email': 'diego.jorqueras@usm.cl',
          'roleId': '1', // Referencia al rol de superuser
        });

        print("Usuario registrado exitosamente");
      } catch (e) {
        print("Error al registrar usuario: $e");
      }
    }

}




















    

  
