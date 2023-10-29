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
      bottomNavigationBar: getFooter(MediaQuery.of(context).size),
      body: SafeArea(
        child: screens[selectedIndex],
      ),
    );
  }

  getFooter(size) {
    List bottomItems = [
      Icon(Icons.home),
      Icon(Icons.home),
      Icon(Icons.home),
      Icon(Icons.home),
    ];

    return Container(
      width: double.infinity,
      height: 70,
      decoration: BoxDecoration(),
      child: Padding(
        padding: const EdgeInsets.only(
          top: 10,
          bottom: 20,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: double.infinity,
              height: 0.4,
              decoration: const BoxDecoration(
                color: Color(0xFFBDBDBD),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(
                bottomItems.length,
                (index) {
                  return InkWell(
                    onTap: () {
                      selectedTab(index);
                    },
                    child: SizedBox(
                      width: size.width / 7,
                      child: Icon(
                        bottomItems[index],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  selectedTab(index) {
    setState(() {
      selectedIndex = index;
    });
  }
}
