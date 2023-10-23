// ignore_for_file: implementation_imports

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:fooddelivery/models/MenuModel.dart';
import 'package:fooddelivery/screens/MyOrderScreen.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:nb_utils/nb_utils.dart';

import '../main.dart';
import '../services/GetRestaurantLocation.dart';
import 'package:google_maps_webservice/src/places.dart';

class RequestOrder extends StatefulWidget {
  final bool isGrocery;
  const RequestOrder({super.key, required this.isGrocery});

  @override
  State<RequestOrder> createState() => _RequestOrderState();
}

class ItemModel {
  TextEditingController? textEditingController;
  int? qty;

  ItemModel({
    this.qty,
    this.textEditingController,
  });
}

class _RequestOrderState extends State<RequestOrder> {
  final TextEditingController otherController = TextEditingController();
  String qty = '0';
  bool accepted = false;
  bool isLoading = true;
  String restaurantName = '';
  LatLng? location;
  String city = '';
  List<ItemModel> items = [];

  void getUserLocation() async {
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    double latitude = position.latitude;
    double longitude = position.longitude;
    location = LatLng(latitude, longitude);
    // isLocationInCity(latitude, longitude, 'Thiès');
    city = await getUserCity(latitude, longitude);
    print(city);
    isLoading = false;
    setState(() {});
  }

  Future<bool> isLocationInCity(
      double latitude, double longitude, String cityName) async {
    // Use reverse geocoding to get the address information for the provided coordinates
    List<Placemark> placemarks =
        await placemarkFromCoordinates(latitude, longitude);

    // Iterate through the list of placemarks and check if any matches the specified city or region
    for (Placemark placemark in placemarks) {
      if (placemark.locality == cityName || placemark.locality == cityName) {
        print("Within City");
        return true; // Location is within the city or region
      }
    }
    print("Not within");
    return false; // Location is not within the city or region
  }

  Future<String> getUserCity(double latitude, double longitude) async {
    try {
      // Use reverse geocoding to get the address information for the provided coordinates
      List<Placemark> placemarks =
          await placemarkFromCoordinates(latitude, longitude);

      // Extract the city name from the obtained placemarks
      if (placemarks.isNotEmpty) {
        String cityName = placemarks[0].locality ?? '';
        return cityName;
      } else {
        return 'Unknown';
      }
    } catch (e) {
      print('Error: $e');
      return 'Unknown';
    }
  }

  var _formKey = GlobalKey<FormState>();
  @override
  void initState() {
    items
        .add(ItemModel(qty: 1, textEditingController: TextEditingController()));
    getUserLocation();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget(
        widget.isGrocery ? 'Yonnima' : 'Request Order',
        color: context.cardColor,
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: mediumSeaGreen),
            onPressed: () {
              setState(() {
                items.add(ItemModel(
                    qty: 1, textEditingController: TextEditingController()));
              });
            },
            child: Text(
              "Add More",
              style: primaryTextStyle(),
            ),
          ),
        ],
      ),
      body: isLoading
          ? CircularProgressIndicator(
              backgroundColor: seaGreen,
            ).center()
          : SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      10.height,
                      city != 'Dakar' && city != 'Thies'
                          ? Text(
                              "Orders are not accepted in $city",
                              style: primaryTextStyle(color: redColor),
                            )
                          : Container(),
                      10.height,
                      Text("Please write want you would want to get",
                          style: boldTextStyle(size: 14)),
                      4.height,
                      SizedBox(
                        height: items.length * 88,
                        width: MediaQuery.of(context).size.width,
                        child: ListView.builder(
                            itemCount: items.length,
                            physics: NeverScrollableScrollPhysics(),
                            itemBuilder: (context, index) {
                              return Padding(
                                padding:
                                    const EdgeInsets.only(top: 8, bottom: 8),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Item Name",
                                      style: boldTextStyle(),
                                      textAlign: TextAlign.start,
                                    ),
                                    Row(
                                      children: [
                                        Expanded(
                                            child: TextFormField(
                                          controller: items[index]
                                              .textEditingController,
                                          style: primaryTextStyle(),
                                          decoration: InputDecoration(
                                            // hintText: "Item Name",
                                            hintStyle: secondaryTextStyle(),
                                            border: OutlineInputBorder(),
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                                    vertical: 10.0),
                                          ),
                                        )),
                                        10.width,
                                        Row(
                                          children: [
                                            InkWell(
                                              onTap: () {
                                                setState(() {
                                                  if (items[index].qty! <= 1) {
                                                    items.removeAt(index);
                                                  } else {
                                                    items[index].qty =
                                                        items[index].qty! - 1;
                                                  }
                                                });
                                              },
                                              child: CircleAvatar(
                                                radius: 10,
                                                child: Icon(
                                                  items[index].qty! <= 1
                                                      ? Icons.delete
                                                      : CupertinoIcons.minus,
                                                  size: 15,
                                                  color: items[index].qty! <= 1
                                                      ? redColor
                                                      : white,
                                                ),
                                              ),
                                            ),
                                            5.width,
                                            Text(
                                              items[index].qty.toString(),
                                              style: primaryTextStyle(),
                                            ),
                                            5.width,
                                            InkWell(
                                              onTap: () {
                                                setState(() {
                                                  items[index].qty =
                                                      items[index].qty! + 1;
                                                });
                                              },
                                              child: CircleAvatar(
                                                radius: 10,
                                                child: Icon(
                                                  CupertinoIcons.add,
                                                  size: 15,
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            }),
                      ),
                      4.height,
                      Text(
                        "Preferred Buy From (Optional)",
                        style: boldTextStyle(),
                      ),
                      TextFormField(
                        style: primaryTextStyle(),
                        onChanged: (value) {
                          restaurantName = value.toString();
                        },
                        decoration: InputDecoration(
                          // hintText: "Enter Pavillion Number AND Room No",
                          hintStyle: secondaryTextStyle(),
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                              vertical:
                                  10.0), // Adjust the vertical padding as needed
                        ),
                      ),
                      10.height,
                      Text(
                        "Additional Information (Optional)",
                        style: boldTextStyle(),
                      ),
                      AppTextField(
                        controller: otherController,
                        textFieldType: TextFieldType.MULTILINE,
                        decoration: InputDecoration(
                            hintText: "Type here....",
                            border: OutlineInputBorder()),
                      ),
                      10.height,
                      Row(
                        children: [
                          Checkbox(
                              value: accepted,
                              onChanged: (val) {
                                setState(() {
                                  accepted = !accepted;
                                });
                              }),
                          Text(
                            "Accept Policy",
                            style: primaryTextStyle(),
                          ),
                        ],
                      ),
                      10.height,
                      Container(
                        padding: EdgeInsets.only(left: 8, right: 8),
                        decoration: BoxDecoration(
                          color: mediumSeaGreen,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: SizedBox(
                            width: MediaQuery.of(context).size.width * 0.99,
                            height: 50,
                            child: Text("Proceed").center()),
                      ).onTap(() {
                        accepted && _formKey.currentState!.validate()
                            ? showConfirmDialog(
                                context, "Do you want to proceed?",
                                negativeText: "No",
                                positiveText: "Yes", onAccept: () {
                                addToCart();
                              })
                            : toast(
                                "please accept policy before you can proceed");
                      }),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Future<void> addToCart() async {
    items.forEach((element) async {
      MenuModel food = MenuModel(
        itemName: element.textEditingController!.text,
        restaurantName: restaurantName,
        qty: element.qty,
        otherInformation: otherController.text,
        image:
            "https://cdn.pixabay.com/photo/2017/06/10/07/18/list-2389219_1280.png",
        createdAt: DateTime.now(),
      );
      await myCartDBService.addDocument(food.toJson()).then((value) {
        appStore.addToCart(MenuModel(
          id: value.id,
          itemName: element.textEditingController!.text,
          restaurantName: restaurantName,
          qty: element.qty,
          image:
              "https://cdn.pixabay.com/photo/2017/06/10/07/18/list-2389219_1280.png",
          createdAt: DateTime.now(),
        ));
        setState(() {});
      }).whenComplete(() {
        MyOrderScreen().launch(context);
      }).catchError((e) {});
    });

    toast(appStore.translate('added'));
  }
}
