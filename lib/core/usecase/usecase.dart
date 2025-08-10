import 'package:context_for_ai/core/typedefs/type.dart';

abstract class FutureUseCaseWithParams<T, P> {
  const FutureUseCaseWithParams();
  ResultFuture<T> call(P params);
}

abstract class FutureUseCaseWithoutParams<T> {
  const FutureUseCaseWithoutParams();
  ResultFuture<T> call();
}