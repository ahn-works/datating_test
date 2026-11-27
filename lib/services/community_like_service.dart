import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<List<String>> setCommunityLike(String postId, bool liked, {String? commentId}) async {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null || postId.isEmpty) throw StateError('로그인이 필요해요.');
  final db = FirebaseFirestore.instance;
  final post = db.collection('community_posts').doc(postId);
  final ref = commentId == null ? post : post.collection('comments').doc(commentId);
  return db.runTransaction((tx) async {
    final snapshot = await tx.get(ref);
    if (!snapshot.exists) throw StateError('삭제된 글이에요.');
    final raw = snapshot.data()?['likedUserIds'];
    final ids = raw is List ? raw.whereType<String>().toSet() : <String>{};
    final changed = liked ? ids.add(uid) : ids.remove(uid);
    final result = ids.toList();
    if (changed) tx.update(ref, {'likedUserIds': result, 'likes': result.length});
    return result;
  });
}
