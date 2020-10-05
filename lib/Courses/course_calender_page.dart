import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:unify/Courses/AssignmentWidget.dart';
import 'package:unify/Components/Constants.dart';
import 'package:unify/Models/assignment.dart';
import 'package:unify/Models/club.dart';
import 'package:unify/Models/course.dart';
import 'package:timeago/timeago.dart' as timeago;

class CourseCalendarPage extends StatefulWidget {
  final Course course;
  final Club club;
  CourseCalendarPage({Key key, this.course, this.club}) : super(key: key);

  @override
  _CourseCalendarPage createState() => _CourseCalendarPage();
}

class _CourseCalendarPage extends State<CourseCalendarPage> {
  CalendarController _calendarController;
  DateTime dateTimeSelected;
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController timeDueController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _calendarController = CalendarController();
    dateTimeSelected = DateTime.now();
  }

  @override
  void dispose() {
    _calendarController.dispose();
    titleController.dispose();
    descriptionController.dispose();
    timeDueController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    TableCalendar tCalendar = TableCalendar(
      onDaySelected: (dt, lst) {
        setState(() {
          dateTimeSelected = dt;
        });
      },
      calendarController: _calendarController,
      daysOfWeekStyle: DaysOfWeekStyle(
        weekdayStyle: GoogleFonts.quicksand(
          textStyle: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.lightBlue),
        ),
        weekendStyle: GoogleFonts.quicksand(
          textStyle: TextStyle(
              fontSize: 14, fontWeight: FontWeight.w500, color: Colors.red),
        ),
      ),
      headerStyle: HeaderStyle(
        titleTextStyle: GoogleFonts.quicksand(
          textStyle: TextStyle(
              fontSize: 17, fontWeight: FontWeight.w500, color: Colors.black),
        ),
        formatButtonTextStyle: GoogleFonts.quicksand(
          textStyle: TextStyle(
              fontSize: 15, fontWeight: FontWeight.w500, color: Colors.black),
        ),
      ),
      calendarStyle: CalendarStyle(
        weekdayStyle: GoogleFonts.quicksand(
          textStyle: TextStyle(
              fontSize: 17, fontWeight: FontWeight.w500, color: Colors.black),
        ),
        weekendStyle: GoogleFonts.quicksand(
          textStyle: TextStyle(
              fontSize: 17, fontWeight: FontWeight.w500, color: Colors.black),
        ),
        holidayStyle: GoogleFonts.quicksand(
          textStyle: TextStyle(
              fontSize: 17, fontWeight: FontWeight.w500, color: Colors.black),
        ),
        outsideHolidayStyle: GoogleFonts.quicksand(
          textStyle: TextStyle(
              fontSize: 17, fontWeight: FontWeight.w500, color: Colors.black),
        ),
        selectedStyle: GoogleFonts.quicksand(
          textStyle: TextStyle(
              fontSize: 17, fontWeight: FontWeight.w500, color: Colors.white),
        ),
        todayStyle: GoogleFonts.quicksand(
          textStyle: TextStyle(
              fontSize: 17, fontWeight: FontWeight.w500, color: Colors.black),
        ),
        outsideStyle: GoogleFonts.quicksand(
          textStyle: TextStyle(
              fontSize: 17, fontWeight: FontWeight.w500, color: Colors.red),
        ),
        outsideWeekendStyle: GoogleFonts.quicksand(
          textStyle: TextStyle(
              fontSize: 17, fontWeight: FontWeight.w500, color: Colors.red),
        ),
        unavailableStyle: GoogleFonts.quicksand(
          textStyle: TextStyle(
              fontSize: 17, fontWeight: FontWeight.w500, color: Colors.blue),
        ),
      ),
    );

    showAddDialog() {
      AwesomeDialog(
          context: context,
          animType: AnimType.SCALE,
          dialogType: DialogType.NO_HEADER,
          body: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "${widget.course != null ? 'Assignment Due Date:' : 'Event Date:'} ${dateTimeSelected.year} ${dateTimeSelected.month} ${dateTimeSelected.day}",
                  style: GoogleFonts.quicksand(
                    textStyle: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black),
                  ),
                ),
              ),
              TextField(
                controller: titleController,
                decoration: new InputDecoration(
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    contentPadding: EdgeInsets.only(
                        left: 15, bottom: 11, top: 11, right: 15),
                    hintText: widget.course != null
                        ? "Assignment Title..."
                        : "Event Title"),
                style: GoogleFonts.quicksand(
                  textStyle: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black),
                ),
              ),
              TextField(
                controller: descriptionController,
                decoration: new InputDecoration(
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    contentPadding: EdgeInsets.only(
                        left: 15, bottom: 11, top: 11, right: 15),
                    hintText: widget.course != null
                        ? "Assignment Description..."
                        : "Event Description"),
                style: GoogleFonts.quicksand(
                  textStyle: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black),
                ),
              ),
              TextField(
                controller: timeDueController,
                decoration: new InputDecoration(
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    contentPadding: EdgeInsets.only(
                        left: 15, bottom: 11, top: 11, right: 15),
                    hintText:
                        widget.course != null ? "Time Due..." : "When is it?"),
                style: GoogleFonts.quicksand(
                  textStyle: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black),
                ),
              ),
            ],
          ),
          btnOkOnPress: () async {
            var assignment = Assignment(
                title: titleController.text,
                description: descriptionController.text,
                timeDue: timeDueController.text);
            String formattedDate =
                DateFormat('yyyy-MM-dd').format(dateTimeSelected);
            var res = widget.course != null
                ? await createAssignment(
                    assignment, widget.course, formattedDate)
                : await createEventReminder(
                    assignment, widget.club, formattedDate);
            if (res) {
            } else {}
            titleController.clear();
            descriptionController.clear();
            timeDueController.clear();
            setState(() {});
          })
        ..show();
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        brightness: Brightness.light,
        title: Text(
          widget.course != null
              ? "${widget.course.code} Calendar"
              : "${widget.club.name} Calendar",
          style: GoogleFonts.quicksand(
            textStyle: TextStyle(
                fontSize: 15, fontWeight: FontWeight.w500, color: Colors.black),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0.0,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Stack(children: [
        ListView(
          children: <Widget>[
            tCalendar,
            InkWell(
              onTap: () {
                showAddDialog();
              },
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(3.0),
                      color: Colors.deepOrange),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(Icons.add, color: Colors.white),
                        Text(
                          widget.course != null
                              ? "Create note for ${widget.course.code}"
                              : "Create note for ${widget.club.name}",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.quicksand(
                            textStyle: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            FutureBuilder(
              future: widget.course != null
                  ? fetchAssignments(dateTimeSelected, widget.course)
                  : fetchEventReminders(dateTimeSelected, widget.club),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return ListView.builder(
                    shrinkWrap: true,
                    scrollDirection: Axis.vertical,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: snapshot.data != null ? snapshot.data.length : 0,
                    itemBuilder: (BuildContext context, int index) {
                      Assignment assignment = snapshot.data[index];

                      Function delete = () async {
                        String formattedDate =
                            DateFormat('yyyy-MM-dd').format(dateTimeSelected);
                        var res = await deleteAssignment(widget.club,
                            widget.course, assignment, formattedDate);
                        if (res) {
                          setState(() {});
                        }
                      };
                      var timeAgo = new DateTime.fromMillisecondsSinceEpoch(
                          assignment.timeStamp);
                      return AssignmentWidget(
                          club: widget.club,
                          assignment: assignment,
                          timeAgo: timeago.format(timeAgo),
                          delete: delete);
                    },
                  );
                } else {
                  return Container();
                }
              },
            ),
          ],
        )
      ]),
    );
  }
}
