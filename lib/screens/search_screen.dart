import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:roy_mariane_mobile/screens/profile_screen.dart';
import 'package:multi_select_flutter/dialog/multi_select_dialog_field.dart';
import 'package:multi_select_flutter/util/multi_select_item.dart';
import 'package:multi_select_flutter/util/multi_select_list_type.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';


class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController searchController = TextEditingController();
  bool isShowUsers = false;
  List<String> skillsList = [
    'C++',
    'Flutter',
    'Java',
    // Add more options as needed
  ];

  List<String> selectedSkills = []; // Track selected skills

  void _searchWithFilters() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Filter By Skills'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                // Add your edit fields here
                SizedBox(height: 16), // Add spacing between fields
                MultiSelectDialogField(
                  items: skillsList
                      .map((e) => MultiSelectItem(e, e))
                      .toList(),
                  listType: MultiSelectListType.CHIP,
                  initialValue: selectedSkills,
                  onConfirm: (values) {
                    setState(() {
                      selectedSkills = values;
                    });
                  },
                  selectedColor: Colors.purple, // Change to your desired color
                  selectedItemsTextStyle: TextStyle(color: Colors.black), // Change to your desired color
                ),
                SizedBox(height: 16), // Add spacing between fields
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () async {
                setState(() {
                  isShowUsers = true;
                });
                Navigator.of(context).pop();
              },
              child: Text('Search'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Expanded(
              child: TextField(
                controller: searchController,
                decoration:
                InputDecoration(hintText: 'Search for a user...'),
                onSubmitted: (String _) {
                  setState(() {
                    isShowUsers = true;
                  });
                },
              ),
            ),
            IconButton(
              icon: Icon(Icons.filter_alt_outlined),
              onPressed: _searchWithFilters,
            ),
          ],
        ),
      ),
      body: isShowUsers
          ? FutureBuilder(
        future: FirebaseFirestore.instance
            .collection('users')
            .where('username', isGreaterThanOrEqualTo: searchController.text)
            .where('username', isLessThanOrEqualTo: searchController.text + '\uf8ff')
            .get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          var docs = [];
          docs = snapshot.data!.docs;

          // Filter by selected skills
          if (selectedSkills.isNotEmpty) {
            docs = docs.where((doc) {
              List<dynamic> userSkills = doc['skills'];
              return selectedSkills.every((skill) =>
                  userSkills.contains(skill));
            }).toList();
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(
                    docs[index]['photoUrl'],
                  ),
                  radius: 16,
                ),
                title: Text(docs[index]['username']),
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => ProfileScreen(
                      uid: docs[index]['uid'],
                    ),
                  ));
                },
              );
            },
          );
        },
      )
          : FutureBuilder(
        future: FirebaseFirestore.instance
            .collection('posts')
            .orderBy('datePublished')
            .get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          return GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 4.0,
              crossAxisSpacing: 4.0,
              childAspectRatio: 0.7, // Adjust this aspect ratio as needed
            ),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (BuildContext context, int index) {
              return AspectRatio(
                aspectRatio: index.isEven ? 0.7 : 1.0, // Adjust aspect ratio for staggered effect
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.0),
                    image: DecorationImage(
                      image: NetworkImage(snapshot.data!.docs[index]['postUrl']),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              );
            },
          );

        },
      ),
    );
  }
}
