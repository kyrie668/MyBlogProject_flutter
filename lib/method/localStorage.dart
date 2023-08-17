import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  // 存储数据
  static Future<void> saveData(String key, String value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  // 获取数据
  static Future<String?> getData(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  // 删除数据
  static Future<void> removeData(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }

  // 获取当前用户的信息，包括用户名、头像、token（用户id）
  static Future<Map> loadUserData() async {
    String? token = await LocalStorage.getData('token');
    String? avatar = await LocalStorage.getData('avatar');
    String? username = await LocalStorage.getData('username');
    // 执行回调函数
    return {
      "token": token,
      "avatar": avatar,
      "username": username,
    };
  }
}
