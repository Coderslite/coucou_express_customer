// ignore_for_file: implementation_imports

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fooddelivery/models/MenuModel.dart';
import 'package:fooddelivery/screens/MyOrderScreen.dart';
import 'package:fooddelivery/utils/Common.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:nb_utils/nb_utils.dart';

import '../main.dart';
import '../utils/Constants.dart';

class RequestOrder extends StatefulWidget {
  final bool isGrocery;
  const RequestOrder({super.key, required this.isGrocery});

  @override
  State<RequestOrder> createState() => _RequestOrderState();
}

// class ItemModel {
//   TextEditingController? textEditingController;
//   int? qty;

//   ItemModel({
//     this.qty,
//     this.textEditingController,
//   });
// }

class _RequestOrderState extends State<RequestOrder> {
  final TextEditingController otherController = TextEditingController();
  var qty = TextEditingController();
  var itemName = TextEditingController();
  var suggestedPrice = TextEditingController();
  bool accepted = false;
  bool isLoading = true;
  String restaurantName = '';
  LatLng? location;
  String city = '';
  List<YonimmaOrder> items = [];

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
              showInDialog(context,
                  title: Text(
                    "Add Item",
                    style: primaryTextStyle(),
                  ),
                  actions: [
                    ElevatedButton(
                        style:
                            ElevatedButton.styleFrom(backgroundColor: redColor),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text("Close")),
                    ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: mediumSeaGreen),
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            var item = YonimmaOrder(
                                name: itemName.text,
                                qty: int.parse(qty.text),
                                price: int.tryParse(suggestedPrice.text));
                            handleAddToList(item);
                          }
                        },
                        child: Text("Add")),
                  ],
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AppTextField(
                          controller: itemName,
                          textFieldType: TextFieldType.NAME,
                          decoration: InputDecoration(
                            labelStyle: primaryTextStyle(),
                            label: Text("Item Name *"),
                          ),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return "Field Required";
                            }
                            return null;
                          },
                        ),
                        AppTextField(
                          controller: qty,
                          textFieldType: TextFieldType.NUMBER,
                          decoration: InputDecoration(
                            label: Text("Quantity *"),
                            labelStyle: primaryTextStyle(),
                          ),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return "Field Required";
                            }
                            return null;
                          },
                        ),
                        AppTextField(
                          controller: suggestedPrice,
                          textFieldType: TextFieldType.NUMBER,
                          isValidationRequired: false,
                          decoration: InputDecoration(
                            label: Text(
                              "Suggested price per quantity",
                              style: primaryTextStyle(wordSpacing: 2),
                            ),
                            labelStyle: primaryTextStyle(),
                          ),
                        ),
                      ],
                    ),
                  ));
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
          : Padding(
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
                  Text("Please add the items you want to buy",
                      style: boldTextStyle(size: 14)),
                  4.height,
                  Expanded(
                    child: items.isEmpty
                        ? Center(
                            child: Text(
                              "No Item Added Yet",
                              style: primaryTextStyle(),
                            ),
                          )
                        : ListView.builder(
                            itemCount: items.length,
                            physics: NeverScrollableScrollPhysics(),
                            itemBuilder: (context, index) {
                              var yonnima = items[index];
                              return Card(
                                child: ListTile(
                                  title: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "${yonnima.name} * ${yonnima.qty}",
                                        style: primaryTextStyle(size: 20),
                                      ),
                                      InkWell(
                                        onTap: () {
                                          itemName.text = yonnima.name;
                                          qty.text = "${yonnima.qty}";
                                          if (yonnima.price == null) {
                                            suggestedPrice.clear();
                                          } else {
                                            suggestedPrice.text =
                                                yonnima.price.toString();
                                          }
                                          showInDialog(context,
                                              title: Text(
                                                "Update Item",
                                                style: primaryTextStyle(),
                                              ),
                                              actions: [
                                                ElevatedButton(
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                            backgroundColor:
                                                                redColor),
                                                    onPressed: () {
                                                      Navigator.pop(context);
                                                    },
                                                    child: Text("Close")),
                                                ElevatedButton(
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                            backgroundColor:
                                                                mediumSeaGreen),
                                                    onPressed: () {
                                                      var item = YonimmaOrder(
                                                          name: itemName.text,
                                                          qty: int.parse(
                                                              qty.text),
                                                          price: int.tryParse(
                                                              suggestedPrice
                                                                  .text));
                                                      handleUpdateItem(
                                                          item, index);
                                                    },
                                                    child: Text("Update Item")),
                                              ],
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  AppTextField(
                                                    controller: itemName,
                                                    textFieldType:
                                                        TextFieldType.NAME,
                                                    decoration: InputDecoration(
                                                      label: Text("Item Name"),
                                                      labelStyle:
                                                          primaryTextStyle(),
                                                    ),
                                                  ),
                                                  AppTextField(
                                                    controller: qty,
                                                    textFieldType:
                                                        TextFieldType.NUMBER,
                                                    decoration: InputDecoration(
                                                      label: Text("Quantity"),
                                                      labelStyle:
                                                          primaryTextStyle(),
                                                    ),
                                                  ),
                                                  AppTextField(
                                                    controller: suggestedPrice,
                                                    textFieldType:
                                                        TextFieldType.NUMBER,
                                                    decoration: InputDecoration(
                                                      label: Text(
                                                          "Suggested price per quantity"),
                                                      labelStyle:
                                                          primaryTextStyle(),
                                                    ),
                                                  ),
                                                ],
                                              ));
                                        },
                                        child: Icon(
                                          Icons.edit,
                                          size: 18,
                                          color: mediumSeaGreen,
                                        ),
                                      )
                                    ],
                                  ),
                                  subtitle: Text(
                                    yonnima.price != null && yonnima.price! > 0
                                        ? "${getAmount(yonnima.price! * yonnima.qty)}"
                                        : 'price not available',
                                    style: secondaryTextStyle(size: 14),
                                  ),
                                  leading: Text(
                                    (index + 1).toString(),
                                    style: primaryTextStyle(),
                                  ),
                                  trailing: InkWell(
                                    onTap: () {
                                      setState(() {
                                        items.removeAt(index);
                                      });
                                    },
                                    child: Icon(
                                      Icons.delete,
                                      color: redColor,
                                    ),
                                  ),
                                ),
                              );
                            }),
                  ),
                  4.height,
                  items.isEmpty
                      ? Container()
                      : Container(
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
                          showInDialog(context,
                              actions: [
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: mediumSeaGreen),
                                  onPressed: () {
                                    // showConfirmDialog(
                                    //     context, "Do you want to proceed?",
                                    //     negativeText: "No",
                                    //     positiveText: "Yes", onAccept: () {
                                    //   addToCart();
                                    //   Navigator.pop(context);
                                    // });
                                    addToCart();
                                    Navigator.pop(context);
                                  },
                                  child: Text("Continue"),
                                )
                              ],
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  AppTextField(
                                    onChanged: (value) {
                                      restaurantName = value.toString();
                                    },
                                    isValidationRequired: false,
                                    textFieldType: TextFieldType.NAME,
                                    decoration: InputDecoration(
                                      label: Text(
                                        "Preferred buy from location",
                                        style: secondaryTextStyle(),
                                      ), // Adjust the vertical padding as needed
                                    ),
                                  ),
                                  10.height,
                                  AppTextField(
                                    isValidationRequired: false,
                                    controller: otherController,
                                    textFieldType: TextFieldType.MULTILINE,
                                    minLines: 3,
                                    maxLines: 5,
                                    decoration: InputDecoration(
                                      label: Text(
                                        "Additional Information about item",
                                        style: secondaryTextStyle(),
                                      ),
                                    ),
                                  ),
                                ],
                              ));
                        }),
                ],
              ),
            ),
    );
  }

  handleAddToList(YonimmaOrder item) async {
    items.add(item);
    setState(() {
      itemName.clear();
      qty.clear();
      suggestedPrice.clear();
    });
  }

  handleUpdateItem(YonimmaOrder item, int index) async {
    items[index] = item;
    setState(() {
      itemName.clear();
      qty.clear();
      suggestedPrice.clear();
    });
    Navigator.pop(context);
  }

  Future<void> addToCart() async {
    items.forEach((element) async {
      MenuModel food = MenuModel(
        itemName: element.name,
        restaurantName: restaurantName,
        isSuggestedPrice: element.price != null ? true : false,
        itemPrice: element.price,
        qty: element.qty,
        otherInformation: otherController.text,
        image: img,
        createdAt: DateTime.now(),
      );
      await myCartDBService.addDocument(food.toJson()).then((value) {
        appStore.addToCart(MenuModel(
          id: value.id,
          itemName: element.name,
          restaurantName: restaurantName,
          isSuggestedPrice: element.price != null ? true : false,
          itemPrice: element.price,
          qty: element.qty,
          image: img,
          createdAt: DateTime.now(),
        ));
        setState(() {
          itemName.clear();
          qty.clear();
          suggestedPrice.clear();
          items.clear();
        });
      }).whenComplete(() {
        MyOrderScreen().launch(context);
      }).catchError((e) {});
    });
    toast(appStore.translate('added'));
  }
}

class YonimmaOrder {
  String name;
  int qty;
  int? price;

  YonimmaOrder({
    required this.name,
    required this.qty,
    this.price,
  });
}
