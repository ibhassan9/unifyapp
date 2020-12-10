import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:unify/Models/course.dart';
import 'package:unify/pages/course_page.dart';
import 'package:unify/Components/Constants.dart';

class CourseWidget extends StatefulWidget {
  final Course course;

  CourseWidget({Key key, @required this.course}) : super(key: key);

  @override
  _CourseWidgetState createState() => _CourseWidgetState();
}

class _CourseWidgetState extends State<CourseWidget> {
  Color color;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => CoursePage(
                      course: widget.course,
                    )));
      },
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Container(
          height: 110,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 5.0),
            child: Row(
              children: <Widget>[
                Column(
                  children: <Widget>[
                    IconButton(
                      icon: Icon(AntDesign.team,
                          color: Theme.of(context).accentColor),
                      onPressed: () {},
                    ),
                    Text(
                      "${widget.course.memberCount}",
                      style: GoogleFonts.manjari(
                        textStyle: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Theme.of(context).accentColor),
                      ),
                    ),
                  ],
                ),
                Container(width: 3.0, color: color),
                SizedBox(
                  width: 15.0,
                ),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Container(
                          child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            widget.course.code,
                            style: GoogleFonts.manjari(
                              textStyle: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context).accentColor),
                            ),
                          ),
                          Divider(),
                          Text(
                            widget.course.name,
                            style: GoogleFonts.manjari(
                              textStyle: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: Theme.of(context).accentColor),
                            ),
                            maxLines: null,
                          )
                        ],
                      )),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          InkWell(
                            onTap: () async {
                              if (widget.course.inCourse) {
                                setState(() {
                                  widget.course.inCourse = false;
                                  widget.course.memberCount -= 1;
                                });
                                await leaveCourse(widget.course);
                              } else {
                                var res = await joinCourse(widget.course);
                                if (res) {
                                  setState(() {
                                    widget.course.inCourse = true;
                                    widget.course.memberCount += 1;
                                  });
                                }
                              }
                            },
                            child: Text(
                              status(),
                              style: GoogleFonts.manjari(
                                textStyle: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.lightBlue),
                              ),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String status() {
    if (widget.course.inCourse) {
      return 'Leave Course';
    } else {
      return 'Join Course';
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    color = Constants.color();
  }
}
