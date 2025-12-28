part of 'employees_cubit.dart';

class EmployeesState extends Equatable {
  final List<EmployeeEntity> employees;
  final bool isLoading;
  final String? error;

  const EmployeesState({
    required this.employees,
    required this.isLoading,
    this.error,
  });

  const EmployeesState.initial()
      : this(employees: const [], isLoading: false, error: null);

  EmployeesState copyWith({
    List<EmployeeEntity>? employees,
    bool? isLoading,
    String? error,
  }) {
    return EmployeesState(
      employees: employees ?? this.employees,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  @override
  List<Object?> get props => [employees, isLoading, error];
}
