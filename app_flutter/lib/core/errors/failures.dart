// lib/core/errors/failures.dart
abstract class Failure {
  final String message;
  const Failure(this.message);
}

class DatabaseFailure extends Failure {
  const DatabaseFailure(super.message);
}

class VoiceFailure extends Failure {
  const VoiceFailure(super.message);
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

class ExportFailure extends Failure {
  const ExportFailure(super.message);
}

class PermissionFailure extends Failure {
  const PermissionFailure(super.message);
}
