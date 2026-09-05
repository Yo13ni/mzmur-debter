/// Local Nest API until Render deploy.
/// Override at build/run time:
///   flutter run --dart-define=API_BASE_URL=https://your-api.onrender.com/api
const String kApiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://127.0.0.1:3000/api',
);
