import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:fooddelivery/main.dart';
import 'package:fooddelivery/services/GetFixedDeliveryFee.dart';
import 'package:fooddelivery/utils/Colors.dart';
import 'package:fooddelivery/utils/Constants.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:nb_utils/nb_utils.dart';

import '../services/GetKiloDeliveryFee.dart';
import '../utils/ModalKeys.dart';
import 'CartFragment.dart';
import 'HomeFragment.dart';
import 'OrderFragment.dart';
import 'ProfileFragment.dart';

class DashboardScreen extends StatefulWidget {
  static String tag = '/DashboardScreen';

  @override
  DashboardScreenState createState() => DashboardScreenState();
}

class DashboardScreenState extends State<DashboardScreen> {
  int selectedIndex = 0;
  LatLng? location;

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
    handleGetFixCharge();
    getUserLocation();
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

  void getUserLocation() async {
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    double latitude = position.latitude;
    double longitude = position.longitude;
    location = LatLng(latitude, longitude);
    // isLocationInCity(latitude, longitude, 'Thiès');
    appStore.setLocation(location!);
    var city = await getUserCity(latitude, longitude);
    appStore.setCity(city);
    setState(() {});
  }

  Future<String> getUserCity(double latitude, double longitude) async {
    try {
      // Use reverse geocoding to get the address information for the provided coordinates
      List<Placemark> placemarks =
          await placemarkFromCoordinates(latitude, longitude);

      // Extract the city name from the obtained placemarks
      if (placemarks.isNotEmpty) {
        String cityName = placemarks[0].locality ?? '';
        return cityName;
      } else {
        return 'Unknown';
      }
    } catch (e) {
      print('Error: $e');
      return 'Unknown';
    }
  }

  handleGetFixCharge() async {
    var fee = await getFixedDeliveryFee();
    var fee2 = await getKiloDeliveryFee();
    print("delivery fee ${fee.amount}");
    appStore.setConstantDeliveryCharge(fee.amount!.toDouble());
    appStore.setKmDeliveryCharge(fee2.amount!.toDouble());
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
