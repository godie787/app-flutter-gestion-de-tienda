import 'package:flutter/material.dart';

class SuperuserAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text('Superuser Panel'),
      backgroundColor: Colors.teal,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
