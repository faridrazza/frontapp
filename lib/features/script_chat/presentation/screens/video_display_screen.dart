import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../bloc/script_chat_bloc.dart';
import '../../domain/models/video.dart';
import './script_chat_screen.dart';

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
    
    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: videoId != null
                ? YoutubePlayer(
                    controller: YoutubePlayerController(
                      initialVideoId: videoId,
                      flags: const YoutubePlayerFlags(
                        autoPlay: false,
                        mute: true,
                      ),
                    ),
                  )
                : const Center(child: Text('Invalid video URL')),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  video.title ?? 'Untitled Video',
                  style: Theme.of(context).textTheme.titleMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                ElevatedButton(
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
                    backgroundColor: const Color(0xFFC6F432),
                    foregroundColor: Colors.black,
                  ),
                  child: const Text('Challenge'),
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
      appBar: AppBar(
        title: const Text('Video Challenges'),
        backgroundColor: Colors.black,
      ),
      body: BlocBuilder<ScriptChatBloc, ScriptChatState>(
        builder: (context, state) {
          if (state is ScriptChatLoading) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFC6F432)),
              ),
            );
          }
          
          if (state is VideosLoaded) {
            return GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.75,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: state.videos.length,
              itemBuilder: (context, index) => _buildVideoCard(state.videos[index]),
            );
          }
          
          if (state is ScriptChatError) {
            return Center(
              child: Text(
                'Error: ${state.message}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }
          
          return const Center(child: Text('No videos available'));
        },
      ),
    );
  }
} 