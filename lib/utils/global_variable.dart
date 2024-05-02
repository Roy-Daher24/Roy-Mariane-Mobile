import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../screens/add_post_screen.dart';
import 'package:roy_mariane_mobile/screens/feed_screen.dart';
// import 'package:roy_mariane_mobile/screens/profile_screen.dart';
// import 'package:roy_mariane_mobile/screens/search_screen.dart';

const webScreenSize = 600;


const homeScreenItems = [
  FeedScreen(),
  Text('search'),
  AddPostScreen(),
  Text('notifications'),
  Text('profile'),
];


// List<Widget> homeScreenItems = [
//   // const FeedScreen(),
//   // const SearchScreen(),
//   const AddPostScreen(),
//   const Text('notifications'),
//   // ProfileScreen(
//   //   uid: FirebaseAuth.instance.currentUser!.uid,
//   // ),
// ];
