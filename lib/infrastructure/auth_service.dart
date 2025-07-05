import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../domain/user_entity.dart';

final authServiceProvider = Provider<AuthService>((ref) => AuthService());
final firebaseUserProvider = StreamProvider<User?>((ref) => FirebaseAuth.instance.authStateChanges());

class AuthService {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  // Stream of UserEntity for current user
  Stream<UserEntity?> userEntityStream() {
    return _auth.authStateChanges().asyncMap((user) async {
      if (user == null) return null;
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        return UserEntity.fromMap(doc.data()!, user.uid);
      } else {
        // If user doc doesn't exist, create it
        final entity = UserEntity(
          uid: user.uid,
          name: user.displayName ?? '',
          email: user.email ?? '',
          role: 'student',
          verified: false,
          photoURL: user.photoURL,
        );
        await _firestore.collection('users').doc(user.uid).set(entity.toMap());
        return entity;
      }
    });
  }

  // Register with email/password
  Future<UserEntity> register({required String name, required String email, required String password, required String role}) async {
    final cred = await _auth.createUserWithEmailAndPassword(email: email, password: password);
    await cred.user!.updateDisplayName(name);
    await cred.user!.sendEmailVerification();
    final entity = UserEntity(
      uid: cred.user!.uid,
      name: name,
      email: email,
      role: role,
      verified: false,
      photoURL: cred.user!.photoURL,
      phone: null,
      school: null,
      campus: null,
      studentId: null,
      studentIdPhotoUrl: null,
      location: null,
    );
    await _firestore.collection('users').doc(cred.user!.uid).set(entity.toMap());
    return entity;
  }

  // Login with email/password
  Future<UserEntity> login({required String email, required String password}) async {
    final cred = await _auth.signInWithEmailAndPassword(email: email, password: password);
    final doc = await _firestore.collection('users').doc(cred.user!.uid).get();
    return UserEntity.fromMap(doc.data()!, cred.user!.uid);
  }

  // Google Sign-In
  Future<UserEntity> signInWithGoogle() async {
    final googleUser = await GoogleSignIn().signIn();
    final googleAuth = await googleUser?.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );
    final cred = await _auth.signInWithCredential(credential);
    final user = cred.user!;
    final doc = await _firestore.collection('users').doc(user.uid).get();
    if (doc.exists) {
      return UserEntity.fromMap(doc.data()!, user.uid);
    } else {
      final entity = UserEntity(
        uid: user.uid,
        name: user.displayName ?? '',
        email: user.email ?? '',
        role: 'student',
        verified: false,
        photoURL: user.photoURL,
        phone: null,
        school: null,
        campus: null,
        studentId: null,
        studentIdPhotoUrl: null,
        location: null,
      );
      await _firestore.collection('users').doc(user.uid).set(entity.toMap());
      return entity;
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
    await GoogleSignIn().signOut();
  }

  // Password reset
  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  // Check if current user's email is verified
  bool isEmailVerified() {
    final user = _auth.currentUser;
    return user?.emailVerified ?? false;
  }

  // Update user profile fields
  Future<void> updateUserProfile(String userId, Map<String, dynamic> data) async {
    await _firestore.collection('users').doc(userId).update(data);
  }
}
