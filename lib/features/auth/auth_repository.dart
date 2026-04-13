import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

final authRepositoryProvider = Provider((ref) => AuthRepository());

class AuthRepository {
  static const String boxName = 'authBox';
  static const String userKey = 'currentUser';

  Future<void> init() async {
    await Hive.openBox(boxName);
  }

  bool get isLoggedIn => Hive.box(boxName).get(userKey) != null;
  String? get currentUserName => Hive.box(boxName).get(userKey);

  Future<void> signup(String name, String email, String password) async {
    // Simulate API delay
    await Future.delayed(const Duration(seconds: 1));
    await Hive.box(boxName).put(userKey, name);
  }

  Future<void> login(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));
    await Hive.box(boxName).put(userKey, "Isaac"); // Mock login
  }

  Future<void> logout() async {
    await Hive.box(boxName).delete(userKey);
  }
}

final authStateProvider = StateProvider<String?>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return repo.currentUserName;
});
