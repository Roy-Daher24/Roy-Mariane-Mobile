import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:visibility_detector/visibility_detector.dart'; // Import the visibility_detector library
import 'package:roy_mariane_mobile/utils/colors.dart';
import 'package:roy_mariane_mobile/utils/global_variable.dart';
import 'package:roy_mariane_mobile/widgets/post_card.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({Key? key}) : super(key: key);

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: width > webScreenSize ? webBackgroundColor : mobileBackgroundColor,
      appBar: width > webScreenSize
          ? null
          : AppBar(
          backgroundColor: mobileBackgroundColor,
          centerTitle: false,
          title: SvgPicture.asset(
            'assets/codergram.svg',
            height: 32,
          )
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('posts').orderBy('datePublished', descending: true).snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (ctx, index) {
              return VisibilityDetector(
                key: Key(snapshot.data!.docs[index].id), // Use post ID as the key
                onVisibilityChanged: (visibilityInfo) {
                  if (visibilityInfo.visibleFraction == 1) {
                    // Increment views when the post becomes fully visible
                    _incrementViews(snapshot.data!.docs[index].id);
                  }
                },
                child: Container(
                  margin: EdgeInsets.symmetric(
                    horizontal: width > webScreenSize ? width * 0.3 : 0,
                    vertical: width > webScreenSize ? 15 : 0,
                  ),
                  child: PostCard(
                    snap: snapshot.data!.docs[index].data(),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // Function to increment views for a specific post
  Future<void> _incrementViews(String postId) async {
    try {
      // Get a reference to the post document
      DocumentReference postRef = FirebaseFirestore.instance.collection('posts').doc(postId);

      // Use a transaction to ensure atomicity
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        // Get the current views count
        DocumentSnapshot postSnapshot = await transaction.get(postRef);
        int currentViews = postSnapshot.get('views') ?? 0;

        // Increment the views count
        int newViews = currentViews + 1;

        // Update the views count in the document
        transaction.update(postRef, {'views': newViews});
      });
    } catch (error) {
      // Handle errors
      print('Error incrementing views: $error');
    }
  }
}
