import '../utils/app_state.dart';

class ApiServiceProvider {
  Map<String,String> headers = {
    'Authorization': 'Bearer ${AppState.instance.token}',
  };
}