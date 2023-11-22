
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart';
import 'package:livecare/screens/request/create/ride_details_screen.dart';


// For storing our result
class Suggestion {
  final String placeId;
  final String description;

  Suggestion(this.placeId, this.description);

  @override
  String toString() {
    return 'Suggestion(description: $description, placeId: $placeId)';
  }
}


class PlaceApiProvider {

  final client = Client();

  PlaceApiProvider();

  static const String androidKey = 'AIzaSyBz5W_-edgh8wW7Uox4pexqDkVYlW2gX0M';
  static const String iosKey = 'AIzaSyBz5W_-edgh8wW7Uox4pexqDkVYlW2gX0M';
  final apiKey = Platform.isAndroid ? androidKey : iosKey;

  Future<List<AutoCompleteSearchItem>> fetchSuggestions(String input) async {
   /* final request =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$input&'
        'types=address&components=country:ch&key=$apiKey';*/
    final request = 'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$input&location=40.3468578%-82.6310666&radius=150000&types=address&region=US&key=AIzaSyBz5W_-edgh8wW7Uox4pexqDkVYlW2gX0M';
    final response = await client.get(Uri.parse(request));

    if (response.statusCode == 200) {
      final result = json.decode(response.body);
      if (result['status'] == 'OK') {
        // compose suggestions in a list

        return result['predictions']
            .map<AutoCompleteSearchItem>((p) => AutoCompleteSearchItem.fromJson(p))
            .toList();
      }
      if (result['status'] == 'ZERO_RESULTS') {
        return [];
      }
      throw Exception(result['error_message']);
    } else {
      throw Exception('Failed to fetch suggestion');
    }
  }




}