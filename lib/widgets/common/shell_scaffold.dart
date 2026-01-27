import 'package:flutter/material.dart';
import 'nav_bar.dart';
import 'footer.dart';
/**
 * Bu widget, diğer widget'ların çevresini sarar ve navigasyon ve footer bileşenlerini içerir.
 * Fotter: Footer bileşeni, sayfanın altında yer alır ve sosyal medya bağlantıları, haklarınız ve diğer bilgileri içerir.
 * NavBar: NavBar bileşeni, sayfanın üstünde yer alır ve sayfalar arası geçişi sağlar.
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
              child: Column(
                children: [
                  child,
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
