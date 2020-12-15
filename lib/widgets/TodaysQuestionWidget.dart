import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:unify/pages/TodaysQuestionPage.dart';

class TodaysQuestionWidget extends StatefulWidget {
  final Function refresh;
  final String question;
  TodaysQuestionWidget({Key key, this.refresh, this.question})
      : super(key: key);
  @override
  _TodaysQuestionWidgetState createState() => _TodaysQuestionWidgetState();
}

class _TodaysQuestionWidgetState extends State<TodaysQuestionWidget> {
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 20.0),
      child: InkWell(
        onTap: () {
          if (widget.question == null) {
            return;
          }
          Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          TodaysQuestionPage(question: widget.question)))
              .then((value) {
            widget.refresh();
          });
        },
        child: Container(
          height: 50.0,
          decoration: BoxDecoration(
              color: Colors.teal, borderRadius: BorderRadius.circular(25.0)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                FlutterIcons.md_happy_ion,
                color: Colors.white,
              ),
              SizedBox(width: 15.0),
              Text(
                "We've got a question for you!",
                style: GoogleFonts.manjari(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
