import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

final userProvider = StreamProvider<User?>((ref) {
  final firebaseAuth = ref.watch(firebaseAuthProvider);
  return firebaseAuth.authStateChanges();
});

String? getUserEmail(WidgetRef ref) {
  final user = ref.watch(userProvider).value;
  return user?.email;
}

String? getUserUid(WidgetRef ref) {
  final user = ref.watch(userProvider).value;
  return user?.uid;
}