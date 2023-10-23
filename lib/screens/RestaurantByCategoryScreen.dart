import 'package:flutter/material.dart';
import 'package:fooddelivery/components/RestaurantItemComponent.dart';
import 'package:fooddelivery/main.dart';
import 'package:fooddelivery/models/RestaurantModel.dart';
import 'package:fooddelivery/utils/Colors.dart';
import 'package:fooddelivery/utils/Constants.dart';
import 'package:fooddelivery/utils/Widgets.dart';
import 'package:nb_utils/nb_utils.dart';

class RestaurantByCategoryScreen extends StatefulWidget {
  static String tag = '/RestaurantByCategoryScreen';
  final String? catName;

  RestaurantByCategoryScreen({this.catName});

  @override
  RestaurantByCategoryScreenState createState() =>
      RestaurantByCategoryScreenState();
}

class RestaurantByCategoryScreenState
    extends State<RestaurantByCategoryScreen> {
  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    setStatusBarColor(
      appStore.isDarkMode ? scaffoldColorDark : white,
      statusBarIconBrightness:
          appStore.isDarkMode ? Brightness.light : Brightness.dark,
    );
  }

  @override
  void dispose() {
    setStatusBarColor(
      appStore.isDarkMode ? scaffoldColorDark : white,
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
        appBar: appBarWidget(
            '${widget.catName.validate()} ${appStore.translate('restaurant')}',
            color: context.cardColor),
        body: StreamBuilder<List<RestaurantModel>>(
            stream: restaurantDBService.restaurantByCategory(widget.catName,
                cityName: getStringAsync(USER_CITY_NAME)),
            builder: (context, snapshot) {
              if (snapshot.hasError)
                return Text(snapshot.error.toString()).center();
              if (snapshot.hasData) {
                if (snapshot.data!.isEmpty) {
                  return noDataWidget(
                      errorMessage: appStore.translate('noRestaurantFound'));
                } else {
                  return ListView.builder(
                    itemBuilder: (context, index) {
                      return RestaurantItemComponent(
                        restaurant: snapshot.data![index],
                      );
                    },
                    padding: EdgeInsets.all(8),
                    itemCount: snapshot.data!.length,
                    physics: ClampingScrollPhysics(),
                    shrinkWrap: true,
                  );
                }
              }
              return Loader().center();
            }),
      ),
    );
  }
}
