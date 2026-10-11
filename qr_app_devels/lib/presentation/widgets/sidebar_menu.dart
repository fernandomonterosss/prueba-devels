import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_app_devels/config/menu/menu_items.dart';

class SidebarMenu extends StatelessWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  final String location;

  const SidebarMenu({
    super.key,
    required this.scaffoldKey,
    required this.location,
  });

  @override
  Widget build(BuildContext context) {
    final hasNotch = MediaQuery.of(context).viewPadding.top > 35;
    final selectedIndex = appMenuItems.indexWhere(
      (item) => item.link == location,
    );

    return NavigationDrawer(
      selectedIndex: selectedIndex < 0 ? 0 : selectedIndex,
      onDestinationSelected: (value) {
        final menuItem = appMenuItems[value];
        context.go(menuItem.link);
        scaffoldKey.currentState?.closeDrawer();
      },
      backgroundColor: const Color(0xFF10265F),
      indicatorColor: const Color(0xFF2563EB),
      indicatorShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(28, hasNotch ? 0 : 20, 16, 10),
          child: const Text('Menu', style: TextStyle(color: Colors.white)),
        ),
        ...appMenuItems.map(
          (item) => NavigationDrawerDestination(
            icon: Icon(item.icon, color: Colors.white),
            label: Text(item.title, style: const TextStyle(color: Colors.white)),
          ),
        ),
      ],
    );
  }
}