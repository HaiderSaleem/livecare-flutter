import 'package:flutter/material.dart';
import 'package:livecare/resources/app_colors.dart';
import 'package:livecare/resources/app_dimens.dart';

abstract class AppStyles {

  static const TextStyle inputTextStyle = TextStyle(
      color: AppColors.textBlack,
      fontSize: AppDimens.kFontNormal,
      fontFamily: "Lato");

  static const TextStyle buttonTextStyle = TextStyle(
    color: AppColors.textWhite,
    fontFamily: "Lato",
    fontSize: AppDimens.kFontTextButton,
    fontWeight: FontWeight.w700,);

  static const TextStyle textStyle = TextStyle(
    color: AppColors.textWhite,
    fontSize: AppDimens.kFontLabel,
    fontFamily: "Lato",);

  static const TextStyle textBlackStyle = TextStyle(
    color: AppColors.textBlack,
    fontSize: AppDimens.kFontLabel,
    fontFamily: "Lato",);

  static const TextStyle textCellHeaderStyle = TextStyle(
    color: AppColors.textWhite,
    fontSize: AppDimens.kFontBold,
    fontWeight: FontWeight.w700,
    fontFamily: "Lato",);

  static const TextStyle textCellStyle = TextStyle(
    color: AppColors.textBlack,
    fontSize: AppDimens.kFontNormal,
    fontFamily: "Lato",);

  static const TextStyle textTitleStyle = TextStyle(
    color: AppColors.textGrayDark,
    fontSize: AppDimens.kFontTitle,
    fontFamily: "Lato",);

  static const TextStyle textTitleBoldStyle = TextStyle(
    color: AppColors.textGrayDark,
    fontSize: AppDimens.kFontTitle,
    fontWeight: FontWeight.w700,
    fontFamily: "Lato",);

  static const TextStyle textCellTitleBoldStyle = TextStyle(
    color: AppColors.textGray,
    fontSize: AppDimens.kFontCellTitle,
    fontWeight: FontWeight.w700,
    fontFamily: "Lato",);

  static const TextStyle textCellTitleStyle = TextStyle(
    color: AppColors.textGray,
    fontSize: AppDimens.kFontCellTitle,
    fontFamily: "Lato",);

  static const TextStyle textCellTextStyle = TextStyle(
    color: AppColors.separatorLineGray,
    fontSize: AppDimens.kFontCellText,
    fontFamily: "Lato",
  );

  static const TextStyle textCellTextBoldStyle = TextStyle(
    color: AppColors.separatorLineGray,
    fontSize: AppDimens.kFontCellText,
    fontWeight: FontWeight.w700,
    fontFamily: "Lato",);

  static const TextStyle textCellDescriptionStyle = TextStyle(
    color: AppColors.textGray,
    fontSize: AppDimens.kFontDescription,
    fontFamily: "Lato",);

  static const TextStyle pageTitle = TextStyle(
    color: AppColors.textWhite,
    fontSize: AppDimens.kFontBold,
    fontWeight: FontWeight.w700,
    fontFamily: "Lato",);

  static const TextStyle textGrey = TextStyle(
    fontSize: AppDimens.kFontLabel,
    fontFamily: "Lato",
  );

  static const TextStyle hintText = TextStyle(
      fontSize: AppDimens.kFontLabel,
      fontFamily: "Lato",
      color: AppColors.hintColor);

  static const TextStyle dialogTitle =
      TextStyle(fontFamily: "Lato", color: AppColors.primaryColor);

  static const TextStyle dialogbutton =
      TextStyle(fontFamily: "Lato", color: AppColors.buttonRed);

  static const TextStyle bottomMenuText = TextStyle(
      fontFamily: "Lato",
      fontSize: AppDimens.kFontBold,
      color: AppColors.primaryColor,
      fontWeight: FontWeight.w300);

  static const TextStyle bottomMenuCancelText = TextStyle(
      fontFamily: "Lato",
      fontSize: AppDimens.kFontBold,
      color: AppColors.primaryColor,
      fontWeight: FontWeight.w700);

  static const TextStyle boldText = TextStyle(
      fontFamily: "Lato",
      fontSize: AppDimens.kFontBold,
      color: AppColors.textBlack,
      fontWeight: FontWeight.w700);

  static const TextStyle textTiny = TextStyle(
    fontFamily: "Lato",
    fontSize: AppDimens.kFontTiny,
  );

  static const TextStyle dollarText = TextStyle(
      fontFamily: "Lato",
      fontSize: AppDimens.dollarFont,
      color: AppColors.textBlack,
      fontWeight: FontWeight.w700);

  static const TextStyle headingText = TextStyle(
      fontStyle: FontStyle.normal,
      fontFamily: "Lato",
      color: AppColors.textBlack,
      fontSize: AppDimens.kFontNormal,
      fontWeight: FontWeight.w300);

  static const TextStyle rideInformation = TextStyle(
      fontStyle: FontStyle.normal,
      fontFamily: "Lato",
      color: AppColors.textBlack,
      fontSize: AppDimens.kFontNormal,
      fontWeight: FontWeight.w700);

  static const TextStyle tripInformation = TextStyle(
      fontStyle: FontStyle.normal,
      fontFamily: "Lato",
      color: AppColors.primaryColor,
      fontSize: AppDimens.kFontTitle,
      fontWeight: FontWeight.w700);

  static const TextStyle dropDownText = TextStyle(
      fontFamily: "Lato",
      color: AppColors.shareLightBlue,
      fontSize: AppDimens.kFontCellText,
      fontWeight: FontWeight.w700);

  static const TextStyle totalTransactionText = TextStyle(
    fontStyle: FontStyle.normal,
    fontFamily: "Lato",
    fontSize: AppDimens.kFontBold,
    fontWeight: FontWeight.w300,
    color: AppColors.textBlack,
  );

  static const TextStyle filloutForms = TextStyle(
    fontStyle: FontStyle.normal,
    fontFamily: "Lato",
    fontSize: AppDimens.kFontTitle,
    fontWeight: FontWeight.w400,
    color: AppColors.textBlack);

  static const TextStyle amountText = TextStyle(
      fontStyle: FontStyle.normal,
      fontFamily: "Lato",
      color: AppColors.textBlack,
      fontSize: AppDimens.kFontNormal,
      fontWeight: FontWeight.w300);

  static const TextStyle headingValue = TextStyle(
      fontStyle: FontStyle.normal,
      fontFamily: "Lato",
      color: AppColors.textBlack,
      fontSize: AppDimens.kFontNormal,
      fontWeight: FontWeight.w300);

  static const TextStyle buttonSave = TextStyle(
    color: AppColors.textWhite,
    fontSize: AppDimens.kFontTitle,
    fontFamily: "Lato"
  );

  static ButtonStyle defaultButtonStyle = ElevatedButton.styleFrom(
    foregroundColor: AppColors.primaryColor, backgroundColor: AppColors.buttonBackground,
    minimumSize: const Size(double.infinity, AppDimens.kButtonHeight),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(20)),
    ),
  );

  static ButtonStyle roundButtonStyle = ElevatedButton.styleFrom(
    foregroundColor: AppColors.primaryColor, backgroundColor: AppColors.primaryColor,
    minimumSize: const Size(double.infinity, 45),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(10)),
    ),
  );

  static ButtonStyle whiteRoundButtonStyle = ElevatedButton.styleFrom(
    foregroundColor: AppColors.textWhite, backgroundColor: AppColors.textWhite,
    minimumSize: const Size(double.infinity, 45),
    shape: const RoundedRectangleBorder(
      side:BorderSide(color: AppColors.primaryColor, width: 1),
      borderRadius: BorderRadius.all(Radius.circular(10)),
    ),
  );

  static ButtonStyle normalButtonStyle = ElevatedButton.styleFrom(
    foregroundColor: AppColors.primaryColor, backgroundColor: AppColors.buttonBackground,
    minimumSize: const Size(double.infinity, AppDimens.kButtonHeight),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(0)),
    ),
  );

  static ButtonStyle deleteButtonStyle = ElevatedButton.styleFrom(
    foregroundColor: AppColors.buttonRed, backgroundColor: AppColors.buttonRed,
    minimumSize: const Size(50, AppDimens.kButtonHeight),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(16)),
    ),
  );

  static InputDecoration textInputDecoration = InputDecoration(
      contentPadding: AppDimens.kMarginSsmall,
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: AppColors.defaultBackground),
        borderRadius: BorderRadius.circular(30.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: AppColors.defaultBackground),
        borderRadius: BorderRadius.circular(30.0),
      ),
      border: const OutlineInputBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(30.0),
        ),
      ),
      filled: true,
      fillColor: AppColors.defaultBackground);

  static InputDecoration autoCompleteField = InputDecoration(
      contentPadding: AppDimens.kMarginSsmall,
      enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: AppColors.separatorLineGray),
          borderRadius: BorderRadius.circular(5.0)),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: AppColors.separatorLineGray),
        borderRadius: BorderRadius.circular(5.0),
      ),
      border: const OutlineInputBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(5.0),
        ),
      ),
      filled: true,
      hintStyle: const TextStyle(color: AppColors.hintColor),
      fillColor: AppColors.textWhite);

  static InputDecoration searchInputDecoration = InputDecoration(
      contentPadding: AppDimens.kMarginSsmall,
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: AppColors.defaultBackground),
        borderRadius: BorderRadius.circular(6.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: AppColors.defaultBackground),
        borderRadius: BorderRadius.circular(6.0),
      ),
      border: const OutlineInputBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(6.0),
        ),
      ),
      filled: true,
      fillColor: AppColors.textWhite);

  static InputDecoration transactionInputDecoration = const InputDecoration(
      contentPadding: AppDimens.kMarginSsmall,
      filled: true,
      hintStyle: AppStyles.textGrey,
      border: InputBorder.none,
      focusedBorder: InputBorder.none,
      enabledBorder: InputBorder.none,
      errorBorder: InputBorder.none,
      disabledBorder: InputBorder.none,
      fillColor: Colors.transparent);

  static ThemeData appTheme = ThemeData(
      primarySwatch: Colors.blueGrey,
      primaryColorDark: AppColors.primaryColorDark,

      primaryColor: AppColors.primaryColor);


}
