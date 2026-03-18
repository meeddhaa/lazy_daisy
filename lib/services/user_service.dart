import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum UserGender { male, female, other, unset }

class UserService extends ChangeNotifier {
  static const _keyGender = 'user_gender';
  static const _keyName = 'user_name';
  static const _keyOnboarded = 'user_onboarded';

  UserGender _gender = UserGender.unset;
  String _name = '';
  bool _onboarded = false;

  UserGender get gender => _gender;
  String get name => _name;
  bool get onboarded => _onboarded;
  bool get isFemale => _gender == UserGender.female;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final g = prefs.getString(_keyGender) ?? 'unset';
    _gender = UserGender.values.firstWhere(
      (e) => e.name == g,
      orElse: () => UserGender.unset,
    );
    _name = prefs.getString(_keyName) ?? '';
    _onboarded = prefs.getBool(_keyOnboarded) ?? false;
    notifyListeners();
  }

  Future<void> completeOnboarding({
    required String name,
    required UserGender gender,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    _name = name;
    _gender = gender;
    _onboarded = true;
    await prefs.setString(_keyName, name);
    await prefs.setString(_keyGender, gender.name);
    await prefs.setBool(_keyOnboarded, true);
    notifyListeners();
  }

  Future<void> updateGender(UserGender gender) async {
    final prefs = await SharedPreferences.getInstance();
    _gender = gender;
    await prefs.setString(_keyGender, gender.name);
    notifyListeners();
  }

  Future<void> reset() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyGender);
    await prefs.remove(_keyName);
    await prefs.remove(_keyOnboarded);
    _gender = UserGender.unset;
    _name = '';
    _onboarded = false;
    notifyListeners();
  }
}