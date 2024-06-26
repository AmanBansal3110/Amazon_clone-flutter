import 'dart:convert';

import 'package:amazon_clone/common/widgets/bottom_bar.dart';
import 'package:amazon_clone/constants/error_handling.dart';
import 'package:amazon_clone/constants/global_variable.dart';
import 'package:amazon_clone/constants/utils.dart';
import 'package:amazon_clone/features/home/home_screen.dart';
import 'package:amazon_clone/models/user.dart';
import 'package:amazon_clone/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  void signUpUser({
    required BuildContext context,
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      User user = User(
          id: '',
          name: name,
          email: email,
          password: password,
          address: '',
          type: '',
          token: '');

      http.Response res = await http.post(
        Uri.parse('$uri/api/signup'),
        body: user.toJson(),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8'
        },
      );

      // ignore: use_build_context_synchronously
      httpErrorHandle(
          response: res,
          context: context,
          onSuccess: () {
            showSnackBar(
              context,
              'Account has been created in Aman\'s database',
            );
          });
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }

  // signin user
  void signInUser({
    required BuildContext context,
    required String email,
    required String password,
  }) async {
    try {
      http.Response res = await http.post(
        Uri.parse('$uri/api/signin'),
        body: jsonEncode({
          'email': email, // Add 'email' key here
          'password': password,
        }),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8'
        },
      );

      // ignore: use_build_context_synchronously
      print(res.body);
      // ignore: use_build_context_synchronously
      httpErrorHandle(
          response: res,
          context: context,
          onSuccess: () async {
            SharedPreferences prefs = await SharedPreferences.getInstance();
            Provider.of<UserProvider>(context, listen: false).setUser(res.body);
            await prefs.setString(
                'x-auth-token', jsonDecode(res.body)['token']);
            // ignore: use_build_context_synchronously
            Navigator.pushNamedAndRemoveUntil(
                context, BottomBar.routeName, (route) => false);
          });
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }

  void getUserData({
    required BuildContext context,
  }) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('x-auth-token');

      if (token == null) {
        prefs.setString('x-auth-token', '');
      }

      var tokenRes = await http.post(Uri.parse("$uri/tokenIsValid"),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'x-auth-token': token!
          });
      var response = jsonDecode(tokenRes.body);

      if (response == true) {
        http.Response userRes = await http.get(Uri.parse("$uri/"),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
              'x-auth-token': token
            });

        // ignore: use_build_context_synchronously
        var userProvider = Provider.of<UserProvider>(context, listen: false);
        userProvider.setUser(userRes.body);
      }
      // http.Response res = await http.post(
      //   Uri.parse('$uri/api/signin'),
      //   body: jsonEncode({
      //     'email': email, // Add 'email' key here
      //     'password': password,
      //   }),
      //   headers: <String, String>{
      //     'Content-Type': 'application/json; charset=UTF-8'
      //   },
      // );

      // ignore: use_build_context_synchronously
      // ignore: use_build_context_synchronously
      // httpErrorHandle(
      //     response: res,
      //     context: context,
      //     onSuccess: () async {
      //       SharedPreferences prefs = await SharedPreferences.getInstance();
      //       Provider.of<UserProvider>(context, listen: false).setUser(res.body);
      //       await prefs.setString(
      //           'x-auth-token', jsonDecode(res.body)['token']);
      //       // ignore: use_build_context_synchronously
      //       Navigator.pushNamedAndRemoveUntil(
      //           context, HomeScreen.routeName, (route) => false);
      //     });
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }
}
