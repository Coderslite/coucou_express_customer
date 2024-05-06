// ignore_for_file: implementation_imports, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:fooddelivery/models/MenuModel.dart';
import 'package:fooddelivery/screens/MapAddressScreen.dart';
import 'package:fooddelivery/screens/MyOrderScreen.dart';
import 'package:fooddelivery/utils/Common.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:nb_utils/nb_utils.dart';

import '../main.dart';
import '../utils/Constants.dart';

class YonnimaOrder extends StatefulWidget {
  final bool isGrocery;
  const YonnimaOrder({super.key, required this.isGrocery});

  @override
  State<YonnimaOrder> createState() => _YonnimaOrderState();
}

class _YonnimaOrderState extends State<YonnimaOrder> {
  var qty = TextEditingController();
  var itemName = TextEditingController();
  var suggestedPrice = TextEditingController();
  bool accepted = false;
  bool isLoading = false;

  List<YonimmaItem> items = [];

  var _formKey = GlobalKey<FormState>();
  LatLng? location;

  GlobalKey<_MoreInfoDialogState> moreInfoDialogKey = GlobalKey();
  @override
  void initState() {
    handleGetCity();
    super.initState();
  }

  handleGetCity() {
    if (appStore.city == '' || appStore.city == 'Unknown') {
      print("getting city");
      isLoading = true;
      getUserLocation();
      setState(() {});
    } else {
      isLoading = false;
      setState(() {});
    }
  }

  void getUserLocation() async {
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    double latitude = position.latitude;
    double longitude = position.longitude;
    location = LatLng(latitude, longitude);
    // isLocationInCity(latitude, longitude, 'Thiès');
    appStore.setLocation(location!);
    var city = await getUserCity(latitude, longitude);
    appStore.setCity(city);
    isLoading = false;
    setState(() {});
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget(
        widget.isGrocery ? 'Yonnima' : 'Request Order',
        color: context.cardColor,
        actions: isLoading
            ? []
            : [
                items.isEmpty
                    ? Container()
                    : ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: mediumSeaGreen),
                        onPressed: () {
                          showInDialog(
                            context,
                            title: Text(
                              "Add Item",
                              style: primaryTextStyle(),
                            ),
                            actions: [
                              ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: redColor),
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: Text("Close")),
                              ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: mediumSeaGreen),
                                  onPressed: () {
                                    if (_formKey.currentState!.validate()) {
                                      var item = YonimmaItem(
                                          name: itemName.text,
                                          qty: int.parse(qty.text),
                                          price: int.tryParse(
                                              suggestedPrice.text));
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
                                        "Unit price",
                                        style: primaryTextStyle(wordSpacing: 2),
                                      ),
                                      labelStyle: primaryTextStyle(),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                        child: Text(
                          "Add More",
                          style: primaryTextStyle(),
                        ),
                      ),
              ],
      ),
      body: isLoading
          ? Loader().center()
          : Observer(builder: (context) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    10.height,
                    appStore.city != 'Dakar' && appStore.city != 'Thies'
                        ? Text(
                            "Orders are not accepted in ${appStore.city}",
                            style: primaryTextStyle(color: redColor),
                          )
                        : Container(),
                    10.height,
                    Text("Please add the items you want to buy",
                        style: boldTextStyle(size: 14)),
                    4.height,
                    Expanded(
                      child: items.isEmpty
                          ? Form(
                              key: _formKey,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
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
                                          "Unit price",
                                          style:
                                              primaryTextStyle(wordSpacing: 2),
                                        ),
                                        labelStyle: primaryTextStyle(),
                                      ),
                                    ),
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                              backgroundColor: mediumSeaGreen),
                                          onPressed: () {
                                            if (_formKey.currentState!
                                                .validate()) {
                                              var item = YonimmaItem(
                                                  name: itemName.text,
                                                  qty: int.parse(qty.text),
                                                  price: int.tryParse(
                                                      suggestedPrice.text));
                                              handleAddToList(item);
                                            }
                                          },
                                          child: Text("Add")),
                                    ),
                                  ],
                                ),
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
                                                        var item = YonimmaItem(
                                                            name: itemName.text,
                                                            qty: int.parse(
                                                                qty.text),
                                                            price: int.tryParse(
                                                                suggestedPrice
                                                                    .text));
                                                        handleUpdateItem(
                                                            item, index);
                                                      },
                                                      child:
                                                          Text("Update Item")),
                                                ],
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    AppTextField(
                                                      controller: itemName,
                                                      textFieldType:
                                                          TextFieldType.NAME,
                                                      decoration:
                                                          InputDecoration(
                                                        label:
                                                            Text("Item Name"),
                                                        labelStyle:
                                                            primaryTextStyle(),
                                                      ),
                                                    ),
                                                    AppTextField(
                                                      controller: qty,
                                                      textFieldType:
                                                          TextFieldType.NUMBER,
                                                      decoration:
                                                          InputDecoration(
                                                        label: Text("Quantity"),
                                                        labelStyle:
                                                            primaryTextStyle(),
                                                      ),
                                                    ),
                                                    AppTextField(
                                                      controller:
                                                          suggestedPrice,
                                                      textFieldType:
                                                          TextFieldType.NUMBER,
                                                      decoration:
                                                          InputDecoration(
                                                        label: Text(
                                                            "Unit price per quantity"),
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
                                      yonnima.price != null &&
                                              yonnima.price! > 0
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
                                child: Text(
                                  "Add to Cart",
                                  style: primaryTextStyle(),
                                ).center()),
                          ).onTap(() {
                            showInDialog(context,
                                child: MoreInfoDialog(
                                  suggestedPrice: suggestedPrice,
                                  itemName: itemName,
                                  items: items,
                                  qty: qty,
                                ));
                          }),
                  ],
                ),
              );
            }),
    );
  }

  handleAddToList(YonimmaItem item) async {
    if (item.qty <= 0 || (item.price != null && item.price! < 0)) {
      // Show an error message or handle the validation accordingly
      // For example, you can show a snackbar with an error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Invalid quantity or price'),
          backgroundColor: Colors.red,
        ),
      );
    } else {
      items.add(item);
      setState(() {
        itemName.clear();
        qty.clear();
        suggestedPrice.clear();
      });
    }
  }

  handleUpdateItem(YonimmaItem item, int index) async {
    if (item.qty <= 0 || (item.price != null && item.price! < 0)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Invalid quantity or price'),
          backgroundColor: Colors.red,
        ),
      );
    } else {
      items[index] = item;
      setState(() {
        itemName.clear();
        qty.clear();
        suggestedPrice.clear();
      });
      Navigator.pop(context);
    }
  }
}

class YonimmaItem {
  String name;
  int qty;
  int? price;

  YonimmaItem({
    required this.name,
    required this.qty,
    this.price,
  });
}

class MoreInfoDialog extends StatefulWidget {
  final List<YonimmaItem> items;
  final TextEditingController itemName;
  final TextEditingController suggestedPrice;
  final TextEditingController qty;
  const MoreInfoDialog(
      {super.key,
      required this.items,
      required this.itemName,
      required this.suggestedPrice,
      required this.qty});

  @override
  State<MoreInfoDialog> createState() => _MoreInfoDialogState();
}

class _MoreInfoDialogState extends State<MoreInfoDialog> {
  final TextEditingController otherController = TextEditingController();
  var _formKey = GlobalKey<FormState>();
  String restaurantName = '';
  String restaurantLocation = '';
  String restaurantAddress = '';

  Future<void> addToCart() async {
    print(widget.items);
    widget.items.forEach((element) async {
      MenuModel food = MenuModel(
        itemName: element.name,
        restaurantName: restaurantName,
        restaurantLocation: restaurantLocation,
        restaurantAddress: restaurantAddress,
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
          restaurantLocation: restaurantLocation,
          restaurantAddress: restaurantAddress,
          isSuggestedPrice: element.price != null ? true : false,
          itemPrice: element.price,
          qty: element.qty,
          image: img,
          createdAt: DateTime.now(),
        ));
      }).whenComplete(() {
        Navigator.pop(context);
        MyOrderScreen().launch(context);
        setState(() {
          widget.itemName.clear();
          widget.qty.clear();
          widget.suggestedPrice.clear();
          widget.items.clear();
        });
      }).catchError((e) {});
    });
    toast(appStore.translate('added'));
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppTextField(
            onChanged: (value) {
              setState(() {
                restaurantName = value.toString();
              });
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
          DropdownButtonFormField(
            style: primaryTextStyle(),
            dropdownColor: context.scaffoldBackgroundColor,
            items: ['Inside UCAD', 'Around UCAD']
                .map(
                  (e) => DropdownMenuItem(
                    child: Text(e.toString()),
                    value: e,
                  ),
                )
                .toList(),
            validator: (value) {
              if (restaurantName.isNotEmpty && value.toString() == '' ||
                  value == null) {
                return "Please select where this restaurant is located";
              }
              return null;
            },
            decoration: InputDecoration(
              label: Text(
                "Restaurant Location",
                style: secondaryTextStyle(),
              ),
            ),
            onChanged: (val) {
              restaurantLocation = val.toString();
              setState(() {});
            },
          ).visible(restaurantName.isNotEmpty),
          10.height,
          InkWell(
            onTap: () async {
              restaurantAddress = await MapAddressScreen(
                isChooseRestuarantLocation: true,
              ).launch(context);
              setState(() {});
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              decoration:
                  BoxDecoration(border: Border.all(width: 1, color: grey)),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      restaurantAddress != ''
                          ? restaurantAddress
                          : "Select restuanrant location",
                      style: primaryTextStyle(),
                    ),
                  ),
                  Icon(
                    Icons.location_on,
                    color: redColor,
                  ),
                ],
              ),
            ),
          ).visible(
              restaurantName.isNotEmpty && restaurantLocation == 'Around UCAD'),
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
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: mediumSeaGreen),
            onPressed: () {
              if (_formKey.currentState!.validate() == true) {
                if (restaurantLocation == "Around UCAD" &&
                    restaurantAddress == '') {
                  toast("Please select restaurant location");
                } else {
                  addToCart();
                }
              }
            },
            child: Text("Continue"),
          )
        ],
      ),
    );
  }
}
