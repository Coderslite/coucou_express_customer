class AppSettingModel {
  String? termCondition;
  String? privacyPolicy;
  String? contactInfo;

  AppSettingModel({this.termCondition, this.privacyPolicy, this.contactInfo});

  factory AppSettingModel.fromJson(Map<String, dynamic> json) {
    return AppSettingModel(
      termCondition: json['termCondition'],
      privacyPolicy: json['privacyPolicy'],
      contactInfo: json['contactInfo'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['termCondition'] = this.termCondition;
    data['privacyPolicy'] = this.privacyPolicy;
    data['contactInfo'] = this.contactInfo;
    return data;
  }
}
