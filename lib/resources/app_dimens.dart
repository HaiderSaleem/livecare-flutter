import 'package:flutter/material.dart';

/// App Dimensions Class - Resource class for storing app level dimensions constants
abstract class AppDimens {
  static double getHeight(BuildContext context) =>
      MediaQuery.of(context).size.width;

  static double getWidth(BuildContext context) =>
      MediaQuery.of(context).size.width;

  static const EdgeInsets kActivityHorizontalMargin =
      EdgeInsets.symmetric(horizontal: 16.0);
  static const EdgeInsets kActivityVerticalMargin =
      EdgeInsets.symmetric(vertical: 16.0);
  static const EdgeInsets kNavHeaderVerticalSpacing =
      EdgeInsets.symmetric(vertical: 16.0);
  static const double kNavHeaderHeight = 16.0;
  static const double kFabMargin = 16.0;

  static const EdgeInsets kMarginNormal = EdgeInsets.all(16.0);
  static const EdgeInsets kMarginSmall = EdgeInsets.all(12.0);
  static const EdgeInsets kMarginSsmall = EdgeInsets.all(8.0);
  static const EdgeInsets kMarginSssmall = EdgeInsets.all(4.0);
  static const EdgeInsets kMarginTiny = EdgeInsets.all(2.0);
  static const EdgeInsets kMarginBig = EdgeInsets.all(20.0);
  static const EdgeInsets kMarginBbig = EdgeInsets.all(24.0);
  static const EdgeInsets kMarginBbbig = EdgeInsets.all(28.0);
  static const EdgeInsets kMarginHuge = EdgeInsets.all(32.0);

 
  static const EdgeInsets kVerticalMarginNormal =
      EdgeInsets.symmetric(vertical: 16.0);
  static const EdgeInsets kVerticalMarginSmall =
      EdgeInsets.symmetric(vertical: 12.0);
  static const EdgeInsets kVerticalMarginSsmall =
      EdgeInsets.symmetric(vertical: 8.0);
  static const EdgeInsets kVerticalMarginSssmall =
      EdgeInsets.symmetric(vertical: 4.0);
  static const EdgeInsets kVerticalMarginTiny =
      EdgeInsets.symmetric(vertical: 2.0);
  static const EdgeInsets kVerticalMarginBig =
      EdgeInsets.symmetric(vertical: 20.0);
  static const EdgeInsets kVerticalMarginBbig =
      EdgeInsets.symmetric(vertical: 24.0);
  static const EdgeInsets kVerticalMarginBbbig =
      EdgeInsets.symmetric(vertical: 28.0);
  static const EdgeInsets kVerticalMarginHuge =
      EdgeInsets.symmetric(vertical: 32.0);
  static const EdgeInsets kHorizontalMarginNormal =
      EdgeInsets.symmetric(horizontal: 16.0);
  static const EdgeInsets kHorizontalMarginSmall =
      EdgeInsets.symmetric(horizontal: 12.0);
  static const EdgeInsets kHorizontalMarginSsmall =
      EdgeInsets.symmetric(horizontal: 8.0);
  static const EdgeInsets kHorizontalMarginSssmall =
      EdgeInsets.symmetric(horizontal: 4.0);
  static const EdgeInsets kHorizontalMarginTiny =
      EdgeInsets.symmetric(horizontal: 2.0);
  static const EdgeInsets kHorizontalMarginBig =
      EdgeInsets.symmetric(horizontal: 20.0);
  static const EdgeInsets kHorizontalMarginBbig =
      EdgeInsets.symmetric(horizontal: 24.0);
  static const EdgeInsets kHorizontalMarginBbbig =
      EdgeInsets.symmetric(horizontal: 28.0);
  static const EdgeInsets kHorizontalMarginHuge =
      EdgeInsets.symmetric(horizontal: 32.0);

  static const double separatorLine = 1.0;
  static const double dollarFont = 32.0;
  static const double kFontNormal = 15.0;
  static const double kFontBold = 16.0;
  static const double kFontTextButton = 14.0;
  static const double kFontTitle = 18.0;
  static const double kFontDescription = 12.0;
  static const double kFontTiny = 10.0;
  static const double kFontLabel = 14.0;
  static const double kFontCellTitle = 14.0;
  static const double kFontCellTitle1 = 13.0;
  static const double kFontCellText = 12.0;
  static const double kFontCellTextSmall = 10.0;

  static const double kButtonHeight = 36.0;
  static const double kButtonHeightSmall = 30.0;
  static const double kButtonHeightHalf = 18.0;
  static const double kEdittextHeight = 36.0;
  static const double kEdittextHeightHalf = 18.0;

  static const double kLabelWidth = 100.0;
  static const double kLabelWidthSmall = 80.0;
  static const double kLabelWidthBig = 120.0;

  static const double kConsumerAvatarSize = 50.0;

  static const double kAuditModalWidth = 300.0;
  static const double kAuditModalHeight = 380.0;

  static const double kFab1Distance = 160.0;
  static const double kFab2Distance = 110.0;
  static const double kFab3Distance = 60.0;

}
