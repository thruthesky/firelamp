import 'package:firelamp/firelamp.dart';
import 'package:get/get.dart';

/// A controller for Admin page.
///
/// This class has not any Restful Api code. It is merely a Getx controller.
class Admin extends GetxController {
  static Admin to = Get.find();
  Api api = Api.instance;

  List<ApiCategory> checks;

  categoryCheck(List<String> ids) async {
    try {
      checks = await api.categoryGets(ids);
      update();
    } catch (e) {
      alert(e);
    }
  }

  bool hasCategory(String categoryId) {
    if (checks == null || checks.length == 0) return false;
    bool re = checks.indexWhere((c) => c.id == categoryId) > -1;
    return re;
  }

  createDefaultCategories(List<String> ids) async {
    for (final id in ids) {
      try {
        checks.add(await api.categoryCreate(id: id));
      } catch (e) {
        if (e == 'error_category_exists') {
        } else {
          alert(e);
        }
      }
      update();
    }
  }
}
