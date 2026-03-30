import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';

class RemoteConfigService {
  final FirebaseRemoteConfig _remoteConfig = FirebaseRemoteConfig.instance;

  Future<void> init() async {
    try {
      await _remoteConfig.setDefaults(const {
        "is_enrollment_open": true, 
      });

      await _remoteConfig.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(minutes: 1),

        minimumFetchInterval: kDebugMode ? const Duration(minutes: 1) : const Duration(minutes: 5),
      ));

      await _remoteConfig.fetchAndActivate();
      
    } catch (e) {
      debugPrint("Error inicializando Remote Config: $e");
    }
  }

  bool get isEnrollmentOpen => _remoteConfig.getBool("is_enrollment_open");
  
  Future<void> forceFetch() async {
    await _remoteConfig.fetchAndActivate();
  }
}