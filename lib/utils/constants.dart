import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class Constants {
  /*map key*/
  static final String androidKey = 'AIzaSyBo7u69HyRA49RV-VPeTmaJiA3UwbZTwe0';
  static final String iosKey = 'AIzaSyBo7u69HyRA49RV-VPeTmaJiA3UwbZTwe0';

  static int color_black = 0xFF090E21;
  static int color_gray = 0xFF999999;
  static int color_lightgray = 0xFFe8e8e8;
  static int color_like = 0xFFff6060;
  static int color_likelight = 0xFFe2bcbc;
  static int color_theme = 0xFF06C168;
  static int color_orderPending = 0xFFF4AE36;
  static int color_orderPickup = 0xFFd1286b;
  static int color_theme_op = 0xFF9BE6C2;
  static int color_backgroud = 0xFFFAFAFA;
  static int color_rate = 0xFFffc107;
  static int color_blue = 0xFF1492e6;
  static int color_screen_backgroud = 0xFFf2f2f2;
  static int color_hint = 0xFFb9b9b9;
  static String app_font = 'Proxima';
  static String app_font_bold = 'ProximaBold';

  static String registrationOTP = 'regOTP';
  static String registrationEmail = 'regEmail';
  static String registrationPhone = 'regPhone';
  static String registrationUserId = 'userId';

  static String bank_IFSC = 'bank_IFSC';
  static String bank_MICR = 'bank_MICR';
  static String bank_ACC_Name = 'bank_ACC_Name';
  static String bank_ACC_Number = 'bank_ACC_Number';

  static String loginOTP = 'loginOTP';
  static String loginEmail = 'loginEmail';
  static String loginPhone = 'loginPhone';
  static String loginUserId = 'loggeduserId';
  static String loginUserImage = 'loggedImage';
  static String loginUserName = 'loggedName';

/*  static String loginLanguage = 'loginLanguage';
  static String loginIFSC_CODE = 'loginIFSC_CODE';
  static String loginMICR_CODE = 'loginMICR_CODE';
  static String loginBankAccountName = 'loginBankAccountName';
  static String loginBankAccountNumber = 'loginBankAccountNumber';*/

  static String headerToken = 'headerToken';
  static String isLoggedIn = 'isLoggedIn';
  static String stripePaymentToken = 'stripePaymentToken';

  static String selectedAddress = 'selectedAddress';
  static String selectedAddressId = 'selectedAddressId';
  static String recentSearch = 'recentSearch';

  static String appSettingCurrency = 'appSettingCurrency';
  static String appSettingCurrencySymbol = 'appSettingCurrencySymbol';
  static String appSettingPrivacyPolicy = 'appSettingPrivacyPolicy';
  static String appSettingTerm = 'appSettingTerm';
  static String appAboutCompany = 'appAboutCompany';
  static String appSettingHelp = 'appSettingHelp';
  static String appSettingAboutUs = 'appSettingAboutUs';
  static String appSettingDriverAutoRefresh = 'appSettingDriverAutoRefresh';
  static String appSettingBusiness_availability =
      'appSettingBusiness_availability';
  static String appSettingBusiness_message = 'appSettingBusiness_message';
  static String appSettingCustomerAppId = 'appSettingCustomerAppId';
  static String appSetting_android_customer_version =
      'appSetting_android_customer_version';
  static String appSetting_isPickup = 'appSetting_isPickup';
  static String appPush_oneSingleToken = 'push_oneSingleToken';

  static String previousLat = 'previousLat';
  static String previousLng = 'previousLng';

  // payment Setting
  static String this_is_a_testing_app = 'this_is_a_testing_app';
  static String appPaymentWallet = 'appPaymentWallet';
  static String appPaymentCOD = 'appPaymentCOD';
  static String appPaymentStripe = 'appPaymentStripe';
  static String appPaymentRozerPay = 'appPaymentRozerPay';
  static String appPaymentPaypal = 'appPaymentPaypal';
  static String appStripePublishKey = 'appStripePublishKey';
  static String appStripeSecretKey = 'appStripeSecretKey';
  static String appPaypalProduction = 'appPaypalProducation';
  static String appPaypal_client_id = 'appPaypal_client_id';
  static String appPaypal_secret_key = 'appPaypal_secret_key';
  static String appPaypalSendbox = 'appPaypalSendbox';
  static String appRozerpayPublishKey = 'appRozerpayPublishKey';

  static Future<bool> CheckNetwork() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile) {
      return true;
    } else if (connectivityResult == ConnectivityResult.wifi) {
      return true;
    } else {
      Constants.toastMessage("No Internet Connection");
      return false;
    }
  }

  static var kAppLableWidget = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 16.0,
      fontFamily: Constants.app_font_bold);

  static var kTextFieldInputDecoration = InputDecoration(
      hintStyle: TextStyle(color: Color(Constants.color_hint)),
      border: InputBorder.none,
      errorStyle:
          TextStyle(fontFamily: Constants.app_font_bold, color: Colors.red));

  static toastMessage(String msg) {
    Fluttertoast.showToast(
        msg: msg,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.black54,
        textColor: Colors.white,
        fontSize: 16.0);
  }
}
