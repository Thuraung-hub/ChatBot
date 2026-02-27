// lib/screens/main_shell.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';
import '../widgets/floating_chat_bubble.dart';
import 'home_screen.dart';
import 'chat_screen.dart';
import 'profile_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});
  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  static const _screens = [
    HomeScreen(),
    ChatScreen(),
    ProfileScreen(),
  ];

  static const _navItems = [
    _NavData(Icons.home_rounded,           Icons.home_outlined,    'Home'),
    _NavData(Icons.auto_awesome_rounded,   Icons.auto_awesome_outlined, 'Assistant'),
    _NavData(Icons.person_rounded,         Icons.person_outline_rounded,'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    final isChat = _index == 1; // On chat screen — hide bubble

    return Scaffold(
      backgroundColor: AppColors.bg,
      // Keep all screens alive for performance
      body: IndexedStack(
        index: _index,
        children: _screens,
      ),
      floatingActionButton: isChat
          ? null
          : const Padding(
              padding: EdgeInsets.only(bottom: 80),
              child: FloatingChatBubble(),
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: SafeArea(
          child: SizedBox(
            height: 64,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(_navItems.length, (i) {
                final item = _navItems[i];
                final selected = _index == i;
                return NavItem(
                  icon:     selected ? item.selectedIcon : item.icon,
                  label:    item.label,
                  selected: selected,
                  onTap:    () => setState(() => _index = i),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavData {
  final IconData selectedIcon, icon;
  final String   label;
  const _NavData(this.selectedIcon, this.icon, this.label);
}
