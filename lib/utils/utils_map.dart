import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class UtilsMap {
  static const double cameraBearing = 30;
  static const double cameraTilt = 0;
  static const double cameraZoom = 16;

  static LatLngBounds boundsFromLatLngList(List<LatLng> list) {
    assert(list.isNotEmpty);
    double? x0, x1, y0, y1;
    for (LatLng latLng in list) {
      if (x0 == null) {
        x0 = x1 = latLng.latitude;
        y0 = y1 = latLng.longitude;
      } else {
        if (latLng.latitude > x1!) x1 = latLng.latitude;
        if (latLng.latitude < x0) x0 = latLng.latitude;
        if (latLng.longitude > y1!) y1 = latLng.longitude;
        if (latLng.longitude < y0!) y0 = latLng.longitude;
      }
    }
    return LatLngBounds(northeast: LatLng(x1!, y1!), southwest: LatLng(x0!, y0!));
  }


  static launchMap(BuildContext context, lat, lng) async {
    var url = '';

    if (Platform.isAndroid) {
      url = "google.navigation:q=$lat,$lng";
    } else {
       url = "comgooglemaps://?saddr=&daddr=$lat, $lng&destination=$lat, $lng&travelmode=driving";

      //url = 'https://maps.apple.com/?q=$lat,$lng';
    }
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(
        Uri.parse(url),
      );
    } else {
      throw 'Could not launch $url';
    }
  }




}
