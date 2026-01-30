import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/password_entity.dart';
import '../repositories/vault_repository.dart';

class SearchPasswords {
  final VaultRepository repository;

  SearchPasswords(this.repository);

  Future<Either<Failure, List<PasswordEntity>>> call(String query) async {
    return await repository.searchPasswords(query);
  }
}
