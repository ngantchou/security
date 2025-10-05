import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/group_post_entity.dart';
import '../repositories/group_repository.dart';

class CreatePost {
  final GroupRepository repository;

  CreatePost(this.repository);

  Future<Either<Failure, GroupPostEntity>> call({
    required String groupId,
    required String authorId,
    required String authorName,
    String? authorPhoto,
    required String content,
    List<String>? images,
    String? videoUrl,
    PostType type = PostType.regular,
    String? relatedAlertId,
  }) async {
    return await repository.createPost(
      groupId: groupId,
      authorId: authorId,
      authorName: authorName,
      authorPhoto: authorPhoto,
      content: content,
      images: images,
      videoUrl: videoUrl,
      type: type,
      relatedAlertId: relatedAlertId,
    );
  }
}
