import 'package:flutter/material.dart';
import 'package:fooddelivery/AppLocalizations.dart';
import 'package:fooddelivery/models/AddressModel.dart';
import 'package:fooddelivery/models/MenuModel.dart';
import 'package:fooddelivery/utils/Colors.dart';
import 'package:fooddelivery/utils/Constants.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mobx/mobx.dart';
import 'package:nb_utils/nb_utils.dart';

part 'AppStore.g.dart';

class AppStore = _AppStore with _$AppStore;

abstract class _AppStore with Store {
  @observable
  bool isLoggedIn = false;

  @observable
  bool isLoading = false;

  @observable
  bool homescreenLoaded = false;

  @observable
  bool isNotificationOn = true;

  @observable
  bool isDarkMode = false;

  @observable
  bool isAdmin = false;

  @observable
  bool isReView = false;

  @observable
  bool isQtyExist = false;

  @observable
  AppBarTheme appBarTheme = AppBarTheme();

  @observable
  String? userProfileImage = '';

  @observable
  String? userFullName = '';

  @observable
  String? userEmail = '';

  @observable
  String? userId = '';

  @observable
  String? phoneNumber = '';

  @observable
  AddressModel? addressModel;

  @observable
  String? cityName = '';

  @observable
  List<MenuModel?> mCartList = [];

  @observable
  String selectedLanguage = defaultLanguage;

  @observable
  AppLocalizations? appLocale;

  @observable
  double deliveryCharge = 0.0;
  @observable
  double constantDeliveryCharge = 0.0;

  @observable
  double kmDeliveryCharge = 0.0;


  @observable
  bool deliveryFeeAvailable = true;

  @observable
  bool isCalculating = false;

  @observable
  String searchType = '';

  @observable
  String searchQuery = '';

  @observable
  String distance = '';

  @observable
  String time = '';

  @observable
  bool containNoPrice = false;

  @observable
  bool isUploading = false;

  @observable
  String paymentMethod = '';

  @observable
  String city = '';

  @observable
  LatLng? location;

  @action
  void setDeliveryCharge(double value) {
    deliveryCharge = value;
  }

  @action
  void setConstantDeliveryCharge(double value) {
    constantDeliveryCharge = value;
  }

  @action
  void setKmDeliveryCharge(double value) {
    kmDeliveryCharge = value;
  }

  @action
  void setDeliveryFeeAvailable(bool val) {
    deliveryFeeAvailable = val;
  }

  @action
  void setIsCalculating(bool value) {
    isCalculating = value;
  }

  @action
  void setAppLocalization(BuildContext context) {
    appLocale = AppLocalizations.of(context);
  }

  String translate(String key) {
    return appLocale!.translate(key);
  }

  @action
  void setLanguage(String val) {
    selectedLanguage = val;
  }

  @action
  void addToCart(MenuModel? value) {
    mCartList.add(value);
  }

  @action
  void removeFromCart(MenuModel? value) {
    mCartList.remove(value);
  }

  @action
  void updateCartData(String id, MenuModel? value) {
    mCartList.forEachIndexed((element, index) {
      if (element!.id == id) {
        mCartList[index] = value;
      }
    });
  }

  @action
  void clearCart() {
    mCartList.clear();
  }

  @action
  void setAddressModel(AddressModel? val) {
    addressModel = val;
  }

  @action
  void setLoading(bool val) => isLoading = val;

  @action
  Future<void> setLoggedIn(bool val) async {
    isLoggedIn = val;
    await setValue(IS_LOGGED_IN, val);
  }

  @action
  void setNotification(bool val) {
    isNotificationOn = val;

    setValue(IS_NOTIFICATION_ON, val);

    if (isMobile) {
      // OneSignal.shared.setSubscription(val);
    }
  }

  @action
  Future<void> setUserProfile(String? val) async {
    userProfileImage = val;
    await setValue(USER_PHOTO_URL, val.validate());
  }

  @action
  Future<void> setUserId(String? val) async {
    userId = val;
    await setValue(USER_ID, val.validate());
  }

  @action
  Future<void> setUserEmail(String? val) async {
    userEmail = val;
    await setValue(USER_EMAIL, val.validate());
  }

  @action
  Future<void> setFullName(String? val) async {
    userFullName = val;
    await setValue(USER_DISPLAY_NAME, val.validate());
  }

  @action
  Future<void> setPhoneNumber(String? val) async {
    phoneNumber = val;
    await setValue(PHONE_NUMBER, val.validate());
  }

  @action
  void setAdmin(bool val) {
    isAdmin = val;
  }

  @action
  void setReview(bool val) {
    isReView = val;
  }

  @action
  void setQtyExist(bool val) {
    isQtyExist = val;
  }

  @action
  Future<void> setCityName(String? value) async {
    cityName = value;
    await setValue(USER_CITY_NAME, value.validate());
  }

  Future<void> setDarkMode(bool aIsDarkMode) async {
    isDarkMode = aIsDarkMode;

    if (isDarkMode) {
      textPrimaryColorGlobal = Colors.white;
      textSecondaryColorGlobal = textSecondaryColor;

      defaultLoaderBgColorGlobal = scaffoldSecondaryDark;
      appButtonBackgroundColorGlobal = appButtonColorDark;
      shadowColorGlobal = Colors.white12;

      setStatusBarColor(scaffoldColorDark);
    } else {
      textPrimaryColorGlobal = textPrimaryColor;
      textSecondaryColorGlobal = textSecondaryColor;

      defaultLoaderBgColorGlobal = Colors.white;
      appButtonBackgroundColorGlobal = Colors.white;
      shadowColorGlobal = Colors.black12;

      setStatusBarColor(Colors.white);
    }
  }

  @action
  void searchDish(String name, String type) {
    searchQuery = name;
    searchType = type;
  }

  @action
  void setDistance(String dist) {
    distance = dist;
  }

  @action
  setTime(String tim) {
    time = tim;
  }

  @action
  setContainNoPrice(bool val) {
    containNoPrice = val;
  }

  @action
  setIsUploading(bool val) {
    isUploading = val;
  }

  @action
  setPaymentMethod(String val) {
    paymentMethod = val;
  }

  @action
  setHomescrenLoaded(bool val) {
    homescreenLoaded = val;
  }

  @action
  setCity(String val) {
    city = val;
  }

  @action
  setLocation(LatLng val) {
    location = val;
  }
}
