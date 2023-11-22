import 'package:flutter/material.dart';
import 'package:livecare/resources/app_dimens.dart';
import 'package:livecare/resources/app_styles.dart';
import 'package:livecare/screens/base/base_screen.dart';

import '../../models/request/dataModel/location_data_model.dart';

class AutocompleteLocationsListView extends BaseScreen {
  final Iterable<LocationDataModel> options;
  final AutocompleteOnSelected<LocationDataModel>? onSelected;

  const AutocompleteLocationsListView({Key? key, required this.options, this.onSelected}) : super(key: key);

  @override
  _AutocompleteLocationsListViewState createState() => _AutocompleteLocationsListViewState();
}

class _AutocompleteLocationsListViewState extends BaseScreenState<AutocompleteLocationsListView> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      padding: const EdgeInsets.all(8.0),
      itemCount: widget.options.length,
      itemBuilder: (BuildContext context, int index) {
        final LocationDataModel option = widget.options.elementAt(index);
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
