import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/password_entity.dart';

abstract class VaultRepository {
  Future<Either<Failure, List<PasswordEntity>>> getAllPasswords();
  Future<Either<Failure, PasswordEntity>> getPasswordById(String id);
  Future<Either<Failure, Unit>> addPassword(PasswordEntity password);
  Future<Either<Failure, Unit>> updatePassword(PasswordEntity password);
  Future<Either<Failure, Unit>> deletePassword(String id);
  Future<Either<Failure, List<PasswordEntity>>> searchPasswords(String query);
  Future<Either<Failure, List<PasswordEntity>>> getPasswordsByCategory(PasswordCategory category);
  Future<Either<Failure, List<PasswordEntity>>> getFavoritePasswords();
  Future<Either<Failure, List<PasswordEntity>>> getTemporaryPasswords();
  Future<Either<Failure, Unit>> deleteExpiredTemporaryPasswords();
  Future<Either<Failure, int>> getPasswordCount();
}
