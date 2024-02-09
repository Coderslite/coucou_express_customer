import 'dart:math';

import 'package:flutter/material.dart';
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

  Future<void> calculateDeliveryCharges() async {
    appStore.setIsCalculating(true);
    deliveryFee = 0;
    appStore.setDeliveryCharge(deliveryFee);
    appStore.mCartList.forEach((element) {
      if (element?.isSuggestedPrice == true || element?.itemPrice == null) {
        print("Price is not available");
        print(element?.itemPrice);
        appStore.setContainNoPrice(true);
      }
    });
    setState(() {});
    for (var element in appStore.mCartList) {
      if (element!.ownedByUs == true &&
          appStore.addressModel!.addressLocation == 'Inside UCAD') {
        totalQty += 0;
        appStore.setDeliveryFeeAvailable(true);
      } else {
        if (appStore.addressModel!.addressLocation == "Inside UCAD" &&
            (element.restaurantLocation == 'Inside UCAD' ||
                element.restaurantLocation == '')) {
          totalQty += element.qty!;
          appStore.setDeliveryFeeAvailable(true);
        } else if ((appStore.addressModel!.addressLocation == "Inside UCAD" &&
                element.restaurantLocation == 'Around UCAD') ||
            (element.restaurantLocation == '' &&
                appStore.addressModel!.addressLocation == 'Around UCAD')) {
          totalAroundOrder += 1;
          appStore.setDeliveryFeeAvailable(true);
        } else {
          var resLatLng = await getLatLngFromLocationName(
              element.restaurantAddress.toString());
          print(resLatLng);
          if (resLatLng == LatLng(0, 0)) {
            print("error fetching latlng");
            toast("error getting restaurant location on google map");
            appStore.setDeliveryFeeAvailable(false);
          } else {
            appStore.setDeliveryFeeAvailable(true);
            var distance = calculateDistance(resLatLng, UCAD_LOCATION);
            appStore.setDistance(distance.toString());
            if (distance < 1) {
              deliveryFee += 1 * appStore.kmDeliveryCharge;
            } else {
              deliveryFee += distance * appStore.kmDeliveryCharge;
            }
            print(distance);
          }
        }
      }
    }

    if (totalQty <= 4 && totalQty > 0) {
      deliveryFee += 100;
    } else if (totalQty > 4 && totalQty < 25) {
      deliveryFee += totalQty * 25;
    } else if (totalQty > 25) {
      deliveryFee += 500;
    }
    if (totalAroundOrder > 0) {
      deliveryFee += appStore.constantDeliveryCharge;
    }

    appStore.setDeliveryCharge(deliveryFee);
    appStore.setIsCalculating(false);
    setState(() {});
  }

  @override
  void dispose() {
    setStatusBarColor(
      appStore.isDarkMode ? scaffoldColorDark : colorPrimary,
      statusBarIconBrightness:
          appStore.isDarkMode ? Brightness.light : Brightness.dark,
    );
    appStore.setContainNoPrice(false);
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
        bottomNavigationBar: Observer(builder: (context) {
          return MyOrderBottomWidget(
            containIsSuggestedPrice: appStore.containNoPrice,
            totalAmount: totalAmount,
            userLatitude: userLatitude,
            userLongitude: userLongitude,
            orderAddress: address,
            isOrder: true,
            deliveryFee: appStore.deliveryCharge,
            onPlaceOrder: () {
              setState(() {});
            },
          );
        }),
      ),
    );
  }
}
