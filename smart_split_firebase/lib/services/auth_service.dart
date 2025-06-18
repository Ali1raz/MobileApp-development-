import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smart_split_firebase/models/user_profile.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Get user profile stream
  Stream<UserProfile?> getUserProfileStream(String uid) {
    print('Getting user profile stream for uid: $uid');
    return _firestore.collection('users').doc(uid).snapshots().map((doc) {
      print(
        'Received Firestore snapshot: ${doc.exists ? 'exists' : 'does not exist'}',
      );
      if (!doc.exists) return null;
      try {
        final data = doc.data();
        if (data == null) {
          print('Document exists but data is null');
          return null;
        }
        print('Converting Firestore data to UserProfile');
        return UserProfile.fromMap(Map<String, dynamic>.from(data));
      } catch (e) {
        print('Error converting profile data: $e');
        return null;
      }
    });
  }

  // Get user profile once
  Future<UserProfile?> getUserProfile(String uid) async {
    print('Getting user profile for uid: $uid');
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      print('Firestore document exists: ${doc.exists}');
      if (!doc.exists) return null;

      final data = doc.data();
      if (data == null) {
        print('Document exists but data is null');
        return null;
      }

      print('Converting Firestore data to UserProfile');
      final Map<String, dynamic> userData = Map<String, dynamic>.from(data);
      return UserProfile.fromMap(userData);
    } catch (e) {
      print('Error getting user profile: $e');
      return null;
    }
  }

  // Check if email exists
  Future<bool> isEmailRegistered(String email) async {
    print('Checking if email is registered: $email');
    try {
      final methods = await _auth.fetchSignInMethodsForEmail(email);
      print('Sign-in methods found: ${methods.join(', ')}');
      return methods.isNotEmpty;
    } catch (e) {
      print('Error checking email existence: $e');
      return false;
    }
  }

  // Sign in with email and password
  Future<UserCredential> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    print('Attempting to sign in with email: $email');
    try {
      // Attempt to sign in
      print('Calling Firebase Auth signInWithEmailAndPassword');
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      print('Sign in successful, user: ${userCredential.user?.uid}');

      // Verify the sign-in was successful
      if (userCredential.user == null) {
        print('Sign in returned null user');
        throw FirebaseAuthException(
          code: 'sign-in-failed',
          message: 'Sign in failed. Please try again.',
        );
      }

      return userCredential;
    } on FirebaseAuthException catch (e) {
      print('Firebase Auth Error during sign in: ${e.code} - ${e.message}');
      rethrow;
    } catch (e) {
      print('Unexpected error during sign in: $e');
      rethrow;
    }
  }

  // Register with email and password
  Future<UserCredential> registerWithEmailAndPassword(
    String email,
    String password,
  ) async {
    print('Attempting to register with email: $email');
    try {
      // Check if email is already in use
      final isRegistered = await isEmailRegistered(email);
      if (isRegistered) {
        print('Email already registered: $email');
        throw FirebaseAuthException(
          code: 'email-already-in-use',
          message: 'An account already exists with this email.',
        );
      }

      print('Creating new user account');
      // Create the user
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      print('User created successfully: ${userCredential.user?.uid}');

      // Create user profile in Firestore
      if (userCredential.user != null) {
        print('Creating Firestore user profile');
        final userData = {
          'uid': userCredential.user!.uid,
          'email': email,
          'username': null,
          'displayName': null,
          'photoURL': null,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        };

        await _firestore
            .collection('users')
            .doc(userCredential.user!.uid)
            .set(userData);
        print('Firestore user profile created successfully');
      }

      return userCredential;
    } on FirebaseAuthException catch (e) {
      print(
        'Firebase Auth Error during registration: ${e.code} - ${e.message}',
      );
      rethrow;
    } catch (e) {
      print('Unexpected error during registration: $e');
      rethrow;
    }
  }

  // Update user profile
  Future<void> updateUserProfile({
    String? username,
    String? displayName,
    String? photoURL,
  }) async {
    print('Updating user profile');
    try {
      final user = _auth.currentUser;
      if (user == null) {
        print('No user logged in');
        throw Exception('No user logged in');
      }

      print('Updating auth profile for user: ${user.uid}');
      // Update auth profile
      if (displayName != null) {
        await user.updateDisplayName(displayName);
      }
      if (photoURL != null) {
        await user.updatePhotoURL(photoURL);
      }

      print('Updating Firestore profile');
      // Update Firestore profile
      final updates = <String, dynamic>{};
      if (username != null) updates['username'] = username;
      if (displayName != null) updates['displayName'] = displayName;
      if (photoURL != null) updates['photoURL'] = photoURL;
      updates['updatedAt'] = FieldValue.serverTimestamp();

      await _firestore.collection('users').doc(user.uid).update(updates);
      print('Profile updated successfully');
    } catch (e) {
      print('Error updating profile: $e');
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    print('Signing out user');
    try {
      await _auth.signOut();
      print('User signed out successfully');
    } catch (e) {
      print('Error signing out: $e');
      rethrow;
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    print('Sending password reset email to: $email');
    try {
      await _auth.sendPasswordResetEmail(email: email);
      print('Password reset email sent successfully');
    } catch (e) {
      print('Error sending password reset email: $e');
      rethrow;
    }
  }
}
