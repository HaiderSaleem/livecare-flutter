import 'package:flutter/material.dart';
import 'package:livecare/resources/app_dimens.dart';
import 'package:livecare/resources/app_styles.dart';
import 'package:livecare/screens/base/base_screen.dart';
import '../../utils/auto_complete_consumer_searchitem.dart';


class AutocompleteSearchListView extends BaseScreen {
  final Iterable<AutoCompleteConsumerSearchItem> options;
  final AutocompleteOnSelected<AutoCompleteConsumerSearchItem>? onSelected;

  const AutocompleteSearchListView({Key? key, required this.options, this.onSelected}) : super(key: key);

  @override
  _AutocompleteSearchListViewState createState() => _AutocompleteSearchListViewState();
}

class _AutocompleteSearchListViewState extends BaseScreenState<AutocompleteSearchListView> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      padding: const EdgeInsets.all(8.0),
      itemCount: widget.options.length,
      itemBuilder: (BuildContext context, int index) {
        final AutoCompleteConsumerSearchItem option = widget.options.elementAt(index);
        return GestureDetector(
          onTap: () {
            widget.onSelected!(option);
          },
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: AppDimens.kVerticalMarginSsmall,
                width: double.infinity,
                color: Colors.white,
                child: Text(
                  option.szName,
                  style: AppStyles.dropDownText,
                ),
              ),
              const Divider(
                height: 0.5,
              ),
            ],
          ),
        );
      },
    );
  }
}
