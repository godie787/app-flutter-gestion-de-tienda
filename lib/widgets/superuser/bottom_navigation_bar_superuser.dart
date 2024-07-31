import 'package:flutter/material.dart';

class SuperuserBottomNavigationBar extends StatefulWidget {
  @override
  _SuperuserBottomNavigationBarState createState() =>
      _SuperuserBottomNavigationBarState();
}

class _SuperuserBottomNavigationBarState
    extends State<SuperuserBottomNavigationBar> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // Aquí podrías manejar la navegación entre vistas según el índice seleccionado
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      selectedItemColor: Colors.teal,
      unselectedItemColor: Colors.grey,
      currentIndex: _selectedIndex,
      onTap: _onItemTapped,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_add),
          label: 'Agregar Vendedores',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.add_box),
          label: 'Agregar Productos',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.qr_code),
          label: 'Vender',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.analytics),
          label: 'Informes',
        ),
      ],
    );
  }
}
