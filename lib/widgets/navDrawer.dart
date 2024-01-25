// ignore_for_file: camel_case_types, file_names

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intro_project/providers/provider.dart';
import 'package:intro_project/views/curr_screens/currency_archive.dart';
import 'package:intro_project/views/orders_screens/order_archive.dart';
import 'package:intro_project/views/user_screens/user_archive.dart';
import 'package:provider/provider.dart';

class navDrawer extends StatelessWidget {
  const navDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
                color: Colors.green,
                image: DecorationImage(
                    fit: BoxFit.fill,
                    image: AssetImage('assets/images/navBar_background.jpg'))),
            child: Text(
              'Side menu',
              style: TextStyle(color: Colors.white, fontSize: 25),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.people_rounded),
            title: const Text('Users'),
            onTap: () => {Get.offAll(() => const UserArchive())},
          ),
          ListTile(
            leading: const Icon(Icons.account_tree_rounded),
            title: const Text('Orders'),
            onTap: () => {Get.offAll(() => const OrderArchive())},
          ),
          ListTile(
            leading: const Icon(Icons.currency_exchange_rounded),
            title: const Text('Currency'),
            onTap: () => {Get.offAll(() => const CurrencyArchive())},
          ),
          Consumer<SessionProvider>(
            builder: (context, SessionProvider provider, child) => ListTile(
              leading: const Icon(Icons.exit_to_app),
              title: const Text('Logout'),
              onTap: () => {provider.logout(context)},
            ),
          ),
        ],
      ),
    );
  }
}
