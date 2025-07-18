// lib/injection_container.dart
/// This file configures and initializes the app's dependency injection system using 
/// the `get_it` and `injectable` libraries. Dependency injection is a design pattern 
/// where objects receive their dependencies through constructors, factory methods, 
/// or properties rather than creating them internally, improving testability and maintainability.
/// 
/// Key functionalities:
/// - Defines a global singleton `getIt` as the dependency injection container
/// - Automatically registers dependencies via code generation
/// - Provides an initialization method to configure dependencies for all app components
/// 
/// Usage:
/// 1. Annotate classes needing injection with `@injectable`
/// 2. Use `@module` to mark module classes for organizing related dependencies
/// 3. Run `dart pub run build_runner build` to generate registration code
/// 4. Call `configureDependencies()` early in app startup (e.g., in main())

library;
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
// Import generated configuration file
import 'injection_container.config.dart';

/// Global dependency injection container instance
/// 
/// Used to register and resolve all dependencies in the app, following the singleton pattern.
final getIt = GetIt.instance;

/// Initializes the dependency injection container
/// 
/// Calls the `$initGetIt` function generated by `injectable` to automatically register 
/// all classes annotated with `@injectable`. This method should be called early in 
/// app initialization (e.g., in the main function).
/// 
/// Returns a Future because some dependencies may require async initialization 
/// (e.g., database connections).
@injectableInit
void configureDependencies() async {
  await getIt.init(); // Call the generated initialization function
}
