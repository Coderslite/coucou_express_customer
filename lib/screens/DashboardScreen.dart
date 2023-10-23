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

  List<Widget> screens = [
    HomeFragment(),
    OrderFragment(),
    CartFragment(),
    ProfileFragment(),
  ];

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
    appStore.setAppLocalization(context);

    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: colorPrimary,
        unselectedItemColor: Colors.grey,
        backgroundColor: appStore.isDarkMode ? scaffoldSecondaryDark : white,
        onTap: (index) {
          if (index == 1 || index == 3 || index == 2) {
            if (!appStore.isLoggedIn) {
              LoginScreen().launch(context);
              return;
            }
          }
          selectedIndex = index;
          setState(() {});
        },
        type: BottomNavigationBarType.fixed,
        currentIndex: selectedIndex,
        selectedLabelStyle: TextStyle(fontSize: 16),
        unselectedLabelStyle: TextStyle(fontSize: 16),
        items: [
          BottomNavigationBarItem(
              icon: Icon(Icons.restaurant_menu_outlined),
              label: appStore.translate('home')),
          BottomNavigationBarItem(
              icon: Icon(Icons.shopping_basket_outlined),
              label: appStore.translate('order')),
          BottomNavigationBarItem(
              icon: Icon(Icons.add_shopping_cart_outlined),
              label: appStore.translate('cart')),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              label: appStore.translate('profile')),
        ],
      ),
      body: SafeArea(
        child: screens[selectedIndex],
      ),
    );
  }
}
