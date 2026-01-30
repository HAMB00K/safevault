import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/password_entity.dart';
import '../repositories/vault_repository.dart';

class GetAllPasswords {
  final VaultRepository repository;

  GetAllPasswords(this.repository);

  Future<Either<Failure, List<PasswordEntity>>> call() async {
    return await repository.getAllPasswords();
  }
}
