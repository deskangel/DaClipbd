import 'package:da_utils/da_utils.dart';
import 'package:daclipbd/model/clipboard_controller.dart';
import 'package:daclipbd/model/dbhandler.dart';
import 'package:daclipbd/model/premium.dart';
import 'package:daclipbd/model/search_notifier.dart';
import 'package:daclipbd/model/theme_notifier.dart';
import 'package:daclipbd/settings/settings.dart';
import 'package:daclipbd/view/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

void main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();

  await Settings.instance.init();
  await DbHandler.instance.init();

  await ClipboardController.instance.showIconOnDock(Settings.instance.showIconOnDock);
  await ClipboardController.instance.setWindowParkPosition(Settings.instance.position);
  await ClipboardController.instance.setShowWindowHotkey(Settings.instance.keybinding);

  await Premium.instance.initFirstRun();

  runApp(const DaClipBoard());
}

class HideWindow extends Intent {
  static void hideWindow() {
    debugPrint('hideWindow');
    ClipboardController.instance.hideWindow();
  }
}

class SearchItem extends Intent {
  static void search(BuildContext context) {
    debugPrint('search');
    Provider.of<SearchNotifier>(context, listen: false).searching = true;
  }
}

class OpenPreference extends Intent {
  static void openPreference() {
    EventBus.instance.fire(eventId: 'OPEN_PREFERENCE_EVENT');
  }
}

class DaClipBoard extends StatelessWidget {
  const DaClipBoard({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeChangeNotifier()),
        ChangeNotifierProvider(create: (context) => SearchNotifier()),
      ],
      child: Consumer<ThemeChangeNotifier>(
        builder: (context, notifier, child) => MaterialApp(
          title: 'DaClipBoard',
          debugShowCheckedModeBanner: false,
          theme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
          themeMode: notifier.themeMode,
          shortcuts: <LogicalKeySet, Intent>{
            LogicalKeySet(LogicalKeyboardKey.escape): HideWindow(),
            LogicalKeySet(LogicalKeyboardKey.meta, LogicalKeyboardKey.keyF): SearchItem(),
            LogicalKeySet(LogicalKeyboardKey.meta, LogicalKeyboardKey.comma): OpenPreference(),
          },
          actions: {
            HideWindow: CallbackAction<HideWindow>(onInvoke: (intent) => HideWindow.hideWindow()),
            SearchItem: CallbackAction<SearchItem>(onInvoke: (intent) => SearchItem.search(context)),
            OpenPreference: CallbackAction<OpenPreference>(onInvoke: (intent) => OpenPreference.openPreference()),
          },
          home: const HomePage(),
        ),
      ),
    );
  }
}
