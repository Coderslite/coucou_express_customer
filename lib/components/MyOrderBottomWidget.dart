import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:fooddelivery/components/pament_method.dart';
import 'package:fooddelivery/models/AddressModel.dart';
import 'package:fooddelivery/models/OrderItemData.dart';
import 'package:fooddelivery/models/OrderModel.dart';
import 'package:fooddelivery/screens/MyAddressScreen.dart';
import 'package:fooddelivery/utils/Colors.dart';
import 'package:fooddelivery/utils/Common.dart';
import 'package:fooddelivery/utils/Constants.dart';
import 'package:nb_utils/nb_utils.dart';

import '../function/available_drivers.dart';
import '../function/send_notification.dart';
import '../main.dart';
import 'OrderSuccessFullyDialog.dart';

// ignore: must_be_immutable
class MyOrderBottomWidget extends StatefulWidget {
  static String tag = '/MyOrderBottomWidget';
  int? totalAmount;
  bool? isOrder;
  double? userLatitude;
  double? userLongitude;
  String? orderAddress;
  Function? onPlaceOrder;
  double deliveryFee;
  bool containIsSuggestedPrice;

  MyOrderBottomWidget({
    this.totalAmount,
    this.userLatitude,
    this.userLongitude,
    this.orderAddress,
    this.isOrder,
    this.onPlaceOrder,
    required this.deliveryFee,
    required this.containIsSuggestedPrice,
  });

  @override
  MyOrderBottomWidgetState createState() => MyOrderBottomWidgetState();
}

class MyOrderBottomWidgetState extends State<MyOrderBottomWidget> {
  String? restaurantName = '';
  String? restaurantId = '';
  String? deliveryLocation = '';
  String? deliveryAddress = '';
  String? pavilionNo = '';
  String? addressDes = '';
  String? otherItemInformation = '';
  @override
  void initState() {
    super.initState();
    init();
  }

  @override
  void dispose() {
    appStore.setPaymentMethod("");
    super.dispose();
  }

  Future<void> init() async {
    //
  }

  Future<void> order() async {
    if (appStore.addressModel!.addressLocation == null) {
      toast(appStore.translate('select_address'));
      await Future.delayed(Duration(milliseconds: 100));

      AddressModel? data =
          await MyAddressScreen(isOrder: widget.isOrder).launch(context);
      if (data!.addressLocation != null && data is AddressModel) {
        appStore.setAddressModel(data);
        setState(() {});
      }
    } else {
      var id = DateTime.now().millisecondsSinceEpoch;

      List<OrderItemData> items = [];
      appStore.mCartList.forEach((element) {
        restaurantName = element!.restaurantName!;
        restaurantId = element.restaurantId;
        otherItemInformation = element.otherInformation;
        deliveryLocation = appStore.addressModel!.addressLocation;
        deliveryAddress = appStore.addressModel!.address;
        pavilionNo = appStore.addressModel!.pavilionNo;
        addressDes = appStore.addressModel!.otherDetails;
        print("delivery Location $deliveryLocation");
        print("delivery Address $deliveryAddress");

        items.add(
          OrderItemData(
            image: element.image,
            itemName: element.itemName,
            qty: element.qty,
            id: element.id,
            categoryId: element.categoryId,
            categoryName: element.categoryName,
            itemPrice: element.itemPrice,
            isSuggestedPrice: element.isSuggestedPrice,
            // restaurantId: element.restaurantId,
            // restaurantName: element.restaurantName,
          ),
        );
      });

      // if (restaurantId!.isEmpty) return toast(errorMessage);

      OrderModel orderModel = OrderModel();

      orderModel.userId = appStore.userId;
      orderModel.orderStatus = ORDER_RECEIVED;
      orderModel.createdAt = DateTime.now();
      orderModel.updatedAt = DateTime.now();
      orderModel.totalAmount = widget.totalAmount;
      orderModel.totalItem = appStore.mCartList.length;
      orderModel.orderId = id.toString();
      orderModel.listOfOrder = items;
      orderModel.restaurantName = restaurantName;
      orderModel.restaurantId = restaurantId;
      orderModel.deliveryLocation = deliveryLocation;
      orderModel.deliveryAddress = deliveryAddress;
      orderModel.pavilionNo = pavilionNo;
      orderModel.userAddress = appStore.addressModel!.address;
      orderModel.paymentMethod = appStore.paymentMethod;
      orderModel.deliveryCharge = appStore.deliveryCharge.toInt();
      orderModel.restaurantCity = getStringAsync(USER_CITY_NAME);
      orderModel.paymentStatus = PAYMENT_STATUS_PENDING;
      orderModel.orderType = "TextOrder";
      // orderModel.userLocation = GeoPoint(
      //     appStore.addressModel!.userLocation!.latitude,
      //     appStore.addressModel!.userLocation!.longitude);
      orderModel.otherInformation = otherItemInformation;
      orderModel.deliveryAddressDescription = addressDes;
      myOrderDBService.addDocument(orderModel.toJson()).then((value) async {
        await Future.forEach(appStore.mCartList, (dynamic element) async {
          // SendNotification.handleSentToAgent(value.id);
          await myCartDBService.removeDocument(element.id);
        });
        appStore.clearCart();
        widget.totalAmount = 0;
        availableDrivers(value.id);
        widget.onPlaceOrder?.call();

        showInDialog(
          context,
          child: OrderSuccessFullyDialog(
            orderId: value.id,
          ),
          contentPadding: EdgeInsets.all(0),
          shape: RoundedRectangleBorder(borderRadius: radius(12)),
        );
      }).catchError((e) {
        log(e);
      });
    }
  }

  void address() async {
    toast(appStore.translate('hint_select_address'));
    await Future.delayed(Duration(milliseconds: 100));

    AddressModel? data =
        await MyAddressScreen(isOrder: widget.isOrder).launch(context);
    if (data != null) {
      appStore.setAddressModel(data);
      setState(() {});
    }
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: boxDecorationWithRoundedCorners(
        backgroundColor: appStore.isDarkMode ? context.cardColor : colorPrimary,
        borderRadius: radiusOnly(topRight: 16, topLeft: 16),
      ),
      padding: EdgeInsets.all(16),
      child: Observer(builder: (context) {
        return appStore.addressModel == null
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("Please select address"),
                ],
              )
            : appStore.addressModel!.addressLocation == null
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text("Please select address"),
                    ],
                  )
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      widget.containIsSuggestedPrice
                          ? appStore.isCalculating
                              ? Text("Loading")
                              : Column(
                                  children: [
                                    Text(
                                      "please note that price may vary",
                                      style: boldTextStyle(
                                        size: 15,
                                      ),
                                    ),
                                    Divider(
                                      height: 2,
                                    ),
                                    10.height,
                                  ],
                                )
                          : Container(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(appStore.translate('total_item'),
                              style: secondaryTextStyle(
                                  color: Colors.white, size: 14)),
                          Observer(
                              builder: (_) => Text(
                                  appStore.mCartList.length.toString(),
                                  style: boldTextStyle(color: Colors.white))),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(appStore.translate('delivery_charges'),
                              style: secondaryTextStyle(color: Colors.white)),
                          Observer(
                            builder: (_) => appStore.isCalculating == true
                                ? Text("Loading")
                                : Text(
                                    getAmount(appStore.deliveryCharge.toInt()),
                                    style: boldTextStyle(color: Colors.white)),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            appStore.translate('total').toUpperCase(),
                            style: primaryTextStyle(color: Colors.white),
                          ),
                          Observer(
                              builder: (_) => appStore.isCalculating == true
                                  ? Text("Loading")
                                  : Text(
                                      widget.totalAmount != null &&
                                              widget.totalAmount != 0
                                          ? getAmount(
                                              widget.totalAmount!.toInt() +
                                                  appStore.deliveryCharge
                                                      .toInt()
                                                      .validate())
                                          : 'Not Available',
                                      style: boldTextStyle(
                                          color: widget.totalAmount != null &&
                                                  widget.totalAmount != 0
                                              ? context.iconColor
                                              : orangeRed,
                                          size: 20))),
                        ],
                      ),
                      30.height,
                      Observer(
                        builder: (_) => AppButton(
                          width: context.width(),
                          shapeBorder: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(30))),
                          child: appStore.isCalculating
                              ? CircularProgressIndicator(
                                  backgroundColor: colorPrimary,
                                )
                              : Text(appStore.translate('place_order'),
                                  style: boldTextStyle(
                                      color: appStore.isDarkMode
                                          ? white
                                          : colorPrimary)),
                          color:
                              appStore.isDarkMode ? colorPrimary : Colors.white,
                          onTap: () async {
                            if (appStore.addressModel == null) {
                              address();
                            } else {
                              appStore.isCalculating
                                  ? null
                                  : showInDialog(context,
                                      child: PaymentMethod(
                                        amount: widget.totalAmount!,
                                        order: order,
                                      ));
                            }
                          },
                        ),
                      )
                    ],
                  );
      }),
    );
  }
}
