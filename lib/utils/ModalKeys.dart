class CommonKeys {
  static String id = 'id';
  static String createdAt = 'createdAt';
  static String updatedAt = 'updatedAt';
  static String categoryId = 'categoryId';
  static String categoryName = 'categoryName';
  static String itemName = 'itemName';
  static String itemPrice = 'itemPrice';
  static String qty = 'qty';
  static String image = 'image';
  static String isDeleted = 'isDeleted';
  static String review = 'review';
  static String rating = 'rating';
  static String reviewTags = 'reviewTags';
  static String restaurantId = 'restaurantId';
  static String isSuggesttedPrice = 'isSuggestedPrice';
}

class UserKeys {
  static String uid = 'uid';
  static String name = 'name';
  static String email = 'email';
  static String photoUrl = 'photoUrl';
  static String number = 'number';
  static String password = 'password';
  static String loginType = 'loginType';
  static String isAdmin = 'isAdmin';
  static String isTester = 'isTester';
  static String listOfAddress = 'listOfAddress';
  static String role = 'role';
  static String favRestaurant = 'favRestaurant';
  static String city = 'city';
  static String oneSignalPlayerId = 'oneSignalPlayerId';
  static String homeAddress = 'homeAddress';
  static String workAddress = 'workAddress';
  static String latitude = 'latitude';
  static String longitude = 'longitude';
}

class FoodKey {
  static String id = 'id';
  static String name = 'name';
  static String image = 'image';
  static String createdAt = 'createdAt';
}

class RestaurantKeys {
  static String restaurantName = 'restaurantName';
  static String restaurantLatitude = 'restaurantLatitude';
  static String restaurantLongitude = 'restaurantLongitude';
  static String photoUrl = 'photoUrl';
  static String openTime = 'openTime';
  static String closeTime = 'closeTime';
  static String restaurantAddress = 'restaurantAddress';
  static String restaurantPhoneNumber = 'restaurantPhoneNumber';
  static String restaurantEmail = 'restaurantEmail';
  static String restaurantDeliveryFees = 'restuarantDeliveryFees';
  static String isVegRestaurant = 'isVegRestaurant';
  static String isNonVegRestaurant = 'isNonVegRestaurant';
  static String isDealOfTheDay = 'isDealOfTheDay';
  static String couponCode = 'couponCode';
  static String couponDesc = 'couponDesc';
  static String caseSearch = 'caseSearch';
  static String restaurantDescription = 'restaurantDescription';
  static String catList = 'catList';
  static String restaurantCity = 'restaurantCity';
  static String ingredientsTags = 'ingredientsTags';
  static String deliveryCharge = 'deliveryCharge';
  static String onGoogle = 'onGoogle';
  static String withinUcad = 'withinUcad';
  static String ownedByUs = 'ownedByUs';
}

class OrderKeys {
  static String listOfOrder = 'listOfOrder';
  static String totalAmount = 'totalAmount';
  static String totalItem = 'totalItem';
  static String userId = 'userId';
  static String orderStatus = 'orderStatus';
  static String orderId = 'orderId';
  static String userLocation = 'userLocation';
  static String userAddress = 'userAddress';
  static String deliveryBoyLocation = 'deliveryBoyLocation';
  static String deliveryBoyId = 'deliveryBoyId';
  static String paymentMethod = 'paymentMethod';
  static String city = 'city';
  static String paymentStatus = 'paymentStatus';
  static String deliveryCharge = 'deliveryCharge';
  static String taken = 'taken';
  static String orderType = 'orderType';
  static String orderUrl = 'orderUrl';
  static String receiptUrl = 'receiptUrl';
}

class CategoryKeys {
  static String color = 'color';
}

class DeliveryBoyReviewKeys {
  static String userId = 'userId';
  static String userName = 'userName';
  static String userImage = 'userImage';
  static String deliveryBoyId = 'deliveryBoyId';
}

class MenuKeys {
  static String ingredientsTags = 'ingredientsTags';
  static String inStock = 'inStock';
  static String description = 'description';
  static String restaurantId = 'restaurantId';
  static String dishImage = 'dishPicUrl';
  static String dishName = 'dishName';
  static String dishCategory = 'dishCategory';
  static String dishPrice = 'dishPrice';
  static String deliveryFee = 'deliveryFee';
  static String onGoogle = 'onGoogle';
  static String deliveryLocation = 'deliveryLocation';
  static String deliveryAddress = 'deliveryAddress';
  static String deliveryAddressDescription = 'deliveryAddressDescription';
  static String pavilionNo = 'pavilionNo';
  static String otherInformation = 'otherInformation';
}

class RestaurantReviewKeys {
  static String reviewerId = 'reviewerId';
  static String reviewerName = 'reviewerName';
  static String reviewerImage = 'reviewerImage';
  static String reviewerLocation = 'reviewerLocation';
}

class AdKeys {
  static String id = 'id';
  static String title = 'title';
  static String? type = 'type';
  static String? description = 'description';
  static String? image = 'image';
  static String? buttonColor = 'buttonColor';
  static String? buttonText = 'buttonText';
  static String? buttonTextColor = 'buttonTextColor';
  static String? textColor = 'textColor';
  static String? restuarantId = 'restaurantId';
}

class AddressKeys {
  static String address = 'address';
  static String details = 'details';
  static String userLocation = 'userLocation';
  static String pavilionNo = 'pavilionNo';
  static String addressLocation = 'addressLocation';
}
