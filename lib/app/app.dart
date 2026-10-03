import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_theme.dart';
import '../data/mock/rescue_grid_state.dart';
import 'router.dart';

class RescueGridApp extends StatelessWidget {
  const RescueGridApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => RescueGridState(),
      child: MaterialApp.router(
        title: 'RescueGrid',
        debugShowCheckedModeBanner: false,
        theme: RgTheme.lightTheme,
        routerConfig: appRouter,
      ),
    );
  }
}
