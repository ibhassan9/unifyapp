import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:unify/Components/Constants.dart';
import 'package:unify/Models/product.dart';
import 'package:unify/Models/user.dart';
import 'package:unify/pages/ChatPage.dart';
import 'package:timeago/timeago.dart' as timeago;

class ProductDetailPage extends StatefulWidget {
  final Product prod;
  ProductDetailPage({this.prod});
  @override
  _ProductDetailPageState createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  bool isRemoving = false;
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Theme.of(context).backgroundColor,
        actions: [
          Visibility(
            visible:
                widget.prod.sellerId != FirebaseAuth.instance.currentUser.uid,
            child: IconButton(
              icon: Icon(FlutterIcons.more_horiz_mdi),
              onPressed: () {
                final act = CupertinoActionSheet(
                  title: Text("What's wrong with this listing?",
                      style: GoogleFonts.quicksand(
                        textStyle: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Theme.of(context).accentColor),
                      )),
                  actions: <Widget>[
                    CupertinoActionSheetAction(
                        child: Text(
                          "It's suspicious or spam",
                          style: GoogleFonts.quicksand(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: Theme.of(context).accentColor),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                          //showSnackBar();
                        }),
                    CupertinoActionSheetAction(
                        child: Text(
                          "It's abusive or harmful",
                          style: GoogleFonts.quicksand(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: Theme.of(context).accentColor),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                          //showSnackBar();
                        }),
                    CupertinoActionSheetAction(
                        child: Text(
                          "It expresses intentions of self-harm or suicide",
                          style: GoogleFonts.quicksand(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: Theme.of(context).accentColor),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                          //showSnackBar();
                        }),
                    CupertinoActionSheetAction(
                        child: Text(
                          "It promotes sexual/inappropriate content",
                          style: GoogleFonts.quicksand(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: Theme.of(context).accentColor),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                          //showSnackBar();
                        }),
                  ],
                );
                showCupertinoModalPopup(
                    context: context, builder: (BuildContext context) => act);
              },
            ),
          )
        ],
        title: Text('Shop',
            style: GoogleFonts.quicksand(
              textStyle: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).accentColor),
            )),
      ),
      body: body(),
    );
  }

  Widget body() {
    return ListView(
      shrinkWrap: true,
      children: [
        Container(
          height: MediaQuery.of(context).size.height / 2.5,
          width: MediaQuery.of(context).size.width,
          child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: widget.prod.imgUrls.length,
              itemBuilder: (context, itemIndex) {
                return Padding(
                  padding: const EdgeInsets.only(right: 10.0),
                  child: Container(
                    height: MediaQuery.of(context).size.height / 2.5,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                    ),
                    child: CachedNetworkImage(
                      imageUrl: widget.prod.imgUrls[itemIndex],
                      width: widget.prod.imgUrls.length > 1
                          ? MediaQuery.of(context).size.width * 0.9
                          : MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height / 2.5,
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              }),
        ),
        SizedBox(height: 10.0),
        Padding(
          padding: const EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: Image.network(
                      widget.prod.seller.profileImgUrl != null
                          ? widget.prod.seller.profileImgUrl
                          : '',
                      width: 20,
                      height: 20,
                      fit: BoxFit.cover,
                      loadingBuilder: (BuildContext context, Widget child,
                          ImageChunkEvent loadingProgress) {
                        if (loadingProgress == null) return child;
                        return SizedBox(
                          height: 20,
                          width: 20,
                          child: Center(
                            child: SizedBox(
                                width: 20,
                                height: 20,
                                child: LoadingIndicator(
                                  indicatorType: Indicator.ballScaleMultiple,
                                  color: Theme.of(context).accentColor,
                                )),
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(width: 5.0),
                  Text(
                      widget.prod.sellerId ==
                              FirebaseAuth.instance.currentUser.uid
                          ? 'Product by you'
                          : 'Product by ' + widget.prod.sellerName,
                      style: GoogleFonts.quicksand(
                        textStyle: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Theme.of(context).accentColor),
                      )),
                ],
              ),
              Row(
                children: [
                  Icon(FlutterIcons.clock_faw5, size: 16.0),
                  SizedBox(width: 5.0),
                  Text(
                      timeago.format(
                          new DateTime.fromMillisecondsSinceEpoch(
                              widget.prod.timeStamp),
                          locale: 'en_short'),
                      style: GoogleFonts.quicksand(
                        textStyle: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Theme.of(context).accentColor),
                      )),
                ],
              ),
            ],
          ),
        ),
        SizedBox(height: 5.0),
        Padding(
          padding: const EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
          child: Text(widget.prod.title,
              style: GoogleFonts.quicksand(
                textStyle: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).accentColor),
              )),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 15.0),
          child: Text(r'$' + widget.prod.price,
              style: GoogleFonts.quicksand(
                textStyle: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).accentColor),
              )),
        ),
        Padding(
            padding: const EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 15.0),
            child: InkWell(
              onTap: () async {
                if (widget.prod.sellerId ==
                    FirebaseAuth.instance.currentUser.uid) {
                  // remove listing
                  setState(() {
                    isRemoving = true;
                  });
                  var res = await Product.remove(widget.prod.id);
                  if (res) {
                    setState(() {
                      isRemoving = false;
                    });
                  }
                  Navigator.pop(context, true);
                } else {
                  // contact seller

                  if (widget.prod.seller == null) {
                    return;
                  }
                  var chatId = '';
                  var myID = FirebaseAuth.instance.currentUser.uid;
                  var peerId = widget.prod.sellerId;
                  if (myID.hashCode <= peerId.hashCode) {
                    chatId = '$myID-$peerId';
                  } else {
                    chatId = '$peerId-$myID';
                  }

                  showBarModalBottomSheet(
                      context: context,
                      expand: true,
                      builder: (context) => ChatPage(
                            receiver: widget.prod.seller,
                            chatId: chatId,
                            prod: widget.prod,
                          ));

                  // Navigator.push(
                  //     context,
                  //     MaterialPageRoute(
                  //         builder: (context) => ChatPage(
                  //               receiver: widget.prod.seller,
                  //               chatId: chatId,
                  //               prod: widget.prod,
                  //             )));
                }
              },
              child: Container(
                height: 50.0,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                    color: widget.prod.sellerId ==
                            FirebaseAuth.instance.currentUser.uid
                        ? Colors.redAccent
                        : Colors.blue,
                    borderRadius: BorderRadius.circular(3.0)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                        widget.prod.sellerId ==
                                FirebaseAuth.instance.currentUser.uid
                            ? 'Remove Listing'
                            : 'Contact Seller',
                        style: GoogleFonts.quicksand(
                          textStyle: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Colors.white),
                        )),
                    // SizedBox(width: 10.0),
                    // Icon(FlutterIcons.send_mco, color: Colors.white, size: 20.0),
                  ],
                ),
              ),
            )),
        Container(
            height: 5.0,
            width: MediaQuery.of(context).size.width,
            color: Theme.of(context).accentColor.withOpacity(0.05)),
        Padding(
          padding: const EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 0.0),
          child: Text('Description',
              style: GoogleFonts.quicksand(
                textStyle: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).accentColor),
              )),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
          child: Text(widget.prod.description,
              style: GoogleFonts.quicksand(
                textStyle: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).accentColor),
              )),
        ),
      ],
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }
}