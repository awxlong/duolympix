// lib/injection_container.dart
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
// Import the module
import 'injection_container.config.dart';

final getIt = GetIt.instance;

@injectableInit
void configureDependencies() async {
  await getIt.init(); // Call the generated `init` function
}