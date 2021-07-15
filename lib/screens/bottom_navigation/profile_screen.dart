import 'package:cached_network_image/cached_network_image.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mealup/screen_animation_utils/transitions.dart';
import 'package:mealup/screens/login_screen.dart';
import 'package:mealup/screens/order_history_screen.dart';
import 'package:mealup/screens/wallet/wallet_screen.dart';
import 'package:mealup/utils/SharedPreferenceUtil.dart';
import 'package:mealup/utils/constants.dart';
import 'package:mealup/utils/localization/language/languages.dart';
import 'package:share/share.dart';
import '../setting_screen.dart';
import '../your_favorites_screen.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    if (!SharedPreferenceUtil.getBool(Constants.isLoggedIn)) {
      Future.delayed(
        Duration(seconds: 0),
        () => Navigator.of(context).pushAndRemoveUntil(
            Transitions(
              transitionType: TransitionType.fade,
              curve: Curves.bounceInOut,
              reverseCurve: Curves.fastLinearToSlowEaseIn,
              widget: LoginScreen(),
            ),
            (Route<dynamic> route) => false),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final space = SizedBox(height: 50);

    return SafeArea(
      child: Scaffold(
          appBar: AppBar(
            elevation: 0,
            title: Text(Languages.of(context).labelProfile,
                style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 20.0,
                    fontFamily: Constants.app_font_bold)),
          ),
          backgroundColor: Color(0xFFFAFAFA),
          body: LayoutBuilder(
            builder:
                (BuildContext context, BoxConstraints viewportConstraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints:
                      BoxConstraints(minHeight: viewportConstraints.maxHeight),
                  child: Container(
                    decoration: BoxDecoration(
                        image: DecorationImage(
                      image: AssetImage('images/ic_background_image.png'),
                      fit: BoxFit.cover,
                    )),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(
                          child: Column(
                            children: [
                              // loginUserImage
                              ClipOval(
                                child: CachedNetworkImage(
                                  width: ScreenUtil().setWidth(100),
                                  height: ScreenUtil().setHeight(100),
                                  imageUrl: SharedPreferenceUtil.getString(
                                      Constants.loginUserImage),
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) =>
                                      CircularProgressIndicator(),
                                  errorWidget: (context, url, error) =>
                                      Icon(Icons.error),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 15),
                                child: Text(
                                  SharedPreferenceUtil.getString(
                                      Constants.loginUserName),
                                  style: TextStyle(
                                      fontFamily: Constants.app_font_bold,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18),
                                ),
                              ),
                              Text(
                                '',
                                style: TextStyle(
                                    fontFamily: Constants.app_font,
                                    fontSize: 12,
                                    color: Color(Constants.color_gray)),
                              )
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 20),
                          child: Container(
                            child: Column(
                              children: [
                                Visibility(
                                  visible: SharedPreferenceUtil.getString(Constants.appPaymentWallet) == '1'? true :true,
                                  child: ProfileMenuWidget(
                                    str_ImagePath: 'images/wallet.svg',
                                    str_menuName: Languages.of(context).walletSetting,
                                    onClick: () {
                                      Navigator.of(context).push(Transitions(
                                          transitionType: TransitionType.slideUp,
                                          curve: Curves.bounceInOut,
                                          reverseCurve:
                                          Curves.fastLinearToSlowEaseIn,
                                          widget: WalletScreen()));
                                    },
                                  ),
                                ),
                                ProfileMenuWidget(
                                  str_ImagePath: 'images/ic_settings.svg',
                                  str_menuName:
                                      Languages.of(context).screenSetting,
                                  onClick: () {
                                    Navigator.of(context).push(Transitions(
                                        transitionType: TransitionType.slideUp,
                                        curve: Curves.bounceInOut,
                                        reverseCurve:
                                            Curves.fastLinearToSlowEaseIn,
                                        widget: SettingScreen()));
                                  },
                                ),
                                ProfileMenuWidget(
                                  str_ImagePath: 'images/ic_heart.svg',
                                  str_menuName:
                                      Languages.of(context).labelYourFavorites,
                                  onClick: () {
                                    Navigator.of(context).push(Transitions(
                                        transitionType: TransitionType.fade,
                                        curve: Curves.bounceInOut,
                                        reverseCurve:
                                            Curves.fastLinearToSlowEaseIn,
                                        widget: YourFavoritesScreen()));
                                  },
                                ),
                                ProfileMenuWidget(
                                  str_ImagePath: 'images/ic_clock.svg',
                                  str_menuName:
                                      Languages.of(context).labelOrderHistory,
                                  onClick: () {
                                    Navigator.of(context).push(Transitions(
                                        transitionType: TransitionType.fade,
                                        curve: Curves.bounceInOut,
                                        reverseCurve:
                                            Curves.fastLinearToSlowEaseIn,
                                        widget: OrderHistoryScreen(
                                          isFromProfile: true,
                                        )));
                                  },
                                ),
                                ProfileMenuWidget(
                                  str_ImagePath: 'images/ic_share.svg',
                                  str_menuName: Languages.of(context)
                                      .labelShareWithFriends,
                                  onClick: () {
                                    Share.share(
                                        "https://play.google.com/store/apps/details?id=app.saasmonsk.mealup");
                                    // share();
                                  },
                                ),
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              );
            },
          )),
    );
  }
}

class ProfileMenuWidget extends StatelessWidget {
  Function onClick;
  String str_ImagePath, str_menuName;

  ProfileMenuWidget(
      {@required this.onClick,
      @required this.str_ImagePath,
      @required this.str_menuName});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 20),
      child: InkWell(
        onTap: onClick,
        child: Container(
          height: 70,
          child: Row(
            children: [
              SvgPicture.asset(
                str_ImagePath,
                width: 20,
                height: 20,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      SizedBox(
                        height: 15,
                      ),
                      Container(
                        child: Text(
                          str_menuName,
                          style: TextStyle(
                              fontSize: 16, fontFamily: Constants.app_font),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                        alignment: Alignment.center,
                        child: DottedLine(
                          direction: Axis.horizontal,
                          dashColor: Color(0xffcccccc),
                        ),
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
