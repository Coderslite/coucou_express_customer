import 'package:flutter/material.dart';
import 'package:fooddelivery/components/RestaurantItemComponent.dart';
import 'package:fooddelivery/models/RestaurantModel.dart';
import 'package:fooddelivery/utils/Constants.dart';
import 'package:fooddelivery/utils/Widgets.dart';
import 'package:nb_utils/nb_utils.dart';

import '../main.dart';

class FavouriteRestaurantListScreen extends StatefulWidget {
  static String tag = '/FavouriteRestaurantListScreen';

  @override
  FavouriteRestaurantListScreenState createState() =>
      FavouriteRestaurantListScreenState();
}

class FavouriteRestaurantListScreenState
    extends State<FavouriteRestaurantListScreen> {
  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    //
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            appBar: appBarWidget(appStore.translate('fav_restaurant'),
                color: context.cardColor),
            body: favRestaurantList.isEmpty
                ? Text("No favourited restaurants yet").center()
                : ListView.builder(
                    padding: EdgeInsets.all(8),
                    physics: ClampingScrollPhysics(),
                    itemBuilder: (_, index) {
                      var resId = favRestaurantList[index];
                      print(resId);
                      return FutureBuilder<RestaurantModel>(
                          future: restaurantDBService.getRestaurantById(resId),
                          builder: (context, snapshot) {
                            if (snapshot.hasError) {
                              return Text("something went wrong").center();
                            }
                            return RestaurantItemComponent(
                              restaurant: snapshot.data!,
                            );
                          });
                    },
                    itemCount: favRestaurantList.length,
                    shrinkWrap: true,
                  )));
  }
}
