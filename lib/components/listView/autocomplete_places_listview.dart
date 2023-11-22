import 'package:flutter/material.dart';
import 'package:livecare/resources/app_dimens.dart';
import 'package:livecare/resources/app_styles.dart';
import 'package:livecare/screens/base/base_screen.dart';
import 'package:livecare/screens/request/create/ride_details_screen.dart';

class AutocompletePlacesListView extends BaseScreen {
  final Iterable<AutoCompleteSearchItem> options;
  final AutocompleteOnSelected<AutoCompleteSearchItem>? onSelected;

  const AutocompletePlacesListView({Key? key, required this.options, this.onSelected}) : super(key: key);

  @override
  _AutocompletePlacesListViewState createState() => _AutocompletePlacesListViewState();
}

class _AutocompletePlacesListViewState extends BaseScreenState<AutocompletePlacesListView> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      padding: const EdgeInsets.all(8.0),
      itemCount: widget.options.length,
      itemBuilder: (BuildContext context, int index) {
        final AutoCompleteSearchItem option = widget.options.elementAt(index);
        return GestureDetector(
          onTap: () {
            widget.onSelected!(option);
          },
          child: Container(
            color: Colors.white,
            padding: AppDimens.kVerticalMarginSsmall.copyWith(bottom: 0),
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  option.szName,
                  style: AppStyles.dropDownText,
                ),
                Text(
                  option.szAddress,
                  style: AppStyles.textGrey,
                ),
                const Divider(
                  height: 10,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
