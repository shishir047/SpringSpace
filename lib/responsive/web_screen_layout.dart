import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:spring_space/util/colors.dart';
import 'package:spring_space/util/global_variables.dart';

class WebScreenLayout extends StatefulWidget {
  const WebScreenLayout({super.key});

  @override
  State<WebScreenLayout> createState() => _WebScreenLayoutState();
}

class _WebScreenLayoutState extends State<WebScreenLayout> {
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
    setState(() {
      _page = page;
    });
  }

  void updateHomeScreenItems() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      homeScreenItems = getHomeScreenItems(user.uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    double oneFifthWidth = MediaQuery.of(context).size.width * 0.2;
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.only(left: oneFifthWidth, right: oneFifthWidth),
        child: PageView(
          physics: const NeverScrollableScrollPhysics(),
          controller: pageController,
          onPageChanged: onPageChanged,
          children: homeScreenItems,
        ),
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
