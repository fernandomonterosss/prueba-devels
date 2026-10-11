import 'package:flutter/material.dart';
import 'package:qr_app_devels/config/menu/menu_items.dart';
import 'package:qr_app_devels/presentation/widgets/offline_banner.dart';
import 'package:qr_app_devels/presentation/widgets/widgets.dart';

class HomePage extends StatefulWidget {
  static const String name = 'home_screen';

  final Widget child;
  final String location;

  const HomePage({super.key, required this.child, required this.location});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final menuItem = appMenuItems.firstWhere(
      (item) => item.link == widget.location,
      orElse: () => appMenuItems.first,
    );

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(menuItem.title),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(child: OfflineBanner()),
          )
        ],
      ),
      drawer: SidebarMenu(
        scaffoldKey: _scaffoldKey,
        location: widget.location,
      ),
      body: widget.child,
    );
  }
}