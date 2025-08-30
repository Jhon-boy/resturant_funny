import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:resturant_funny/app/states/app_state.dart';

final appStateProvider = ChangeNotifierProvider<AppState>((ref) {
  return AppState();
});