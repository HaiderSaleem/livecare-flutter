import 'package:livecare/utils/utils_general.dart';

class UtilsConfig {
  static EnumAppEnvironment enumAppEnvironment = EnumAppEnvironment.production;

  static bool shouldLogForDebugging = const bool.fromEnvironment("dart.vm.product");
  static bool shouldEnableFabric = false;
  static bool shouldMockCurrentLocation = true;
  static String constantsKDispatcherPhoneNumber = "";

  static const String GOOGLE_MAP_API_KEY =
      "AIzaSyBz5W_-edgh8wW7Uox4pexqDkVYlW2gX0M"; //"AIzaSyAOMAR_viNda92ElBBr7Nnf1J4k_kOmu1c"
  static const String GOOGLE_DIRECTION_API_KEY =
      "AIzaSyBz5W_-edgh8wW7Uox4pexqDkVYlW2gX0M"; //"AIzaSyBV7OSGeGGvCB-24MuD_7ZxWAO5UTH-2ms"
  static const String GOOGLE_PLACE_API_KEY =
      "AIzaSyBz5W_-edgh8wW7Uox4pexqDkVYlW2gX0M"; //"AIzaSyAoqIjcNrO55NOrnekgjZnodil_Uks7_is"

}
