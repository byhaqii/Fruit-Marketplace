import 'package:flutter/material.dart';
import '../core/storage/preferences_helper.dart';

class AppSidebar extends StatelessWidget {
  final String? currentRoute;
  const AppSidebar({super.key, this.currentRoute});

  Future<String?> _getDisplayName() async {
    final role = await PreferencesHelper.getUserRole();
    // you can extend this to fetch a user name from prefs or API
    return role != null ? 'Role: $role' : 'Guest';
  }

  void _navigate(BuildContext context, String route) {
    if (route == currentRoute) {
      Navigator.pop(context);
      return;
    }
    Navigator.pop(context);
    Navigator.pushReplacementNamed(context, route);
  }

  Future<void> _logout(BuildContext context) async {
    await PreferencesHelper.clearAll();
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            FutureBuilder<String?>(
              future: _getDisplayName(),
              builder: (context, snap) {
                final title = snap.data ?? 'Loading...';
                return UserAccountsDrawerHeader(
                  accountName: Text(title),
                  accountEmail: const Text(''),
                  currentAccountPicture: CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    child: const Icon(Icons.person, color: Colors.white),
                  ),
                );
              },
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  ListTile(
                    leading: const Icon(Icons.dashboard),
                    title: const Text('Dashboard'),
                    selected: currentRoute == '/',
                    onTap: () => _navigate(context, '/'),
                  ),
                  ListTile(
                    leading: const Icon(Icons.people),
                    title: const Text('Warga'),
                    onTap: () => _navigate(context, '/warga'),
                  ),
                  ListTile(
                    leading: const Icon(Icons.account_balance_wallet),
                    title: const Text('Keuangan / Iuran'),
                    onTap: () => _navigate(context, '/iuran'),
                  ),
                  ListTile(
                    leading: const Icon(Icons.store),
                    title: const Text('Marketplace'),
                    onTap: () => _navigate(context, '/produk'),
                  ),
                  ListTile(
                    leading: const Icon(Icons.notifications),
                    title: const Text('Notifications'),
                    onTap: () => _navigate(context, '/notifications'),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.settings),
                    title: const Text('Settings'),
                    onTap: () => _navigate(context, '/settings'),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _logout(context),
                      icon: const Icon(Icons.exit_to_app),
                      label: const Text('Logout'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
