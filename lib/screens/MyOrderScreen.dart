import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:fooddelivery/components/MyOrderBottomWidget.dart';
import 'package:fooddelivery/components/MyOrderListItemComponent.dart';
import 'package:fooddelivery/components/MyOrderUserInfoComponent.dart';
import 'package:fooddelivery/main.dart';
import 'package:fooddelivery/services/GetLocationLatLng.dart';
import 'package:fooddelivery/services/UserDBService.dart';
import 'package:fooddelivery/utils/Colors.dart';
import 'package:fooddelivery/utils/Constants.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:nb_utils/nb_utils.dart';

import '../services/CalculateDistance.dart';

// ignore: must_be_immutable
class MyOrderScreen extends StatefulWidget {
  static String tag = '/MyOrderScreen';

  String? orderAddress;

  MyOrderScreen({this.orderAddress});

  @override
  MyOrderScreenState createState() => MyOrderScreenState();
}

class MyOrderScreenState extends State<MyOrderScreen> {
  int totalAmount = 0;
  UserDBService? userDBService;

  double? userLatitude;
  double? userLongitude;
  bool? isOrder;
  String address = "";
  double deliveryFee = 0.0;
  bool isCalculating = true;
  bool containNotOnGoogle = false;
  int totalQty = 0;
  int totalAroundOrder = 0;

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    calculateTotal();
    getCurrentUserLocation();
    calculateDeliveryCharges();

    setStatusBarColor(
      appStore.isDarkMode ? scaffoldColorDark : colorPrimary,
      statusBarIconBrightness:
          appStore.isDarkMode ? Brightness.light : Brightness.dark,
    );
  }

  getCurrentUserLocation() async {
    final geoPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      userLatitude = geoPosition.longitude;
      userLongitude = geoPosition.latitude;
    });
  }

  void calculateTotal() {
    totalAmount = appStore.mCartList
            .sumBy(((e) => e!.itemPrice == null ? 0 : e.itemPrice! * e.qty!)) +
        deliveryFee.toInt();
    setState(() {});
  }

  void calculateDeliveryCharges() {
    appStore.setIsCalculating(true);
    deliveryFee = 0;
    appStore.setDeliveryCharge(deliveryFee);
    if (appStore.addressModel == null) {
      print("address is null");
      appStore.setIsCalculating(false);
      isCalculating = false;
    } else {
      print(appStore.addressModel!.address);

      setState(() {});

      appStore.mCartList.forEach((element) async {
        if (appStore.addressModel!.addressLocation == "Inside UCAD") {
          totalQty += element!.qty!;
          print("within UCAD");
        } else {
          if (appStore.addressModel!.address!.isNotEmpty) {
            LatLng userLocation = await getLatLngFromLocationName(
                appStore.addressModel!.address!);
            double roundedValue = double.parse(calculateDistance(UCAD_LOCATION,
                   userLocation)
                .toStringAsFixed(2));
            var charge = roundedValue * AROUND_UCAD_CHARGES;
            deliveryFee = deliveryFee + charge;
            appStore.setDeliveryCharge(deliveryFee);
            appStore.setIsCalculating(false);
          } else {
            print("restaurant name is empty");
          }
        }
        setState(() {});
      });

      if (totalQty <= 4 && totalQty > 0) {
        deliveryFee += 100;
      } else if (totalQty > 4 && totalQty < 25) {
        deliveryFee += totalQty * 25;
      } else if (totalQty > 25) {
        deliveryFee += 500;
      }
      if (totalAroundOrder > 0) {
        deliveryFee += AROUND_UCAD_CHARGES;
      }

      appStore.setIsCalculating(false);

      appStore.setDeliveryCharge(deliveryFee);
    }
  }

  @override
  void dispose() {
    setStatusBarColor(
      appStore.isDarkMode ? scaffoldColorDark : colorPrimary,
      statusBarIconBrightness:
          appStore.isDarkMode ? Brightness.light : Brightness.dark,
    );
    super.dispose();
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: appBarWidget(appStore.translate('checkout'),
            color: appStore.isDarkMode ? scaffoldColorDark : colorPrimary,
            textColor: white,
            showBack: true),
        body: Column(
          children: [
            MyOrderUserInfoComponent(isOrder: true),
            16.height,
            Observer(
              builder: (_) => ListView.builder(
                itemCount: appStore.mCartList.length,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  return MyOrderListItemComponent(
                      myOrderData: appStore.mCartList[index]);
                },
              ).expand(),
            ),
          ],
        ),
        bottomNavigationBar: MyOrderBottomWidget(
          totalAmount: totalAmount,
          userLatitude: userLatitude,
          userLongitude: userLongitude,
          orderAddress: address,
          isOrder: true,
          deliveryFee: appStore.deliveryCharge,
          containNotOnGoogle: containNotOnGoogle,
          onPlaceOrder: () {
            setState(() {});
          },
        ),
      ),
    );
  }
}
