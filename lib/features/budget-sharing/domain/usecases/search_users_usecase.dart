import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:xpensemate/core/error/failures.dart';
import 'package:xpensemate/core/usecase/usecase.dart';
import 'package:xpensemate/features/budget-sharing/domain/entities/user_search_entity.dart';
import 'package:xpensemate/features/budget-sharing/domain/repositories/budget_sharing_repository.dart';

class SearchUsersUseCase implements UseCase<UserSearchPaginationEntity, SearchUsersParams> {

  SearchUsersUseCase(this.repository);
  final BudgetSharingRepository repository;

  @override
  Future<Either<Failure, UserSearchPaginationEntity>> call(SearchUsersParams params) async => repository.searchUsers(
      query: params.query,
      page: params.page,
      limit: params.limit,
    );
}

class SearchUsersParams extends Equatable {

  const SearchUsersParams({
    required this.query,
    this.page = 1,
    this.limit = 10,
  });
  final String query;
  final int page;
  final int limit;

  @override
  List<Object?> get props => [query, page, limit];
}
