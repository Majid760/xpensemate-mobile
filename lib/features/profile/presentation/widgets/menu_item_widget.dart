import 'dart:isolate';

import 'package:flutter/material.dart';
import 'package:xpensemate/core/utils/app_logger.dart';

class MenuItemData {
  const MenuItemData({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
    this.isDestructive = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;
  final bool isDestructive;
}
