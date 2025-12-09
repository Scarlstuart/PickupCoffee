import 'package:flutter/material.dart';
import '../constants/colors.dart';
import 'home_dashboard_page.dart';
import 'inbox_page.dart';
import 'scanner_page.dart';
import 'history_page.dart';
import 'profile_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  int _currentIndex = 0;
  late List<AnimationController> _animationControllers;
  late List<Animation<double>> _scaleAnimations;

  @override
  void initState() {
    super.initState();
    // Initialize animation controllers for each nav item
    _animationControllers = List.generate(
      5,
      (index) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 200),
      ),
    );
    _scaleAnimations = _animationControllers
        .map((controller) => Tween<double>(begin: 1.0, end: 1.2)
            .animate(CurvedAnimation(parent: controller, curve: Curves.easeOut)))
        .toList();
    // Start animation for initial selected item
    _animationControllers[0].forward();
  }

  @override
  void dispose() {
    for (var controller in _animationControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _onNavigateToTab(int index) {
    setState(() {
      // Reverse previous animation
      _animationControllers[_currentIndex].reverse();
      _currentIndex = index;
      // Forward new animation
      _animationControllers[_currentIndex].forward();
    });
  }

  Widget _buildPage(int index) {
    switch (index) {
      case 0:
        return HomeDashboardPage(onNavigateToTab: _onNavigateToTab);
      case 1:
        return const InboxPage();
      case 2:
        return const ScannerPage();
      case 3:
        return const HistoryPage();
      case 4:
        return const ProfilePage();
      default:
        return HomeDashboardPage(onNavigateToTab: _onNavigateToTab);
    }
  }

  Widget _buildScannerIcon(bool isSelected) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.pickupGreen,
          width: 3,
        ),
        color: Colors.transparent,
      ),
      child: Center(
        child: Container(
          width: 42,
          height: 42,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
          ),
          child: Icon(
            Icons.qr_code_scanner,
            size: 24,
            color: AppColors.pickupGreen,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFAFCB86),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.1, 0),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOut,
              )),
              child: child,
            ),
          );
        },
        child: Container(
          key: ValueKey<int>(_currentIndex),
          child: _buildPage(_currentIndex),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.pickupWhite,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildNavItem(
                  icon: Icons.home,
                  label: 'Home',
                  index: 0,
                ),
                _buildNavItem(
                  icon: Icons.inbox,
                  label: 'Inbox',
                  index: 1,
                ),
                _buildNavItem(
                  icon: Icons.qr_code_scanner,
                  label: 'Scanner',
                  index: 2,
                  isScanner: true,
                ),
                _buildNavItem(
                  icon: Icons.history,
                  label: 'History',
                  index: 3,
                ),
                _buildNavItem(
                  icon: Icons.person,
                  label: 'Profile',
                  index: 4,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
    bool isScanner = false,
  }) {
    final isSelected = _currentIndex == index;
    
    return Expanded(
      child: GestureDetector(
        onTap: () {
          _onNavigateToTab(index);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedBuilder(
                animation: _scaleAnimations[index],
                builder: (context, child) {
                  return Transform.scale(
                    scale: _scaleAnimations[index].value,
                    child: child,
                  );
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOut,
                  child: isScanner
                      ? _buildScannerIcon(isSelected)
                      : Icon(
                          icon,
                          size: 24,
                          color: isSelected
                              ? AppColors.pickupGreen
                              : AppColors.pickupGreyLight,
                        ),
                ),
              ),
              const SizedBox(height: 2),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  fontSize: 11,
                  color: isSelected
                      ? AppColors.pickupGreen
                      : AppColors.pickupGreyLight,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

