import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fooddelivery/components/DeliveryBoyReviewDialog.dart';
import 'package:fooddelivery/main.dart';
import 'package:fooddelivery/models/OrderModel.dart';
import 'package:fooddelivery/services/DeliveryBoyReviewDBService.dart';
import 'package:fooddelivery/utils/Colors.dart';
import 'package:fooddelivery/utils/Common.dart';
import 'package:fooddelivery/utils/Constants.dart';
import 'package:fooddelivery/utils/Images.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:nb_utils/nb_utils.dart';

// ignore: must_be_immutable
class OrderTrackingScreen extends StatefulWidget {
  static String tag = '/OrderTrackingScreen';

  OrderModel? orderData;

  OrderTrackingScreen({this.orderData});

  @override
  OrderTrackingScreenState createState() => OrderTrackingScreenState();
}

Map<MarkerId, Marker> markers = {};
bool bToggle = true;

class OrderTrackingScreenState extends State<OrderTrackingScreen> {
  Completer<GoogleMapController> _controller = Completer();

  Map<MarkerId, Marker> markers = {};
  bool bToggle = true;
  bool isReview = false;

  LatLng deliveryBoyLocation = LatLng(0.0, 0.0);

  late BitmapDescriptor pinLocationIcon;
  Set<Marker> _markers = {};

  String? deliveryBoyId = '';
  String? deliveryBoyName = '';
  String? deliveryBoyContactNumber = '';

  late DeliveryBoyReviewsDBService deliveryBoyReviewsDBService;

  @override
  void initState() {
    super.initState();
    deliveryBoyReviewsDBService = DeliveryBoyReviewsDBService();
    init();
  }

  Future<void> init() async {
    setStatusBarColor(
      appStore.isDarkMode ? scaffoldColorDark : colorPrimary,
      statusBarIconBrightness:
          appStore.isDarkMode ? Brightness.light : Brightness.dark,
    );

    /* deliveryBoyReviewsDBService.deliveryBoyReviews(orderID: widget.orderData!.id).then((event) {
      log("event here1:$event");
      */ /* if (!event) {
        isReview = true;
      }
      setState(() {});*/ /*
    });*/

    myOrderDBService.orderById(id: widget.orderData!.id).listen((event) async {
      widget.orderData = event;
      deliveryBoyId = widget.orderData!.deliveryBoyId;
      deliveryBoyLocation = LatLng(1.22, 2.33);
      _markers.clear();
      _markers.add(Marker(
        markerId: MarkerId('Order Tracking'),
        position: deliveryBoyLocation,
        icon: pinLocationIcon,
      ));
      changeLocation();
      if (deliveryBoyName!.isEmpty) {
        await userDBService.getUserById(deliveryBoyId).then((value) {
          deliveryBoyName = value.name;
          deliveryBoyContactNumber = value.number;
        }).catchError((e) {
          toast(e.toString());
        });
      }

      if (widget.orderData!.orderStatus == ORDER_COMPLETE) {
        await showInDialog(
          context,
          barrierDismissible: true,
          child: DeliveryBoyReviewDialog(order: widget.orderData),
          contentPadding: EdgeInsets.all(0),
          shape: RoundedRectangleBorder(borderRadius: radius(16)),
        );
      }
      setState(() {});
    });

    setCustomMapPin();
  }

  void setCustomMapPin() async {
    BitmapDescriptor.fromAssetImage(ImageConfiguration(), delivery_boy)
        .then((onValue) {
      pinLocationIcon = onValue;
    });
  }

  Future<void> changeLocation() async {
    CameraPosition _kDeliveryBoyLocation =
        CameraPosition(target: deliveryBoyLocation, zoom: 19);

    final GoogleMapController controller = await _controller.future;
    controller
        .animateCamera(CameraUpdate.newCameraPosition(_kDeliveryBoyLocation));
  }

  @override
  void dispose() {
    setStatusBarColor(
      appStore.isDarkMode ? scaffoldColorDark : colorPrimary,
      statusBarIconBrightness:
          appStore.isDarkMode ? Brightness.light : Brightness.dark,
    );
    _controller.future.then((value) {
      value.dispose();
    });
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
        appBar: appBarWidget('#${widget.orderData!.orderId}',
            color: context.cardColor),
        backgroundColor: appStore.isDarkMode ? scaffoldColorDark : colorPrimary,
        body: Stack(
          children: [
            GoogleMap(
              myLocationEnabled: true,
              compassEnabled: true,
              zoomControlsEnabled: true,
              markers: _markers,
              initialCameraPosition:
                  CameraPosition(target: LatLng(1.33, 0.44), zoom: 19),
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
              },
            ),
            Positioned(
              bottom: 0,
              child: Container(
                width: context.width(),
                alignment: Alignment.topLeft,
                color: context.scaffoldBackgroundColor,
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding:
                          EdgeInsets.only(left: 8, right: 8, top: 4, bottom: 4),
                      decoration: boxDecorationWithRoundedCorners(
                        borderRadius: radius(8),
                        backgroundColor:
                            getOrderStatusColor(widget.orderData!.orderStatus)
                                .withOpacity(0.05),
                      ),
                      child: Text(
                        getOrderStatusText(
                            widget.orderData!.orderStatus.validate()),
                        style: boldTextStyle(
                            color: getOrderStatusColor(
                                widget.orderData!.orderStatus),
                            size: 12),
                      ),
                    ),
                    4.height,
                    Text(
                        '${appStore.translate('delivery_boy')}: ${deliveryBoyName.validate()}',
                        style: secondaryTextStyle()),
                    4.height,
                    Row(
                      children: [
                        Icon(Icons.phone, color: colorPrimary),
                        8.width,
                        Text('${deliveryBoyContactNumber.validate()}',
                            style: secondaryTextStyle()),
                      ],
                    ).onTap(() {
                      launchUrl(
                          "tel:+91${deliveryBoyContactNumber.validate()}");
                    }),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
