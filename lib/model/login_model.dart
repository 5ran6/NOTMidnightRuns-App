class LoginModel {
  bool success;
  Data data;

  LoginModel({this.success, this.data});

  LoginModel.fromJson(Map<String, dynamic> json) {
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
  String phone;
  int isVerified;
  int status;
  int otp;
  String faviroute;
  String createdAt;
  String updatedAt;
  String token;
  String language;
  String account_name;
  String account_number;
  String micr_code;
  String ifsc_code;
  List<Roles> roles;

  Data(
      {this.id,
      this.name,
      this.image,
      this.emailId,
      this.emailVerifiedAt,
      this.phone,
      this.isVerified,
      this.status,
      this.otp,
      this.faviroute,
      this.createdAt,
      this.updatedAt,
      this.token,
      this.language,
      this.account_name,
      this.account_number,
      this.micr_code,
      this.ifsc_code,
      this.roles});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'].toString();
    image = json['image'];
    emailId = json['email_id'].toString();
    emailVerifiedAt = json['email_verified_at'];
    phone = json['phone'];
    isVerified = json['is_verified'];
    status = json['status'];
    otp = json['otp'];
    faviroute = json['faviroute'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    token = json['token'];

    if (json['language'] != null) {
      language = json['language'];
    }

    if (json['account_name'] != null) {
      account_name = json['account_name'];
    }

    if (json['micr_code'] != null) {
      micr_code = json['micr_code'];
    }

    if (json['ifsc_code'] != null) {
      ifsc_code = json['ifsc_code'];
    }

    if (json['account_number'] != null) {
      account_number = json['account_number'];
    }

    if (json['roles'] != null) {
      roles = new List<Roles>();
      json['roles'].forEach((v) {
        roles.add(new Roles.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['image'] = this.image;
    data['email_id'] = this.emailId;
    data['email_verified_at'] = this.emailVerifiedAt;
    data['phone'] = this.phone;
    data['is_verified'] = this.isVerified;
    data['status'] = this.status;
    data['otp'] = this.otp;
    data['faviroute'] = this.faviroute;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['token'] = this.token;

    if (this.ifsc_code != null) {
      data['ifsc_code'] = this.ifsc_code;
    }
    if (this.micr_code != null) {
      data['micr_code'] = this.micr_code;
    }
    if (this.language != null) {
      data['language'] = this.language;
    }

    if (this.account_number != null) {
      data['account_number'] = this.account_number;
    }

    if (this.account_number != null) {
      data['account_number'] = this.account_number;
    }

    if (this.roles != null) {
      data['roles'] = this.roles.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Roles {
  int id;
  String title;
  String createdAt;
  String updatedAt;
  Pivot pivot;

  Roles({this.id, this.title, this.createdAt, this.updatedAt, this.pivot});

  Roles.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    pivot = json['pivot'] != null ? new Pivot.fromJson(json['pivot']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['title'] = this.title;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    if (this.pivot != null) {
      data['pivot'] = this.pivot.toJson();
    }
    return data;
  }
}

class Pivot {
  int userId;
  int roleId;

  Pivot({this.userId, this.roleId});

  Pivot.fromJson(Map<String, dynamic> json) {
    userId = json['user_id'];
    roleId = json['role_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['user_id'] = this.userId;
    data['role_id'] = this.roleId;
    return data;
  }
}
