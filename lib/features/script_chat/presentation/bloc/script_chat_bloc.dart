import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/models/video.dart';
import '../../../../core/services/api_service.dart';

// Events
abstract class ScriptChatEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FetchVideos extends ScriptChatEvent {}

class StartChat extends ScriptChatEvent {
  final String videoId;
  StartChat(this.videoId);
  
  @override
  List<Object?> get props => [videoId];
}

class SendMessage extends ScriptChatEvent {
  final String sessionId;
  final String message;
  SendMessage(this.sessionId, this.message);
  
  @override
  List<Object?> get props => [sessionId, message];
}

class EndChat extends ScriptChatEvent {
  final String sessionId;
  EndChat(this.sessionId);
  
  @override
  List<Object?> get props => [sessionId];
}

// States
abstract class ScriptChatState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ScriptChatInitial extends ScriptChatState {}
class ScriptChatLoading extends ScriptChatState {}
class VideosLoaded extends ScriptChatState {
  final List<Video> videos;
  VideosLoaded(this.videos);
  
  @override
  List<Object?> get props => [videos];
}
class ChatStarted extends ScriptChatState {
  final String sessionId;
  final String message;
  final String audio;
  
  ChatStarted({
    required this.sessionId,
    required this.message,
    required this.audio,
  });
  
  @override
  List<Object?> get props => [sessionId, message, audio];
}
class ScriptChatError extends ScriptChatState {
  final String message;
  ScriptChatError(this.message);
  
  @override
  List<Object?> get props => [message];
}
class MessageSent extends ScriptChatState {
  final String message;
  final String audio;
  MessageSent(this.message, this.audio);
  
  @override
  List<Object?> get props => [message, audio];
}
class ChatEnded extends ScriptChatState {}

// Bloc
class ScriptChatBloc extends Bloc<ScriptChatEvent, ScriptChatState> {
  final ApiService _apiService;
  
  ScriptChatBloc(this._apiService) : super(ScriptChatInitial()) {
    on<FetchVideos>(_onFetchVideos);
    on<StartChat>(_onStartChat);
    on<SendMessage>(_onSendMessage);
    on<EndChat>(_onEndChat);
  }

  Future<void> _onFetchVideos(FetchVideos event, Emitter<ScriptChatState> emit) async {
    emit(ScriptChatLoading());
    try {
      final videos = await _apiService.fetchVideos();
      emit(VideosLoaded(videos));
    } catch (e) {
      emit(ScriptChatError(e.toString()));
    }
  }

  Future<void> _onStartChat(StartChat event, Emitter<ScriptChatState> emit) async {
    emit(ScriptChatLoading());
    try {
      final response = await _apiService.startScriptChat(event.videoId);
      emit(ChatStarted(
        sessionId: response['sessionId'],
        message: response['message'],
        audio: response['audio'],
      ));
    } catch (e) {
      emit(ScriptChatError(e.toString()));
    }
  }

  Future<void> _onSendMessage(SendMessage event, Emitter<ScriptChatState> emit) async {
    try {
      final response = await _apiService.sendScriptChatMessage(
        event.sessionId,
        event.message,
      );
      emit(MessageSent(response['message'], response['audio']));
    } catch (e) {
      emit(ScriptChatError(e.toString()));
    }
  }

  Future<void> _onEndChat(EndChat event, Emitter<ScriptChatState> emit) async {
    try {
      await _apiService.endScriptChat(event.sessionId);
      emit(ChatEnded());
    } catch (e) {
      emit(ScriptChatError(e.toString()));
    }
  }
} 