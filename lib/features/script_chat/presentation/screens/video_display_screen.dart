import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../bloc/script_chat_bloc.dart';
import '../../domain/models/video.dart';
import './script_chat_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class VideoDisplayScreen extends StatefulWidget {
  const VideoDisplayScreen({Key? key}) : super(key: key);

  @override
  _VideoDisplayScreenState createState() => _VideoDisplayScreenState();
}

class _VideoDisplayScreenState extends State<VideoDisplayScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ScriptChatBloc>().add(FetchVideos());
  }

  String? _extractVideoId(String url) {
    return YoutubePlayer.convertUrlToId(url);
  }

  Widget _buildVideoCard(Video video) {
    final videoId = _extractVideoId(video.videoLink);
    
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: videoId != null
                  ? YoutubePlayer(
                      controller: YoutubePlayerController(
                        initialVideoId: videoId,
                        flags: const YoutubePlayerFlags(
                          autoPlay: false,
                          mute: false,
                          hideControls: false,
                          enableCaption: true,
                        ),
                      ),
                    )
                  : const Center(child: Text('Invalid video URL')),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  video.title ?? 'Watch Video',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFC6F432), Color(0xFF90E0EF)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFC6F432).withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      final bloc = context.read<ScriptChatBloc>();
                      bloc.add(StartChat(video.id));
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BlocProvider.value(
                            value: bloc,
                            child: ScriptChatScreen(
                              videoId: video.id,
                              videoUrl: video.videoLink,
                            ),
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Challenge',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
              ),
            ),
            child: const Icon(
              Icons.arrow_back,
              color: Colors.white,
            ),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Color(0xFFC6F432), Color(0xFF90E0EF)],
          ).createShader(bounds),
          child: Text(
            'Video Challenges',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: BlocBuilder<ScriptChatBloc, ScriptChatState>(
        builder: (context, state) {
          if (state is ScriptChatLoading) {
            return Center(
              child: LoadingAnimationWidget.staggeredDotsWave(
                color: const Color(0xFFC6F432),
                size: 40,
              ),
            );
          }
          
          if (state is VideosLoaded) {
            return ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: state.videos.length,
              itemBuilder: (context, index) => _buildVideoCard(state.videos[index]),
            );
          }
          
          if (state is ScriptChatError) {
            return Center(
              child: Text(
                'Error: ${state.message}',
                style: GoogleFonts.poppins(
                  color: Colors.red[400],
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
            );
          }
          
          return Center(
            child: Text(
              'No videos available',
              style: GoogleFonts.poppins(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
          );
        },
      ),
    );
  }
} 