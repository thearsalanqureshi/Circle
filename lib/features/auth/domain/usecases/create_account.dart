import '../entities/app_user.dart';
import '../repositories/auth_repository.dart';

class CreateAccount {
  const CreateAccount(this._repository);

  final AuthRepository _repository;

  Future<AppUser> call({
    required String name,
    required String email,
    required String password,
  }) {
    return _repository.createUserWithEmailAndPassword(
      name: name,
      email: email,
      password: password,
    );
  }
}
