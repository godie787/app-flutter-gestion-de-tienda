import 'package:flutter/material.dart';
import 'package:re_fashion/screens/import_products_screen/import_products_screen.dart';


class SuperuserBottomNavigationBar extends StatefulWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemTapped;

  const SuperuserBottomNavigationBar({
    required this.selectedIndex,
    required this.onItemTapped,
    Key? key,
  }) : super(key: key);

  @override
  SuperuserBottomNavigationBarState createState() =>
      SuperuserBottomNavigationBarState();
}

class SuperuserBottomNavigationBarState
    extends State<SuperuserBottomNavigationBar> {
  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      selectedItemColor: Colors.teal,
      unselectedItemColor: Colors.grey,
      currentIndex: widget.selectedIndex,
      onTap: (index) {
        widget.onItemTapped(index);

        // Navegar según el ítem seleccionado
        if (index == 5) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ImportProductsScreen()),
          );
        }
      },
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
        BottomNavigationBarItem( // Nueva opción para importar productos
          icon: Icon(Icons.upload_file),
          label: 'Importar Productos',
        ),
      ],
    );
  }
}
