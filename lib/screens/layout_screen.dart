import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_seeker/providers/auth_provider.dart';
import 'package:job_seeker/core/auth/auth_dialog_manager.dart';
import 'package:job_seeker/screens/Profile/profile_screen.dart';

import 'applications_screen.dart';
import 'home_screen.dart';
import 'jobs_screen.dart';
import 'auth/login_screen.dart';

class LayoutScreen extends ConsumerStatefulWidget {
  const LayoutScreen({super.key});

  @override
  ConsumerState<LayoutScreen> createState() => _LayoutScreenState();
}

class _LayoutScreenState extends ConsumerState<LayoutScreen> {
  int currentIndex = 0;
  bool _hasHandledInitialAuth = false;
  bool _isSessionExpiredDialogShown = false;

  final List<String> titles = const <String>[
    'Home',
    'Explore Jobs',
    'My Applications',
    'Profile',
  ];

  final List<Widget> screens = const <Widget>[
    HomeScreen(),
    JobsScreen(),
    ApplicationsScreen(),
    ProfileScreen(),
  ];

  final List<_NavItem> navItems = const [
    _NavItem(
      icon: Icons.grid_view_rounded,
      activeIcon: Icons.grid_view_rounded,
      label: 'Home',
    ),
    _NavItem(
      icon: Icons.search_rounded,
      activeIcon: Icons.search_rounded,
      label: 'Jobs',
    ),
    _NavItem(
      icon: Icons.description_outlined,
      activeIcon: Icons.description_rounded,
      label: 'Applied',
    ),
    _NavItem(
      icon: Icons.person_outline_rounded,
      activeIcon: Icons.person_rounded,
      label: 'Profile',
    ),
  ];

  void _onDestinationSelected(int index) {
    if (index != currentIndex) {
      HapticFeedback.lightImpact();
      setState(() {
        currentIndex = index;
      });
    }
  }

  void _showSessionExpiredDialog() {
    if (_isSessionExpiredDialogShown) return;
    _isSessionExpiredDialogShown = true;

    print('[DEBUG] LayoutScreen: Showing session expired dialog');

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Session Expired'),
        content: const Text('Your session has expired. Please log in again.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
            child: const Text('OK'),
          ),
        ],
      ),
    ).then((_) {
      _isSessionExpiredDialogShown = false;
      AuthDialogManager().resetSessionExpired();
      print('[DEBUG] LayoutScreen: Dialog closed, dialog manager reset');
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AuthState>(authProvider, (previous, next) {
      if (next.status == AuthStatus.unauthenticated && mounted) {
        if (next.sessionExpired) {
          _showSessionExpiredDialog();
        } else {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const LoginScreen()),
            (route) => false,
          );
        }
      }
    });

    if (!_hasHandledInitialAuth) {
      _hasHandledInitialAuth = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final currentState = ref.read(authProvider);
        if (currentState.status == AuthStatus.unauthenticated && mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const LoginScreen()),
            (route) => false,
          );
        }
      });
    }

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        title: Text(
          titles[currentIndex],
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
        toolbarHeight: 48,
        backgroundColor: colorScheme.surface.withOpacity(0.8),
        elevation: 0,
        scrolledUnderElevation: 0,
        forceMaterialTransparency: true,
      ),
      body: Stack(
        children: [
          // Background - IgnorePointer to prevent blocking taps
          IgnorePointer(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [colorScheme.surface, const Color(0xFFF8F9FE)],
                ),
              ),
            ),
          ),

          IndexedStack(index: currentIndex, children: screens),
        ],
      ),
      bottomNavigationBar: _GlassBottomNav(
        items: navItems,
        currentIndex: currentIndex,
        onTap: _onDestinationSelected,
      ),
    );
  }
}

class _GlassBottomNav extends StatelessWidget {
  final List<_NavItem> items;
  final int currentIndex;
  final Function(int) onTap;

  const _GlassBottomNav({
    required this.items,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = const Color(0xFF4E60FF); // Vibrant Blue for active

    return Padding(
      padding: EdgeInsets.fromLTRB(
        24,
        0,
        24,
        MediaQuery.of(context).padding.bottom + 16,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Blur Layer
          ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: Container(
                height: 72, // Slightly Taller for labels
                width: double.infinity,
                color: Colors.white.withValues(alpha: 0.85),
              ),
            ),
          ),

          // Border Layer
          IgnorePointer(
            child: Container(
              height: 72,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.5),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
            ),
          ),

          // Content Layer
          Container(
            height: 72,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(items.length, (index) {
                final isSelected = index == currentIndex;
                return GestureDetector(
                  onTap: () => onTap(index),
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    width: 64, // Fixed target width
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeOut,
                          child: Icon(
                            isSelected
                                ? items[index].activeIcon
                                : items[index].icon,
                            color: isSelected
                                ? primaryColor
                                : Colors.grey.shade500,
                            size: 26,
                          ),
                        ),
                        const SizedBox(height: 4),
                        AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 200),
                          style: TextStyle(
                            fontFamily: 'Inter', // Assuming Inter is used
                            fontSize: 10,
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: isSelected
                                ? primaryColor
                                : Colors.grey.shade500,
                          ),
                          child: Text(items[index].label),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}
