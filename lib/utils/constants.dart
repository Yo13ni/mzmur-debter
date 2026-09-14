/// Render-deployed Nest API.
/// Override at build/run time:
///   flutter run --dart-define=API_BASE_URL=http://127.0.0.1:3000/api
const String kApiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'https://mezmur-debter-backend.onrender.com/api',
);
