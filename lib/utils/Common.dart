import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../main.dart';
import 'Constants.dart';

Future<void> launchUrl(String url,
    {bool forceWebView = false, bool forceSafariVC = false}) async {
  log(url);
  await launch(url,
          forceWebView: forceWebView,
          enableJavaScript: true,
          forceSafariVC: forceSafariVC)
      .catchError((e) {
    log(e);
    toast('Invalid URL: $url');
  });
}

List<String> setSearchParam(String caseNumber) {
  List<String> caseSearchList = [];
  String temp = "";
  for (int i = 0; i < caseNumber.length; i++) {
    temp = temp + caseNumber[i];
    caseSearchList.add(temp.toLowerCase());
  }
  return caseSearchList;
}

Widget cachedImage(String? url,
    {double? height,
    double? width,
    BoxFit? fit,
    AlignmentGeometry? alignment,
    bool usePlaceholderIfUrlEmpty = true,
    double? radius}) {
  if (url.validate().isEmpty) {
    return placeHolderWidget(
        height: height,
        width: width,
        fit: fit,
        alignment: alignment,
        radius: radius);
  } else if (url.validate().startsWith('http')) {
    return CachedNetworkImage(
      imageUrl: url!,
      height: height,
      width: width,
      fit: fit,
      alignment: alignment as Alignment? ?? Alignment.center,
      errorWidget: (_, s, d) {
        return placeHolderWidget(
            height: height,
            width: width,
            fit: fit,
            alignment: alignment,
            radius: radius);
      },
      placeholder: (_, s) {
        if (!usePlaceholderIfUrlEmpty) return SizedBox();
        return placeHolderWidget(
            height: height,
            width: width,
            fit: fit,
            alignment: alignment,
            radius: radius);
      },
    );
  } else {
    return Image.asset(url!,
            height: height,
            width: width,
            fit: fit,
            alignment: alignment ?? Alignment.center)
        .cornerRadiusWithClipRRect(radius ?? defaultRadius);
  }
}

Widget placeHolderWidget(
    {double? height,
    double? width,
    BoxFit? fit,
    AlignmentGeometry? alignment,
    double? radius}) {
  return Image.asset('assets/placeholder.jpg',
          height: height,
          width: width,
          fit: fit ?? BoxFit.cover,
          alignment: alignment ?? Alignment.center)
      .cornerRadiusWithClipRRect(radius ?? defaultRadius);
}

bool isLoggedInWithGoogle() {
  return appStore.isLoggedIn && getStringAsync(LOGIN_TYPE) == LoginTypeGoogle;
}

bool isLoggedInWithApp() {
  return appStore.isLoggedIn && getStringAsync(LOGIN_TYPE) == LoginTypeApp;
}

bool isLoggedInWithOTP() {
  return appStore.isLoggedIn && getStringAsync(LOGIN_TYPE) == LoginTypeOTP;
}

String storeBaseURL() {
  return playStoreBaseURL;
}

List<String> lowRateTags() {
  List<String> list = [];
  list.add('tasteless food');
  list.add('food quantity');
  list.add('stale food');
  list.add('packaging issue');
  return list;
}

List<String> highRateTags() {
  List<String> list = [];
  list.add('delicious food');
  list.add('timely service');
  list.add('nice packaging');
  list.add('worth the money');
  return list;
}

List<String> lowDeliveryTags() {
  List<String> list = [];
  list.add('unclean packaging');
  list.add('bad quality food');
  list.add('value for money');
  list.add('bad delivery service');
  return list;
}

List<String> highDeliveryTags() {
  List<String> list = [];
  list.add('fresh food with good quality');
  list.add('spill proof packaging');
  list.add('timely service');
  return list;
}

Future<void> saveOneSignalPlayerId() async {
  await OneSignal.shared.getDeviceState().then((value) async {
    if (value!.userId.validate().isNotEmpty)
      await setValue(PLAYER_ID, value.userId.validate());
  });
}

String getOrderStatusText(String orderStatus) {
  if (orderStatus == ORDER_RECEIVED) {
    return appStore.translate('order_is_being_approved');
  } else if (orderStatus == ORDER_ACCEPTED) {
    return "A delivery boy is assigned";
  } else if (orderStatus == ORDER_PICKUP) {
    return appStore.translate('your_food_is_on_the_way');
  } else if (orderStatus == ORDER_DELIVERED) {
    return appStore.translate('order_is_delivered');
  } else if (orderStatus == ORDER_CANCELLED) {
    return appStore.translate('cancelled');
  }
  return orderStatus;
}

Color getOrderStatusColor(String? orderStatus) {
  if (orderStatus == ORDER_RECEIVED) {
    return Color(0xFF9A8500);
  } else if (orderStatus == ORDER_PENDING) {
    return Color(0xFF6A8500);
  } else if (orderStatus == ORDER_ACCEPTED) {
    return Colors.orangeAccent;
  } else if (orderStatus == ORDER_PICKUP) {
    return Colors.greenAccent;
  } else if (orderStatus == ORDER_DELIVERED) {
    return Colors.green;
  } else if (orderStatus == ORDER_CANCELLED) {
    return Colors.red;
  } else {
    return Colors.black;
  }
}

String getAmount(int data) {
  final numberFormat = NumberFormat.decimalPattern();
  // String data2 = "₹ " + data.toString() + " /-";
  var amount = numberFormat.format(data);
  String data2 = "\CFA " + amount.toString() + "";

  return data2;
}
