// lib/widgets/bottombar.dart
import 'package:flutter/material.dart';
import '_nav_item.dart'; 

// Definisi route item navigasi
class NavData {
  final IconData icon;
  final String label;
  final String route;

  const NavData({required this.icon, required this.label, required this.route});
}

// Data navigasi untuk BottomBar (5 ITEMS)
final List<NavData> navItems = [
  const NavData(icon: Icons.home, label: 'Home', route: '/'),
  const NavData(icon: Icons.shopping_bag, label: 'Marketplace', route: '/produk'),
  const NavData(icon: Icons.qr_code_scanner, label: 'Scan', route: '/scan'), // <<< NEW SCAN ITEM
  const NavData(icon: Icons.group, label: 'User', route: '/user'), // Bergeser ke index 3
  const NavData(icon: Icons.person, label: 'Akun', route: '/akun'), // Bergeser ke index 4
];

class BottomBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const BottomBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return BottomAppBar(
      color: Colors.white,
      // Mengubah desain agar sesuai dengan 5 item jika digunakan di Scaffold utama
      shape: const CircularNotchedRectangle(), // Biarkan bentuk notch, tapi tidak kita gunakan centernya
      notchMargin: 6.0,
      padding: EdgeInsets.zero,
      surfaceTintColor: Colors.white,
      child: SizedBox(
        height: 60.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            // Item 1: Home (Index 0)
            NavItem(
              icon: navItems[0].icon,
              label: navItems[0].label,
              isSelected: selectedIndex == 0,
              onTap: () => onItemTapped(0),
              activeColor: primaryColor,
            ),

            // Item 2: Marketplace (Index 1)
            NavItem(
              icon: navItems[1].icon,
              label: navItems[1].label,
              isSelected: selectedIndex == 1,
              onTap: () => onItemTapped(1),
              activeColor: primaryColor,
            ),
            
            // Item 3: Scan (Index 2)
            NavItem(
              icon: navItems[2].icon,
              label: navItems[2].label,
              isSelected: selectedIndex == 2,
              onTap: () => onItemTapped(2),
              activeColor: primaryColor,
            ),

            // Item 4: User (Index 3)
            NavItem(
              icon: navItems[3].icon,
              label: navItems[3].label,
              isSelected: selectedIndex == 3,
              onTap: () => onItemTapped(3),
              activeColor: primaryColor,
            ),

            // Item 5: Akun (Index 4)
            NavItem(
              icon: navItems[4].icon,
              label: navItems[4].label,
              isSelected: selectedIndex == 4,
              onTap: () => onItemTapped(4),
              activeColor: primaryColor,
            ),
          ],
        ),
      ),
    );
  }
}