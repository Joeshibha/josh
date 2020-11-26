import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:linkedin_login/linkedin_login.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() => runApp(MyApp());

// @TODO IMPORTANT - you need to change variable values below
// You need to add your own data from LinkedIn application
// From: https://www.linkedin.com/developers/

final String redirectUrl = 'http://app.carde.de';
final String clientId = '86wjevwli6ym1s';
final String clientSecret = 'z9gqKaQsbjZESC2r';

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: DefaultTabController(
          length: 2,
          child: Scaffold(
            appBar: PreferredSize(
              preferredSize: Size.fromHeight(120.0),
              child: AppBar(
                bottom: TabBar(
                  unselectedLabelColor: Colors.lightBlueAccent,
                  indicatorSize: TabBarIndicatorSize.label,
                  indicator: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      color: Colors.lightGreen),
                  tabs: [
                    Tab(
                      child: Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                                color: Colors.lightBlueAccent, width: 2)),
                        child: Align(
                          alignment: Alignment.center,
                          child: Text(
                            'LinkedIn',
                            style: TextStyle(fontSize: 20),
                          ),
                        ),
                      ),
                    ),
                    Tab(
                      child: Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                            border: Border.all(
                                color: Colors.lightBlueAccent, width: 2)),
                        child: Align(
                          alignment: Alignment.center,
                          child: Text(
                            'Facebook',
                            style: TextStyle(fontSize: 20),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                centerTitle: true,
                title: Text(
                  'SOCIAL MEDIA INTEGRATION',
                  style: TextStyle(fontSize: 25),
                ),
                backgroundColor: Color(0xFFFF1744),
              ),
            ),
            body: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/out1.jpeg'),
                  fit: BoxFit.cover,
                ),
              ),
              child: TabBarView(
                children: [
                  LinkedInProfileExamplePage(),
                  FacebookProfileExamplePage(),
                ],
              ),
            ),
          ),
        ));
  }
}

class LinkedInProfileExamplePage extends StatefulWidget {
  @override
  State createState() => _LinkedInProfileExamplePageState();
}

class _LinkedInProfileExamplePageState
    extends State<LinkedInProfileExamplePage> {
  UserObject user;
  bool logoutUser = false;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            LinkedInButtonStandardWidget(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext context) => LinkedInUserWidget(
                      appBar: AppBar(
                        title: Text('LinkedIn'),
                      ),
                      destroySession: logoutUser,
                      redirectUrl: redirectUrl,
                      clientId: clientId,
                      clientSecret: clientSecret,
                      projection: [
                        ProjectionParameters.id,
                        ProjectionParameters.localizedFirstName,
                        ProjectionParameters.localizedLastName,
                        ProjectionParameters.firstName,
                        ProjectionParameters.lastName,
                        ProjectionParameters.profilePicture,
                      ],

                      onGetUserProfile: (LinkedInUserModel linkedInUser) {
                        print('Access token ${linkedInUser.token.accessToken}');

                        print('User id: ${linkedInUser.userId}');

                        user = UserObject(
                          firstName: linkedInUser?.firstName?.localized?.label,
                          lastName: linkedInUser?.lastName?.localized?.label,
                          email: linkedInUser
                              ?.email?.elements[0]?.handleDeep?.emailAddress,
                          profileImageUrl: linkedInUser
                              ?.profilePicture
                              ?.displayImageContent
                              ?.elements[0]
                              ?.identifiers[0]
                              ?.identifier,
                        );

                        setState(() {
                          logoutUser = false;
                        });

                        Navigator.pop(context);
                      },
                      catchError: (LinkedInErrorObject error) {
                        print('Error description: ${error.description},'
                            ' Error code: ${error.statusCode.toString()}');
                        Navigator.pop(context);
                      },
                    ),
                    fullscreenDialog: true,
                  ),
                );
              },
            ),
            LinkedInButtonStandardWidget(
              onTap: () {
                setState(() {
                  user = null;
                  logoutUser = true;
                });
              },
              buttonText: 'Logout',
            ),
            Container(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text('First name: ${user?.firstName} '),
                  Text('Last name: ${user?.lastName} '),
                  Text('Email id: ${user?.email}'),
                  Text('Profile image: ${user?.profileImageUrl}'),
                ],
              ),
            ),
          ]),
    );
  }
}

class AuthCodeObject {
  String code, state;

  AuthCodeObject({this.code, this.state});
}

class UserObject {
  String firstName, lastName, email, profileImageUrl;

  UserObject({this.firstName, this.lastName, this.email, this.profileImageUrl});
}

class FacebookProfileExamplePage extends StatefulWidget {
  @override
  State createState() => _FacebookProfileExamplePageState();
}

class _FacebookProfileExamplePageState
    extends State<FacebookProfileExamplePage> {
  bool _isLoggedIn = false;
  Map userProfile;
  var facebookLogin = FacebookLogin();

  void _loginWithFB() async {
    var result = await facebookLogin.logIn(['email']);
    switch (result.status) {
      case FacebookLoginStatus.loggedIn:
        final token = result.accessToken.token;
        final graphResponse = await http.get(
            'https://graph.facebook.com/v2.12/me?fields=name,first_name,last_name,picture.height(200),email&access_token=$token');
        final profile = json.decode(graphResponse.body);
        print(profile);
        setState(() {
          userProfile = profile;
          _isLoggedIn = true;
        });
        break;

      case FacebookLoginStatus.cancelledByUser:
        print("Cancelled By User");
        setState(() => _isLoggedIn = false);
        break;
      case FacebookLoginStatus.error:
        print("Error");
        setState(() => _isLoggedIn = false);
        break;
    }
  }

  _logout() {
    facebookLogin.logOut();
    setState(() {
      _isLoggedIn = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 30.0),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              _isLoggedIn
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Container(
                          height: 200.0,
                          width: 200.0,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            image: DecorationImage(
                              fit: BoxFit.fill,
                              image: NetworkImage(
                                userProfile["picture"]["data"]["url"],
                              ),
                            ),
                          ),
                        ),
                        Text(userProfile["name"]),
                        Text(userProfile["first_name"]),
                        Text(userProfile["last_name"]),
                        Text(userProfile["email"]),
                        RaisedButton(
                          child: Text("Logout"),
                          onPressed: () {
                            _logout();
                          },
                        )
                      ],
                    )
                  : InkWell(
                      onTap: () {
                        _loginWithFB();
                      },
                      child: Container(
                          padding: EdgeInsets.symmetric(
                            vertical: 20.0,
                            horizontal: 20.0,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Icon(
                                  FontAwesomeIcons.facebookF,
                                  color: Colors.blue,
                                  size: 30.0,
                                ),
                                Text(
                                  '| Sign in with Facebook',
                                  style: TextStyle(
                                    color: Colors.blue,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20.0,
                                  ),
                                ),
                              ])),
                    )
            ]));
  }
}
