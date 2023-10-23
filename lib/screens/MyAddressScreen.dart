import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:fooddelivery/components/AddressListComponent.dart';
import 'package:fooddelivery/models/UserModel.dart';
import 'package:fooddelivery/screens/MapAddressScreen.dart';
import 'package:fooddelivery/utils/Colors.dart';
import 'package:geolocator/geolocator.dart';
import 'package:nb_utils/nb_utils.dart';

import '../main.dart';
import '../models/AddressModel.dart';
import '../utils/ModalKeys.dart';

// ignore: must_be_immutable
class MyAddressScreen extends StatefulWidget {
  static String tag = '/MyAddressScreen';
  bool? isOrder = false;

  MyAddressScreen({this.isOrder});

  @override
  MyAddressScreenState createState() => MyAddressScreenState();
}

class MyAddressScreenState extends State<MyAddressScreen> {
  double? userLatitude;
  double? userLongitude;

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    getCurrentUserLocation();
  }

  Future<void> getCurrentUserLocation() async {
    final geoPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    userLatitude = geoPosition.latitude;
    userLongitude = geoPosition.longitude;
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  String address = '';
  var _formKey = GlobalKey<FormState>();
  var addressFormKey = GlobalKey<FormState>();
  List<AddressModel> listOfAddress = [];
  String otherDetails = '';
  String pavilionNo = '';

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: appBarWidget(appStore.translate('my_address'),
            color: context.cardColor),
        body: SingleChildScrollView(
          child: Column(
            children: [
              SettingItemWidget(
                padding:
                    EdgeInsets.only(top: 16, right: 16, left: 16, bottom: 8),
                leading: Icon(Icons.add, color: colorPrimary),
                title: appStore.translate('add_address'),
                titleTextStyle: primaryTextStyle(color: colorPrimary),
                onTap: () async {
                  if (userLatitude != null) {
                    showModalBottomSheet(
                        context: context,
                        builder: (_) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    "Where is the address located ?",
                                    style: boldTextStyle(),
                                  ),
                                  address == ''
                                      ? DropdownButtonFormField(
                                          decoration: InputDecoration(
                                            prefixIcon: IconButton(
                                              onPressed: () {
                                                setState(() {
                                                  address = '';
                                                });
                                                Navigator.pop(context);
                                              },
                                              icon: Icon(Icons.delete_sweep),
                                            ),
                                          ),
                                          items: ["Inside UCAD", "Around UCAD"]
                                              .map((e) => DropdownMenuItem(
                                                    child: Text(
                                                      e.toString(),
                                                    ),
                                                    value: e,
                                                  ))
                                              .toList(),
                                          validator: (value) {
                                            if (value!.isEmpty) {
                                              return "Field is Required";
                                            }
                                            return null;
                                          },
                                          onChanged: (val) {
                                            address = val.toString();
                                          })
                                      : DropdownButtonFormField(
                                          value: address,
                                          decoration: InputDecoration(
                                            prefixIcon: IconButton(
                                              onPressed: () {
                                                setState(() {
                                                  address = '';
                                                });
                                                Navigator.pop(context);
                                              },
                                              icon: Icon(Icons.delete_sweep),
                                            ),
                                          ),
                                          items: ["Inside UCAD", "Around UCAD"]
                                              .map((e) => DropdownMenuItem(
                                                    child: Text(
                                                      e.toString(),
                                                    ),
                                                    value: e,
                                                  ))
                                              .toList(),
                                          validator: (value) {
                                            if (value!.isEmpty) {
                                              return "Field is Required";
                                            }
                                            return null;
                                          },
                                          onChanged: (val) {
                                            address = val.toString();
                                          }),
                                  ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                          backgroundColor: seaGreen),
                                      onPressed: () {
                                        if (_formKey.currentState!.validate()) {
                                          if (address == "Inside UCAD") {
                                            Navigator.pop(context);
                                            showDialog(
                                                context: context,
                                                builder: (_) {
                                                  return AlertDialog(
                                                    title: Text("Add Address"),
                                                    content: Form(
                                                      key: addressFormKey,
                                                      child: Column(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          TextFormField(
                                                            onChanged: (value) {
                                                              pavilionNo = value
                                                                  .toString();
                                                            },
                                                            decoration:
                                                                InputDecoration(
                                                                    hintText:
                                                                        "Enter pavilion/Room Number "),
                                                          ),
                                                          8.height,
                                                          TextFormField(
                                                            onChanged: (value) {
                                                              otherDetails = value
                                                                  .toString();
                                                            },
                                                            decoration:
                                                                InputDecoration(
                                                                    hintText:
                                                                        "Add additional information about the address"),
                                                          ),
                                                          ElevatedButton(
                                                              style: ElevatedButton
                                                                  .styleFrom(
                                                                      backgroundColor:
                                                                          seaGreen),
                                                              onPressed: () {
                                                                validate();
                                                              },
                                                              child:
                                                                  Text("Save"))
                                                        ],
                                                      ),
                                                    ),
                                                  );
                                                });
                                          } else {
                                            Navigator.pop(context);
                                            MapAddressScreen(
                                                    userLatitude: userLatitude,
                                                    userLongitude:
                                                        userLongitude)
                                                .launch(context);
                                          }
                                        }
                                      },
                                      child: Text("Proceed")),
                                ],
                              ),
                            ),
                          );
                        });
                  } else {
                    setState(() {
                      getCurrentUserLocation();
                    });
                  }
                },
              ),
              Stack(
                children: [
                  StreamBuilder<UserModel>(
                    stream: userDBService.userById(appStore.userId),
                    builder: (_, snap) {
                      if (snap.hasData) {
                        return AddressListComponent(
                            userData: snap.data, isOrder: widget.isOrder);
                      } else {
                        return snapWidgetHelper(snap);
                      }
                    },
                  ),
                  Observer(
                      builder: (_) =>
                          Loader().center().visible(appStore.isLoading)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void validate() async {
    hideKeyboard(context);

    if (addressFormKey.currentState!.validate()) {
      addressFormKey.currentState!.save();

      appStore.setLoading(true);

      listOfAddress.add(
        AddressModel(
            pavilionNo: pavilionNo,
            otherDetails: otherDetails,
            addressLocation: 'Inside UCAD'),
      );

      await userDBService.updateDocument({
        CommonKeys.updatedAt: DateTime.now(),
        UserKeys.listOfAddress: FieldValue.arrayUnion(
            listOfAddress.map((e) => e.toJson()).toList()),
      }, appStore.userId).then((value) {
        toast(appStore.translate('saved'));
        appStore.setLoading(false);
        finish(context);
      }).catchError((e) {
        appStore.setLoading(false);
        log(e);
      });
    }
  }
}
