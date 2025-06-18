import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  final String uid;
  final String email;
  final String? username;
  final String? displayName;
  final String? photoURL;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  UserProfile({
    required this.uid,
    required this.email,
    this.username,
    this.displayName,
    this.photoURL,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'username': username,
      'displayName': displayName,
      'photoURL': photoURL,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    try {
      return UserProfile(
        uid: map['uid']?.toString() ?? '',
        email: map['email']?.toString() ?? '',
        username: map['username']?.toString(),
        displayName: map['displayName']?.toString(),
        photoURL: map['photoURL']?.toString(),
        createdAt: _parseTimestamp(map['createdAt']),
        updatedAt: _parseTimestamp(map['updatedAt']),
      );
    } catch (e) {
      print('Error parsing UserProfile: $e');
      rethrow;
    }
  }

  static DateTime? _parseTimestamp(dynamic timestamp) {
    if (timestamp == null) return null;
    if (timestamp is Timestamp) return timestamp.toDate();
    if (timestamp is DateTime) return timestamp;
    return null;
  }
}
