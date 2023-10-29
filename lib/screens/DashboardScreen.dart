import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:fooddelivery/main.dart';
import 'package:fooddelivery/utils/Colors.dart';
import 'package:fooddelivery/utils/Constants.dart';
import 'package:geolocator/geolocator.dart';
import 'package:nb_utils/nb_utils.dart';

import '../utils/ModalKeys.dart';
import 'CartFragment.dart';
import 'HomeFragment.dart';
import 'LoginScreen.dart';
import 'OrderFragment.dart';
import 'ProfileFragment.dart';

class DashboardScreen extends StatefulWidget {
  static String tag = '/DashboardScreen';

  @override
  DashboardScreenState createState() => DashboardScreenState();
}

class DashboardScreenState extends State<DashboardScreen> {
  int selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    init();
    updateUserProfile();
  }

  void updateUserProfile() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      userDBService.updateDocument({
        UserKeys.latitude: position.latitude,
        UserKeys.longitude: position.longitude,
        UserKeys.oneSignalPlayerId: getStringAsync(PLAYER_ID),
      }, getStringAsync(USER_ID));
    } catch (e) {
      print('Error: ${e.toString()}');
    }
  }

  Future<void> init() async {
    await Future.delayed(Duration(milliseconds: 400));

    setStatusBarColor(
      context.scaffoldBackgroundColor,
      statusBarIconBrightness:
          appStore.isDarkMode ? Brightness.light : Brightness.dark,
    );

    int themeModeIndex = getIntAsync(THEME_MODE_INDEX);
    if (themeModeIndex == ThemeModeSystem) {
      appStore.setDarkMode(context.platformBrightness() == Brightness.dark);
    }
    window.onPlatformBrightnessChanged = () {
      if (getIntAsync(THEME_MODE_INDEX) == ThemeModeSystem) {
        appStore.setDarkMode(
            MediaQuery.of(context).platformBrightness == Brightness.light);
      }
    };
  }

  @override
  void afterFirstLayout(BuildContext context) {
    appStore.setAppLocalization(context);
  }

  @override
  void didUpdateWidget(covariant DashboardScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    setState(() {});
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    print("reloaded");
    appStore.setAppLocalization(context);

    return Scaffold(
      bottomNavigationBar: getFooter(),
      body: SafeArea(
        child: IndexedStack(
          index: selectedIndex,
          children: [
            HomeFragment(),
            OrderFragment(),
            CartFragment(),
            ProfileFragment(),
          ],
        ),
      ),
    );
  }

  getFooter() {
    return BottomNavigationBar(
      selectedItemColor: colorPrimary,
      unselectedItemColor: Colors.grey,
      backgroundColor: appStore.isDarkMode ? scaffoldSecondaryDark : white,
      onTap: (index) {
        selectedTab(index);
      },
      type: BottomNavigationBarType.fixed,
      currentIndex: selectedIndex,
      selectedLabelStyle: TextStyle(fontSize: 16),
      unselectedLabelStyle: TextStyle(fontSize: 16),
      items: <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.shopping_cart),
          label: 'Orders',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.receipt),
          label: 'Cart',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
    );
  }

  selectedTab(index) {
    setState(() {
      selectedIndex = index;
    });
  }
}
