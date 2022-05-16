import 'package:equations/equations.dart';
import 'package:equations_solver/blocs/system_solver/system_solver.dart';
import 'package:equations_solver/routes/system_page/system_body.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// This bloc handles the contents of a [SystemBody] widget by processing
/// the inputs (received as raw strings) and solving systems of equations.
class SystemBloc extends Bloc<SystemEvent, SystemState> {
  /// The type system solving algorithm this bloc has to use.
  final SystemType systemType;

  /// This is required to parse the coefficients received from the user as 'raw'
  /// strings.
  final _parser = const ExpressionParser();

  /// Initializes a [SystemBloc] with [SystemNone].
  SystemBloc(this.systemType) : super(const SystemNone()) {
    on<RowReductionMethod>(_onRowReduction);
    on<FactorizationMethod>(_onFactorization);
    on<IterativeMethod>(_onIterative);
    on<SystemClean>(_onSystemClean);
  }

  void _onRowReduction(RowReductionMethod event, Emitter<SystemState> emit) {
    try {
      // Parsing the system
      final matrix = _valueParser(event.matrix);
      final vector = _valueParser(event.knownValues);

      final solver = GaussianElimination(
        matrix: RealMatrix.fromFlattenedData(
          rows: vector.length,
          columns: vector.length,
          data: matrix,
        ),
        knownValues: vector,
      );

      if (solver.hasSolution()) {
        emit(
          SystemGuesses(
            solution: solver.solve(),
            systemSolver: solver,
          ),
        );
      } else {
        emit(const SingularSystemError());
      }
    } on Exception {
      emit(const SystemError());
    }
  }

  void _onFactorization(FactorizationMethod event, Emitter<SystemState> emit) {
    try {
      late final SystemSolver solver;

      // Parsing the system
      final matrix = _valueParser(event.matrix);
      final vector = _valueParser(event.knownValues);

      final realMatrix = RealMatrix.fromFlattenedData(
        rows: vector.length,
        columns: vector.length,
        data: matrix,
      );

      switch (event.method) {
        case FactorizationMethods.lu:
          solver = LUSolver(
            matrix: realMatrix,
            knownValues: vector,
          );
          break;
        case FactorizationMethods.cholesky:
          solver = CholeskySolver(
            matrix: realMatrix,
            knownValues: vector,
          );
          break;
      }

      if (solver.hasSolution()) {
        emit(
          SystemGuesses(
            solution: solver.solve(),
            systemSolver: solver,
          ),
        );
      } else {
        emit(const SingularSystemError());
      }
    } on Exception {
      emit(const SystemError());
    }
  }

  void _onIterative(IterativeMethod event, Emitter<SystemState> emit) {
    try {
      late final SystemSolver solver;

      // Parsing the system
      final matrix = _valueParser(event.matrix);
      final vector = _valueParser(event.knownValues);

      final realMatrix = RealMatrix.fromFlattenedData(
        rows: vector.length,
        columns: vector.length,
        data: matrix,
      );

      switch (event.method) {
        case IterativeMethods.sor:
          solver = SORSolver(
            matrix: realMatrix,
            knownValues: vector,
            w: _parser.evaluate(event.w),
          );
          break;
        case IterativeMethods.gaussSeidel:
          solver = GaussSeidelSolver(
            matrix: realMatrix,
            knownValues: vector,
          );
          break;
        case IterativeMethods.jacobi:
          solver = JacobiSolver(
            matrix: realMatrix,
            knownValues: vector,
            x0: _valueParser(event.jacobiInitialVector),
          );
          break;
      }

      if (solver.hasSolution()) {
        emit(
          SystemGuesses(
            solution: solver.solve(),
            systemSolver: solver,
          ),
        );
      } else {
        emit(const SingularSystemError());
      }
    } on Exception {
      emit(const SystemError());
    }
  }

  void _onSystemClean(_, Emitter<SystemState> emit) {
    emit(const SystemNone());
  }

  List<double> _valueParser(List<String> source) {
    return source.map(_parser.evaluate).toList();
  }
}
