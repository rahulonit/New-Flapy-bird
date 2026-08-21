import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme.dart';
import 'core/router.dart';
import 'core/audio_service.dart';
import 'application/providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock orientation to landscape
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  // Immersive mode
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  // Initialize audio
  await AudioService.init();

  runApp(const ProviderScope(child: FlapverseApp()));
}

class FlapverseApp extends ConsumerStatefulWidget {
  const FlapverseApp({super.key});

  @override
  ConsumerState<FlapverseApp> createState() => _FlapverseAppState();
}

class _FlapverseAppState extends ConsumerState<FlapverseApp>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.read(playerSaveProvider.notifier).ensureDailyReset();
      AudioService.resumeBgm();
    }
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      AudioService.pauseBgm();
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(playerSaveProvider, (_, next) {
      next.whenData(
        (save) => AudioService.configure(
          music: save.musicEnabled,
          sfx: save.sfxEnabled,
          haptics: save.hapticsEnabled,
        ),
      );
    });
    return MaterialApp.router(
      title: 'Flapverse 3D',
      theme: appTheme,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
