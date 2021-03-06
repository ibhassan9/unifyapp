import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unify/Components/Constants.dart';
import 'package:unify/Models/assignment.dart';
import 'package:unify/Models/club.dart';
import 'package:unify/Models/comment.dart';
import 'package:unify/Models/post.dart';
import 'package:unify/Models/user.dart';
import 'package:unify/pages/DB.dart';

class OneHealingSpace {
  static bool isRequested(Club club) {
    var joinRequests = club.joinRequests;
    if (joinRequests == null || joinRequests.length == 0) {
      return false;
    }
    if ((joinRequests.singleWhere((it) => it.id == FIR_UID,
            orElse: () => null)) !=
        null) {
      return true;
    } else {
      return false;
    }
  }

  static Future<bool> request(Club club) async {
    var db = FirebaseDatabase.instance
        .reference()
        .child("partners")
        .child("onehealingspace")
        .child('joinRequests')
        .child(FIR_UID);
    await db.set(Constants.uniString(uniKey));
    return true;
  }

  static Future<bool> cancelRequest(Club club) async {
    var db = FirebaseDatabase.instance
        .reference()
        .child("partners")
        .child("onehealingspace")
        .child('joinRequests')
        .child(FIR_UID);
    await db.remove();
    return true;
  }

  static Future<bool> removeUserFromRequests(PostUser user) async {
    var db = FirebaseDatabase.instance
        .reference()
        .child("partners")
        .child('onehealingspace')
        .child('joinRequests')
        .child(user.id);
    await db.remove();
    return true;
  }

  static Future<bool> acceptUser(PostUser user) async {
    var db = FirebaseDatabase.instance
        .reference()
        .child("partners")
        .child('onehealingspace');
    await db
        .child('memberList')
        .child(user.id)
        .set(Constants.uniString(uniKey));
    await removeUserFromRequests(user);
    return true;
  }

  static Future<List<PostUser>> getJoinRequests(
      Map<dynamic, dynamic> requests) async {
    List<PostUser> p = [];
    for (var key in requests.keys) {
      var university = requests[key];
      PostUser user = await getUserWithUniversity(key, university);
      p.add(user);
    }
    return p;
  }

  static Future<bool> removeUserFromClub(Club club, PostUser user) async {
    var db = FirebaseDatabase.instance
        .reference()
        .child('partners')
        .child('onehealingspace')
        .child('memberList')
        .child(user.id);
    await db.remove().catchError((e) {
      return false;
    });
    return true;
  }

  static Future<bool> leave() async {
    var db = FirebaseDatabase.instance
        .reference()
        .child("partners")
        .child('onehealingspace');
    await db.child('memberList').child(FIR_UID).remove();
    return true;
  }

  static Future<bool> join() async {
    var db = FirebaseDatabase.instance
        .reference()
        .child("partners")
        .child('onehealingspace');
    await db
        .child('memberList')
        .child(FIR_UID)
        .set(Constants.uniString(uniKey));
    return true;
  }

  static Future<List<PostUser>> members(Map<dynamic, dynamic> members) async {
    List<PostUser> p = [];
    for (var key in members.keys) {
      var university = members[key];
      PostUser user = await getUserWithUniversity(key, university);
      p.add(user);
    }
    if (p.isEmpty) {
      return [];
    } else {
      return p;
    }
  }

  static Future<Club> object() async {
    var db = FirebaseDatabase.instance
        .reference()
        .child("partners")
        .child('onehealingspace');
    DataSnapshot s = await db.once();
    Map<dynamic, dynamic> value = s.value;

    var club = Club(
        id: value['id'],
        name: value['name'],
        description: value['description'],
        postCount: value['postCount'],
        admin: value['adminId'] == FIR_UID,
        privacy: value['privacy'],
        adminId: value['adminId'],
        imgUrl: value['imgUrl']);

    PostUser admin = await getUserWithUniversity(value['adminId'], "UofT");

    if (value['memberList'] != null) {
      club.memberList = await members(value['memberList']);
      club.memberList.insert(0, admin);
    } else {
      club.memberList = [admin];
    }

    if (value['joinRequests'] != null) {
      club.joinRequests = await getJoinRequests(value['joinRequests']);
    } else {}

    club.memberCount = club.memberList.length;

    club.inClub = inClub(club);
    club.requested = isRequested(club);

    return club;
  }

  static bool inClub(Club club) {
    var memberList = club.memberList;
    if (memberList == null || memberList.length == 0) {
      return false;
    }
    if ((memberList.singleWhere((it) => it.id == FIR_UID,
            orElse: () => null)) !=
        null) {
      return true;
    } else {
      return false;
    }
  }

  static Future<Post> fetchPost(String postId) async {
    Post p;
    var db = FirebaseDatabase.instance
        .reference()
        .child("partners")
        .child("onehealingspace")
        .child('posts')
        .child(postId);

    var snapshot = await db.once().catchError((e) {
      print(e.toString());
      return null;
    });
    var blockList = await getBlocks();
    var hiddenList = await getHiddenList();

    Map<dynamic, dynamic> value = snapshot.value;

    if (value == null) {
      return null;
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    var filters = prefs.getStringList('filters');

    var post = Post(
        id: postId,
        userId: value['userId'],
        username: value['name'],
        content: value['content'],
        timeStamp: value['timeStamp'],
        isAnonymous:
            value['isAnonymous'] != null ? value['isAnonymous'] : false,
        courseId: value['courseId'],
        likeCount: value['likes'] != null ? value['likes'].length : 0,
        imgUrl: value['imgUrl'],
        university: value['university']);

    if (value['comments'] != null) {
      post.commentCount = value['comments'].length;
    } else {
      post.commentCount = 0;
    }

    if (value['questionOne'] != null && value['questionTwo'] != null) {
      if (value['votes'] != null) {
        List<int> voteCounts = getVotes(value['votes']);
        post.questionOneLikeCount = voteCounts[0];
        post.questionTwoLikeCount = voteCounts[1];
      } else {
        post.questionOneLikeCount = 0;
        post.questionTwoLikeCount = 0;
      }
      post.questionOne = value['questionOne'];
      post.questionTwo = value['questionTwo'];
    }

    if (value['votes'] != null) {
      var voted = checkIsVoted(value['votes']);
      post.votes = value['votes'];
      post.isVoted = voted;
      if (voted) {
        int option = whichOption(value['votes']);
        if (option != 0) {
          post.whichOption = option;
        }
      }
    } else {
      post.isVoted = false;
    }

    if (value['likes'] != null) {
      var liked = checkIsLiked(value['likes']);
      post.isLiked = liked;
    } else {
      post.isLiked = false;
    }

    if (value['tcQuestion'] != null) {
      post.tcQuestion = value['tcQuestion'];
    }

    var i = 0;

    if (post.userId != FIR_UID) {
      if (filters != null) {
        for (var filter in filters) {
          if (post.content.toLowerCase().contains(filter.toLowerCase())) {
            i += 1;
          }
        }
      }
    }

    if (i == 0 &&
        blockList.containsKey(post.userId) == false &&
        hiddenList.contains(post.id) == false) {
      p = post;
    }
    return p;
  }

  static Future<List<Post>> fetchPosts(int sortBy) async {
    List<Post> p = [];
    var db = FirebaseDatabase.instance
        .reference()
        .child("partners")
        .child("onehealingspace")
        .child('posts');

    var snapshot = await db.once();
    var blockList = await getBlocks();
    var hiddenList = await getHiddenList();

    Map<dynamic, dynamic> values = snapshot.value;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    var filters = prefs.getStringList('filters');

    values.forEach((key, value) {
      var post = Post(
          id: key,
          userId: value['userId'],
          username: value['name'],
          content: value['content'],
          timeStamp: value['timeStamp'],
          isAnonymous:
              value['isAnonymous'] != null ? value['isAnonymous'] : false,
          courseId: value['courseId'],
          likeCount: value['likes'] != null ? value['likes'].length : 0,
          imgUrl: value['imgUrl'],
          university: value['university']);

      if (value['comments'] != null) {
        post.commentCount = value['comments'].length;
      } else {
        post.commentCount = 0;
      }

      if (value['questionOne'] != null && value['questionTwo'] != null) {
        if (value['votes'] != null) {
          List<int> voteCounts = getVotes(value['votes']);
          post.questionOneLikeCount = voteCounts[0];
          post.questionTwoLikeCount = voteCounts[1];
        } else {
          post.questionOneLikeCount = 0;
          post.questionTwoLikeCount = 0;
        }
        post.questionOne = value['questionOne'];
        post.questionTwo = value['questionTwo'];
      }

      if (value['votes'] != null) {
        var voted = checkIsVoted(value['votes']);
        post.votes = value['votes'];
        post.isVoted = voted;
        if (voted) {
          int option = whichOption(value['votes']);
          if (option != 0) {
            post.whichOption = option;
          }
        }
      } else {
        post.isVoted = false;
      }

      if (value['likes'] != null) {
        var liked = checkIsLiked(value['likes']);
        post.isLiked = liked;
      } else {
        post.isLiked = false;
      }

      if (value['tcQuestion'] != null) {
        post.tcQuestion = value['tcQuestion'];
      }

      var i = 0;

      if (post.userId != FIR_UID) {
        if (filters != null) {
          for (var filter in filters) {
            if (post.content.toLowerCase().contains(filter.toLowerCase())) {
              i += 1;
            }
          }
        }
      }

      if (i == 0 &&
          blockList.containsKey(post.userId) == false &&
          hiddenList.contains(post.id) == false) {
        p.add(post);
      }
    });

    if (sortBy == 0) {
      p.sort((a, b) => b.timeStamp.compareTo(a.timeStamp));
    } else {
      p.sort((a, b) => (b.userId == FIR_UID)
          .toString()
          .compareTo((a.userId == FIR_UID).toString()));
    }
    return p;
  }

  static Future<bool> createPost(Post post) async {
    PostUser user = await getUser(FIR_UID);
    var db = FirebaseDatabase.instance
        .reference()
        .child('partners')
        .child('onehealingspace')
        .child('posts');
    var userDB = FirebaseDatabase.instance
        .reference()
        .child('users')
        .child(Constants.uniString(uniKey))
        .child(user.id)
        .child('myposts');
    var key = db.push();
    final Map<String, dynamic> data = {
      "userId": FIR_UID,
      "name": user.name,
      "content": post.content,
      "timeStamp": DateTime.now().millisecondsSinceEpoch,
      "isAnonymous": post.isAnonymous,
      "likeCount": 0,
      "commentCount": 0,
      "imgUrl": post.imgUrl,
      "university": Constants.uniString(uniKey)
    };

    if (post.questionOne != null && post.questionTwo != null) {
      data['questionOne'] = post.questionOne;
      data['questionTwo'] = post.questionTwo;
      data['questionOneLikeCount'] = 0;
      data['questionTwoLikeCount'] = 0;
    }

    if (post.tcQuestion != null) {
      data['tcQuestion'] = post.tcQuestion;
    }

    await key.set(data);
    await userDB.child(key.key).set({'type': 'onehealingspace'});
    DataSnapshot ds = await key.once();
    if (ds.value != null) {
      return true;
    } else {
      return false;
    }
  }

  static Future<bool> deletePost(String postId) async {
    var myDB = FirebaseDatabase.instance
        .reference()
        .child('users')
        .child(Constants.uniString(uniKey))
        .child(FIR_UID)
        .child('myposts')
        .child(postId);
    var postdb = FirebaseDatabase.instance
        .reference()
        .child('partners')
        .child('onehealingspace')
        .child('posts')
        .child(postId);
    await postdb.remove().catchError((e) {
      return false;
    });

    await myDB.remove().catchError((e) {
      return false;
    });

    return true;
  }

  static Future<bool> deletePostWithUser(
      String postId, String userId, String uni) async {
    var myDB = FirebaseDatabase.instance
        .reference()
        .child('users')
        .child(uni)
        .child(userId)
        .child('myposts')
        .child(postId);
    var postdb = FirebaseDatabase.instance
        .reference()
        .child('partners')
        .child('onehealingspace')
        .child('posts')
        .child(postId);
    await postdb.remove().catchError((e) {
      return false;
    });

    await myDB.remove().catchError((e) {
      return false;
    });

    return true;
  }

  static Future<List<Comment>> fetchComments(Post post) async {
    List<Comment> c = [];
    var db = FirebaseDatabase.instance
        .reference()
        .child('partners')
        .child('onehealingspace')
        .child('posts')
        .child(post.id)
        .child('comments');

    var snapshot = await db.once();

    Map<dynamic, dynamic> values = snapshot.value;

    if (snapshot.value != null) {
      values.forEach((key, value) {
        var comment = Comment(
            content: value['content'],
            username: value['username'],
            userId: value['userId'],
            timeStamp: value['timeStamp']);
        c.add(comment);
      });
      c.sort((a, b) => a.timeStamp.compareTo(b.timeStamp));
    }
    return c;
  }

  static Future<Null> deleteComment(Post post) async {}

  static Future<bool> postComment(Comment comment, Post post) async {
    var university = Constants.uniString(uniKey);
    PostUser user = await getUser(FIR_UID);
    var db = FirebaseDatabase.instance
        .reference()
        .child('partners')
        .child('onehealingspace')
        .child('posts')
        .child(post.id)
        .child('comments');
    //var key = commentsDB.child(post.id).push();
    var key = db.push();
    final Map<String, dynamic> data = {
      "content": comment.content,
      "username": user.name,
      "userId": FIR_UID,
      "timeStamp": DateTime.now().millisecondsSinceEpoch,
      "university": university
    };

    await key.set(data).catchError((err) {
      return false;
    });

    return true;
  }

  static Future<bool> like(Post post) async {
    await FirebaseDatabase.instance
        .reference()
        .child('partners')
        .child('onehealingspace')
        .child('posts')
        .child(post.id)
        .child('likes')
        .child(FIR_UID)
        .set(FIR_UID)
        .catchError((err) {
      return false;
    });
    return true;
  }

  static Future<bool> vote(Post post, int option) async {
    await FirebaseDatabase.instance
        .reference()
        .child('partners')
        .child('onehealingspace')
        .child('posts')
        .child(post.id)
        .child('votes')
        .child(FIR_UID)
        .set(option)
        .catchError((err) {
      return false;
    });
    return true;
  }

  static Future<bool> unlike(Post post) async {
    await FirebaseDatabase.instance
        .reference()
        .child('partners')
        .child('onehealingspace')
        .child('posts')
        .child(post.id)
        .child('likes')
        .child(FIR_UID)
        .remove()
        .catchError((err) {
      return false;
    });
    return true;
  }

  static Future<bool> createReminder(Assignment assignment, String date) async {
    PostUser user = await getUser(FIR_UID);
    var key = FirebaseDatabase.instance
        .reference()
        .child('partners')
        .child('onehealingspace')
        .child('reminders')
        .child(date)
        .push();
    final Map<String, dynamic> data = {
      "title": assignment.title,
      "description": assignment.description,
      "createdBy": user.name,
      "timeDue": assignment.timeDue,
      "userId": FIR_UID,
      "timeStamp": DateTime.now().millisecondsSinceEpoch
    };

    await key.set(data);
    DataSnapshot ds = await key.once();
    if (ds.value != null) {
      return true;
    } else {
      return false;
    }
  }

  static Future<bool> deleteReminder(
      Club club, Assignment a, String dateTime) async {
    var db = FirebaseDatabase.instance
        .reference()
        .child('partners')
        .child('onehealingspace')
        .child('reminders')
        .child(dateTime)
        .child(a.id);
    await db.remove().catchError((err) {
      return false;
    });
    return true;
  }

  static Future<List<Assignment>> fetchReminders(DateTime _date) async {
    String date = DateFormat('yyyy-MM-dd').format(_date);
    List<Assignment> a = [];
    var db = FirebaseDatabase.instance
        .reference()
        .child("partners")
        .child('onehealingspace')
        .child('reminders')
        .child(date);

    var snapshot = await db.once();

    Map<dynamic, dynamic> values = snapshot.value;

    if (snapshot.value != null) {
      values.forEach((key, value) {
        var assignment = Assignment(
            id: key,
            title: value['title'],
            description: value['description'],
            createdBy: value['createdBy'],
            timeDue: value['timeDue'],
            timeStamp: value['timeStamp'],
            userId: value['userId']);
        a.add(assignment);
      });
      a.sort((a, b) => b.timeStamp.compareTo(a.timeStamp));
    }
    return a;
  }

  static Future<List<PostUser>> fetchMemberList(Club club) async {
    var memberDB = FirebaseDatabase.instance
        .reference()
        .child('partners')
        .child('onehealingspace')
        .child('memberList');
    DataSnapshot snap = await memberDB.once();
    Map<dynamic, dynamic> values = snap.value;

    List<PostUser> p = [];
    for (var key in values.keys) {
      var university = values[key];
      PostUser user = await getUserWithUniversity(key, university);
      p.add(user);
    }

    var admin = await getUser(club.adminId);
    p.insert(0, admin);

    if (p.isEmpty) {
      return [];
    } else {
      return p;
    }
  }

  static Future<Null> pushRedirect() async {
    var db = FirebaseDatabase.instance
        .reference()
        .child('partners')
        .child('onehealingspace')
        .child('redirects')
        .child(FIR_UID);
    var count = 0;
    DataSnapshot snap = await db.once();
    if (snap.value != null) {
      int currentCount = snap.value;
      count = currentCount + 1;
    } else {
      count += 1;
    }
    await db.set(count);
  }
}
