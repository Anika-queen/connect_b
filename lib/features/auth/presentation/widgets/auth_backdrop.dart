import 'package:flutter/material.dart';

class AuthBackdrop extends StatelessWidget {
  const AuthBackdrop({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(color: Colors.white, child: child);
  }
}
