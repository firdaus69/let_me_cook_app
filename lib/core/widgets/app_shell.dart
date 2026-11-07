import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../router/app_router.dart';

/// Bottom navigation around the Home, Saved and Profile tabs.
///
/// "My fridge" opens the full-screen fridge flow instead of switching tabs,
/// so its sticky "Find recipes" bar has the whole screen to itself.
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.shell});

  final StatefulNavigationShell shell;

  // Branch index -> destination index (destination 1 is "My fridge").
  static const _branchToDestination = [0, 2, 3];

  void _onSelect(BuildContext context, int destination) {
    if (destination == 1) {
      context.push(AppRoutes.fridge);
      return;
    }
    final branch = _branchToDestination.indexOf(destination);
    shell.goBranch(branch, initialLocation: branch == shell.currentIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: shell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _branchToDestination[shell.currentIndex],
        onDestinationSelected: (i) => _onSelect(context, i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.kitchen_outlined),
            label: 'My fridge',
          ),
          NavigationDestination(
            icon: Icon(Icons.bookmark_border),
            selectedIcon: Icon(Icons.bookmark),
            label: 'Saved',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
