import 'package:equations/equations.dart';

/// When it comes to analysis, the term **numerical integration** indicates a
/// group of algorithms for calculating the numerical value of a definite
/// integral on an interval.
///
/// Numerical integration algorithms compute an approximate solution to a
/// definite integral with a certain degree of accuracy. `NumericalIntegration`
/// is the direct supertype of:
///
///  1. [IntervalsIntegration], which is used for numerical integration
///    algorithms that split the integration bounds into intervals.
///
///  2. [AdaptiveQuadrature], which uses the "adaptive quadrature" algorithm to
///    evaluate the integral.
///
/// The function must be continuous in the `[lowerBound, upperBound]`
/// interval.
abstract base class NumericalIntegration {
  /// Internal functions evaluator.
  static const _evaluator = ExpressionParser();

  /// The function to be integrated on the given interval.
  final String function;

  /// The lower bound of the integral.
  final double lowerBound;

  /// The upper bound of the integral.
  final double upperBound;

  /// Creates a [NumericalIntegration] object.
  const NumericalIntegration({
    required this.function,
    required this.lowerBound,
    required this.upperBound,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    if (other is NumericalIntegration) {
      return runtimeType == other.runtimeType &&
          function == other.function &&
          lowerBound == other.lowerBound &&
          upperBound == other.upperBound;
    } else {
      return false;
    }
  }

  @override
  int get hashCode => Object.hash(function, lowerBound, upperBound);

  @override
  String toString() {
    final lower = lowerBound.toStringAsFixed(2);
    final upper = upperBound.toStringAsFixed(2);

    return '$function on [$lower, $upper]';
  }

  /// Evaluates the given [function] on the [x] point.
  double evaluateFunction(double x) => _evaluator.evaluateOn(function, x);

  /// Calculates the numerical value of the **definite** [function] integral
  /// between [lowerBound] and [upperBound]. Returns a [Record] object whose
  /// members are:
  ///
  ///  - a `guesses` named field, which contains the list of values generated by
  ///    the algorithm on each step;
  ///
  ///  - a `result` named field, which contains the evaluation of the integral
  ///    in the `[a, b]` interval.
  ({List<double> guesses, double result}) integrate();
}
