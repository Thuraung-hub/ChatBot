import 'package:flutter/material.dart';

class RbacVisibility extends StatelessWidget {
  final bool isAdmin;
  final Widget child;
  final Widget fallback;

  const RbacVisibility({
    super.key,
    required this.isAdmin,
    required this.child,
    this.fallback = const SizedBox.shrink(),
  });

  @override
  Widget build(BuildContext context) {
    return isAdmin ? child : fallback;
  }
}
