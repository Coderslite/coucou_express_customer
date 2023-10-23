import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fooddelivery/main.dart';
import 'package:fooddelivery/models/RestaurantModel.dart';
import 'package:fooddelivery/screens/RestaurantMenuScreen.dart';
import 'package:fooddelivery/services/RestaurantReviewDBService.dart';
import 'package:fooddelivery/utils/Colors.dart';
import 'package:fooddelivery/utils/Common.dart';
import 'package:nb_utils/nb_utils.dart';

import '../models/AddressModel.dart';
import '../screens/MyAddressScreen.dart';
import '../utils/Constants.dart';
import '../utils/ModalKeys.dart';
import '../utils/rating.dart';

class RestaurantItemComponent extends StatefulWidget {
  final RestaurantModel? restaurant;
  final String? tag;

  RestaurantItemComponent({
    this.restaurant,
    this.tag,
  });

  @override
  RestaurantItemComponentState createState() => RestaurantItemComponentState();
}

class RestaurantItemComponentState extends State<RestaurantItemComponent> {
  RestaurantReviewsDBService? restaurantReviewsDBService;

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    await 1.microseconds.delay;

    restaurantReviewsDBService =
        RestaurantReviewsDBService(widget.restaurant!.id);
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  Future<void> addToFavRestaurant() async {
    favRestaurantList.add(widget.restaurant!.id);

    await userDBService.updateDocument({
      UserKeys.favRestaurant: favRestaurantList,
      CommonKeys.updatedAt: DateTime.now(),
    }, appStore.userId).then((value) {
      //
    }).catchError((e) {
      setState(() {});
    });
  }

  Future<void> removeToRestaurant() async {
    favRestaurantList.remove(widget.restaurant!.id);

    await userDBService.updateDocument({
      UserKeys.favRestaurant: favRestaurantList,
      CommonKeys.updatedAt: DateTime.now(),
    }, appStore.userId).then((value) {
      //
    }).catchError((e) {
      favRestaurantList.add(widget.restaurant!.id);
      setState(() {});
    });
  }

  Future<void> favRestaurant() async {
    if (appStore.isLoggedIn) {
      if (favRestaurantList.contains(widget.restaurant!.id)) {
        await removeToRestaurant();
      } else {
        await addToFavRestaurant();
      }
      await setValue(FAVORITE_RESTAURANT, jsonEncode(favRestaurantList));

      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(8),
      width: context.width(),
      decoration: boxDecorationWithRoundedCorners(
        backgroundColor: context.scaffoldBackgroundColor,
        boxShadow: defaultBoxShadow(spreadRadius: 0.0, blurRadius: 0.0),
        border: Border.all(color: context.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            alignment: Alignment.bottomLeft,
            children: [
              cachedImage(
                widget.restaurant!.photoUrl.validate(),
                height: 180,
                width: context.width(),
                fit: BoxFit.cover,
              ).cornerRadiusWithClipRRectOnly(topLeft: 8, topRight: 8),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "${widget.restaurant!.restaurantName.validate()}",
                style: primaryTextStyle(),
              ),
              IconButton(
                icon: Icon(
                    favRestaurantList.contains(widget.restaurant!.id.validate())
                        ? Icons.favorite
                        : Icons.favorite_border),
                onPressed: () => favRestaurant(),
              ),
            ],
          ).paddingOnly(left: 10, right: 10),
          appStore.addressModel == null
              ? Text(
                  "",
                  style: secondaryTextStyle(),
                ).paddingOnly(left: 10, right: 10).onTap(() async {
                  AddressModel? data =
                      await MyAddressScreen(isOrder: true).launch(context);
                  if (data != null) {
                    appStore.setAddressModel(data);
                  }
                  setState(() {});
                })
              : Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      "${appStore.distance} km",
                      style: secondaryTextStyle(),
                    ),
                    10.width,
                    Text(
                      "${appStore.time} mins",
                      style: secondaryTextStyle(),
                    ),
                    10.width,
                    Text(
                      "CFA ${widget.restaurant!.restaurantDeliveryFees.validate()} delivery fees",
                      style: secondaryTextStyle(),
                    ),
                  ],
                ).paddingOnly(left: 10, right: 10),
          StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection("restaurantReviews")
                  .where('restaurantId', isEqualTo: widget.restaurant!.id)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Text("");
                } else if (snapshot.hasData) {
                  if (snapshot.data!.docs.isEmpty) {
                    return Text("");
                  } else {
                    var data = snapshot.data!.docs;
                    var num = data.length;
                    var totalReview = 0;
                    for (int x = 0; x < num; x++) {
                      totalReview +=
                          int.parse(data[x].data()['rating'].toString());
                    }
                    var avg = totalReview / num;
                    return Row(
                      children: [
                        RatingStars(
                          averageRating: avg,
                          size: 13,
                          color: orange,
                        ),
                        5.width,
                        Text(
                          "(${num > 1 ? '$num Reviews' : '$num Review'})",
                          style: primaryTextStyle(size: 13),
                        ),
                      ],
                    );
                  }
                } else {
                  return Text("");
                }
              }).paddingOnly(left: 10, right: 10, bottom: 10),
        ],
      ),
    ).onTap(() {
      hideKeyboard(context);
      RestaurantMenuScreen(
        restaurant: widget.restaurant,
      ).launch(context);
    },
        highlightColor:
            appStore.isDarkMode ? scaffoldColorDark : context.cardColor);
  }
}
