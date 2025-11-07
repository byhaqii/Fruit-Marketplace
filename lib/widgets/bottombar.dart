import 'package:flutter/material.dart';
import '_nav_item.dart'; // Import NavItem

// Definisi route item navigasi
class NavData {
  final IconData icon;
  final String label;
  final String route;

  const NavData({required this.icon, required this.label, required this.route});
}

// Data navigasi untuk BottomBar
final List<NavData> navItems = [
  const NavData(icon: Icons.home, label: 'Home', route: '/'),
  const NavData(icon: Icons.shopping_bag, label: 'Marketplace', route: '/produk'),
  const NavData(icon: Icons.bar_chart, label: 'Statisticssssss', route: '/statistic'), 
  const NavData(icon: Icons.person, label: 'Akun', route: '/akun'), 
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
      // Membuat takik melingkar
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
            NavItem(
              icon: navItems[0].icon,
              label: navItems[0].label,
              isSelected: selectedIndex == 0,
              onTap: () => onItemTapped(0),
              activeColor: primaryColor,
            ),
            
            // Item 2: Marketplace
            NavItem(
              icon: navItems[1].icon,
              label: navItems[1].label,
              isSelected: selectedIndex == 1,
              onTap: () => onItemTapped(1),
              activeColor: primaryColor,
            ),

            // Spacer kosong untuk menyeimbangkan tombol 'Scan'
            const SizedBox(width: 48), 

            // Item 3: Statistic 
            NavItem(
              icon: navItems[2].icon,
              label: navItems[2].label,
              isSelected: selectedIndex == 2,
              onTap: () => onItemTapped(2),
              activeColor: primaryColor,
            ),
            
            // Item 4: Akun 
            NavItem(
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