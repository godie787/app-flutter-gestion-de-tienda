import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'screens/superuser/home_superuser.dart';
import 'screens/recover/recover_password.dart'; // Importa la nueva pantalla

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  //createRoles();
  //registerUser();
  runApp(MyApp());
}

/*Future<void> createRoles() async {
  await FirebaseFirestore.instance.collection('Roles').doc('1').set({
    'name': 'superuser',
  });

  await FirebaseFirestore.instance.collection('Roles').doc('2').set({
    'name': 'vendedor',
  });

  print("Roles creados exitosamente");
}*/

/*
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
}*/

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginScreen(),
    );
  }
}

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  String _errorMessage = '';

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
              email: _emailController.text, password: _passwordController.text);

      // Obtener el rol del usuario desde Firestore
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(userCredential.user!.uid)
          .get();

      String roleId = userDoc.get('roleId');

      if (roleId == '1') {
        // Si es superuser, redirigir a la pantalla específica de superuser
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => SuperuserHome()));
      } else {
        // Redirigir a otra pantalla o manejar otros roles
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => SuperuserHome()));
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorMessage = e.message ?? "Error al iniciar sesión";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Inicio de Sesión',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Correo Electrónico',
                  prefixIcon: const Icon(Icons.email, color: Colors.teal),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Contraseña',
                  prefixIcon: const Icon(Icons.lock, color: Colors.teal),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 20),
              if (_errorMessage.isNotEmpty)
                Text(
                  _errorMessage,
                  style: const TextStyle(color: Colors.red),
                ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => RecoverPasswordScreen(),
                    ),
                  );
                },
                child: const Text(
                  'Recuperar Contraseña',
                  style: TextStyle(
                    color: Colors.teal,
                    fontSize: 14,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: _isLoading ? null : _login,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding:
                      const EdgeInsets.symmetric(vertical: 15, horizontal: 100),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      )
                    : const Text(
                        'Iniciar Sesión',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
