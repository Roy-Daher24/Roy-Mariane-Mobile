import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:quill_html_editor/quill_html_editor.dart';
import 'package:roy_mariane_mobile/models/user.dart';
import 'package:roy_mariane_mobile/providers/user_provider.dart';
import 'package:roy_mariane_mobile/resources/firestore_methods.dart';
import 'package:roy_mariane_mobile/utils/colors.dart';
import 'package:roy_mariane_mobile/utils/utils.dart';
import 'package:roy_mariane_mobile/widgets/comment_card.dart';
import 'package:provider/provider.dart';

class CommentsScreen extends StatefulWidget {
  final postId;
  const CommentsScreen({Key? key, required this.postId}) : super(key: key);

  @override
  _CommentsScreenState createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {
  final TextEditingController commentEditingController =
      TextEditingController();
  final QuillEditorController _quillEditorController = QuillEditorController();
  final _editorTextStyle = const TextStyle(
    fontSize: 18,
    color: Colors.black,
    fontWeight: FontWeight.normal,
    fontFamily: 'Roboto',
  );
  final customToolBarList = [
    ToolBarStyle.bold,
    ToolBarStyle.italic,
    ToolBarStyle.align,
    ToolBarStyle.color,
  ];
  String text = '';

  void postComment(String uid, String name, String profilePic) async {
    String? htmlText = await _quillEditorController.getText();
    try {
      String res = await FireStoreMethods().postComment(
        widget.postId,
        htmlText,
        uid,
        name,
        profilePic,
      );

      if (res != 'success') {
        if (context.mounted) showSnackBar(context, res);
      }
      String? emptyText = await _quillEditorController.setText('');
      setState(() {
          text = emptyText!;
      });
    } catch (err) {
      showSnackBar(
        context,
        err.toString(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final User user = Provider.of<UserProvider>(context).getUser;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: mobileBackgroundColor,
        title: const Text(
          'Comments',
        ),
        centerTitle: false,
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('posts')
            .doc(widget.postId)
            .collection('comments')
            .snapshots(),
        builder: (context,
            AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (ctx, index) => CommentCard(
              snap: snapshot.data!.docs[index],
            ),
          );
        },
      ),
      // text input
      bottomNavigationBar: SafeArea(
        child: Container(
          height: 200,
          margin:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          padding: const EdgeInsets.only(left: 16, right: 8),
          child: Row(
            children: [
              CircleAvatar(
                backgroundImage: NetworkImage(user.photoUrl),
                radius: 18,
              ),
              Expanded(
                  child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 16, right: 8),
                    child: ToolBar(
                      controller: _quillEditorController,
                      toolBarConfig: customToolBarList,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 16, right: 8),
                    child: QuillHtmlEditor(
                      text: text,
                      controller: _quillEditorController,
                      isEnabled: true,
                      minHeight: 100,
                      textStyle: _editorTextStyle,
                      hintTextAlign: TextAlign.start,
                      padding: const EdgeInsets.only(left: 10, top: 5),
                      hintTextPadding: EdgeInsets.zero,
                      onFocusChanged: (hasFocus) =>
                          debugPrint('has focus $hasFocus'),
                      onTextChanged: (text) =>
                          debugPrint('widget text change $text'),
                      onEditorCreated: () =>
                          debugPrint('Editor has been loaded'),
                      onEditingComplete: (s) =>
                          debugPrint('Editing completed $s'),
                      onEditorResized: (height) =>
                          debugPrint('Editor resized $height'),
                      onSelectionChanged: (sel) =>
                          debugPrint('${sel.index},${sel.length}'),
                      loadingBuilder: (context) {
                        return const Center(
                            child: CircularProgressIndicator(
                          strokeWidth: 0.4,
                        ));
                      },
                    ),
                  ),
                ],
              )),
              InkWell(
                onTap: () => postComment(
                  user.uid,
                  user.username,
                  user.photoUrl,
                ),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                  child: const Text(
                    'Post',
                    style: TextStyle(color: purpleColor),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
