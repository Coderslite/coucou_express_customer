import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fooddelivery/components/RestaurantMenuTabWidget.dart';
import 'package:fooddelivery/components/RestaurantMenuTopWidget.dart';
import 'package:fooddelivery/components/ReviewTabComponent.dart';
import 'package:fooddelivery/models/RestaurantModel.dart';
import 'package:fooddelivery/utils/Colors.dart';
import 'package:fooddelivery/utils/Constants.dart';
import 'package:fooddelivery/utils/ModalKeys.dart';
import 'package:nb_utils/nb_utils.dart';

import '../main.dart';

// ignore: must_be_immutable
class RestaurantMenuScreen extends StatefulWidget {
  static String tag = '/RestaurantMenuScreen';

  RestaurantModel? restaurant;
  final String? restId;

  RestaurantMenuScreen({
    this.restaurant,
    this.restId,
  });

  @override
  RestaurantMenuScreenState createState() => RestaurantMenuScreenState();
}

class RestaurantMenuScreenState extends State<RestaurantMenuScreen>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    _tabController = TabController(length: 2, vsync: this);

    setStatusBarColor(appStore.isDarkMode ? scaffoldColorDark : colorPrimary,
        statusBarIconBrightness: Brightness.light);
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
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    setStatusBarColor(appStore.isDarkMode ? scaffoldColorDark : Colors.white);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: appBarWidget(
          widget.restaurant!.restaurantName.validate(),
          color: appStore.isDarkMode ? scaffoldColorDark : colorPrimary,
          textColor: whiteColor,
          actions: [
            IconButton(
              icon: Icon(
                  favRestaurantList.contains(widget.restaurant!.id.validate())
                      ? Icons.favorite
                      : Icons.favorite_border),
              onPressed: () => favRestaurant(),
            ),
          ],
        ),
        body: DefaultTabController(
          length: 2,
          child: NestedScrollView(
            headerSliverBuilder:
                (BuildContext context, bool innerBoxIsScrolled) {
              return [
                SliverAppBar(
                  expandedHeight: 240,
                  backgroundColor: Colors.white,
                  automaticallyImplyLeading: false,
                  bottom: TabBar(
                    controller: _tabController,
                    labelStyle: boldTextStyle(),
                    unselectedLabelStyle: primaryTextStyle(),
                    indicatorSize: TabBarIndicatorSize.tab,
                    labelPadding: EdgeInsets.all(8),
                    indicatorColor: colorPrimary,
                    unselectedLabelColor: grey,
                    tabs: <Widget>[
                      Text(appStore.translate('menu')),
                      Text(appStore.translate('review')),
                    ],
                  ),
                  flexibleSpace: FlexibleSpaceBar(
                    collapseMode: CollapseMode.parallax,
                    background: widget.restaurant != null
                        ? RestaurantMenuTopWidget(
                            restaurantData: widget.restaurant)
                        : SizedBox(),
                  ),
                ),
              ];
            },
            body: TabBarView(
              controller: _tabController,
              children: [
                RestaurantMenuTabWidget(restaurantData: widget.restaurant),
                ReviewTabComponent(restaurantData: widget.restaurant),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
