// lib/modules/dashboard/widgets/bottom_bar_widget.dart
import 'package:flutter/material.dart';
import 'nav_item_widget.dart'; // Import widget NavItem

// Definisi data navigasi
class NavData {
  final IconData icon;
  final String label;
  const NavData({required this.icon, required this.label});
}

// Data navigasi untuk BottomBar
// Kita ekspor 'navItems' agar bisa dibaca oleh dashboard_page.dart
final List<NavData> navItems = [
  const NavData(icon: Icons.home, label: 'Home'),
  const NavData(icon: Icons.shopping_bag, label: 'Marketplace'),
  const NavData(icon: Icons.bar_chart, label: 'Statistics'),
  const NavData(icon: Icons.person, label: 'Akun'),
];

class BottomBarWidget extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const BottomBarWidget({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return BottomAppBar(
      color: Colors.white,
      shape: const CircularNotchedRectangle(),
      notchMargin: 6.0,
      padding: EdgeInsets.zero,
      surfaceTintColor: Colors.white,
      child: SizedBox(
        height: 60.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            // Item 1: Home
            NavItemWidget(
              icon: navItems[0].icon,
              label: navItems[0].label,
              isSelected: selectedIndex == 0,
              onTap: () => onItemTapped(0),
              activeColor: primaryColor,
            ),

            // Item 2: Marketplace
            NavItemWidget(
              icon: navItems[1].icon,
              label: navItems[1].label,
              isSelected: selectedIndex == 1,
              onTap: () => onItemTapped(1),
              activeColor: primaryColor,
            ),

            // Spacer kosong untuk tombol 'Scan'
            const SizedBox(width: 48),

            // Item 3: Statistic
            NavItemWidget(
              icon: navItems[2].icon,
              label: navItems[2].label,
              isSelected: selectedIndex == 2,
              onTap: () => onItemTapped(2),
              activeColor: primaryColor,
            ),

            // Item 4: Akun
            NavItemWidget(
              icon: navItems[3].icon,
              label: navItems[3].label,
              isSelected: selectedIndex == 3,
              onTap: () => onItemTapped(3),
              activeColor: primaryColor,
            ),
          ],
        ),
      ),
    );
  }
}