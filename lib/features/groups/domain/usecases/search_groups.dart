import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/danger_group_entity.dart';
import '../repositories/group_repository.dart';

class SearchGroups {
  final GroupRepository repository;

  SearchGroups(this.repository);

  Future<Either<Failure, List<DangerGroupEntity>>> call(String query) async {
    return await repository.searchGroups(query);
  }
}
