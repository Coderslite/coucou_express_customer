import 'package:flutter/material.dart';
import 'package:fooddelivery/main.dart';
import 'package:fooddelivery/models/AddressModel.dart';
import 'package:fooddelivery/models/UserModel.dart';
import 'package:fooddelivery/utils/Colors.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:nb_utils/nb_utils.dart';

import '../services/CalculateDistance.dart';
import '../services/GetLocationLatLng.dart';
import '../utils/Constants.dart';

// ignore: must_be_immutable
class AddressListComponent extends StatefulWidget {
  static String tag = '/AddressListComponent';
  UserModel? userData;
  bool? isOrder;

  AddressListComponent({this.userData, this.isOrder});

  @override
  AddressListComponentState createState() => AddressListComponentState();
}

class AddressListComponentState extends State<AddressListComponent> {
  double deliveryFee = 0;
  int totalQty = 0;
  int totalAroundOrder = 0;

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    //
  }

  Future removeAddress(int index) async {
    appStore.setLoading(true);

    widget.userData!.listOfAddress!.removeAt(index);
    widget.userData!.updatedAt = DateTime.now();

    await userDBService
        .updateDocument(widget.userData!.toJson(), appStore.userId)
        .then((value) {
      toast(appStore.translate('removed'));

      appStore.setLoading(false);
    }).catchError((e) {
      appStore.setLoading(false);
      toast(e.toString());
    });
    setState(() {});
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.userData!.listOfAddress.validate().isEmpty)
      return Text(appStore.translate('no_address_found'),
              style: secondaryTextStyle())
          .center();

    return ListView.builder(
      padding: EdgeInsets.all(8),
      itemBuilder: (_, index) {
        AddressModel addressModel = widget.userData!.listOfAddress![index];

        return Container(
          margin: EdgeInsets.all(8),
          padding: EdgeInsets.all(8),
          decoration: boxDecorationWithShadow(
            borderRadius: radius(12),
            boxShadow: defaultBoxShadow(),
            backgroundColor:
                appStore.isDarkMode ? scaffoldSecondaryDark : Colors.white,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(addressModel.addressLocation.validate(),
                  style: boldTextStyle(size: 14),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis),
              4.height,
              Text(
                  addressModel.addressLocation == 'Inside UCAD'
                      ? addressModel.pavilionNo.validate()
                      : addressModel.address.validate(),
                  style: boldTextStyle(size: 14),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis),
              4.height,
              Text(addressModel.otherDetails.validate(),
                  style: secondaryTextStyle()),
              8.height,
              Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(Icons.delete, color: colorPrimary).onTap(() {
                    showConfirmDialog(context,
                            appStore.translate('delete_address_confirmation'))
                        .then((value) {
                      if (value ?? false) {
                        removeAddress(index);
                      }
                    });
                  }),
                ],
              )
            ],
          ),
        ).onTap(() {
          if (widget.isOrder.validate()) {
            appStore.setAddressModel(addressModel);
            appStore.setIsCalculating(true);
            deliveryFee = 0;
            appStore.setDeliveryCharge(deliveryFee);
            appStore.mCartList.forEach((element) async {
              if (addressModel.addressLocation == "Inside UCAD") {
                totalQty += element!.qty!;
                print("within UCAD");
              } else {
                if (addressModel.address!.isNotEmpty) {
                  LatLng userLocation =
                      await getLatLngFromLocationName(addressModel.address!);
                  double roundedValue = double.parse(
                      calculateDistance(UCAD_LOCATION, userLocation)
                          .toStringAsFixed(2));
                  var charge = roundedValue * AROUND_UCAD_CHARGES;
                  deliveryFee = deliveryFee + charge;
                  appStore.setDeliveryCharge(deliveryFee);
                  print("distance is $roundedValue");
                } else {
                  print("restaurant name is empty");
                }
              }
            });

            if (totalQty <= 4 && totalQty > 0) {
              deliveryFee += 100;
            } else if (totalQty > 4 && totalQty < 25) {
              deliveryFee += totalQty * 25;
            } else if (totalQty > 25) {
              deliveryFee += 500;
            }

            setState(() {
              appStore.setIsCalculating(false);
              appStore.setDeliveryCharge(deliveryFee);
            });
            finish(
              context,
              addressModel,
            );
          }
        });
      },
      itemCount: widget.userData!.listOfAddress.validate().length,
      shrinkWrap: true,
      physics: ClampingScrollPhysics(),
    );
  }
}
