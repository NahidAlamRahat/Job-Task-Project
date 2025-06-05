import 'package:flutter/material.dart';
import 'package:job_task/ui/widgets/show_custom_alert_dialog.dart';

import '../screen/auth_screen.dart';

class DrawerMenu extends StatelessWidget {
  const DrawerMenu({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(
            padding: EdgeInsets.all(0),
            child: UserAccountsDrawerHeader(
                decoration: BoxDecoration(color: Color.fromRGBO(2, 84, 100, 1)),
                accountName: SizedBox(
                    height: 20,
                    child: Text(UserController.userData?.displayName ?? '')),
                accountEmail: Text(UserController.userData?.email ?? ''),
                currentAccountPicture: CircleAvatar(
                  radius: 30,
                  backgroundImage: (UserController.userData?.photoURL != null &&
                      UserController.userData!.photoURL!.isNotEmpty)
                      ? NetworkImage(UserController.userData!.photoURL!)
                      : null,
                  child: (UserController.userData?.photoURL == null ||
                      UserController.userData!.photoURL!.isEmpty)
                      ? Icon(Icons.person, size: 30)
                      : null,
                )
            ),
          ),
          Card(
            elevation: 10,
            color: Colors.white,
            shadowColor: Color(0xFFFEFFA7),
            child: ListTile(
              trailing: Icon(Icons.logout_outlined, color: Colors.black),
              title: Center(
                  child: Text('LogOut', style: TextStyle(color: Colors.black))),
              onTap: () {
                showCustomAlertDialog(
                  context,
                  text: const Text('Logout!', style: TextStyle(fontSize: 20)),
                  message: 'Are you sure you want to logout?',
                  onConfirm: () async {
                    UserController.signOut(context: context);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}