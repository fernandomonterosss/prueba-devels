import 'package:flutter/material.dart';

class MenuItem {
  final String title;
  final String link;
  final IconData icon;

  MenuItem({
    required this.title, 
    required this.link, 
    required this.icon
  });
}

final appMenuItems = <MenuItem>[
  MenuItem(
    title: 'Pedidos',  
    link: '/', 
    icon: Icons.view_in_ar_outlined
  ),
   MenuItem(
    title: 'Pedidos Pendientes', 
    link: '/orders-pending', 
    icon: Icons.list_alt
  ),
];