import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:roy_mariane_mobile/resources/auth_methods.dart';
import 'package:roy_mariane_mobile/resources/firestore_methods.dart';
import 'package:roy_mariane_mobile/screens/login_screen.dart';
import 'package:roy_mariane_mobile/utils/colors.dart';
import 'package:roy_mariane_mobile/utils/utils.dart';

class ProfileScreen extends StatefulWidget {
  final String uid;
  const ProfileScreen({Key? key, required this.uid}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  var userData = {};
  int postLen = 0;
  int currentPostLen = 0;
  int followers = 0;
  int following = 0;
  bool isFollowing = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    getData();
  }

  getData() async {
    setState(() {
      isLoading = true;
    });
    try {
      var userSnap = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.uid)
          .get();


      postLen = userSnap.data()!['posts'];
      userData = userSnap.data()!;
      followers = userSnap.data()!['followers'].length;
      following = userSnap.data()!['following'].length;
      isFollowing = userSnap
          .data()!['followers']
          .contains(FirebaseAuth.instance.currentUser!.uid);


      setState(() {});
    } catch (e) {
      showSnackBar(
        context,
        e.toString(),
      );
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Center(
            child: CircularProgressIndicator(),
          )
        : Scaffold(
            // appBar: AppBar(
            //   backgroundColor: mobileBackgroundColor,
            //   // title: Text(
            //   //   userData['username'],
            //   // ),
            //   centerTitle: false,
            // ),
            body: ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.grey,
                            backgroundImage: NetworkImage(
                              userData['photoUrl'],
                            ),
                            radius: 40,
                          ),
                          Expanded(
                            flex: 1,
                            child: Column(
                              children: [
                                Column(
                                  children: [
                                    Container(
                                      alignment: Alignment.centerLeft,
                                      padding: const EdgeInsets.only(
                                          top: 15, left: 30),
                                      child: Text(
                                        userData['username'],
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      alignment: Alignment.centerLeft,
                                      padding: const EdgeInsets.only(
                                          top: 1, left: 30),
                                      child: Text(
                                        userData['bio'],
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w200,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      alignment: Alignment.centerLeft,
                                      padding: const EdgeInsets.only(
                                          top: 1, left: 30),
                                      child: Text(
                                        userData['skills'].join(' | '),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: greenColor,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    FirebaseAuth.instance.currentUser!.uid ==
                                        widget.uid
                                        ?
                                    SizedBox(
                                      width: 150, // Set the width of the button statically
                                      child: Padding(
                                        padding: const EdgeInsets.only(left: 30, top: 8),
                                        child: TextButton(
                                          onPressed: () async {
                                            await AuthMethods().signOut();
                                            if (context.mounted) {
                                              Navigator.of(context).pushReplacement(
                                                MaterialPageRoute(
                                                  builder: (context) => const LoginScreen(),
                                                ),
                                              );
                                            }
                                          },
                                          child: Text(
                                            'Sign Out',
                                            style: TextStyle(color: primaryColor),
                                          ),
                                          style: ButtonStyle(
                                            backgroundColor: MaterialStateProperty.all<Color>(mobileBackgroundColor),
                                            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                              RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(18.0),
                                                side: BorderSide(color: purpleColor),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ):
                                    FirebaseAuth.instance.currentUser!.uid == widget.uid
                                        ? SizedBox() // Hides the Follow/Unfollow buttons if the user is signing out
                                        : SizedBox(
                                      width: 120, // Set the width of the button statically
                                      child: Padding(
                                        padding: const EdgeInsets.only(left: 30, top: 8),
                                        child: isFollowing
                                            ? TextButton(
                                          onPressed: () async {
                                            await FireStoreMethods().followUser(
                                              FirebaseAuth.instance.currentUser!.uid,
                                              userData['uid'],
                                            );

                                            setState(() {
                                              isFollowing = false;
                                              followers--;
                                            });
                                          },
                                          child: Text(
                                            'Unfollow',
                                            style: TextStyle(color: primaryColor),
                                          ),
                                          style: ButtonStyle(
                                            backgroundColor: MaterialStateProperty.all<Color>(mobileBackgroundColor),
                                            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                              RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(18.0),
                                                side: BorderSide(color: purpleColor),
                                              ),
                                            ),
                                          ),
                                        )
                                            : TextButton(
                                          onPressed: () async {
                                            await FireStoreMethods().followUser(
                                              FirebaseAuth.instance.currentUser!.uid,
                                              userData['uid'],
                                            );

                                            setState(() {
                                              isFollowing = true;
                                              followers++;
                                            });
                                          },
                                          child: Text(
                                            'Follow',
                                            style: TextStyle(color: Colors.white),
                                          ),
                                          style: ButtonStyle(
                                            backgroundColor: MaterialStateProperty.all<Color>(purpleColor),
                                            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                              RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(18.0),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                              ],
                            ),
                          ),
                        ],
                      ),
                      Container(
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.only(top: 10, bottom: 30),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            buildStatColumn(postLen, "posts"),
                            buildStatColumn(followers, "followers"),
                            buildStatColumn(following, "following"),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                FutureBuilder(
                  future: FirebaseFirestore.instance
                      .collection('posts')
                      .where('uid', isEqualTo: widget.uid)
                      .orderBy('datePublished', descending: true)
                      .get(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    return GridView.builder(
                      shrinkWrap: true,
                      itemCount: (snapshot.data! as dynamic).docs.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12.5,
                        mainAxisSpacing: 12.5,
                        childAspectRatio: 1,
                      ),
                      itemBuilder: (context, index) {
                        DocumentSnapshot snap =
                            (snapshot.data! as dynamic).docs[index];

                        return SizedBox(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(
                                10), // Adjust the value as needed
                            child: Image(
                              image: NetworkImage(snap['postUrl']),
                              fit: BoxFit.cover,
                            ),
                          ),
                        );
                      },
                    );
                  },
                )
              ],
            ),
          );
  }

  Column buildStatColumn(int num, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          num.toString(),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Container(
          margin: const EdgeInsets.only(top: 4),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w400,
              color: Colors.grey,
            ),
          ),
        ),
      ],
    );
  }
}
