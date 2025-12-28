import 'package:equatable/equatable.dart';

class EmptyEntity extends Equatable {
  final String id;

  const EmptyEntity({required this.id});

  @override
  List<Object?> get props => [id];
}
