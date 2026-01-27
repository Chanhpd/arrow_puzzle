import 'package:flutter/material.dart';
import 'core/di/injection.dart';
import 'features/app/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Configure dependency injection
  await configureDependencies();

  runApp(const MyApp());
}
