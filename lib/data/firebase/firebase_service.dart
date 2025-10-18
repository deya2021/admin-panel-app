import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_functions/cloud_functions.dart';

import '../../core/utils/logger.dart';

/// Firebase service for initialization and configuration
class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  bool _initialized = false;

  /// Initialize Firebase
  Future<void> initialize() async {
    if (_initialized) return;

    try {
      await Firebase.initializeApp();
      
      // Enable Firestore offline persistence
      FirebaseFirestore.instance.settings = const Settings(
        persistenceEnabled: true,
        cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
      );

      _initialized = true;
      Logger.success('Firebase initialized successfully');
    } catch (e, stackTrace) {
      Logger.error('Failed to initialize Firebase', e, stackTrace);
      rethrow;
    }
  }

  /// Get Firestore instance
  FirebaseFirestore get firestore => FirebaseFirestore.instance;

  /// Get Auth instance
  FirebaseAuth get auth => FirebaseAuth.instance;

  /// Get Storage instance
  FirebaseStorage get storage => FirebaseStorage.instance;

  /// Get Functions instance
  FirebaseFunctions get functions => FirebaseFunctions.instance;

  /// Get current user
  User? get currentUser => auth.currentUser;

  /// Check if user is logged in
  bool get isLoggedIn => currentUser != null;
}

