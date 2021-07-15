import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mealup/network_api/Retro_Api.dart';
import 'package:mealup/network_api/api_client.dart';
import 'package:mealup/screen_animation_utils/transitions.dart';
import 'package:mealup/screens/wallet/wallet_payment_method_screen.dart';
import 'package:mealup/utils/app_toolbar.dart';
import 'package:mealup/utils/constants.dart';
import 'package:mealup/utils/localization/language/languages.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class WalletAddScreen extends StatefulWidget {
  @override
  _WalletAddScreenState createState() => _WalletAddScreenState();
}

class _WalletAddScreenState extends State<WalletAddScreen> {
  bool _isSyncing = false;
  String balance = '';
  TextEditingController amountController = new TextEditingController();

  @override
  void initState() {
    super.initState();
    amountController.text = '';
    Constants.CheckNetwork().whenComplete(() => getWalletBalance());
  }

  void _onRefresh() async {
    // monitor network fetch
    await Future.delayed(Duration(milliseconds: 1000));
    // if failed,use refreshFailed()
    Constants.CheckNetwork().whenComplete(() => getWalletBalance());
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: ApplicationToolbar(appbarTitle: '' //Languages.of(context).walletSetting,
            ),
        body: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints viewportConstraints) {
            return ConstrainedBox(
                constraints: BoxConstraints(minHeight: viewportConstraints.maxHeight),
                child: Container(
                  decoration: BoxDecoration(
                      image: DecorationImage(
                    image: AssetImage('images/ic_background_image.png'),
                    fit: BoxFit.cover,
                  )),
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    child: ModalProgressHUD(
                      inAsyncCall: _isSyncing,
                      child: Container(
                        margin: EdgeInsets.only(left: 20, right: 20),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: EdgeInsets.all(10),
                                margin: EdgeInsets.only(top: 10, bottom: 10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Text(
                                      Languages.of(context).mealUpWallet,
                                      style: TextStyle(
                                          color: Color(Constants.color_black),
                                          fontFamily: Constants.app_font_bold,
                                          fontSize: 22),
                                    ),
                                    Text(
                                      "${Languages.of(context).availableMealUpBalance} \u0024$balance",
                                      style: TextStyle(
                                          color: Color(Constants.color_black),
                                          fontFamily: Constants.app_font,
                                          fontSize: 16),
                                    ),
                                    SizedBox(
                                      height: 30,
                                    ),
                                    Column(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          Languages.of(context).addMoney,
                                          style: TextStyle(
                                              color: Color(Constants.color_black),
                                              fontFamily: Constants.app_font_bold,
                                              fontSize: 20),
                                        ),
                                        SizedBox(
                                          height: 20,
                                        ),
                                        TextField(
                                          style: TextStyle(color: Colors.black, fontSize: 25),
                                          controller: amountController,
                                          decoration: InputDecoration(
                                            contentPadding:
                                                EdgeInsets.symmetric(vertical: 0, horizontal: 20),
                                            border: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                width: 1,
                                                style: BorderStyle.none,
                                              ),
                                              borderRadius: BorderRadius.all(Radius.circular(10)),
                                            ),
                                            hintText: Languages.of(context).enterAmount,
                                            hintStyle: TextStyle(
                                                color: Color(Constants.color_gray),
                                                fontSize: 25,
                                                fontFamily: Constants.app_font_bold),
                                          ),
                                        ),
                                        SizedBox(
                                          height: 30,
                                        ),
                                        Center(
                                          child: Text(
                                            Languages.of(context).moneyWillBeAddedToMealUpWallet,
                                            style: TextStyle(
                                                color: Color(Constants.color_black),
                                                fontFamily: Constants.app_font,
                                                fontSize: 14),
                                          ),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width,
                                child: RawMaterialButton(
                                  onPressed: () {
                                    if (amountController.text.isEmpty) {
                                      Constants.toastMessage('Enter amount');
                                    } else {
                                      Navigator.of(context).pushReplacement(
                                        Transitions(
                                          transitionType: TransitionType.fade,
                                          curve: Curves.bounceInOut,
                                          reverseCurve: Curves.fastLinearToSlowEaseIn,
                                          widget: WalletPaymentMethodScreen(
                                            orderAmount: amountController.text.toString(),
                                          ),
                                        ),
                                      );
                                      /*Map<String, String> body = {
                                            'amount': amountController.text.toString(),
                                            'payment_type': 'paypal',
                                            'payment_token': 'fff4f11f1f1',
                                          };
                                          addUserBalance(body);*/
                                    }
                                  },
                                  elevation: 2.0,
                                  fillColor: Colors.green,
                                  child: Text(
                                    'Process',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontFamily: Constants.app_font_bold,
                                        fontSize: 20),
                                  ),
                                  splashColor: Colors.grey.withAlpha(50),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  padding: EdgeInsets.all(10.0),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ));
          },
        ),
      ),
    );
  }

  void addUserBalance(map) {
    setState(() {
      _isSyncing = true;
    });

    RestClient(Retro_Api().Dio_Data()).addBalance(map).then((response) {
      setState(() {
        _isSyncing = false;
        Constants.toastMessage(response.data);
        Navigator.of(context).pop({'selection': 'done'});
      });
    }).catchError((Object obj) {
      setState(() {
        _isSyncing = false;
      });
      /*   switch (obj.runtimeType) {
        case DioError:
          final res = (obj as DioError).response;
          var msg = res.statusMessage;
          var responsecode = res.statusCode;
          if (responsecode == 401) {
            Constants.toastMessage('$responsecode');
            print(responsecode);
            print(res.statusMessage);
          } else if (responsecode == 422) {
            print("code:$responsecode");
            print("msg:$msg");
            Constants.toastMessage('$responsecode');
          } else if (responsecode == 500) {
            print("code:$responsecode");
            print("msg:$msg");
            Constants.toastMessage(
                Languages.of(context).labelInternalServerError);
          }
          break;
        default:
      }*/
    });
  }

  void getWalletBalance() {
    setState(() {
      _isSyncing = true;
    });

    RestClient(Retro_Api().Dio_Data()).getWalletBalance().then((response) {
      setState(() {
        _isSyncing = false;
        balance = response.data;
      });
    }).catchError((Object obj) {
      setState(() {
        _isSyncing = false;
      });
      /* switch (obj.runtimeType) {
        case DioError:
          final res = (obj as DioError).response;
          var msg = res.statusMessage;
          var responsecode = res.statusCode;
          if (responsecode == 401) {
            Constants.toastMessage('$responsecode');
            print(responsecode);
            print(res.statusMessage);
          } else if (responsecode == 422) {
            print("code:$responsecode");
            print("msg:$msg");
            Constants.toastMessage('$responsecode');
          } else if (responsecode == 500) {
            print("code:$responsecode");
            print("msg:$msg");
            Constants.toastMessage(
                Languages.of(context).labelInternalServerError);
          }
          break;
        default:
      }*/
    });
  }
}
