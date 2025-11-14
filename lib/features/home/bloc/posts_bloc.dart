import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../model/post.dart';
import '../repo/posts_repo.dart';

/// Events for Posts BLoC
abstract class PostsEvent extends Equatable {
  const PostsEvent();

  @override
  List<Object> get props => [];
}

/// Event to fetch all posts/trips
class FetchAllPosts extends PostsEvent {
  final String? postType;
  final String? pickupLocation;
  final String? dropoffLocation;
  final String? currentLocation;
  final bool? pickupDropoffBoth;
  final int? page;
  final int? limit;

  const FetchAllPosts({
    this.postType,
    this.pickupLocation,
    this.dropoffLocation,
    this.currentLocation,
    this.pickupDropoffBoth,
    this.page,
    this.limit,
  });

  @override
  List<Object> get props => [
        postType ?? '',
        pickupLocation ?? '',
        dropoffLocation ?? '',
        currentLocation ?? '',
        pickupDropoffBoth ?? false,
        page ?? 0,
        limit ?? 0,
      ];
}

/// Event to fetch user's own posts
class FetchUserPosts extends PostsEvent {
  final int? page;
  final int? limit;
  final String? status;
  final String? search;
  final String? dateFrom;
  final String? dateTo;
  final bool? includeAssigned;

  const FetchUserPosts({this.page, this.limit, this.status, this.search, this.dateFrom, this.dateTo, this.includeAssigned});

  @override
  List<Object> get props => [page ?? 0, limit ?? 0, status ?? '', search ?? '', dateFrom ?? '', dateTo ?? '', includeAssigned ?? false];
}

/// Event to create a new post
class CreatePost extends PostsEvent {
  final String title;
  final String description;
  final String? postType;
  final String? pickupLocation;
  final String? dropLocation;
  final String? goodsType;
  final String? vehicleType;
  final String? imageUrl;
  // Trip-specific fields
  final TripLocation? tripStartLocation;
  final TripLocation? tripDestination;
  final List<TripLocation>? viaRoutes;
  final RouteGeoJSON? routeGeoJSON;
  final String? vehicle;
  final bool? selfDrive;
  final String? driver;
  final Distance? distance;
  final TripDuration? duration;
  final String? goodsTypeId;
  final double? weight;
  final DateTime? tripStartDate;
  final DateTime? tripEndDate;

  const CreatePost({
    required this.title,
    required this.description,
    this.postType,
    this.pickupLocation,
    this.dropLocation,
    this.goodsType,
    this.vehicleType,
    this.imageUrl,
    this.tripStartLocation,
    this.tripDestination,
    this.viaRoutes,
    this.routeGeoJSON,
    this.vehicle,
    this.selfDrive,
    this.driver,
    this.distance,
    this.duration,
    this.goodsTypeId,
    this.weight,
    this.tripStartDate,
    this.tripEndDate,
  });

  @override
  List<Object> get props => [
    title,
    description,
    postType ?? '',
    pickupLocation ?? '',
    dropLocation ?? '',
    goodsType ?? '',
    vehicleType ?? '',
    imageUrl ?? '',
    tripStartLocation ?? '',
    tripDestination ?? '',
    viaRoutes ?? [],
    routeGeoJSON ?? '',
    vehicle ?? '',
    selfDrive ?? false,
    driver ?? '',
    distance ?? '',
    duration ?? '',
    goodsTypeId ?? '',
    weight ?? 0.0,
    tripStartDate ?? DateTime.now(),
    tripEndDate ?? DateTime.now(),
  ];
}

/// Event to update an existing post
class UpdatePost extends PostsEvent {
  final String postId;
  final String? title;
  final String? description;
  final String? postType;
  final String? pickupLocation;
  final String? dropLocation;
  final String? goodsType;
  final String? vehicleType;
  final String? imageUrl;
  final bool? isActive;
  // Trip-specific fields
  final TripLocation? tripStartLocation;
  final TripLocation? tripDestination;
  final List<TripLocation>? viaRoutes;
  final RouteGeoJSON? routeGeoJSON;
  final String? vehicle;
  final bool? selfDrive;
  final String? driver;
  final Distance? distance;
  final TripDuration? duration;
  final String? goodsTypeId;
  final double? weight;
  final DateTime? tripStartDate;
  final DateTime? tripEndDate;

  const UpdatePost({
    required this.postId,
    this.title,
    this.description,
    this.postType,
    this.pickupLocation,
    this.dropLocation,
    this.goodsType,
    this.vehicleType,
    this.imageUrl,
    this.isActive,
    this.tripStartLocation,
    this.tripDestination,
    this.viaRoutes,
    this.routeGeoJSON,
    this.vehicle,
    this.selfDrive,
    this.driver,
    this.distance,
    this.duration,
    this.goodsTypeId,
    this.weight,
    this.tripStartDate,
    this.tripEndDate,
  });

  @override
  List<Object> get props => [
    postId,
    title ?? '',
    description ?? '',
    postType ?? '',
    pickupLocation ?? '',
    dropLocation ?? '',
    goodsType ?? '',
    vehicleType ?? '',
    imageUrl ?? '',
    isActive ?? false,
    tripStartLocation ?? '',
    tripDestination ?? '',
    viaRoutes ?? [],
    routeGeoJSON ?? '',
    vehicle ?? '',
    selfDrive ?? false,
    driver ?? '',
    distance ?? '',
    duration ?? '',
    goodsTypeId ?? '',
    weight ?? 0.0,
    tripStartDate ?? DateTime.now(),
    tripEndDate ?? DateTime.now(),
  ];
}

/// Event to delete a post
class DeletePost extends PostsEvent {
  final String postId;

  const DeletePost({required this.postId});

  @override
  List<Object> get props => [postId];
}

/// Event to toggle post/trip status (active/inactive)
class TogglePostStatus extends PostsEvent {
  final String postId;
  final bool isActive;

  const TogglePostStatus({required this.postId, required this.isActive});

  @override
  List<Object> get props => [postId, isActive];
}

/// Event to fetch a single post by ID
class FetchPostById extends PostsEvent {
  final String postId;

  const FetchPostById({required this.postId});

  @override
  List<Object> get props => [postId];
}

/// Event to refresh posts
class RefreshPosts extends PostsEvent {
  final String? postType;
  final String? pickupLocation;
  final String? dropoffLocation;
  final String? currentLocation;
  final bool? pickupDropoffBoth;

  const RefreshPosts({
    this.postType,
    this.pickupLocation,
    this.dropoffLocation,
    this.currentLocation,
    this.pickupDropoffBoth,
  });

  @override
  List<Object> get props => [
        postType ?? '',
        pickupLocation ?? '',
        dropoffLocation ?? '',
        currentLocation ?? '',
        pickupDropoffBoth ?? false,
      ];
}

/// States for Posts BLoC
abstract class PostsState extends Equatable {
  const PostsState();

  @override
  List<Object> get props => [];
}

/// Initial state
class PostsInitial extends PostsState {}

/// Loading state
class PostsLoading extends PostsState {}

/// Success state with posts data
class PostsLoaded extends PostsState {
  final List<Post> posts;
  final bool hasMore;
  final int currentPage;

  const PostsLoaded({required this.posts, this.hasMore = false, this.currentPage = 1});

  @override
  List<Object> get props => [posts, hasMore, currentPage];
}

/// Success state for user posts
class UserPostsLoaded extends PostsState {
  final List<Post> posts;
  final bool hasMore;
  final int currentPage;

  const UserPostsLoaded({required this.posts, this.hasMore = false, this.currentPage = 1});

  @override
  List<Object> get props => [posts, hasMore, currentPage];
}

/// Success state for post creation
class PostCreated extends PostsState {
  final Post post;

  const PostCreated({required this.post});

  @override
  List<Object> get props => [post];
}

/// Success state for post update
class PostUpdated extends PostsState {
  final Post post;

  const PostUpdated({required this.post});

  @override
  List<Object> get props => [post];
}

/// Success state for fetching a single post
class PostLoaded extends PostsState {
  final Post post;

  const PostLoaded({required this.post});

  @override
  List<Object> get props => [post];
}

/// Success state for post deletion
class PostDeleted extends PostsState {
  final String postId;

  const PostDeleted({required this.postId});

  @override
  List<Object> get props => [postId];
}

/// Error state
class PostsError extends PostsState {
  final String message;

  const PostsError({required this.message});

  @override
  List<Object> get props => [message];
}

/// BLoC for managing posts/trips state and events
class PostsBloc extends Bloc<PostsEvent, PostsState> {
  final PostsRepository repository;

  PostsBloc({required this.repository}) : super(PostsInitial()) {
    on<FetchAllPosts>(_onFetchAllPosts);
    on<FetchUserPosts>(_onFetchUserPosts);
    on<FetchPostById>(_onFetchPostById);
    on<CreatePost>(_onCreatePost);
    on<UpdatePost>(_onUpdatePost);
    on<DeletePost>(_onDeletePost);
    on<TogglePostStatus>(_onTogglePostStatus);
    on<RefreshPosts>(_onRefreshPosts);
  }

  Future<void> _onFetchAllPosts(FetchAllPosts event, Emitter<PostsState> emit) async {
    emit(PostsLoading());

    try {
      final result = await repository.getAllPosts(
        postType: event.postType,
        pickupLocation: event.pickupLocation,
        dropoffLocation: event.dropoffLocation,
        currentLocation: event.currentLocation,
        pickupDropoffBoth: event.pickupDropoffBoth,
        page: event.page,
        limit: event.limit,
      );

      if (result.isSuccess) {
        emit(PostsLoaded(posts: result.data!, hasMore: result.data!.length >= (event.limit ?? 10), currentPage: event.page ?? 1));
      } else {
        emit(PostsError(message: result.message!));
      }
    } catch (e) {
      emit(PostsError(message: 'An error occurred: ${e.toString()}'));
    }
  }

  Future<void> _onFetchUserPosts(FetchUserPosts event, Emitter<PostsState> emit) async {
    emit(PostsLoading());

    try {
      final result = await repository.getUserPosts(
        page: event.page,
        limit: event.limit,
        status: event.status,
        search: event.search,
        dateFrom: event.dateFrom,
        dateTo: event.dateTo,
        includeAssigned: event.includeAssigned,
      );

      if (result.isSuccess) {
        emit(UserPostsLoaded(posts: result.data!, hasMore: result.data!.length >= (event.limit ?? 10), currentPage: event.page ?? 1));
      } else {
        emit(PostsError(message: result.message!));
      }
    } catch (e) {
      emit(PostsError(message: 'An error occurred: ${e.toString()}'));
    }
  }

  Future<void> _onFetchPostById(FetchPostById event, Emitter<PostsState> emit) async {
    emit(PostsLoading());

    try {
      final result = await repository.getPostById(event.postId);

      if (result.isSuccess) {
        emit(PostLoaded(post: result.data!));
      } else {
        emit(PostsError(message: result.message!));
      }
    } catch (e) {
      emit(PostsError(message: 'An error occurred: ${e.toString()}'));
    }
  }

  Future<void> _onCreatePost(CreatePost event, Emitter<PostsState> emit) async {
    emit(PostsLoading());

    try {
      final result = await repository.createPost(
        title: event.title,
        description: event.description,
        postType: event.postType,
        pickupLocation: event.pickupLocation,
        dropLocation: event.dropLocation,
        goodsType: event.goodsType,
        vehicleType: event.vehicleType,
        imageUrl: event.imageUrl,
        // Trip-specific fields
        tripStartLocation: event.tripStartLocation,
        tripDestination: event.tripDestination,
        viaRoutes: event.viaRoutes,
        routeGeoJSON: event.routeGeoJSON,
        vehicle: event.vehicle,
        selfDrive: event.selfDrive,
        driver: event.driver,
        distance: event.distance,
        duration: event.duration,
        goodsTypeId: event.goodsTypeId,
        weight: event.weight,
        tripStartDate: event.tripStartDate,
        tripEndDate: event.tripEndDate,
      );

      if (result.isSuccess) {
        emit(PostCreated(post: result.data!));
      } else {
        emit(PostsError(message: result.message!));
      }
    } catch (e) {
      emit(PostsError(message: 'An error occurred: ${e.toString()}'));
    }
  }

  Future<void> _onUpdatePost(UpdatePost event, Emitter<PostsState> emit) async {
    emit(PostsLoading());

    try {
      final result = await repository.updatePost(
        postId: event.postId,
        title: event.title,
        description: event.description,
        postType: event.postType,
        pickupLocation: event.pickupLocation,
        dropLocation: event.dropLocation,
        goodsType: event.goodsType,
        vehicleType: event.vehicleType,
        imageUrl: event.imageUrl,
        isActive: event.isActive,
        // Trip-specific fields
        tripStartLocation: event.tripStartLocation,
        tripDestination: event.tripDestination,
        viaRoutes: event.viaRoutes,
        routeGeoJSON: event.routeGeoJSON,
        vehicle: event.vehicle,
        selfDrive: event.selfDrive,
        driver: event.driver,
        distance: event.distance,
        duration: event.duration,
        goodsTypeId: event.goodsTypeId,
        weight: event.weight,
        tripStartDate: event.tripStartDate,
        tripEndDate: event.tripEndDate,
      );

      if (result.isSuccess) {
        emit(PostUpdated(post: result.data!));
      } else {
        emit(PostsError(message: result.message!));
      }
    } catch (e) {
      emit(PostsError(message: 'An error occurred: ${e.toString()}'));
    }
  }

  Future<void> _onDeletePost(DeletePost event, Emitter<PostsState> emit) async {
    emit(PostsLoading());

    try {
      final result = await repository.deletePost(event.postId);

      if (result.isSuccess) {
        emit(PostDeleted(postId: event.postId));
      } else {
        emit(PostsError(message: result.message!));
      }
    } catch (e) {
      emit(PostsError(message: 'An error occurred: ${e.toString()}'));
    }
  }

  Future<void> _onTogglePostStatus(TogglePostStatus event, Emitter<PostsState> emit) async {
    emit(PostsLoading());

    try {
      final result = await repository.updateTripStatus(tripId: event.postId, isActive: event.isActive);

      if (result.isSuccess) {
        emit(PostUpdated(post: result.data!));
      } else {
        emit(PostsError(message: result.message!));
      }
    } catch (e) {
      emit(PostsError(message: 'An error occurred: ${e.toString()}'));
    }
  }

  Future<void> _onRefreshPosts(RefreshPosts event, Emitter<PostsState> emit) async {
    add(FetchAllPosts(
      postType: event.postType,
      pickupLocation: event.pickupLocation,
      dropoffLocation: event.dropoffLocation,
      currentLocation: event.currentLocation,
      pickupDropoffBoth: event.pickupDropoffBoth,
      page: 1,
      limit: 20,
    ));
  }
}
