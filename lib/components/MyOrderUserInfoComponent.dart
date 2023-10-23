import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:fooddelivery/main.dart';
import 'package:fooddelivery/models/AddressModel.dart';
import 'package:fooddelivery/screens/MyAddressScreen.dart';
import 'package:fooddelivery/utils/Colors.dart';
import 'package:nb_utils/nb_utils.dart';

// ignore: must_be_immutable
class MyOrderUserInfoComponent extends StatefulWidget {
  static String tag = '/MyOrderUserInfoComponent';

  bool? isOrder;

  MyOrderUserInfoComponent({this.isOrder});

  @override
  MyOrderUserInfoComponentState createState() =>
      MyOrderUserInfoComponentState();
}

class MyOrderUserInfoComponentState extends State<MyOrderUserInfoComponent> {
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
  void didUpdateWidget(covariant MyOrderUserInfoComponent oldWidget) {
    setState(() {});
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(appStore.translate('deliver_to'),
                    style: primaryTextStyle()),
                8.width,
                Text(appStore.userFullName.validate(),
                        style: boldTextStyle(),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis)
                    .expand(),
              ],
            ),
            Observer(
              builder: (_) => Text(
                appStore.addressModel!.addressLocation != null
                    ? appStore.addressModel!.addressLocation == "Inside UCAD"
                        ? appStore.addressModel!.pavilionNo.validate()
                        : appStore.addressModel!.address.validate()
                    : appStore.translate('select_shipping_address'),
                style: secondaryTextStyle(),
                maxLines: 2,
              ),
            ),
          ],
        ).expand(),
        4.width,
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: viewLineColor)),
          child: Text(
            appStore.addressModel!.addressLocation == null
                ? appStore.translate('select_address')
                : appStore.translate('change_address'),
            style: secondaryTextStyle(color: colorPrimary),
          ),
        ).onTap(() async {
          AddressModel? data =
              await MyAddressScreen(isOrder: widget.isOrder).launch(context);
          if (data != null) {
            appStore.setAddressModel(data);
          }
          setState(() {});
        }),
      ],
    ).paddingOnly(left: 16, right: 16, top: 16);
  }
}
