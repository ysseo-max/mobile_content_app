import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class FirebaseService {
  static FirebaseFirestore? _firestoreInstance;
  static FirebaseAuth? _authInstance;

  static FirebaseFirestore? get _firestore {
    try {
      _firestoreInstance ??= FirebaseFirestore.instance;
      return _firestoreInstance;
    } catch (_) {
      return null;
    }
  }

  static FirebaseAuth? get _auth {
    try {
      _authInstance ??= FirebaseAuth.instance;
      return _authInstance;
    } catch (_) {
      return null;
    }
  }

  // ==================== AUTH ====================

  /// 익명 로그인으로 체험자 세션 생성
  static Future<String?> signInAnonymously() async {
    try {
      final auth = _auth;
      if (auth == null) return null;
      final credential = await auth.signInAnonymously();
      return credential.user?.uid;
    } catch (e) {
      debugPrint('FirebaseService.signInAnonymously: $e');
      return null;
    }
  }

  /// 현재 유저 ID
  static String? get currentUserId {
    try {
      return _auth?.currentUser?.uid;
    } catch (_) {
      return null;
    }
  }

  /// 인증 상태 확인
  static bool get isSignedIn {
    try {
      return _auth?.currentUser != null;
    } catch (_) {
      return false;
    }
  }

  // ==================== FIRESTORE: 체험자 데이터 ====================

  /// 체험자 정보 저장 (AI 이미지 체험 시작 시)
  static Future<String> saveUserExperience({
    required String birthYear,
    required String gender,
  }) async {
    final firestore = _firestore;
    if (firestore == null) return 'offline-${DateTime.now().millisecondsSinceEpoch}';
    final uid = currentUserId ?? 'anonymous';
    final docRef = await firestore.collection('experiences').add({
      'userId': uid,
      'birthYear': birthYear,
      'gender': gender,
      'type': 'ai_image',
      'createdAt': FieldValue.serverTimestamp(),
      'status': 'created',
    });
    return docRef.id;
  }

  /// AI 이미지 생성 결과 업데이트
  static Future<void> updateExperienceImage({
    required String experienceId,
    required String generatedImageUrl,
  }) async {
    final firestore = _firestore;
    if (firestore == null) return;
    await firestore.collection('experiences').doc(experienceId).update({
      'generatedImageUrl': generatedImageUrl,
      'status': 'image_generated',
      'generatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// LED 송출 기록 저장
  static Future<String> saveLedTransmission({
    required String experienceId,
    required String imageUrl,
    required String paymentMethod,
    String? couponCode,
  }) async {
    final firestore = _firestore;
    if (firestore == null) return 'offline-${DateTime.now().millisecondsSinceEpoch}';
    final docRef = await firestore.collection('led_transmissions').add({
      'experienceId': experienceId,
      'userId': currentUserId ?? 'anonymous',
      'imageUrl': imageUrl,
      'paymentMethod': paymentMethod,
      'couponCode': couponCode,
      'status': 'queued',
      'createdAt': FieldValue.serverTimestamp(),
    });
    return docRef.id;
  }

  /// LED 송출 상태 업데이트
  static Future<void> updateLedStatus({
    required String transmissionId,
    required String status,
  }) async {
    final firestore = _firestore;
    if (firestore == null) return;
    await firestore.collection('led_transmissions').doc(transmissionId).update({
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ==================== FIRESTORE: 스탬프 랠리 ====================

  /// 스탬프 세션 생성
  static Future<String> createStampSession() async {
    final firestore = _firestore;
    if (firestore == null) return 'offline-${DateTime.now().millisecondsSinceEpoch}';
    final docRef = await firestore.collection('stamp_sessions').add({
      'userId': currentUserId ?? 'anonymous',
      'stamps': {'C': false, 'B': false, 'A': false},
      'completed': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
    return docRef.id;
  }

  /// 스탬프 획득 기록
  static Future<void> collectStamp({
    required String sessionId,
    required String location,
  }) async {
    final firestore = _firestore;
    if (firestore == null) return;
    await firestore.collection('stamp_sessions').doc(sessionId).update({
      'stamps.$location': true,
      'lastStampAt': FieldValue.serverTimestamp(),
    });
  }

  /// 스탬프 완료 처리
  static Future<void> completeStampSession({
    required String sessionId,
    required String couponCode,
  }) async {
    final firestore = _firestore;
    if (firestore == null) return;
    await firestore.collection('stamp_sessions').doc(sessionId).update({
      'completed': true,
      'couponCode': couponCode,
      'completedAt': FieldValue.serverTimestamp(),
    });
  }

  // ==================== FIRESTORE: 쿠폰 ====================

  /// 쿠폰 생성 및 저장
  static Future<void> saveCoupon({
    required String couponCode,
    required String source,
  }) async {
    final firestore = _firestore;
    if (firestore == null) return;
    await firestore.collection('coupons').doc(couponCode).set({
      'code': couponCode,
      'source': source,
      'userId': currentUserId ?? 'anonymous',
      'used': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// 쿠폰 유효성 확인 (서버 기반)
  static Future<bool> validateCouponFromServer(String couponCode) async {
    try {
      final firestore = _firestore;
      if (firestore == null) return false;
      final doc =
          await firestore.collection('coupons').doc(couponCode).get();
      if (!doc.exists) return false;
      final data = doc.data()!;
      return data['used'] != true;
    } catch (e) {
      return false;
    }
  }

  /// 쿠폰 사용 처리
  static Future<void> useCouponOnServer(String couponCode) async {
    final firestore = _firestore;
    if (firestore == null) return;
    await firestore.collection('coupons').doc(couponCode).update({
      'used': true,
      'usedAt': FieldValue.serverTimestamp(),
    });
  }

  // ==================== 결제 기록 ====================

  /// 결제 기록 저장
  static Future<String> savePayment({
    required String experienceId,
    required String method,
    required double amount,
    required String currency,
  }) async {
    final firestore = _firestore;
    if (firestore == null) return 'offline-${DateTime.now().millisecondsSinceEpoch}';
    final docRef = await firestore.collection('payments').add({
      'experienceId': experienceId,
      'userId': currentUserId ?? 'anonymous',
      'method': method,
      'amount': amount,
      'currency': currency,
      'status': 'completed',
      'createdAt': FieldValue.serverTimestamp(),
    });
    return docRef.id;
  }
}
