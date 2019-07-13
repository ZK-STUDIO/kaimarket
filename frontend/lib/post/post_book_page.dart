import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:week_3/post/post_category_button.dart';
import 'package:week_3/post/select_map_page.dart';
import 'package:week_3/utils/base_height.dart';
import 'package:week_3/post/photo_button.dart';
import 'package:week_3/utils/utils.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:week_3/models/book.dart';
import 'package:week_3/post/post_book_card.dart';
import 'package:intl/intl.dart';
import 'package:week_3/post/select_map_page.dart';

class PostBookPage extends StatefulWidget {
  final Book book;

  PostBookPage({@required this.book});

  @override
  State<StatefulWidget> createState() => PostBookPageState();
}

class PostBookPageState extends State<PostBookPage> {
  static var selectedCategory;
  List<Asset> selectedPhotos = new List<Asset>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: _buildAppBar(context),
        body: Stack(
          children: <Widget>[
            Positioned.fill(
              child: _buildTotal(context),
            ),
            _buildBottomTabs(context),
          ],
        ));
  }

  Widget _buildAppBar(context) {
    return AppBar(
      backgroundColor: Colors.white,
      title: Text(
        "도서 판매하기",
        style: TextStyle(fontSize: 16.0),
      ),
      actions: <Widget>[
        GestureDetector(
          onTap: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => SelectMapPage()));
          },
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: Text("완료"),
          ),
        ),
      ],
    );
  }

  Widget _buildTotal(context) {
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          SizedBox(height: screenAwareSize(5.0, context)),
          _buildBookInfo(context),
          _buildDivider(context),
          _buildPriceInput(context),
          _buildDivider(context),
          _buildMajorInput(context),
          _buildDivider(context),
          Container(
            child: Column(
              children: <Widget>[
                selectedPhotos.length > 0
                    ? _buildPhotoList(context)
                    : Container(),
                _buildContentInput(context),
              ],
            ),
          ),
          SizedBox(height: screenAwareSize(50.0, context))
        ],
      ),
    );
  }

  Widget _buildBookInfo(context) {
    return Column(
      children: <Widget>[
        PostBookCard(
          book: widget.book,
        ),
      ],
    );
  }

  Widget _buildDivider(context) {
    return Container(
      width: double.infinity,
      height: 1.0,
      color: Colors.grey[300],
    );
  }

  Widget _buildPriceInput(context) {
    return Padding(
      padding: EdgeInsets.only(top: screenAwareSize(5, context)),
      child: Container(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: TextField(
            maxLines: 1,
            decoration: InputDecoration(
              hintText: "희망가격",
              hintStyle: TextStyle(
                fontSize: 14.0,
              ),
              border: InputBorder.none,
            ),
            keyboardType: TextInputType.number,
          ),
        ),
      ),
    );
  }

  Widget _buildMajorInput(context) {
    return Padding(
      padding: EdgeInsets.all(5.0),
      child: Container(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: TextField(
            maxLines: 1,
            decoration: InputDecoration(
              hintText: "사용한 수업명",
              hintStyle: TextStyle(
                fontSize: 14.0,
              ),
              border: InputBorder.none,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContentInput(context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: TextField(
        maxLines: 10,
        decoration: InputDecoration(
          hintText:
              "책 상태를 자세하게 입력해주세요.\n예시)\n구입날짜: 2019년 01월 01일\n상태:필기흔적없음, 깨끗함",
          hintStyle: TextStyle(
            fontSize: 14.0,
          ),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildPhotoList(context) {
    return Container(
      height: screenAwareSize(75, context),
      child: ListView.separated(
        physics: BouncingScrollPhysics(),
        padding: EdgeInsets.all(10.0),
        itemBuilder: (context, idx) {
          return PhotoButton(
            asset: selectedPhotos[idx],
            onPressed: () {
              setState(() {
                selectedPhotos.removeAt(idx);
              });
            },
          );
        },
        separatorBuilder: (context, idx) {
          return SizedBox(
            width: 10.0,
          );
        },
        itemCount: selectedPhotos.length,
        scrollDirection: Axis.horizontal,
      ),
    );
  }

  Widget _buildBottomTabs(context) {
    return Positioned(
      left: 0.0,
      right: 0.0,
      bottom: 0,
      child: Container(
        width: double.infinity,
        height: screenAwareSize(50.0, context),
        decoration: BoxDecoration(color: Colors.white, boxShadow: [
          BoxShadow(
            blurRadius: 10.0,
            color: Colors.black12,
          )
        ]),
        child: Row(
          children: <Widget>[
            Material(
              color: Colors.transparent,
              child: InkResponse(
                containedInkWell: true,
                onTap: () async {
                  var galleryFiles = await MultiImagePicker.pickImages(
                    maxImages: 10,
                    enableCamera: true,
                  );
                  setState(() {
                    selectedPhotos = galleryFiles;
                  });
                },
                radius: 10.0,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: screenAwareSize(15.0, context),
                    vertical: screenAwareSize(15.0, context),
                  ),
                  child: Icon(Icons.camera_alt),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
