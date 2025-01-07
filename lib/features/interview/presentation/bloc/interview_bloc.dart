import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/interview_repository.dart';
import '../../domain/models/interview_session.dart';
import '../../domain/models/interview_message.dart';
import 'interview_event.dart';
import 'interview_state.dart';
import 'package:logger/logger.dart';

class InterviewBloc extends Bloc<InterviewEvent, InterviewState> {
  final InterviewRepository repository;
  final Logger _logger = Logger();

  InterviewBloc({required this.repository}) : super(InterviewInitial()) {
    on<StartInterview>(_onStartInterview);
    on<SendResponse>(_onSendResponse);
    on<EndInterview>(_onEndInterview);
    on<ResetInterview>((event, emit) => emit(InterviewInitial()));
  }

  void _onStartInterview(StartInterview event, Emitter<InterviewState> emit) async {
    _logger.i('Starting interview process');
    emit(InterviewLoading());
    
    try {
      final response = await repository.startInterview(
        event.role,
        event.experienceLevel,
      );
      
      final session = InterviewSession(
        sessionId: response['sessionId'],
        role: event.role,
        experienceLevel: event.experienceLevel,
        messages: [
          InterviewMessage(
            content: response['message'],
            isAI: true,
            audioBuffer: response['audio'],
          ),
        ],
      );

      emit(InterviewInProgress(session: session));
      _logger.i('Interview started successfully');
    } catch (e) {
      _logger.e('Error starting interview: $e');
      emit(InterviewError(e.toString()));
    }
  }

  void _onSendResponse(SendResponse event, Emitter<InterviewState> emit) async {
    if (state is InterviewInProgress) {
      final currentState = state as InterviewInProgress;
      
      // Add user message immediately
      final updatedSession = currentState.session.copyWith(
        messages: [
          ...currentState.session.messages,
          InterviewMessage(content: event.response, isAI: false),
        ],
      );
      
      emit(currentState.copyWith(
        session: updatedSession,
        isProcessing: true,
      ));

      try {
        final response = await repository.sendResponse(
          currentState.session.sessionId,
          event.response,
        );

        final newSession = updatedSession.copyWith(
          messages: [
            ...updatedSession.messages,
            InterviewMessage(
              content: response['message'],
              isAI: true,
              audioBuffer: response['audio'],
            ),
          ],
        );

        emit(InterviewInProgress(session: newSession));
      } catch (e) {
        _logger.e('Error sending response: $e');
        emit(InterviewError(e.toString()));
      }
    }
  }

  void _onEndInterview(EndInterview event, Emitter<InterviewState> emit) async {
    if (state is InterviewInProgress) {
      final currentState = state as InterviewInProgress;
      emit(InterviewLoading());

      try {
        final feedback = await repository.endInterview(currentState.session.sessionId);
        
        if (feedback != null) {
          emit(InterviewCompleted(
            feedback: feedback,
            session: currentState.session.copyWith(isCompleted: true),
          ));
        } else {
          throw Exception('No feedback received');
        }
      } catch (e) {
        _logger.e('Error ending interview: $e');
        emit(InterviewError(e.toString()));
      }
    }
  }
}
