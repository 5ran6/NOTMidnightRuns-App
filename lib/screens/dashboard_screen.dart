import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mealup/screens/bottom_navigation/explore_screen.dart';
import 'package:mealup/screens/bottom_navigation/home_scree.dart';
import 'package:mealup/screens/bottom_navigation/my_cart_screen.dart';
import 'package:mealup/screens/bottom_navigation/profile_screen.dart';
import 'package:mealup/utils/SharedPreferenceUtil.dart';
import 'package:mealup/utils/constants.dart';
import 'package:mealup/utils/localization/language/languages.dart';

class DashboardScreen extends StatefulWidget {
  int _currentIndex;
  int save_prev_index;

  DashboardScreen(_currentIndex) {
    this._currentIndex = _currentIndex;
  }

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
  }

  final List<Widget> _children = [HomeScreen(), ExploreScreen(), MyCartScreen(), ProfileScreen()];

  Future<bool> _onWillPop() {
    setState(() {
      if (widget._currentIndex != 0) {
        if (widget._currentIndex == widget.save_prev_index) {
          widget._currentIndex--;
        } else if (widget.save_prev_index != null) {
          widget._currentIndex = widget.save_prev_index;
        } else {
          widget._currentIndex = 0;
        }
      } else {
        showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text(Languages.of(context).labelConfirmExit),
                content: Text(Languages.of(context).labelAreYouSureExit),
                actions: <Widget>[
                  FlatButton(
                    child: Text(Languages.of(context).labelYES),
                    onPressed: () {
                      SystemNavigator.pop();
                    },
                  ),
                  FlatButton(
                    child: Text(Languages.of(context).labelNO),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  )
                ],
              );
            });
        return Future.value(true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    dynamic screenWidth = MediaQuery.of(context).size.width;
    dynamic screenHeight = MediaQuery.of(context).size.height;

    ScreenUtil.init(BoxConstraints(maxWidth: screenWidth, maxHeight: screenHeight),
        designSize: Size(360, 690), orientation: Orientation.portrait);

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        body: _children[widget._currentIndex],
        bottomNavigationBar: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            backgroundColor: Color(Constants.color_theme),
            selectedItemColor: Colors.black,
            unselectedItemColor: Colors.white,
            selectedFontSize: 12,
            unselectedFontSize: 12,
            currentIndex: widget._currentIndex,
            onTap: (value) {
              print(value);
              setState(() {
                widget.save_prev_index = widget._currentIndex;
                widget._currentIndex = value;
              });
            },
            items: [
              BottomNavigationBarItem(
                icon: SvgPicture.asset(
                  'images/ic_home.svg',
                  height: ScreenUtil().setHeight(25),
                  width: 25,
                  color: Colors.white,
                ),
                activeIcon: SvgPicture.asset(
                  'images/ic_home.svg',
                  height: ScreenUtil().setHeight(25),
                  width: 25,
                ),
                title: Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(Languages.of(context).labelHome),
                ),
              ),
              BottomNavigationBarItem(
                icon: SvgPicture.asset(
                  'images/ic_explore.svg',
                  height: ScreenUtil().setHeight(25),
                  width: 25,
                  color: Colors.white,
                ),
                activeIcon: SvgPicture.asset(
                  'images/ic_explore.svg',
                  height: ScreenUtil().setHeight(25),
                  width: 25,
                ),
                title: Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(Languages.of(context).labelExplore),
                ),
              ),
              BottomNavigationBarItem(
                icon: SvgPicture.asset(
                  'images/ic_cart.svg',
                  height: ScreenUtil().setHeight(25),
                  width: 25,
                  color: Colors.white,
                ),
                activeIcon: SvgPicture.asset(
                  'images/ic_cart.svg',
                  height: ScreenUtil().setHeight(25),
                  width: 25,
                ),
                title: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(Languages.of(context).labelCart),
                ),
              ),
              BottomNavigationBarItem(
                icon: Container(
                  width: ScreenUtil().setHeight(25),
                  height: ScreenUtil().setHeight(25),
                  decoration: new BoxDecoration(
                    color: const Color(0xff7c94b6),
                    image: new DecorationImage(
                      image: new NetworkImage(
                          SharedPreferenceUtil.getString(Constants.loginUserImage)),
                      fit: BoxFit.cover,
                    ),
                    borderRadius: new BorderRadius.all(new Radius.circular(50.0)),
                    border: new Border.all(
                      color: Colors.white,
                      width: 2.0,
                    ),
                  ),
                ),
                activeIcon: Container(
                  width: ScreenUtil().setHeight(25),
                  height: ScreenUtil().setHeight(25),
                  decoration: new BoxDecoration(
                    color: const Color(0xff7c94b6),
                    image: new DecorationImage(
                      image: new NetworkImage(
                          SharedPreferenceUtil.getString(Constants.loginUserImage)),
                      fit: BoxFit.cover,
                    ),
                    borderRadius: new BorderRadius.all(new Radius.circular(50.0)),
                  ),
                ),
                title: Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(Languages.of(context).labelProfile),
                ),
              ),
            ]),
      ),
    );
  }
}
