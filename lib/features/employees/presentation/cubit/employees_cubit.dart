import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:balansoved_mobile/features/employees/domain/entities/employee_entity.dart';
import 'package:balansoved_mobile/features/employees/domain/usecases/get_employees_usecase.dart';

part 'employees_state.dart';

class EmployeesCubit extends Cubit<EmployeesState> {
  final GetEmployeesUseCase _getEmployeesUseCase;

  EmployeesCubit({required GetEmployeesUseCase getEmployeesUseCase})
      : _getEmployeesUseCase = getEmployeesUseCase,
        super(const EmployeesState.initial());

  Future<void> fetchEmployees(String firmId) async {
    if (state.isLoading) return;
    emit(state.copyWith(isLoading: true, error: null));

    final result = await _getEmployeesUseCase(firmId);
    result.fold(
      (failure) {
        emit(
          state.copyWith(
            isLoading: false,
            error: failure.message,
          ),
        );
      },
      (employees) {
        emit(
          state.copyWith(
            isLoading: false,
            employees: employees,
            error: null,
          ),
        );
      },
    );
  }

  void clearEmployees() {
    emit(const EmployeesState.initial());
  }
}
