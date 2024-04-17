import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import '../../utils/app_state.dart';
import '../../utils/common_constants.dart' as constants;
import '../view_model/home_view_model.dart';

class HomeDrawerWidget extends StatefulWidget {
  const HomeDrawerWidget({Key? key}) : super(key: key);

  @override
  State<HomeDrawerWidget> createState() => _HomeDrawerWidgetState();
}

class _HomeDrawerWidgetState extends State<HomeDrawerWidget>
    with SingleTickerProviderStateMixin {
  late HomeViewModel viewModel;

  @override
  void initState() {
    viewModel = Provider.of<HomeViewModel>(context, listen: false);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          SizedBox(
            height: constants.appDrawerHeaderHeight,
            child: DrawerHeader(
              decoration: const BoxDecoration(
                color: Colors.black,
              ),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0.0, 0.0,
                      constants.mediumPadding, constants.largePadding * 0.25),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const SizedBox(
                        height: constants.mediumPadding,
                      ),
                      Expanded(
                        child: Text(
                          'Hello, ${AppState.instance.userName}',
                          style: constants.appBarHeaderTextStyle,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Tool Inventory List Tile
          ListTile(
            title: Text(
              "Tool Inventory",
              style: constants.appBarListTileTextStyle,
            ),
            onTap: () async {
              Navigator.pushReplacementNamed(context, '/toolInventory');
            },
            leading: Icon(Icons.inventory), // Add appropriate icon
          ),
          ListTile(
            title: Text(
              "Prompt Management",
              style: constants.appBarListTileTextStyle,
            ),
            onTap: () async {
              Navigator.pushReplacementNamed(context, '/promptManagement');
            },
            leading: const Icon(Icons.settings), // Add appropriate icon
          ),
          ListTile(
            title: Text(
              "Logout",
              style: constants.appBarListTileTextStyle,
            ),
              leading: Icon(Icons.logout), // Add appropriate icon
              onTap: () async {
              bool? result = await viewModel.deleteToken(context);
              if (result != null && result) {
                await viewModel.setLogoutSharedPreferences(context);
                Fluttertoast.showToast(msg: "Logged out");
                Navigator.pushReplacementNamed(context, '/login');
              }
            }
          )
        ],
      ),
    );
  }
}
