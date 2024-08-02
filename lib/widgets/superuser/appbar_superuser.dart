import 'package:flutter/material.dart';

class SuperuserAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title; // Añadido para personalizar el título en cada vista
  final Color backgroundColor; // Añadido para personalizar el color de fondo
  final IconData leadingIcon; // Añadido para personalizar el icono principal
  final Function()?
      onLeadingPressed; // Añadido para manejar la acción del icono principal
  final List<Widget>?
      actions; // Añadido para personalizar las acciones del AppBar

  const SuperuserAppBar({
    Key? key,
    required this.title,
    this.backgroundColor = Colors.teal,
    this.leadingIcon = Icons.menu,
    this.onLeadingPressed,
    this.actions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 24, // Cambia el tamaño del texto
          fontWeight: FontWeight.bold, // Cambia el grosor del texto
          color: Colors.white, // Cambia el color del texto
        ),
      ),
      backgroundColor: backgroundColor, // Color de fondo personalizado
      elevation: 4, // Añade una sombra para dar un efecto de elevación
      leading: IconButton(
        icon: Icon(leadingIcon, color: Colors.white),
        onPressed: onLeadingPressed ??
            () {
              // Abre un menú lateral si no se proporciona otra acción
              Scaffold.of(context).openDrawer();
            },
      ),
      actions: actions ??
          [
            IconButton(
              icon: const Icon(Icons.notifications, color: Colors.white),
              onPressed: () {
                // Aquí puedes agregar la acción deseada
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Notificaciones')),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.settings, color: Colors.white),
              onPressed: () {
                // Acción para abrir configuración o cualquier otra funcionalidad
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Configuración')),
                );
              },
            ),
          ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
