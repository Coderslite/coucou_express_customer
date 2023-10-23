import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:fooddelivery/main.dart';
import 'package:fooddelivery/models/RestaurantModel.dart';
import 'package:fooddelivery/utils/Common.dart';
import 'package:fooddelivery/utils/Widgets.dart';
import 'package:nb_utils/nb_utils.dart';

// ignore: must_be_immutable
class RestaurantMenuTopWidget extends StatefulWidget {
  static String tag = '/RestaurantMenuTopWidget';
  RestaurantModel? restaurantData;

  RestaurantMenuTopWidget({this.restaurantData});

  @override
  RestaurantMenuTopWidgetState createState() => RestaurantMenuTopWidgetState();
}

class RestaurantMenuTopWidgetState extends State<RestaurantMenuTopWidget> {
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
    return Stack(
      children: [
        cachedImage(widget.restaurantData!.photoUrl, width: context.width(), fit: BoxFit.cover, height: 200),
        Container(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0, tileMode: TileMode.mirror),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: [
                        Text(widget.restaurantData!.restaurantName.toString(), style: boldTextStyle(size: 18, color: Colors.white)).expand(),
                        8.width,
                        Row(
                          children: [
                            vegNonVegIcon(color: Colors.green).visible(widget.restaurantData!.isVegRestaurant.validate()),
                            4.width,
                            vegNonVegIcon(color: Colors.red).visible(widget.restaurantData!.isNonVegRestaurant.validate()),
                          ],
                        ),
                      ],
                    ).paddingOnly(left: 16, right: 16, top: 16),
                    4.height,
                    Text(
                      widget.restaurantData!.restaurantAddress.validate(),
                      style: primaryTextStyle(size: 12, color: Colors.white),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ).paddingOnly(left: 16, right: 16),
                    4.height,
                    Row(
                      children: [
                        Text('${appStore.translate('open_hours')}: ', style: secondaryTextStyle(size: 12, color: Colors.white)),
                        Text(
                          '${widget.restaurantData!.openTime.validate()} - ${widget.restaurantData!.closeTime.validate()}',
                          style: primaryTextStyle(size: 12, color: Colors.white),
                        ),
                      ],
                    ).paddingOnly(left: 16, right: 16),
                    4.height,
                    Text(
                      widget.restaurantData!.restaurantDescription.validate(),
                      style: secondaryTextStyle(size: 12, color: Colors.white),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ).paddingOnly(left: 16, right: 16),
                  ],
                ).expand(),
                cachedImage(widget.restaurantData!.photoUrl.validate(), fit: BoxFit.cover, height: 100, width: 100).cornerRadiusWithClipRRect(8).paddingRight(16).paddingTop(16),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
