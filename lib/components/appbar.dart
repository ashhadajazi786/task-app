import 'package:flutter/material.dart';

class userappbar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onHomePressed;
  final VoidCallback? onProductsPressed;
  final VoidCallback? onCartPressed;

  const userappbar({
    super.key,
    required this.title,
    this.onHomePressed,
    this.onProductsPressed,
    this.onCartPressed,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Image(
          image: AssetImage('logoblack.png'),
          height: 48,
        ),
      backgroundColor: Colors.black,
      foregroundColor: Colors.white,
      elevation: 1,
      centerTitle: true,
      
      actions: [
        IconButton(
          icon: const Icon(Icons.person),
          tooltip: 'User_info',
          onPressed:
              onCartPressed ??
              () {
                Navigator.pushNamed(context, '/userdetails');
              },
        ),
      ],
      iconTheme: const IconThemeData(color: Colors.white),
    );
  }
}
