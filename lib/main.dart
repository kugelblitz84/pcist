import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pcist/config/userConfig.dart';
import 'package:pcist/pages/MainPage.dart';
import 'package:pcist/pages/about_us_full.dart';
import 'package:pcist/pages/admin%20pages/chatpage.dart';
import 'package:pcist/pages/admin%20pages/viewProfilePage.dart';
import 'package:pcist/pages/authPages/login.dart';
import 'package:pcist/pages/authPages/signup.dart';
import 'package:pcist/pages/admin%20pages/userDashBoard.dart';
import 'package:pcist/pages/authPages/OTPpage.dart';
import 'package:pcist/pages/TakeUserDetials.dart';
import 'package:pcist/pages/admin%20pages/SetEventPage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:pcist/firebase_options.dart';
import 'package:pcist/config/firebase.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:pcist/pages/admin%20pages/userListPage.dart';
import 'package:pcist/pages/eventPages/all_events.dart';
import 'package:pcist/pages/admin%20pages/AdminFeatures.dart';
import 'package:pcist/pages/admin%20pages/CreatePadPage.dart';
import 'package:pcist/pages/admin%20pages/PadHistoryPage.dart';
import 'package:pcist/pages/admin%20pages/CreateInvoicePage.dart';
import 'package:pcist/pages/admin%20pages/InvoiceHistoryPage.dart';
import 'package:pcist/pages/admin%20pages/DownloadedDocumentsPage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  //print(LoggedInUserData.role);
  runApp(pcIST());
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(); // Required if Firebase not yet initialized
  print("Handling background message: ${message.messageId}");
}

class pcIST extends StatelessWidget {
  const pcIST({super.key});

  @override
  Widget build(BuildContext context) {
    FirebaseNotifications.initialize(context);
    UserConfig.initialiseUser();
    return GetMaterialApp(
      title: "pcIST",
      theme: ThemeData(
        fontFamily: 'Outfit',
        // textTheme: Theme.of(context).textTheme.apply(
        //   fontWeightDelta: 2, // makes the default weight bolder
        // ),
      ),
      debugShowCheckedModeBanner: false,
      getPages: [
        GetPage(name: '/', page: () => MainPage()),
        GetPage(
          name: '/login',
          page: () => LoginPage(),
          transition: Transition.cupertino,
        ),
        GetPage(
          name: '/signup',
          page: () => SignUp(),
          transition: Transition.cupertino,
        ),
        GetPage(name: '/dashBoard', page: () => UserDashboard()),
        GetPage(name: '/OtpPage', page: () => OTPpage()),
        GetPage(name: '/takeUserDetails', page: () => MemberFormPage()),
        GetPage(name: '/setEvent', page: () => SetEventPage()),
        GetPage(name: '/AboutUsFull', page: () => AboutUsFull()),
        GetPage(name: '/userListPage', page: () => UserListPage()),
        GetPage(name: '/chat', page: () => ChatPage()),
        GetPage(name: '/allEvents', page: () => AllEventsPage()),
        GetPage(name: '/adminFeatures', page: () => AdminFeatures()),
        GetPage(name: '/createPad', page: () => CreatePadPage()),
        GetPage(name: '/padHistory', page: () => PadHistoryPage()),
        GetPage(name: '/createInvoice', page: () => CreateInvoicePage()),
        GetPage(name: '/invoiceHistory', page: () => InvoiceHistoryPage()),
        GetPage(
          name: '/downloadedDocuments',
          page: () => DownloadedDocumentsPage(),
        ),
        GetPage(name: '/viewProfile', page: () => ViewProfilePage()),
      ],
      home: MainPage(),
    );
  }
}
