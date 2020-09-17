import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:unify/Comments/CommentWidget.dart';
import 'package:unify/Components/Constants.dart';
import 'package:unify/Models/comment.dart';
import 'package:unify/Models/course.dart';
import 'package:unify/Models/post.dart';
import 'package:timeago/timeago.dart' as timeago;

class PostDetailPage extends StatefulWidget {
  final Post post;
  final Course course;

  PostDetailPage({Key key, this.post, this.course}) : super(key: key);
  @override
  _PostDetailPageState createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage> {
  @override
  Widget build(BuildContext context) {
    TextEditingController commentController = TextEditingController();

    @override
    void dispose() {
      commentController.dispose();
      super.dispose();
    }

    Padding commentBox = Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        height: 70,
        decoration: BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: Colors.grey.shade300))),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              CircleAvatar(
                backgroundColor: Colors.deepPurple,
              ),
              Flexible(
                  child: TextField(
                controller: commentController,
                decoration: new InputDecoration(
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    contentPadding: EdgeInsets.only(
                        left: 15, bottom: 11, top: 11, right: 15),
                    hintText: "Comment Here"),
                style: GoogleFonts.quicksand(
                  textStyle: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black),
                ),
              )),
              IconButton(
                icon: Icon(
                  Icons.send,
                  color: Colors.black,
                ),
                onPressed: () async {
                  Comment comment = Comment(content: commentController.text);
                  var res = await postComment(comment, widget.post,
                      widget.course == null ? null : widget.course);
                  if (res) {
                    commentController.clear();
                  } else {}
                  setState(() {});
                },
              )
            ],
          ),
        ),
      ),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "Comments",
          style: GoogleFonts.quicksand(
            textStyle: TextStyle(
                fontSize: 17, fontWeight: FontWeight.w700, color: Colors.black),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0.0,
        iconTheme: IconThemeData(color: Colors.black),
        brightness: Brightness.light,
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Stack(
          children: <Widget>[
            ListView(
              children: <Widget>[
                FutureBuilder(
                  future: fetchComments(widget.post),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return ListView.builder(
                        shrinkWrap: true,
                        scrollDirection: Axis.vertical,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount:
                            snapshot.data != null ? snapshot.data.length : 0,
                        itemBuilder: (BuildContext context, int index) {
                          Comment comment = snapshot.data[index];
                          var timeAgo = new DateTime.fromMillisecondsSinceEpoch(
                              comment.timeStamp);
                          return CommentWidget(
                              comment: comment,
                              timeAgo: timeago.format(timeAgo));
                        },
                      );
                    } else {
                      return Container();
                    }
                  },
                ),
              ],
            )
          ],
        ),
      ),
      bottomNavigationBar: Padding(
          padding: EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 10.0),
          child: commentBox),
    );
  }
}
