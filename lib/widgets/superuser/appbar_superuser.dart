import 'package:flutter/material.dart';

class SuperuserAppBar extends StatelessWidget implements PreferredSizeWidget {
  const SuperuserAppBar({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text('Home'),
      backgroundColor: Colors.teal,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
