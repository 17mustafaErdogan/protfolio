import 'package:flutter/material.dart';
import 'nav_bar.dart';
import 'footer.dart';
/**
 * Bu widget, diğer widget'ların çevresini sarar ve navigasyon ve footer bileşenlerini içerir.
 * Footer: Footer bileşeni, sayfanın altında yer alır ve sosyal medya bağlantıları, haklarınız ve diğer bilgileri içerir.
 * NavBar: NavBar bileşeni, sayfanın üstünde yer alır ve sayfalar arası geçişi sağlar.
 *
 * SingleChildScrollView + Column yapısı geçiş sırasında overflow ve önceki ekranın
 * üst üste binme hatalarını önlemek için CustomScrollView yerine kullanılır.
 */
class ShellScaffold extends StatelessWidget {
  final Widget child;

  const ShellScaffold({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const NavBar(),
          Expanded(
            child: SingleChildScrollView(
              clipBehavior: Clip.hardEdge,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  RepaintBoundary(child: child),
                  const Footer(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
