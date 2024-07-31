import 'package:flutter/material.dart';
import 'package:re_fashion/widgets/superuser/appbar_superuser.dart';
import 'package:re_fashion/widgets/superuser/bottom_navigation_bar_superuser.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SuperuserHome extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        bool shouldLogout = await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Salir de la aplicación'),
            content: const Text(
                '¿Estás seguro de que quieres salir? Se cerrará la sesión si lo haces.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Salir'),
              ),
            ],
          ),
        );

        if (shouldLogout) {
          await FirebaseAuth.instance.signOut();
          return true;
        } else {
          return false;
        }
      },
      child: Scaffold(
        appBar: SuperuserAppBar(), // AppBar modular
        body: const Center(
          child: Text('Bienvenido al panel Superuser!'),
        ),
        bottomNavigationBar:
            SuperuserBottomNavigationBar(), // BottomNavigationBar modular
      ),
    );
  }
}
