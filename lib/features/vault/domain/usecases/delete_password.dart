import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/vault_repository.dart';

class DeletePassword {
  final VaultRepository repository;

  DeletePassword(this.repository);

  Future<Either<Failure, Unit>> call(String id) async {
    return await repository.deletePassword(id);
  }
}
