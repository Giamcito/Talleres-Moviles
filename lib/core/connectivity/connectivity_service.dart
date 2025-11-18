import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final connectivityServiceProvider = Provider<ConnectivityService>((ref) {
  final service = ConnectivityService(ref);
  service.init();
  return service;
});

class ConnectivityService {
  final Ref ref;
  ConnectivityService(this.ref);

  void init() {
    Connectivity().onConnectivityChanged.listen((event) {
      if (event.contains(ConnectivityResult.mobile) || event.contains(ConnectivityResult.wifi)) {
        // Disparar sincronización al recuperar conexión.
        ref.read(_connectivityOnlineProvider.notifier).state = true;
      } else {
        ref.read(_connectivityOnlineProvider.notifier).state = false;
      }
    });
  }
}

final _connectivityOnlineProvider = StateProvider<bool>((ref) => true);
final connectivityOnlineProvider = Provider<bool>((ref) => ref.watch(_connectivityOnlineProvider));
