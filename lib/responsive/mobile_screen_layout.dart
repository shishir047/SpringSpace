import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:spring_space/util/colors.dart';
import 'package:spring_space/util/global_variables.dart';

class MobileScreenLayout extends StatefulWidget {
  const MobileScreenLayout({super.key});

  @override
  State<MobileScreenLayout> createState() => _MobileScreenLayoutState();
}

class _MobileScreenLayoutState extends State<MobileScreenLayout> {
  int _page = 0;
  late PageController pageController;
  late List<Widget> homeScreenItems;

  @override
  void initState() {
    super.initState();
    pageController = PageController();
    updateHomeScreenItems();
  }

  @override
  void dispose() {
    super.dispose();
    pageController.dispose();
  }

  void onPageChanged(int page) {
    setState(() {
      _page = page;
    });
  }

  void navigationTapped(int page) {
    pageController.jumpToPage(page);
  }

  void updateHomeScreenItems() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      homeScreenItems = getHomeScreenItems(user.uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        physics: const NeverScrollableScrollPhysics(),
        controller: pageController,
        onPageChanged: onPageChanged,
        children: homeScreenItems,
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: customGreen,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.home,
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.search,
            ),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.menu,
            ),
            label: 'Menu',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.leaderboard_sharp,
            ),
            label: 'Leaderboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.person,
            ),
            label: 'Profile',
          ),
        ],
        onTap: (page) {
          navigationTapped(page);
          // Update homeScreenItems when the profile page is selected
          if (page == 4) {
            updateHomeScreenItems();
          }
        },
        currentIndex: _page,
        selectedItemColor: Colors.white,
        unselectedItemColor: customGreen[300],
        showSelectedLabels: false,
        showUnselectedLabels: false,
      ),
    );
  }
}
