import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:mealup/model/cartmodel.dart';
import 'package:mealup/network_api/Retro_Api.dart';
import 'package:mealup/network_api/api_client.dart';
import 'package:mealup/screen_animation_utils/transitions.dart';
import 'package:mealup/screens/order_history_screen.dart';
import 'package:mealup/utils/SharedPreferenceUtil.dart';
import 'package:mealup/utils/constants.dart';
import 'package:mealup/utils/database_helper.dart';
import 'package:mealup/utils/localization/language/languages.dart';
import 'package:mealup/utils/rounded_corner_app_button.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'package:stripe_payment/stripe_payment.dart';
import 'package:flutter_credit_card/credit_card_form.dart';
import 'package:flutter_credit_card/credit_card_model.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';

class PaymentStripe extends StatefulWidget {
  final int venderId,
      orderAmount,
      addressId,
      vendorDiscountAmount,
      vendorDiscountId;
  final String orderDate,
      orderTime,
      orderStatus,
      orderCustomization,
      ordrePromoCode,
      orderDeliveryType,
      // strTaxAmount,
      orderDeliveryCharge;
  // final double orderItem;
  final List<Map<String, dynamic>> orderItem;
  final List<Map<String, dynamic>> allTax;

  const PaymentStripe(
      {Key key,
      this.venderId,
      this.orderDeliveryCharge,
      this.orderAmount,
      this.addressId,
      this.orderDate,
      this.orderTime,
      this.orderStatus,
      this.orderCustomization,
      this.ordrePromoCode,
      this.orderDeliveryType,
      this.orderItem,
      this.vendorDiscountAmount,
      this.vendorDiscountId,
      this.allTax})
      : super(key: key);
  @override
  _PaymentStripeState createState() => _PaymentStripeState();
}

class _PaymentStripeState extends State<PaymentStripe> {
  ProgressDialog progressDialog;
  final dbHelper = DatabaseHelper.instance;

  String expDate;
  String cvv;

  String patmentType;

  Token _paymentToken;
  PaymentMethod _paymentMethod;
  String _error;
  String _currentSecret; //set this yourself, e.g using curl
  PaymentIntentResult _paymentIntent;
  Source _source;
  String stripePublicKey;
  String stripeSecretKey;
  String stripeToken;
  int paymentTokenKnow;
  int paymentStatus;
  String paymentType;
  ScrollController _controller = ScrollController();
  String cardNumber = '';
  String cardHolderName = '';
  String expiryDate = '';
  String cvvCode = '';
  bool isCvvFocused = false;
  bool showSpinner = false;
  int selectedIndex;
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  @override
  initState() {
    super.initState();
    // getStripePublishKey();
    stripeSecretKey = SharedPreferenceUtil.getString(Constants.appStripeSecretKey);
    stripePublicKey = SharedPreferenceUtil.getString(Constants.appStripePublishKey);
    StripePayment.setOptions(StripeOptions(
        publishableKey: "$stripePublicKey",
        merchantId: "Test",
        androidPayMode: 'test'));
  }

  Future<void> getStripePublishKey() async {
    stripeSecretKey =
        SharedPreferenceUtil.getString(Constants.appStripeSecretKey);
    stripePublicKey =
        SharedPreferenceUtil.getString(Constants.appStripePublishKey);
    StripePayment.setOptions(StripeOptions(
        publishableKey: "$stripePublicKey",
        merchantId: "Test",
        androidPayMode: 'test'));
  }

  void setError(dynamic error) {
    showSpinner = false;
    _scaffoldKey.currentState
        .showSnackBar(SnackBar(content: Text(error.toString())));
    setState(() {
      _error = error.toString();
    });
  }

  void onCreditCardModelChange(CreditCardModel creditCardModel) {
    setState(() {
      cardNumber = creditCardModel.cardNumber;
      expiryDate = creditCardModel.expiryDate;
      cardHolderName = creditCardModel.cardHolderName;
      cvvCode = creditCardModel.cvvCode;
      isCvvFocused = creditCardModel.isCvvFocused;
    });
  }

  @override
  Widget build(BuildContext context) {
    progressDialog = ProgressDialog(
      context,
      type: ProgressDialogType.Normal,
      isDismissible: false,
    );

    progressDialog.style(
      message: Languages.of(context).labelpleasewait,
      borderRadius: 5.0,
      backgroundColor: Colors.white,
      progressWidget: SpinKitFadingCircle(color: Color(Constants.color_theme)),
      elevation: 10.0,
      insetAnimCurve: Curves.easeInOut,
      progressTextStyle: TextStyle(
          color: Colors.black,
          fontSize: 14.0,
          fontWeight: FontWeight.w600,
          fontFamily: Constants.app_font),
      messageTextStyle: TextStyle(
          color: Colors.black,
          fontSize: 14.0,
          fontWeight: FontWeight.w600,
          fontFamily: Constants.app_font),
    );

    return Scaffold(
      backgroundColor: Colors.grey[800],
      key: _scaffoldKey,
      appBar: new AppBar(
        title: new Text(
          'Stripe Payment',
        ),
        centerTitle: true,
      ),
      body: ModalProgressHUD(
        inAsyncCall: showSpinner,
        child: Container(
          color: Colors.white,
          child: ListView(
            scrollDirection: Axis.vertical,
            controller: _controller,
            children: <Widget>[
              CreditCardWidget(
                cardNumber: cardNumber,
                expiryDate: expiryDate,
                cardHolderName: cardHolderName,
                cvvCode: cvvCode,
                showBackView: isCvvFocused,
              ),
              SingleChildScrollView(
                child: CreditCardForm(
                  onCreditCardModelChange: onCreditCardModelChange,
                ),
              ),
              SizedBox(height: 20.0),
              //click to next
              Container(
                  width: MediaQuery.of(context).size.width,
                  margin:
                      EdgeInsets.only(left: 15, right: 15, top: 10, bottom: 20),
                  child: RoundedCornerAppButton(
                      btn_lable: 'Continue',
                      onPressed: () {
                        showSpinner = true;
                        var expMonth = expiryDate.split('/')[0];
                        var expYear = expiryDate.split('/')[1];
                        int finalExpMonth = int.parse(expMonth.toString());
                        int finalExpYear = int.parse(expYear.toString());
                        StripePayment.createTokenWithCard(
                          CreditCard(
                            number: '$cardNumber',
                            expMonth: finalExpMonth,
                            expYear: finalExpYear,
                            cvc: '$cvvCode',
                            name: '$cardHolderName',
                          ),
                        ).then((token) {
                          _scaffoldKey.currentState.showSnackBar(
                              // SnackBar(content: Text('Received ${token.tokenId}')));
                              SnackBar(content: Text('Payment Completed')));
                          setState(() {
                            showSpinner = false;
                            _paymentToken = token;
                            stripeToken = token.tokenId;
                            SharedPreferenceUtil.putString(
                                Constants.stripePaymentToken, stripeToken);
                            placeOrder();
                          });
                        }).catchError(setError);
                      })),
            ],
          ),
        ),
      ),
    );
  }

  void _deleteTable() async {
    final table = await dbHelper.deleteTable();
    print('table deleted $table');
  }

  void placeOrder() {
    progressDialog.show();
    print('without ${json.encode(widget.orderItem.toString())}');
    String item1 = json.encode(widget.orderItem).toString();
    print('with ${item1.toString()}');
    // var json = jsonEncode(widget.orderItem, toEncodable: (e) => e.toString());
    Map<String, dynamic> item = {"id": 11, "price": 200, "qty": 1};

    item[{"id": 10, "price": 195, "qty": 3}];

    List<Map<String, dynamic>> temp = [];
    temp.add({'id': 10, 'price': 195, 'qty': 3});
    temp.add({'id': 11, 'price': 200, 'qty': 1});

    print('with $item');
    print('temp without ${json.encode(temp.toString())}');
    print('temp with' + json.encode(temp).toString());

    print('item with' + jsonEncode(item));
    // item.addEntries({"id": 2, "price": 200, "qty": 2});
    Map<String, String> body = {
      'vendor_id': widget.venderId.toString(),
      'date': widget.orderDate,
      'time': widget.orderTime,
      //change
      // 'item': widget.orderItem.toString(),
      'item': json.encode(widget.orderItem).toString(),
      // 'item': '[{\'id\':\'11\',\'price\':\'200\',\'qty\':\'1\'},{\'id\':\'10\',\'price\':\'195\',\'qty\':\'3\'}]',
      'amount': widget.orderAmount.toString(),
      'delivery_type': widget.orderDeliveryType,
      'address_id':
          widget.orderDeliveryType == 'SHOP' ? '' : widget.addressId.toString(),
      'delivery_charge': widget.orderDeliveryCharge,
      'payment_type': 'STRIPE',
      'payment_status': '1',
      'order_status': widget.orderStatus,
      'custimization': json.encode(widget.orderCustomization).toString(),
      'promocode_id': widget.ordrePromoCode,
      'payment_token': stripeToken,
      'vendor_discount_price': widget.vendorDiscountAmount != 0
          ? widget.vendorDiscountAmount.toString()
          : '',
      'vendor_discount_id': widget.vendorDiscountId != 0
          ? widget.vendorDiscountId.toString()
          : '',
      // 'tax': widget.strTaxAmount
      'tax': json.encode(widget.allTax).toString(),
    };

    /*RestClient(Retro_Api().Dio_Data())
        .book_order(widget.venderId,widget.orderDate,widget.orderItem,widget.orderTime,widget.orderAmount,widget.orderDeliveryType,
        widget.addressId,widget.orderDeliveryCharge,orderPaymentType,widget.orderPaymentStatus,widget.orderStatus,widget.orderCustomization,
    widget.ordrePromoCode)*/
    RestClient(Retro_Api().Dio_Data()).book_order(body).then((response) {
      progressDialog.hide();
      print(response);
      print(response.success);
      if (response.success) {
        Constants.toastMessage(response.data);
        _deleteTable();
        ScopedModel.of<CartModel>(context, rebuildOnChange: true).clearCart();
        Navigator.pop(context);
        Navigator.of(context).pushAndRemoveUntil(
            Transitions(
              transitionType: TransitionType.fade,
              curve: Curves.bounceInOut,
              reverseCurve: Curves.fastLinearToSlowEaseIn,
              widget: OrderHistoryScreen(
                isFromProfile: false,
              ),
            ),
            (Route<dynamic> route) => true);
      } else {
        Constants.toastMessage('Errow while place order.');
      }
    }).catchError((Object obj) {
      progressDialog.hide();
      switch (obj.runtimeType) {
        case DioError:
          final res = (obj as DioError).response;
          var error = res.data;
          var msg = res.statusMessage;
          var responsecode = res.statusCode;
          if (responsecode == 401) {
            Constants.toastMessage('{status code : $responsecode}');
            print(responsecode);
            print(res.statusMessage);
          } else if (responsecode == 422) {
            print("code:$responsecode");
            print("msg:$msg");
            Constants.toastMessage('{status code : $responsecode}');
          } else if (responsecode == 500) {
            print("code:$responsecode");
            print("msg:$msg");
            print('error is $error');
            Constants.toastMessage(
                Languages.of(context).labelInternalServerError);
          }
          break;
        default:
      }
    });
  }
}
