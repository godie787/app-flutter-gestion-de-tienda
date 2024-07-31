import 'package:flutter/material.dart';

class SuperuserBottomNavigationBar extends StatefulWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemTapped;

  SuperuserBottomNavigationBar({
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  _SuperuserBottomNavigationBarState createState() =>
      _SuperuserBottomNavigationBarState();
}

class _SuperuserBottomNavigationBarState
    extends State<SuperuserBottomNavigationBar> {
  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      selectedItemColor: Colors.teal,
      unselectedItemColor: Colors.grey,
      currentIndex: widget.selectedIndex,
      onTap: widget.onItemTapped,
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
