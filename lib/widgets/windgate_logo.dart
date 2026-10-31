import 'package:flutter/material.dart';

enum WindgateLogoVariant { stacked, horizontal, mark }

class WindgateLogo extends StatelessWidget {
  const WindgateLogo({
    super.key,
    this.variant = WindgateLogoVariant.stacked,
    this.width,
    this.height,
  });

  final WindgateLogoVariant variant;
  final double? width;
  final double? height;

  static const String stackedAsset = 'assets/images/windgate_logo_stacked.png';
  static const String horizontalAsset =
      'assets/images/windgate_logo_horizontal.png';
  static const String markAsset = 'assets/images/windgate_mark.png';

  String get _asset => switch (variant) {
    WindgateLogoVariant.stacked => stackedAsset,
    WindgateLogoVariant.horizontal => horizontalAsset,
    WindgateLogoVariant.mark => markAsset,
  };

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      _asset,
      width: width,
      height: height,
      fit: BoxFit.contain,
      semanticLabel: 'Windgate Museum of Art at Hendrix College',
    );
  }
}
