import 'package:ARMOYU/Services/API/api_service.dart';

class FunctionsBlocking {
  final ApiService apiService = ApiService();

  Future<Map<String, dynamic>> list() async {
    Map<String, String> formData = {"": ""};
    Map<String, dynamic> jsonData =
        await apiService.request("engel/0/0/", formData);
    return jsonData;
  }

  Future<Map<String, dynamic>> add(int userID) async {
    Map<String, String> formData = {"userID": "$userID"};
    Map<String, dynamic> jsonData =
        await apiService.request("engel/ekle/0/", formData);
    return jsonData;
  }

  Future<Map<String, dynamic>> remove(int userID) async {
    Map<String, String> formData = {"userID": "$userID"};
    Map<String, dynamic> jsonData =
        await apiService.request("engel/sil/0/", formData);
    return jsonData;
  }
}
