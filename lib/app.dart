import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:image_picker/image_picker.dart';
import 'package:job_task/ui/screen/auth_screen.dart';
import 'package:job_task/ui/screen/home_screen.dart';
import 'package:job_task/ui/screen/login_screen.dart';
import 'package:job_task/ui/screen/share_experience_screen.dart';
import 'package:month_year_picker/month_year_picker.dart';
import 'package:flutter_localizations/flutter_localizations.dart';


class DeveloperLook extends StatelessWidget {
  DeveloperLook({super.key});


  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      initialRoute: UserController.userData != null
          ? HomeScreen.name
          : SignInScreen.name,
      onGenerateRoute: (RouteSettings settings) {
        // Remove 'late' and provide a default route
        Widget route;

        if (settings.name == SignInScreen.name) {
          route = SignInScreen();
        }
        else if (settings.name == HomeScreen.name) {
          route = HomeScreen();
        }

        else if (settings.name == ShareExperienceScreen.name) {
          route = ShareExperienceScreen();
        }
        else {
          route = const Scaffold(
            body: Center(
              child: Text('Route not found'),
            ),
          );
        }

        return MaterialPageRoute(builder: (context) => route);
      },


      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        MonthYearPickerLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''), // ✅ Add the locales you want
        // Add more if needed like Locale('bn', '') for Bangla
      ],


    );
  }
}