

import '../utils/app_state.dart';

class ApiServiceProvider {
  Map<String,String> headers = {
    'applicationId': '60ee4cef-e776-4ce2-9ae6-fec1793d97a5',
    'Authorization': 'bearer ${AppState.instance.token}',
    'Csrf-Token': AppState.instance.csrfToken,
    "userId" : AppState.instance.userId,
  };
}