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

class AddressListComponent extends StatefulWidget {
  static String tag = '/AddressListComponent';
  final UserModel userData;
  final bool isOrder;

  AddressListComponent({required this.userData, required this.isOrder});

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
    // Initialize any required data
  }

  Future<void> removeAddress(int index) async {
    appStore.setLoading(true);

    widget.userData.listOfAddress!.removeAt(index);
    widget.userData.updatedAt = DateTime.now();

    try {
      await userDBService.updateDocument(
          widget.userData.toJson(), appStore.userId);
      toast(appStore.translate('removed'));
    } catch (e) {
      toast(e.toString());
    } finally {
      appStore.setLoading(false);
      setState(() {});
    }
  }

  // Create a set to keep track of clicked items
  final Set<int> clickedItems = Set<int>();

  @override
  Widget build(BuildContext context) {
    if (widget.userData.listOfAddress.validate().isEmpty) {
      return Text(appStore.translate('no_address_found'),
              style: secondaryTextStyle())
          .center();
    }

    return ListView.builder(
      padding: EdgeInsets.all(8),
      itemBuilder: (_, index) {
        AddressModel addressModel = widget.userData.listOfAddress![index];

        // Determine if the item has been clicked
        final bool isClicked = clickedItems.contains(index);

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
              Text(
                addressModel.addressLocation.validate(),
                style: boldTextStyle(size: 14),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              4.height,
              Text(
                addressModel.addressLocation == 'Inside UCAD'
                    ? addressModel.pavilionNo.validate()
                    : addressModel.address.validate(),
                style: boldTextStyle(size: 14),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
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
        ).onTap(() async {
          if (widget.isOrder && !isClicked) {
            // Mark the item as clicked
            appStore.setContainNoPrice(false);

            clickedItems.add(index);
            appStore.mCartList.forEach((element) {
              if (element?.isSuggestedPrice == true ||
                  element?.itemPrice == null) {
                print("Price is not available");
                print(element?.itemPrice);
                appStore.setContainNoPrice(true);
              }
            });
            setState(() {});

            // Calculate delivery fee and wait for it to finish
            await calculateDeliveryFee(addressModel);

            // Finish after everything is done
            await Future.delayed(Duration(seconds: 1));

            finish(context, addressModel);
          }
        });
      },
      itemCount: widget.userData.listOfAddress.validate().length,
      shrinkWrap: true,
      physics: ClampingScrollPhysics(),
    );
  }

  Future<void> calculateDeliveryFee(AddressModel addressModel) async {
    appStore.setAddressModel(addressModel);
    appStore.setIsCalculating(true);
    deliveryFee = 0;
    appStore.setDeliveryCharge(deliveryFee);

    for (var element in appStore.mCartList) {
      if (element!.ownedByUs == true &&
          addressModel.addressLocation == 'Inside UCAD') {
        totalQty += 0;
      } else {
        if (addressModel.addressLocation == "Inside UCAD") {
          totalQty += element.qty!;
        } else {
          if (addressModel.address!.isNotEmpty) {
            LatLng userLocation =
                await getLatLngFromLocationName(addressModel.address!);
            double distance = calculateDistance(UCAD_LOCATION, userLocation);
            double charge = distance * AROUND_UCAD_CHARGES;
            deliveryFee += charge;
            print("Distance is $distance");
          } else {
            print("Restaurant name is empty");
          }
        }
      }
    }

    if (totalQty <= 4 && totalQty > 0) {
      deliveryFee += 100;
    } else if (totalQty > 4 && totalQty < 25) {
      deliveryFee += totalQty * 25;
    } else if (totalQty > 25) {
      deliveryFee += 500;
    }

    appStore.setDeliveryCharge(deliveryFee);
    appStore.setIsCalculating(false);
    setState(() {});
  }
}
