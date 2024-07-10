import 'package:flutter/material.dart';
import 'package:spring_space/screens/home_screen.dart';
import 'package:spring_space/screens/leaderboard_screen.dart';
import 'package:spring_space/screens/profile_screen.dart';
import 'package:spring_space/screens/menu_screen.dart';
import 'package:spring_space/screens/search_screen.dart';

const webScreenSize = 600;
List<Widget> getHomeScreenItems(String uid) {
  return [
    const HomeScreen(postType: 'allPosts',),
    const SearchScreen(),
    const MenuScreen(),
    const LeaderboardScreen(),
    ProfileScreen(uid: uid),
  ];
}
