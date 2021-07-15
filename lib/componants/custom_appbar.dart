import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mealup/utils/constants.dart';
import 'package:mealup/utils/localization/language/languages.dart';

class CustomAppbar extends StatelessWidget with PreferredSizeWidget {
  final Function onOfferTap,onSearchTap,onLocationTap,onFilterTap;
  bool isFilter = false;

  String strSelectedAddress = '';
  CustomAppbar({@required this.onOfferTap,this.isFilter,@required this.onSearchTap,@required this.onLocationTap,this.onFilterTap,this.strSelectedAddress});


  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: onLocationTap,
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: SvgPicture.asset(
                    'images/ic_map.svg',
                    width: 18,
                    height: 18,
                    color: Color(Constants.color_theme),
                  ),
                ),
                Container(
                  width: ScreenUtil().setWidth(150),
                  child: Text(
                    strSelectedAddress.isEmpty || strSelectedAddress == null ? Languages.of(context).labelSelectAddress : strSelectedAddress,
                      overflow: TextOverflow.ellipsis,
                    style:
                        TextStyle(fontSize: 16.0, fontFamily: Constants.app_font),
                  ),
                ),
                Icon(Icons.keyboard_arrow_down),
              ],
            ),
          ),
          Row(
            children: [
           /*   Padding(
                padding: const EdgeInsets.only(right: 20),
                child: GestureDetector(
                  onTap: onOfferTap,
                  child: SvgPicture.asset(
                    'images/offers.svg',
                    width: 18,
                    height: 18,
                  ),
                ),
              ),*/
              Visibility(
                visible: isFilter,
                child: Padding(
                  padding: const EdgeInsets.only(right: 20),
                  child: GestureDetector(
                    onTap: onFilterTap,
                    child: SvgPicture.asset(
                      'images/ic_filter.svg',
                      width: 18,
                      height: 18,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 10),
                child: GestureDetector(
                  onTap: onSearchTap,
                  child: SvgPicture.asset(
                    'images/search.svg',
                    width: 18,
                    height: 18,
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
