import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/password_entity.dart';
import '../../domain/repositories/vault_repository.dart';
import '../datasources/vault_local_datasource.dart';
import '../models/password_model.dart';

class VaultRepositoryImpl implements VaultRepository {
  final VaultLocalDataSource localDataSource;

  VaultRepositoryImpl(this.localDataSource);

  @override
  Future<Either<Failure, List<PasswordEntity>>> getAllPasswords() async {
    try {
      final passwords = await localDataSource.getAllPasswords();
      return Right(passwords);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, PasswordEntity>> getPasswordById(String id) async {
    try {
      final password = await localDataSource.getPasswordById(id);
      return Right(password);
    } on Exception catch (e) {
      if (e.toString().contains('not found')) {
        return const Left(PasswordNotFoundFailure());
      }
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> addPassword(PasswordEntity password) async {
    try {
      final model = PasswordModel.fromEntity(password);
      await localDataSource.addPassword(model);
      return const Right(unit);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> updatePassword(PasswordEntity password) async {
    try {
      final model = PasswordModel.fromEntity(password);
      await localDataSource.updatePassword(model);
      return const Right(unit);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> deletePassword(String id) async {
    try {
      await localDataSource.deletePassword(id);
      return const Right(unit);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<PasswordEntity>>> searchPasswords(String query) async {
    try {
      final passwords = await localDataSource.searchPasswords(query);
      return Right(passwords);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<PasswordEntity>>> getPasswordsByCategory(
      PasswordCategory category) async {
    try {
      final passwords = await localDataSource.getPasswordsByCategory(
        category.toString().split('.').last,
      );
      return Right(passwords);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<PasswordEntity>>> getFavoritePasswords() async {
    try {
      final passwords = await localDataSource.getFavoritePasswords();
      return Right(passwords);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<PasswordEntity>>> getTemporaryPasswords() async {
    try {
      final passwords = await localDataSource.getTemporaryPasswords();
      return Right(passwords);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteExpiredTemporaryPasswords() async {
    try {
      await localDataSource.deleteExpiredTemporaryPasswords();
      return const Right(unit);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, int>> getPasswordCount() async {
    try {
      final count = await localDataSource.getPasswordCount();
      return Right(count);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }
}
