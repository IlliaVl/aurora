import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:injectable/injectable.dart';

// This is the auto-generated file
import 'injection_container.config.dart';

final sl = GetIt.instance; // Service Locator

@InjectableInit(
  initializerName: 'init', // default
  preferRelativeImports: true, // default
  asExtension: true, // default
)
Future<void> configureDependencies() async => sl.init();

// --- Module for registering third-party dependencies ---
@module
abstract class RegisterModule {
  // Register Dio as a singleton
  @lazySingleton
  Dio get dio => Dio();

  // --- ADDED ---
  // Register http.Client for our new service
  @lazySingleton
  http.Client get httpClient => http.Client();
}
