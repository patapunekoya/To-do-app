/// A tiny Either implementation without extra deps.
/// Either<L, R> where L = Failure (usually), R = success type.
sealed class Either<L, R> {
  const Either();
  T fold<T>(T Function(L l) leftFn, T Function(R r) rightFn) {
    final self = this;
    if (self is Left<L, R>) return leftFn(self.value);
    return rightFn((self as Right<L, R>).value);
  }

  bool get isLeft => this is Left<L, R>;
  bool get isRight => this is Right<L, R>;

  L? get leftOrNull => (this is Left<L, R>) ? (this as Left<L, R>).value : null;
  R? get rightOrNull => (this is Right<L, R>) ? (this as Right<L, R>).value : null;

  Either<L2, R2> map<L2 extends L, R2>(R2 Function(R r) mapper) {
    final self = this;
    if (self is Right<L, R>) return Right<L2, R2>(mapper(self.value));
    return Left<L2, R2>((self as Left<L, R>).value as L2);
  }

  Either<L, R2> flatMap<R2>(Either<L, R2> Function(R r) binder) {
    final self = this;
    if (self is Right<L, R>) return binder(self.value);
    return Left<L, R2>((self as Left<L, R>).value);
  }

  R getOrElse(R Function() orElse) {
    final self = this;
    return (self is Right<L, R>) ? self.value : orElse();
  }
}

final class Left<L, R> extends Either<L, R> {
  final L value;
  const Left(this.value);
  @override
  String toString() => 'Left($value)';
}

final class Right<L, R> extends Either<L, R> {
  final R value;
  const Right(this.value);
  @override
  String toString() => 'Right($value)';
}
