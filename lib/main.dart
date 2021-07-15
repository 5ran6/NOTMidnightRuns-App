import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:mealup/model/cartmodel.dart';
import 'package:mealup/screens/splash_screen.dart';
import 'package:mealup/utils/SharedPreferenceUtil.dart';
import 'package:mealup/utils/constants.dart';
import 'package:mealup/utils/localization/localizations_delegate.dart';
import 'package:mealup/utils/preference_utils.dart';
import 'package:scoped_model/scoped_model.dart';

import 'utils/localization/locale_constant.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SharedPreferenceUtil.getInstance();
  runApp(MyApp(model: CartModel(),));
}

class MyApp extends StatefulWidget {
  final CartModel model;

  const MyApp({Key key, this.model}) : super(key: key);

  static void setLocale(BuildContext context, Locale newLocale) {
    var state = context.findAncestorStateOfType<_MyAppState>();
    state.setLocale(newLocale);
  }

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Locale _locale;

  void setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  void didChangeDependencies() async {
    getLocale().then((locale) {
      setState(() {
        _locale = locale;
      });
    });
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    PreferenceUtils.init();
    return ScopedModel<CartModel>(
      model: widget.model,
      child: MaterialApp(
        locale: _locale,
        supportedLocales: [
          Locale('en', ''),
          Locale('es', ''),
          Locale('ar', ''),
        ],
        localizationsDelegates: [
          AppLocalizationsDelegate(),
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        localeResolutionCallback: (locale, supportedLocales) {
          for (var supportedLocale in supportedLocales) {
            if (supportedLocale?.languageCode == locale?.languageCode &&
                supportedLocale?.countryCode == locale?.countryCode) {
              return supportedLocale;
            }
          }
          return supportedLocales?.first;
        },
        theme: ThemeData(
          brightness: Brightness.light,
          primaryColor: Color(Constants.color_backgroud),
          accentColor: Color(Constants.color_theme),
        ),
        home: SplashScreen(model: widget.model,),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
