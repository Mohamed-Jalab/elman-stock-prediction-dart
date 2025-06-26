void main() {
  print(calculate(
      weights: [
        
       0.1745666400435337,
    -0.18058752881799023,
    -0.20155423613613327,
    -0.08611140404476572,
    0.18273777397335947,
    -0.1757081508996989,
    -0.09611963886301282,
    -0.18076727814310287,
    -0.12929901595084226,
    -0.003904898607945434,
    -0.16520069294898165,
    0.18849139238135595
      ],
      inputs: [1,1,1,1,1,1,1,1,1,1,1],
      bias: -1));
}

double calculate(
    {required List<double> weights,
    required List<double> inputs,
    required double bias}) {
  double res = 0;

  for (int i = 0; i < weights.length - 1; i++) res += inputs[i] * weights[i];
  res += bias * weights.last;
  return res;
}
