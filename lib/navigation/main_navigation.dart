import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/app_colors.dart';
import '../screens/home/home_screen.dart';
import '../screens/bible/bible_screen.dart';
import '../screens/worship/worship_screen.dart';
import '../screens/media/media_screen.dart';
import '../screens/profile/profile_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _index = 0;

  void _switchTo(int i) {
    if (i == _index) return;
    HapticFeedback.selectionClick();
    setState(() => _index = i);
  }

  @override
  Widget build(BuildContext context) {
    final screens = <Widget>[
      HomeScreen(onSwitch: _switchTo),
      const BibleScreen(),
      const WorshipScreen(),
      const MediaScreen(),
      const ProfileScreen(),
    ];
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: IndexedStack(index: _index, children: screens),
      bottomNavigationBar: _BottomBar(index: _index, onTap: _switchTo),
    );
  }
}

class _BottomBar extends StatelessWidget {
  final int index;
  final void Function(int) onTap;
  const _BottomBar({required this.index, required this.onTap});

  static const _items = [
    _NavDef('Home',    Icons.home_outlined,          Icons.home_rounded),
    _NavDef('Bible',   Icons.menu_book_outlined,     Icons.menu_book_rounded),
    _NavDef('Worship', Icons.music_note_outlined,    Icons.music_note_rounded),
    _NavDef('Media',   Icons.play_circle_outline,    Icons.play_circle_rounded),
    _NavDef('Profile', Icons.person_outline_rounded, Icons.person_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(color: AppColors.navBg, border: Border(top: BorderSide(color: AppColors.border))),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 62,
          child: Row(
            children: List.generate(_items.length,
              (i) => Expanded(child: _NavItem(def: _items[i], active: i == index, onTap: () => onTap(i)))),
          ),
        ),
      ),
    );
  }
}

class _NavDef {
  final String label;
  final IconData icon;
  final IconData activeIcon;
  const _NavDef(this.label, this.icon, this.activeIcon);
}

class _NavItem extends StatefulWidget {
  final _NavDef def;
  final bool active;
  final VoidCallback onTap;
  const _NavItem({required this.def, required this.active, required this.onTap});

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 220), value: widget.active ? 1.0 : 0.0);
  late final Animation<double> _scale  = Tween(begin: 0.82, end: 1.0).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack));

  @override
  void didUpdateWidget(_NavItem old) {
    super.didUpdateWidget(old);
    widget.active ? _ctrl.forward() : _ctrl.reverse();
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final color = widget.active ? AppColors.gold : AppColors.muted;
    return GestureDetector(
      onTap: widget.onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        AnimatedContainer(duration: const Duration(milliseconds: 200),
          width: widget.active ? 26 : 0, height: 2.5, margin: const EdgeInsets.only(bottom: 4),
          decoration: BoxDecoration(color: AppColors.gold, borderRadius: BorderRadius.circular(2))),
        ScaleTransition(scale: _scale,
          child: AnimatedContainer(duration: const Duration(milliseconds: 200),
            width: 38, height: 26,
            decoration: BoxDecoration(
              color: widget.active ? AppColors.gold.withOpacity(0.12) : Colors.transparent,
              borderRadius: BorderRadius.circular(8)),
            child: Icon(widget.active ? widget.def.activeIcon : widget.def.icon, color: color, size: 20))),
        const SizedBox(height: 3),
        AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 180),
          style: TextStyle(fontFamily: 'Nunito', fontSize: 10, fontWeight: widget.active ? FontWeight.w700 : FontWeight.w500, color: color),
          child: Text(widget.def.label)),
      ]),
    );
  }
}
