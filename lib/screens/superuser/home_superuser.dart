import 'package:flutter/material.dart';
import 'package:re_fashion/widgets/superuser/appbar_superuser.dart';
import 'package:re_fashion/widgets/superuser/bottom_navigation_bar_superuser.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:re_fashion/screens/options_navigator/add_products/add_product_screen.dart';

class SuperuserHome extends StatefulWidget {
  const SuperuserHome({Key? key}) : super(key: key);

  @override
  SuperuserHomeState createState() => SuperuserHomeState();
}

class SuperuserHomeState extends State<SuperuserHome> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  final List<Widget> _pages = [
    const Center(child: Text('Bienvenido al panel Superuser!')),
    const Center(child: Text('Agregar Vendedores')),
    const AddProductScreen(),
    const Center(child: Text('Vender')),
    const Center(child: Text('Informes')),
  ];

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
        body: IndexedStack(
          index: _selectedIndex,
          children: _pages,
        ),
        bottomNavigationBar: SuperuserBottomNavigationBar(
          selectedIndex: _selectedIndex,
          onItemTapped: _onItemTapped,
        ),
      ),
    );
  }
}
