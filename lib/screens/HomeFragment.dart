// ignore_for_file: deprecated_member_use

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:fooddelivery/components/RestaurantItemComponent.dart';
import 'package:fooddelivery/main.dart';
import 'package:fooddelivery/models/AddressModel.dart';
import 'package:fooddelivery/models/CategoryModel.dart';
import 'package:fooddelivery/models/FoodModel.dart';
import 'package:fooddelivery/models/RestaurantModel.dart';
import 'package:fooddelivery/screens/LoginScreen.dart';
import 'package:fooddelivery/screens/OrderDetailsScreen.dart';
import 'package:fooddelivery/utils/Colors.dart';
import 'package:fooddelivery/utils/Common.dart';
import 'package:fooddelivery/utils/ModalKeys.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:paginate_firestore/bloc/pagination_listeners.dart';
import 'package:upgrader/upgrader.dart';

import '../components/AdWidget.dart';
import '../components/ServiceCategory.dart';
import '../models/AdModel.dart';
import '../services/CalculateDistance.dart';
import '../utils/Constants.dart';

class HomeFragment extends StatefulWidget {
  static String tag = '/HomeFragment';

  @override
  HomeFragmentState createState() => HomeFragmentState();
}

class HomeFragmentState extends State<HomeFragment>
    with AfterLayoutMixin<HomeFragment> {
  PaginateRefreshedChangeListener refreshChangeListener =
      PaginateRefreshedChangeListener();

  TextEditingController searchCont = TextEditingController();

  String searchText = '';

  LatLng? userLatLng;

  int retry = 0;

  int pageKey = 0;
  String distance = '0';
  String time = '0';
  final PagingController<int, RestaurantModel> _pagingController =
      PagingController(firstPageKey: 0);
  DocumentSnapshot? lastLoadedItem;
  Future<void> _fetchPage(int pageKey, String type) async {
    try {
      Query newItemsQuery = appStore.searchQuery == ''
          ? FirebaseFirestore.instance.collection("restaurant")
          : type == 'restaurant'
              ? FirebaseFirestore.instance
                  .collection("restaurant")
                  .where('restaurantName',
                      isGreaterThanOrEqualTo: appStore.searchQuery)
                  .where('restaurantName',
                      isLessThanOrEqualTo: appStore.searchQuery + '\uf8ff')
              : FirebaseFirestore.instance
                  .collection("restaurant")
                  .where('foodList', arrayContains: appStore.searchQuery);

      // Check if this is the first page or not
      if (pageKey != 0) {
        // If not the first page, use lastLoadedItem to start the next page
        newItemsQuery = newItemsQuery.startAfterDocument(lastLoadedItem!);
      }

      final restaurantSnapshot = await newItemsQuery.limit(1).get();

      final List<RestaurantModel> restaurants = restaurantSnapshot.docs
          .map((snapshot) =>
              RestaurantModel.fromJson(snapshot.data() as Map<String, dynamic>))
          .toList();
      appStore.isLoading = false;
      if (restaurants.isEmpty) {
        print("No more restaurants to load.");
        _pagingController.appendLastPage([]);
      } else {
        _pagingController.appendPage(restaurants, pageKey + 1);
        // Set lastLoadedItem to the last restaurant on this page
        lastLoadedItem = restaurantSnapshot.docs.last;
        print("Restaurants fetched for page $pageKey");
      }
    } catch (error) {
      _pagingController.error = error;
      print(error);
    }
  }

  @override
  void initState() {
    super.initState();
    init();
    searchCont.text = appStore.searchQuery;
    _pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey, '');
    });
  }

  init() async {
    checkPermission();
    await appSettingService.setAppSettings();
    setStatusBarColor(
      context.scaffoldBackgroundColor,
      statusBarIconBrightness:
          appStore.isDarkMode ? Brightness.light : Brightness.dark,
    );
  }

  @override
  void afterFirstLayout(BuildContext context) {
    OneSignal.shared
        .setNotificationOpenedHandler((OSNotificationOpenedResult result) {
      if (!appStore.isLoggedIn) {
        LoginScreen().launch(context, isNewTask: true);
      } else {
        if (result.notification.additionalData!.containsKey('orderId')) {
          String? orderId = result.notification.additionalData!['orderId'];

          myOrderDBService.getOrderById(orderId).then((value) {
            OrderDetailsScreen(listOfOrder: value.listOfOrder, orderData: value)
                .launch(context);
          }).catchError((e) {
            toast(e.toString());
          });
        }
      }
    });
  }

  Future<void> checkPermission() async {
    LocationPermission locationPermission =
        await Geolocator.requestPermission();

    if (locationPermission == LocationPermission.whileInUse ||
        locationPermission == LocationPermission.always) {
      if ((await Geolocator.isLocationServiceEnabled())) {
        getUserLocation();
      } else {
        Geolocator.openLocationSettings().then((value) {
          if (value) getUserLocation();
        });
      }
    } else {
      Geolocator.openAppSettings();
    }
  }

  void calc(LatLng add) {
    // print(appStore.addressModel!.userLocation!.latitude);
    distance = appStore.addressModel == null
        ? "0"
        : double.parse(calculateDistance(UCAD_LOCATION, add).toString())
            .toStringAsFixed(1);
    time = (double.parse(distance) * 5).toStringAsFixed(1);
  }

  Future<void> getUserLocation() async {
    if (retry >= 3) return;
    retry++;

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    List<Placemark> placemarks =
        await placemarkFromCoordinates(position.latitude, position.longitude);

    Placemark place = placemarks[0];
    if (place.locality != null) {
      userCityNameGlobal = place.locality;
    } else {
      userCityNameGlobal = place.subLocality;
    }
    String address =
        "${place.name != null ? place.name : place.subThoroughfare}, ${place.subLocality}, ${place.locality}, ${place.administrativeArea} ${place.postalCode}, ${place.country}";
    userAddressGlobal = address;

    appStore.setAddressModel(AddressModel(
        userLocation: GeoPoint(position.latitude, position.longitude)));
    calc(LatLng(position.latitude, position.longitude));
    appStore.setTime(time);
    appStore.setDistance(distance);

    if (userCityNameGlobal.validate().isNotEmpty) {
      await appStore.setCityName(userCityNameGlobal);

      if (appStore.isLoggedIn) {
        Map<String, dynamic> data = {
          UserKeys.city: userCityNameGlobal,
          CommonKeys.updatedAt: DateTime.now(),
        };

        await userDBService
            .updateDocument(data, appStore.userId)
            .then((res) async {
          //
        }).catchError((error) {
          appStore.setLoading(false);
          toast(error.toString());
        });
      }
    } else {
      getUserLocation();
    }

    setState(() {});
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: colorPrimary,
      backgroundColor: context.cardColor,
      onRefresh: () async {
        appSettingService.setAppSettings();
        appStore.searchQuery = '';
        _pagingController.itemList!.clear();
        _fetchPage(0, '');

        setState(() {});
        await 2.seconds.delay;
      },
      child: Scaffold(
        body: UpgradeAlert(
          upgrader: Upgrader(
            canDismissDialog: false,
            showIgnore: false,
            showLater: false,
            dialogStyle: Platform.isIOS
                ? UpgradeDialogStyle.cupertino
                : UpgradeDialogStyle.material,
            durationUntilAlertAgain: const Duration(minutes: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  appStore.userProfileImage.validate().isEmpty
                      ? Icon(Icons.location_on, size: 30)
                      : cachedImage(
                          appStore.userProfileImage.validate(),
                          usePlaceholderIfUrlEmpty: true,
                          height: 50,
                          width: 50,
                          fit: BoxFit.cover,
                        ).cornerRadiusWithClipRRect(30),
                  10.width,
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Row(
                      //   children: [
                      //     Text('${appStore.translate('hello')},',
                      //         style: boldTextStyle(size: 20)),
                      //     4.width,
                      //     Text(appStore.userFullName.validate(),
                      //         style: boldTextStyle(size: 18)),
                      //   ],
                      // ),
                      Text(userAddressGlobal.validate(),
                          style: boldTextStyle(size: 12)),
                    ],
                  ).visible(appStore.isLoggedIn).expand(),
                ],
              ).paddingAll(10).visible(appStore.isLoggedIn),
              5.height,
              Observer(builder: (context) {
                searchCont.text = appStore.searchQuery;
                return Row(
                  children: <Widget>[
                    Container(
                        decoration: boxDecorationWithRoundedCorners(
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(color: viewLineColor),
                          backgroundColor: appStore.isDarkMode
                              ? scaffoldSecondaryDark
                              : Colors.white,
                        ),
                        child: TextFormField(
                          style: primaryTextStyle(),
                          controller: searchCont,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            prefixIcon:
                                Icon(Icons.search, color: context.iconColor),
                            hintText: appStore.translate('search_restaurant'),
                            hintStyle: primaryTextStyle(),
                            suffixIcon: CloseButton(
                              color: context.iconColor,
                              onPressed: () {
                                appStore.searchQuery = '';
                                searchCont.text = '';
                                _pagingController.itemList!.clear();
                                _fetchPage(0, '');

                                setState(() {});
                                1.seconds.delay.then((value) {
                                  hideKeyboard(context);
                                });
                              },
                            ).visible(appStore.searchQuery.isNotEmpty),
                          ),
                          onFieldSubmitted: (s) {
                            appStore.searchQuery = s;
                            hideKeyboard(context);
                            _pagingController.itemList!.clear();
                            _fetchPage(0, 'restaurant');
                            setState(() {});
                          },
                        )).expand(),
                  ],
                ).paddingOnly(left: 16, right: 16, bottom: 8);
              }),
              Observer(builder: (context) {
                return appStore.isLoading
                    ? Loader()
                    : Expanded(
                        child: PagedListView<int, RestaurantModel>(
                            pagingController: _pagingController,
                            builderDelegate:
                                PagedChildBuilderDelegate<RestaurantModel>(
                                    // animateTransitions: true,

                                    noItemsFoundIndicatorBuilder: (context) {
                              return homeComponents(context);
                            }, itemBuilder: (context, item, index) {
                              return Column(
                                children: [
                                  index == 0
                                      ? homeComponents(context)
                                      : Container(),
                                  RestaurantItemComponent(
                                    restaurant: item,
                                  ),
                                ],
                              );
                            })),
                      );
              })
            ],
          ),
        ),
      ),
    );
  }

  Column homeComponents(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 70,
          width: MediaQuery.of(context).size.width,
          child: StreamBuilder<List<CategoryModel>>(
              stream: categoryDBService.categories(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Text(
                    "Something went wrong",
                    style: primaryTextStyle(),
                  );
                }
                if (snapshot.hasData) {
                  var data = snapshot.data;
                  return ListView.builder(
                      itemCount: data!.length,
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, index) {
                        var category = data[index];
                        return ServiceCategory(
                          data: category,
                        );
                      });
                } else {
                  return Text("");
                }
              }),
        ),
        SizedBox(
          height: 70,
          width: MediaQuery.of(context).size.width,
          child: StreamBuilder<List<FoodModel>>(
              stream: foodDBService.categories(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text("something went wrong"));
                } else if (snapshot.hasData) {
                  var data = snapshot.data;
                  return ListView.builder(
                      itemCount: data!.length,
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, index) {
                        var food = data[index];
                        return Container(
                          margin: EdgeInsets.symmetric(horizontal: 5),
                          child: Column(
                            children: [
                              ClipOval(
                                child: SizedBox(
                                  height: 50,
                                  width: 50,
                                  child: Padding(
                                    padding: const EdgeInsets.all(5.0),
                                    child: cachedImage(
                                      food.image.validate(),
                                      height: 180,
                                      width: context.width(),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                              Text(
                                food.name.validate(),
                                style: primaryTextStyle(size: 12),
                              )
                            ],
                          ),
                        ).onTap(() async {
                          setState(() {
                            appStore.isLoading = true;
                            appStore.searchDish(food.name!, 'Food');
                            _pagingController.itemList!.clear();
                            _fetchPage(pageKey, 'food');
                          });
                        });
                      });
                } else {
                  return Text("");
                }
              }),
        ),
        15.height,
        StreamBuilder<List<AdModel>>(
          stream: advertDBService.adverts(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Text(
                "Something went wrong",
                style: primaryTextStyle(),
              );
            } else if (snapshot.hasData) {
              var data = snapshot.data!;
              return SizedBox(
                width: MediaQuery.of(context).size.width,
                height: 130,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    var ad = data[index];
                    return AdWidget(
                      adModel: ad,
                    );
                  },
                ),
              );
            } else {
              return Text("");
            }
          },
        ),
        15.height,
        Text(appStore.translate('restaurants'), style: boldTextStyle(size: 24))
            .paddingLeft(16),
        _pagingController.itemList!.isEmpty
            ? Center(
                child: Text(
                "No Restaurant Found",
                style: primaryTextStyle(),
              ))
            : Container(),
      ],
    );
  }
}
