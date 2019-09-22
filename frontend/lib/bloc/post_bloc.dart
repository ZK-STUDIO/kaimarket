import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:week_3/bloc/post_event.dart';
import './bloc.dart';
import 'package:week_3/models/post.dart';
import 'package:week_3/utils/dio.dart';
import 'package:week_3/utils/utils.dart';
import 'package:rxdart/rxdart.dart';

class PostBloc extends Bloc<PostEvent, PostState> {
  @override
  PostState get initialState => PostUninitialized();

  @override
  Stream<PostState> mapEventToState(PostEvent event) async* {
    try {
      if (event is PostFetch) {
        final searchText = event.searchText;
        final selectedCategory = event.selectedCategory;

        //데이터 받아오기
        var res = await dio.getUri(getUri(
          '/api/posts',
          {
            'q': searchText,
            'category': selectedCategory.toString(),
            'offset': currentState is PostLoaded && !event.reload
                ? (currentState as PostLoaded).posts.length.toString()
                : '0'
          },
        ));

        List<Post> posts = res.data
            .map((p) {
              return Post.fromJson(p);
            })
            .toList()
            .cast<Post>();

        yield PostLoaded(
            posts: currentState is PostLoaded && !event.reload
                ? (currentState as PostLoaded).posts + posts
                : posts,
            bReachedMax: posts.length != 5);
      }

      if (event is SearchWish && currentState is PostLoaded) {
        List<Post> list = (currentState as PostLoaded).posts;
        int postId = (event as SearchWish).postId;
        bool wish = (event as SearchWish).wish;

        list = list.map((p) {
          if (p.id != postId) return p;
          var post = p.copyWith(isWish: wish);
          post.isWish = wish;
          return post;
        }).toList();

        yield PostLoaded(posts: list);
      }

      if (event is PostDelete && currentState is PostLoaded) {
        List<Post> list = (currentState as PostLoaded).posts;
        int postId = (event as PostDelete).postId;

        // 서버에서 지우기
        await dio.deleteUri(getUri('/api/posts/' + postId.toString()));
        log.i('이전');
        for (Post p in list){
          log.i(p.id);
        }
        // bloc에서 지우기
        list = list.where((p) => p.id != postId).toList();
        log.i('이후');
        for (Post p in list){
          log.i(p.id);
        }

        // postLoaded 재설정하기(reload)
        yield PostLoaded(posts: list);
      }

      if (event is StatusUpdate){
        List<Post> list = (currentState as PostLoaded).posts;
        int postId = (event as StatusUpdate).postId;
        int status = (event as StatusUpdate).status;

        await dio.postUri(getUri('/api/posts/${event.postId}/status/${event.status}/'));
        
        list = list.map((p) {
          if (p.id != postId) return p;
          var post = p.copyWith(status: status);
          log.i("before post", post.status);
          log.i("status", status);
          post.status = status;
          log.i("changed post", post.status);
          return post;
        }).toList();
        log.i(list);
        yield PostLoaded(posts: list);
      }
    } catch (_) {
      print(_);
      yield PostError();
    }
  }

  // @override
  // Stream<PostState> transform(
  //   Stream<PostEvent> events,
  //   Stream<PostState> Function(PostEvent event) next,
  // ) {
  //   return super.transform(
  //     (events as Observable<PostEvent>).throttleTime(
  //       Duration(milliseconds: 500),
  //     ),
  //     next,
  //   );
  // }

  Future<List<Post>> _getAllPost() async {
    var response = await dio.getUri(getUri('/api/posts'));
    List<Post> list = List<Post>();
    for (var iterator in response.data) {
      Post post = Post.fromJson(iterator);
      list.add(post);
    }

    return list;
  }

  // @override
  // //이벤트의 흐름에서 디바운스시킨다.
  // Stream<PostState> transform(
  //     Stream<PostEvent> events, Stream<PostState> next(PostEvent event)) {
  //   return super.transform(
  //     (events as Observable<PostEvent>)
  //         .debounceTime(Duration(milliseconds: 500)),
  //     next,
  //   );
  // }
}

// void _getAllPosts() async {
//   final store = Provider.of<Store>(context);
//   var res = await dio.getUri(getUri('/api/posts'));
//   List<Post> list = List<Post>();
//   for (var iterator in res.data) {
//     Post post = Post.fromJson(iterator);
//     list.add(post);
//   }
//   store.addPosts(list);
// }
