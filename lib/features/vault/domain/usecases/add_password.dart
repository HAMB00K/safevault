import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/password_entity.dart';
import '../repositories/vault_repository.dart';

class AddPassword {
  final VaultRepository repository;

  AddPassword(this.repository);

  Future<Either<Failure, Unit>> call(PasswordEntity password) async {
    return await repository.addPassword(password);
  }
}
