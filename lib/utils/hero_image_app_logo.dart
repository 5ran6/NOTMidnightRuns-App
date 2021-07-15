import 'package:flutter/material.dart';

class HeroImage extends StatelessWidget {
  const HeroImage({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 50.0),
      child: Hero(
        tag: 'App_logo',
        child: Center(
            child: Image.asset('images/ic_intro_logo.'
                'png',
            width: 140.0,
            height: 40,),
        ),
      ),
    );
  }
}
