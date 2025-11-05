import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:resturant_funny/app/states/app_state.dart';

final appStateProvider = ChangeNotifierProvider<AppState>((ref) {
  return AppState();
});

// Provider para el índice de navegación del MainPage
final navigationIndexProvider = StateProvider<int>((ref) => 0);
