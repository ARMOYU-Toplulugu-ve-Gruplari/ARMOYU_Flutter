import 'dart:developer';

import 'package:ARMOYU/Functions/API_Functions/blocking.dart';
import 'package:ARMOYU/Models/user.dart';
import 'package:ARMOYU/Services/API/api_service.dart';

class ClientFunctionsProfile {
  final User currentUser;
  late final ApiService apiService;

  ClientFunctionsProfile({required this.currentUser}) {
    apiService = ApiService(user: currentUser);
  }

  Future<String> userblock(int userID) async {
    FunctionsBlocking f = FunctionsBlocking(currentUser: currentUser);
    Map<String, dynamic> response = await f.add(userID);
    log(response["aciklama"]);
    return response["aciklama"];
  }
}
