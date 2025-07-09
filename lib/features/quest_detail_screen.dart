// lib/features/quest_detail_screen.dart
/// Quest Detail Screen
/// 
/// Displays detailed information and interaction options for a specific quest.
/// Supports different quest types (physical, mental health) with appropriate
/// interfaces, progress tracking, completion handling, and community features
/// like comments for public quests.
library;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:duolympix/features/community/data/models/comment.dart';
import 'package:duolympix/features/community/data/presentation/providers/community_provider.dart';
import 'package:duolympix/features/mental_health/presentation/widgets/typing_indicator.dart';
import 'package:duolympix/features/profile/data/mappers/user_mapper.dart';
import 'package:duolympix/features/profile/data/providers/user_provider.dart';
import 'package:duolympix/global_data/models/user.dart';
import 'mental_health/presentation/widgets/chat_bubble.dart';
import 'mental_health/provider/chat_provider.dart';
import 'quests/provider/quest_provider.dart';
import 'quests/presentation/widgets/quest_progress.dart';
import 'quests/data/models/quest_model.dart';
import 'quests/presentation/widgets/timer_display.dart';

/// Screen for viewing and interacting with a specific quest's details
/// 
/// Handles different UI layouts based on quest type (physical vs. mental health),
/// tracks progress, manages completion, and integrates community features for
/// public quests.
class QuestDetailScreen extends StatefulWidget {
  /// The quest to display details for
  final Quest quest;

  const QuestDetailScreen({super.key, required this.quest});

  @override
  State<QuestDetailScreen> createState() => _QuestDetailScreenState();
}

class _QuestDetailScreenState extends State<QuestDetailScreen> {
  /// Flag to show completion screen after quest is finished
  bool _showCompletion = false;
  
  /// Controller for mental health chat messages
  final TextEditingController _messageController = TextEditingController();
  
  /// Controller for community comments
  final TextEditingController _commentController = TextEditingController();
  
  /// Provider for community features (comments, investments)
  late CommunityProvider _communityProvider;
  
  /// Current user information
  late User _currentUser;

  @override
  void initState() {
    super.initState();
    // Initialize community provider and current user data
    _communityProvider = Provider.of<CommunityProvider>(context, listen: false);
    final userEntity = Provider.of<UserProvider>(context, listen: false).state.user!;
    _currentUser = UserMapper.mapEntityToUser(userEntity);

    // Load community data after widget initialization for public quests
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.quest.isPublic) {
        _communityProvider.fetchColleaguesByQuest(widget.quest.id);
        _communityProvider.fetchInvestmentsByQuest(widget.quest.id);
        _communityProvider.fetchCommentsByQuest(widget.quest.id);
      }
    });
  }

  /// Builds the community interaction section for public quests
  /// 
  /// Currently includes only the comment system (other community features
  /// like colleagues and XP investment are commented out but structurally
  /// prepared for future implementation).
  Widget _buildCommunitySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // // Colleague section (future implementation)
        // _buildColleagueSection(),
        // const SizedBox(height: 20),

        // // XP investment section (future implementation)
        // _buildXpInvestmentSection(),
        // const SizedBox(height: 20),

        // Active comment section
        _buildCommentSection(),
      ],
    );
  }

  /// Builds the comment interface for public quests
  /// 
  /// Displays existing comments, a text input for new comments, and a post button.
  /// Handles loading states and empty comment scenarios with user feedback.
  Widget _buildCommentSection() {
    final state = _communityProvider.state;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Comments',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),

        // Display list of comments or empty state
        if (state.comments != null && state.comments!.isNotEmpty)
          Column(
            children: state.comments!
               .map((comment) => _buildCommentItem(comment))
               .toList(),
          )
        else if (state.status == CommunityStatus.success)
          const Center(child: Text('No comments yet, be the first to comment!')),

        const SizedBox(height: 20),

        // Comment input and post button
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _commentController,
                decoration: const InputDecoration(
                  hintText: 'Leave your comment...',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 10),
            ElevatedButton(
              onPressed: _commentController.text.isEmpty
                  ? null
                  : () async {
                      // Create and post new comment
                      final comment = Comment(
                        questId: widget.quest.id,
                        username: _currentUser.username.toString(),
                        content: _commentController.text,
                        timestamp: DateTime.now(),
                      );
                      await _communityProvider.postComment(comment);
                      _commentController.clear();
                    },
              child: const Text('Post'),
            ),
          ],
        ),
      ],
    );
  }

  /// Builds a single comment item for display in the comment list
  /// 
  /// Shows comment author, content, and timestamp.
  Widget _buildCommentItem(Comment comment) {
    return ListTile(
      title: Text(comment.username),
      subtitle: Text(comment.content),
      trailing: Text(comment.timestamp.toString()),
    );
  }

  /// Builds the interface for physical quests (distance/strength)
  /// 
  /// Includes a timer, progress indicator, completion button, and error display.
  Widget _buildPhysicalQuestScreen(QuestProvider provider, Quest quest) {
    return Column(
      children: [
        TimerDisplay(
          duration: provider.elapsedTime,
          targetDuration: quest.targetDuration,
        ),
        const SizedBox(height: 20),
        QuestProgress(
          quest: quest,
          progress: _calculateProgress(quest, provider, null),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () => _handleQuestCompletion(provider),
          child: const Text('Complete Quest'),
        ),
        if (provider.errorMessage != null)
          Text('Error: ${provider.errorMessage}',
            style: const TextStyle(color: Colors.red)),
      ],
    );
  }

  /// Builds the chat interface for mental health quests
  /// 
  /// Includes a timer, chat history with bubbles, typing indicator, message input,
  /// and completion button (enabled when session is complete).
  Widget _buildChatInterface(ChatProvider chatProvider, QuestProvider questProvider) {
    return Column(
      children: [
        TimerDisplay(
          duration: chatProvider.elapsedTime,
          targetDuration: widget.quest.targetDuration,
        ),
        Expanded(
          child: Stack(
            children: [
              ListView.builder(
                reverse: true, // Show newest messages at the bottom
                itemCount: chatProvider.messages.length,
                itemBuilder: (context, index) {
                  final message = chatProvider.messages.reversed.toList()[index];
                  return ChatBubble(
                    message: message.text,
                    isUser: message.isUser,
                  );
                },
              ),
              if (chatProvider.isLoading) _buildTypingIndicator(),
            ],
          ),
        ),
        _buildChatInput(chatProvider),
        ElevatedButton(
          onPressed: chatProvider.isSessionComplete 
              ? () => _handleQuestCompletion(questProvider) 
              : null,
          child: const Text('Complete Quest'),
        ),
      ],
    );
  }

  /// Displays a typing indicator while waiting for responses
  Widget _buildTypingIndicator() {
    return const TypingIndicator();
  }

  /// Builds the message input area for mental health chat
  /// 
  /// Includes a text field and send button, with submission handling.
  Widget _buildChatInput(ChatProvider provider) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: const InputDecoration(
                hintText: 'Type your message...',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (value) => _sendMessage(value, _messageController, provider),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: () => _sendMessage(_messageController.text, _messageController, provider),
          ),
        ],
      ),
    );
  }

  /// Handles sending a message in mental health chat
  /// 
  /// Clears the input field after sending and ignores empty messages.
  void _sendMessage(String text, TextEditingController controller, ChatProvider provider) {
    if (text.trim().isEmpty) return;
    controller.clear();
    provider.sendMessage(text);
  }

  /// Calculates quest progress based on type and parameters
  /// 
  /// For distance quests: combines distance and time progress
  /// For mental health quests: uses time progress only
  /// For other types: uses time progress based on min/max/target durations
  double _calculateProgress(Quest quest, QuestProvider provider, ChatProvider? chatProvider) {
    if (quest.type == QuestType.distance) {
      final distanceProgress = provider.currentDistance / (quest.targetDistance ?? 1);
      double timeProgress = 0;

      // Calculate time progress based on min/max/target durations
      if (quest.minDuration != null && quest.maxDuration != null) {
        if (provider.elapsedTime < quest.minDuration!) {
          timeProgress = provider.elapsedTime.inSeconds / quest.minDuration!.inSeconds;
        } else if (provider.elapsedTime > quest.maxDuration!) {
          timeProgress = 1;
        } else {
          timeProgress = (provider.elapsedTime.inSeconds - quest.minDuration!.inSeconds) / 
                        (quest.maxDuration!.inSeconds - quest.minDuration!.inSeconds);
        }
      } else if (quest.minDuration != null) {
        timeProgress = provider.elapsedTime.inSeconds / quest.minDuration!.inSeconds;
      } else if (quest.maxDuration != null) {
        timeProgress = provider.elapsedTime.inSeconds / quest.maxDuration!.inSeconds;
      }

      return (distanceProgress + timeProgress) / 2;
    } else if (quest.type == QuestType.mentalHealth) {
      double timeProgress = 0;

      // Calculate time progress for mental health quests
      if (quest.minDuration != null && quest.maxDuration != null) {
        if (chatProvider!.elapsedTime < quest.minDuration!) {
          timeProgress = chatProvider.elapsedTime.inSeconds / quest.minDuration!.inSeconds;
        } else if (chatProvider.elapsedTime > quest.maxDuration!) {
          timeProgress = 1;
        } else {
          timeProgress = (chatProvider.elapsedTime.inSeconds - quest.minDuration!.inSeconds) / 
                        (quest.maxDuration!.inSeconds - quest.minDuration!.inSeconds);
        }
      } else if (quest.minDuration != null) {
        timeProgress = chatProvider!.elapsedTime.inSeconds / quest.minDuration!.inSeconds;
      } else if (quest.maxDuration != null) {
        timeProgress = chatProvider!.elapsedTime.inSeconds / quest.maxDuration!.inSeconds;
      }

      return timeProgress;
    }

    // Default time progress calculation for other quest types
    double timeProgress = 0;

    if (quest.minDuration != null && quest.maxDuration != null) {
      if (provider.elapsedTime < quest.minDuration!) {
        timeProgress = provider.elapsedTime.inSeconds / quest.minDuration!.inSeconds;
      } else if (provider.elapsedTime > quest.maxDuration!) {
        timeProgress = 1;
      } else {
        timeProgress = (provider.elapsedTime.inSeconds - quest.minDuration!.inSeconds) / 
                      (quest.maxDuration!.inSeconds - quest.minDuration!.inSeconds);
      }
    } else if (quest.minDuration != null) {
      timeProgress = provider.elapsedTime.inSeconds / quest.minDuration!.inSeconds;
    } else if (quest.maxDuration != null) {
      timeProgress = provider.elapsedTime.inSeconds / quest.maxDuration!.inSeconds;
    }

    return timeProgress;
  }

  /// Builds the completion screen shown after quest completion
  /// 
  /// Displays success icon, XP reward, and a button to return to quests list.
  Widget _buildCompletionScreen(Quest quest) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.check_circle, color: Colors.green, size: 80),
        const SizedBox(height: 20),
        Text('+${quest.xpReward} XP',
            style: const TextStyle(fontSize: 24, color: Colors.amber)),
        const SizedBox(height: 40),
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Back to Quests'),
        ),
      ],
    );
  }

  /// Handles quest completion process
  /// 
  /// Notifies quest provider to mark as completed, updates user data,
  /// and shows the completion screen.
  Future<void> _handleQuestCompletion(QuestProvider provider) async {
    await provider.completeQuest();
    // Update user data with quest completion
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    await userProvider.completeQuest(widget.quest);
    setState(() => _showCompletion = true);
  }

  /// Main build method for the screen
  /// 
  /// Shows completion screen if quest is finished, otherwise displays
  /// appropriate interface based on quest type and includes community
  /// features for public quests.
  @override
  Widget build(BuildContext context) {
    final questProvider = Provider.of<QuestProvider>(context);
    final chatProvider = widget.quest.type == QuestType.mentalHealth
        ? Provider.of<ChatProvider>(context)
        : null;
    final isCompleted = questProvider.completedQuests.contains(widget.quest);

    // Auto-show completion screen if quest is already completed
    if (isCompleted && !_showCompletion) {
      Future.delayed(Duration.zero, () {
        if (mounted) {
          setState(() => _showCompletion = true);
        }
      });
    }

    return Scaffold(
      appBar: AppBar(title: Text(widget.quest.title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: _showCompletion
            ? _buildCompletionScreen(widget.quest)
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Show appropriate interface based on quest type
                  if (widget.quest.type == QuestType.mentalHealth)
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.6,
                      child: _buildChatInterface(chatProvider!, questProvider),
                    )
                  else
                    _buildPhysicalQuestScreen(questProvider, widget.quest),
                  const SizedBox(height: 20),
                  // Show community section for public quests
                  if (widget.quest.isPublic) _buildCommunitySection(),
                ],
              ),
      ),
    );
  }
}

/// Suggested Extensions for Future Development
/// 
/// 1. Community Feature Expansion:
///    - Implement colleague management section (add/remove colleagues)
///    - Add XP investment functionality with input validation
///    - Display colleague contributions and investment leaderboards
///    - Add notifications for new comments or colleague joins
/// 
/// 2. Quest Progress Enhancements:
///    - Add visual indicators for milestone achievements
///    - Implement progress sharing functionality (social media)
///    - Add detailed statistics (pace, calories for physical quests)
///    - Support pausing/resuming timers with persistence
/// 
/// 3. User Experience Improvements:
///    - Add quest instructions/guidelines section
///    - Implement pull-to-refresh for community data
///    - Add loading skeletons for better perceived performance
///    - Support landscape orientation with optimized layout
/// 
/// 4. Accessibility Features:
///    - Add screen reader support for progress updates
///    - Implement adjustable text sizes for all text elements
///    - Add high contrast mode for better visibility
///    - Support voice input for chat/comments
/// 
/// 5. Error Handling & Recovery:
///    - Add retry logic for failed community operations
///    - Implement offline mode with data sync when online
///    - Add confirmation dialogs for quest completion
///    - Handle network errors gracefully with user feedback
/// 
/// 6. Social Integration:
///    - Add option to invite friends to join a quest
///    - Implement quest sharing with progress snapshots
///    - Add real-time updates when colleagues join/complete
///    - Support group quest completion with combined progress
/// 