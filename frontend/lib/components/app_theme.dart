import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      title: Image.asset(
        'assets/images/logo.png',
        scale: 6,
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(2.0),
        child: Divider(
          height: 0.8,
          color: Colors.grey.withOpacity(0.5),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(56.0);
}
