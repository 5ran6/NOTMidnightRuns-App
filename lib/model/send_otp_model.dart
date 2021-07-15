class SendOTPModel {
  bool success;
  Data data;

  SendOTPModel({this.success, this.data});

  SendOTPModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    if (this.data != null) {
      data['data'] = this.data.toJson();
    }
    return data;
  }
}

class Data {
  int id;
  String name;
  String image;
  String emailId;
  Null emailVerifiedAt;
  String deviceToken;
  String phone;
  int isVerified;
  int status;
  String otp;
  Null faviroute;
  String createdAt;
  String updatedAt;

  Data(
      {this.id,
        this.name,
        this.image,
        this.emailId,
        this.emailVerifiedAt,
        this.deviceToken,
        this.phone,
        this.isVerified,
        this.status,
        this.otp,
        this.faviroute,
        this.createdAt,
        this.updatedAt});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'].toString();
    image = json['image'];
    emailId = json['email_id'];
    emailVerifiedAt = json['email_verified_at'];
    deviceToken = json['device_token'];
    phone = json['phone'];
    isVerified = json['is_verified'];
    status = json['status'];
    otp = json['otp'];
    faviroute = json['faviroute'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['image'] = this.image;
    data['email_id'] = this.emailId;
    data['email_verified_at'] = this.emailVerifiedAt;
    data['device_token'] = this.deviceToken;
    data['phone'] = this.phone;
    data['is_verified'] = this.isVerified;
    data['status'] = this.status;
    data['otp'] = this.otp;
    data['faviroute'] = this.faviroute;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}
