import 'package:flutter/material.dart';
import 'package:re_fashion/screens/options_navigator/home/home_screen.dart';
import 'package:re_fashion/widgets/superuser/appbar_superuser.dart';
import 'package:re_fashion/widgets/superuser/bottom_navigation_bar_superuser.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:re_fashion/screens/options_navigator/add_products/add_product_screen.dart';
import 'package:re_fashion/screens/options_navigator/sell_products/sell_product_screen.dart';
import 'package:re_fashion/screens/options_navigator/reports/reports_screen.dart';
import 'package:re_fashion/screens/options_navigator/add_sellers/add_sellers_screen.dart';
import 'package:re_fashion/screens/options_drawer/chistes_fomes.dart';

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
    const HomeScreen(),
    const AddSellerScreen(),
    const AddProductScreen(),
    const SellProductScreen(),
    ReportsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        bool shouldLogout = await showDialog(
          context: context,
          builder: (context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
            child: Container(
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.exit_to_app,
                    size: 60,
                    color: Colors.teal,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Salir de la aplicación',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    '¿Estás seguro de que quieres salir? Se cerrará la sesión si lo haces.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop(false);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[200],
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        child: const Text('Cancelar'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop(true);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        child: const Text('Salir'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
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
        appBar: const SuperuserAppBar(
          title: 'Dashboard',
          backgroundColor: Colors.teal,
          leadingIcon: Icons.menu,
          actions: [Icon(Icons.notifications)],
        ),
        body: IndexedStack(
          index: _selectedIndex,
          children: _pages,
        ),
        bottomNavigationBar: SuperuserBottomNavigationBar(
          selectedIndex: _selectedIndex,
          onItemTapped: _onItemTapped,
        ),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.teal,
                ),
                child: Center(
                  child: Icon(
                    Icons.account_circle,
                    size: 80,
                    color: Colors.white,
                  ),
                ),
              ),
              ListTile(
                leading: Icon(Icons.person),
                title: Text('Perfil'),
                onTap: () {
                  Navigator.pop(context);
                  // Navegar a la vista del perfil
                },
              ),
              ListTile(
  leading: Icon(Icons.sentiment_very_satisfied),
  title: Text('Chistes Fomes'),
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ChistesFomesScreen()),
    );
  },
),
              ListTile(
                leading: Icon(Icons.help),
                title: Text('Soporte'),
                onTap: () {
                  Navigator.pop(context);
                  // Navegar a la vista de soporte
                },
              ),
              ListTile(
                leading: Icon(Icons.settings),
                title: Text('Configuración'),
                onTap: () {
                  Navigator.pop(context);
                  // Navegar a la vista de configuración
                },
              ),
              ListTile(
                leading: Icon(Icons.exit_to_app),
                title: Text('Cerrar Sesión'),
                onTap: () async {
                  await FirebaseAuth.instance.signOut();
                  Navigator.of(context).pop(true);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
