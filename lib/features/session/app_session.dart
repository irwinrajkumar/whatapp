import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

@immutable
class UserProfile {
  final String displayName;
  final String about;
  final String? phoneNumber;
  final String? email;
  final String? photoPath; // local file path (picked image)

  const UserProfile({
    required this.displayName,
    required this.about,
    this.phoneNumber,
    this.email,
    this.photoPath,
  });

  UserProfile copyWith({
    String? displayName,
    String? about,
    String? phoneNumber,
    String? email,
    String? photoPath,
  }) {
    return UserProfile(
      displayName: displayName ?? this.displayName,
      about: about ?? this.about,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      photoPath: photoPath ?? this.photoPath,
    );
  }

  Map<String, Object?> toJson() => {
        'displayName': displayName,
        'about': about,
        'phoneNumber': phoneNumber,
        'email': email,
        'photoPath': photoPath,
      };

  static UserProfile? fromJson(Map<String, Object?> json) {
    final name = json['displayName'];
    final about = json['about'];
    if (name is! String || name.trim().isEmpty) return null;
    if (about is! String) return null;
    return UserProfile(
      displayName: name,
      about: about,
      phoneNumber: json['phoneNumber'] as String?,
      email: json['email'] as String?,
      photoPath: json['photoPath'] as String?,
    );
  }
}

@immutable
class PrivacySettings {
  final String lastSeen;
  final String profilePhoto;
  final String about;
  final String status;
  final bool readReceipts;

  const PrivacySettings({
    required this.lastSeen,
    required this.profilePhoto,
    required this.about,
    required this.status,
    required this.readReceipts,
  });

  factory PrivacySettings.defaults() => const PrivacySettings(
        lastSeen: 'Everyone',
        profilePhoto: 'Everyone',
        about: 'Everyone',
        status: 'My contacts',
        readReceipts: true,
      );

  PrivacySettings copyWith({
    String? lastSeen,
    String? profilePhoto,
    String? about,
    String? status,
    bool? readReceipts,
  }) {
    return PrivacySettings(
      lastSeen: lastSeen ?? this.lastSeen,
      profilePhoto: profilePhoto ?? this.profilePhoto,
      about: about ?? this.about,
      status: status ?? this.status,
      readReceipts: readReceipts ?? this.readReceipts,
    );
  }

  Map<String, Object?> toJson() => {
        'lastSeen': lastSeen,
        'profilePhoto': profilePhoto,
        'about': about,
        'status': status,
        'readReceipts': readReceipts,
      };

  static PrivacySettings? fromJson(Map<String, Object?> json) {
    final lastSeen = json['lastSeen'];
    final profilePhoto = json['profilePhoto'];
    final about = json['about'];
    final status = json['status'];
    final readReceipts = json['readReceipts'];
    if (lastSeen is! String ||
        profilePhoto is! String ||
        about is! String ||
        status is! String ||
        readReceipts is! bool) {
      return null;
    }
    return PrivacySettings(
      lastSeen: lastSeen,
      profilePhoto: profilePhoto,
      about: about,
      status: status,
      readReceipts: readReceipts,
    );
  }
}

class AppSession extends ChangeNotifier {
  static const _kIsLoggedIn = 'session.isLoggedIn';
  static const _kAuthIdentity = 'session.authIdentity';
  static const _kUserProfile = 'session.userProfile';
  static const _kPrivacy = 'session.privacy';

  bool _isReady = false;
  bool _isLoggedIn = false;
  String? _authIdentity; // phone/email used to login
  UserProfile? _profile;
  PrivacySettings _privacy = PrivacySettings.defaults();

  bool get isReady => _isReady;
  bool get isLoggedIn => _isLoggedIn;
  String? get authIdentity => _authIdentity;
  UserProfile? get profile => _profile;
  PrivacySettings get privacy => _privacy;

  bool get hasProfile => _profile != null;

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();

    _isLoggedIn = prefs.getBool(_kIsLoggedIn) ?? false;
    _authIdentity = prefs.getString(_kAuthIdentity);

    final rawProfile = prefs.getString(_kUserProfile);
    if (rawProfile != null) {
      final decoded = jsonDecode(rawProfile);
      if (decoded is Map) {
        _profile = UserProfile.fromJson(
          decoded.map((k, v) => MapEntry(k.toString(), v)),
        );
      }
    }

    final rawPrivacy = prefs.getString(_kPrivacy);
    if (rawPrivacy != null) {
      final decoded = jsonDecode(rawPrivacy);
      if (decoded is Map) {
        _privacy = PrivacySettings.fromJson(
              decoded.map((k, v) => MapEntry(k.toString(), v)),
            ) ??
            PrivacySettings.defaults();
      }
    }

    _isReady = true;
    notifyListeners();
  }

  Future<void> completeAuth({required String identity}) async {
    final prefs = await SharedPreferences.getInstance();
    _isLoggedIn = true;
    _authIdentity = identity;
    await prefs.setBool(_kIsLoggedIn, true);
    await prefs.setString(_kAuthIdentity, identity);
    notifyListeners();
  }

  Future<void> saveProfile(UserProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    _profile = profile;
    await prefs.setString(_kUserProfile, jsonEncode(profile.toJson()));
    notifyListeners();
  }

  Future<void> savePrivacy(PrivacySettings privacy) async {
    final prefs = await SharedPreferences.getInstance();
    _privacy = privacy;
    await prefs.setString(_kPrivacy, jsonEncode(privacy.toJson()));
    notifyListeners();
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    _isLoggedIn = false;
    _authIdentity = null;
    await prefs.setBool(_kIsLoggedIn, false);
    await prefs.remove(_kAuthIdentity);
    notifyListeners();
  }
}

