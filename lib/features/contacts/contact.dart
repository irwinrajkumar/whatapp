import 'package:flutter/foundation.dart';

@immutable
class Contact {
  final String id;
  final String displayName;
  final String about;
  final String? phoneNumber;
  final String? avatarUrl;

  const Contact({
    required this.id,
    required this.displayName,
    required this.about,
    this.phoneNumber,
    this.avatarUrl,
  });
}

