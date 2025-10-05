import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/comment_model.dart';

abstract class CommentRemoteDataSource {
  Future<List<CommentModel>> getComments(String alertId);
  Stream<List<CommentModel>> watchComments(String alertId);
  Future<CommentModel> addComment({
    required String alertId,
    required String userId,
    required String userName,
    String? userPhoto,
    String? textContent,
    String? audioUrl,
    String? parentCommentId,
  });
  Future<CommentModel> updateComment({
    required String commentId,
    String? textContent,
  });
  Future<void> deleteComment(String commentId);
  Future<void> toggleLike({required String commentId, required String userId});
  Future<void> flagComment(String commentId);
}

class CommentRemoteDataSourceImpl implements CommentRemoteDataSource {
  final FirebaseFirestore firestore;

  CommentRemoteDataSourceImpl({required this.firestore});

  @override
  Future<List<CommentModel>> getComments(String alertId) async {
    final snapshot = await firestore
        .collection('comments')
        .where('alertId', isEqualTo: alertId)
        .orderBy('createdAt', descending: false)
        .get();

    return snapshot.docs
        .map((doc) => CommentModel.fromJson(doc.data()))
        .toList();
  }

  @override
  Stream<List<CommentModel>> watchComments(String alertId) {
    return firestore
        .collection('comments')
        .where('alertId', isEqualTo: alertId)
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => CommentModel.fromJson(doc.data())).toList());
  }

  @override
  Future<CommentModel> addComment({
    required String alertId,
    required String userId,
    required String userName,
    String? userPhoto,
    String? textContent,
    String? audioUrl,
    String? parentCommentId,
  }) async {
    final commentRef = firestore.collection('comments').doc();
    final now = DateTime.now();

    final comment = CommentModel(
      commentId: commentRef.id,
      alertId: alertId,
      userId: userId,
      userName: userName,
      userPhoto: userPhoto,
      textContent: textContent,
      audioUrl: audioUrl,
      createdAt: now,
      updatedAt: now,
      parentCommentId: parentCommentId,
    );

    await commentRef.set(comment.toJson());

    // Update alert comment count
    await firestore.collection('alerts').doc(alertId).update({
      'commentCount': FieldValue.increment(1),
    });

    return comment;
  }

  @override
  Future<CommentModel> updateComment({
    required String commentId,
    String? textContent,
  }) async {
    final commentRef = firestore.collection('comments').doc(commentId);

    await commentRef.update({
      'textContent': textContent,
      'updatedAt': FieldValue.serverTimestamp(),
      'isEdited': true,
    });

    final doc = await commentRef.get();
    return CommentModel.fromJson(doc.data()!);
  }

  @override
  Future<void> deleteComment(String commentId) async {
    final doc = await firestore.collection('comments').doc(commentId).get();
    if (!doc.exists) return;

    final comment = CommentModel.fromJson(doc.data()!);

    await firestore.collection('comments').doc(commentId).delete();

    // Update alert comment count
    await firestore.collection('alerts').doc(comment.alertId).update({
      'commentCount': FieldValue.increment(-1),
    });
  }

  @override
  Future<void> toggleLike({
    required String commentId,
    required String userId,
  }) async {
    final commentRef = firestore.collection('comments').doc(commentId);
    final doc = await commentRef.get();

    if (!doc.exists) return;

    final comment = CommentModel.fromJson(doc.data()!);
    final likedBy = List<String>.from(comment.likedBy);

    if (likedBy.contains(userId)) {
      // Unlike
      likedBy.remove(userId);
      await commentRef.update({
        'likedBy': likedBy,
        'likeCount': FieldValue.increment(-1),
      });
    } else {
      // Like
      likedBy.add(userId);
      await commentRef.update({
        'likedBy': likedBy,
        'likeCount': FieldValue.increment(1),
      });
    }
  }

  @override
  Future<void> flagComment(String commentId) async {
    await firestore.collection('comments').doc(commentId).update({
      'isFlagged': true,
    });
  }
}
