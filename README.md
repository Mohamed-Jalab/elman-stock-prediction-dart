# Google Stock Elman Network

An educational, dependency-light implementation of an Elman recurrent neural
network in Dart. The example trains on daily Google stock observations and
predicts the following day's closing price.

The project demonstrates recurrent state and one-step truncated
backpropagation through time. It is not financial advice or a production
market-forecasting system.

## Highlights

- Deterministic Xavier-style weight initialization
- Configurable hidden and output activations
- Recurrent state managed by the network, with an explicit reset operation
- Correct activation derivatives during training
- Header-aware CSV parsing, including quoted volume values
- Per-column min-max scaling fitted only on the training split
- Unit tests for recurrence, learning, scaling, validation, and CSV parsing

## Project layout

```text
bin/train.dart                 Training example
data/                          Bundled university-project datasets
lib/google_stock_elman.dart    Public package API
lib/src/                       Network, scaler, and CSV implementation
test/                          Automated tests
```

## Requirements

- Dart SDK 3.3 or newer

## Run

```bash
dart pub get
dart analyze
dart test
dart run bin/train.dart 200
```

The optional number is the epoch count. Training uses the first 80% of the
training CSV chronologically and reports RMSE on the remaining 20%. The scaler
is fitted on the training portion only to avoid validation-data leakage.

## Model

At time `t`, the hidden state is:

```text
h(t) = activation(Wx * x(t) + Wh * h(t-1) + bh)
y(t) = activation(Wy * h(t) + by)
```

Training uses one-step truncated backpropagation through time. This updates the
recurrent weights using the immediately preceding hidden state while keeping
the code small enough to study. Longer temporal dependencies would require a
multi-step BPTT implementation.

## Data note

The two original CSV files use different column orders. The loader resolves
fields by header name rather than position, so both layouts parse correctly.

## License

Licensed under the MIT License. See [LICENSE](LICENSE).
