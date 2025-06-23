//
// Dart file for displaying the detail of each quest.
//

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:solo_leveling/features/community/data/models/colleague_relation.dart';
import 'package:solo_leveling/features/community/data/models/comment.dart';
import 'package:solo_leveling/features/community/data/models/xp_investment.dart';
import 'package:solo_leveling/features/community/data/presentation/providers/community_provider.dart';
import 'package:solo_leveling/features/mental_health/presentation/widgets/typing_indicator.dart';
import 'package:solo_leveling/features/profile/data/mappers/user_mapper.dart';
import 'package:solo_leveling/features/profile/data/providers/user_provider.dart';
import 'package:solo_leveling/global_data/models/user.dart';
import 'mental_health/presentation/widgets/chat_bubble.dart';
import 'mental_health/provider/chat_provider.dart';
import 'quests/provider/quest_provider.dart';
import 'quests/presentation/widgets/quest_progress.dart';
import 'quests/data/models/quest_model.dart';
import 'quests/presentation/widgets/timer_display.dart';



class QuestDetailScreen extends StatefulWidget {
  final Quest quest;
  const QuestDetailScreen({super.key, required this.quest});

  @override
  State<QuestDetailScreen> createState() => _QuestDetailScreenState();
}

class _QuestDetailScreenState extends State<QuestDetailScreen> {
  bool _showCompletion = false;
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _commentController = TextEditingController();
  bool _showColleagueSection = false;
  final List<String> _selectedColleagues = [];
  late CommunityProvider _communityProvider;
  final TextEditingController _xpInvestmentController = TextEditingController(text: '50');
  late User _currentUser;

  @override
  void initState() {
    super.initState();
    _communityProvider = Provider.of<CommunityProvider>(context, listen: false);
    final userEntity = Provider.of<UserProvider>(context, listen: false).state.user!;
    _currentUser = UserMapper.mapEntityToUser(userEntity);

    if (widget.quest.isPublic) {
      _communityProvider.fetchColleaguesByQuest(widget.quest.id);
      _communityProvider.fetchInvestmentsByQuest(widget.quest.id);
      _communityProvider.fetchCommentsByQuest(widget.quest.id);
    }
  }

  Widget _buildCommunitySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Colleague section
        _buildColleagueSection(),
        const SizedBox(height: 20),

        // XP investment section
        _buildXpInvestmentSection(),
        const SizedBox(height: 20),

        // Comment section
        _buildCommentSection(),
      ],
    );
  }

  Widget _buildColleagueSection() {
    final state = _communityProvider.state;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Colleagues',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            if (widget.quest.creatorId == _currentUser.id.toString())
              TextButton(
                onPressed: () {
                  setState(() {
                    _showColleagueSection = !_showColleagueSection;
                  });
                },
                child: Text(
                  _showColleagueSection ? 'Collapse' : 'Add',
                  style: const TextStyle(color: Colors.blue),
                ),
              )
          ],
        ),
        const SizedBox(height: 10),

        // Show current colleagues
        if (state.colleagues != null && state.colleagues!.isNotEmpty)
          Wrap(
            spacing: 8,
            children: state.colleagues!
               .map((relation) => _buildColleagueChip(relation.colleagueId))
               .toList(),
          ),
        const SizedBox(height: 10),

        // Add colleagues form
        if (_showColleagueSection && widget.quest.creatorId == _currentUser.id.toString())
          _buildAddColleaguesForm(),
      ],
    );
  }

  Widget _buildColleagueChip(String colleagueId) {
    return Chip(
      label: Text(colleagueId),
    );
  }

  Widget _buildAddColleaguesForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Enter user ID to add colleagues:'),
        const SizedBox(height: 10),
        TextField(
          onChanged: (value) {
            if (value.isNotEmpty && !_selectedColleagues.contains(value)) {
              _selectedColleagues.add(value);
            }
          },
          decoration: const InputDecoration(
            hintText: 'User ID',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          children: _selectedColleagues
             .map((userId) => _buildSelectedColleagueChip(userId))
             .toList(),
        ),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: _selectedColleagues.isEmpty
              ? null
              : () async {
                  for (final userId in _selectedColleagues) {
                    final relation = ColleagueRelation(
                      questId: widget.quest.id,
                      colleagueId: userId,
                    );
                    await _communityProvider.addColleague(relation);
                  }
                  _selectedColleagues.clear();
                  setState(() {});
                },
          child: const Text('Confirm Add'),
        ),
      ],
    );
  }

  Widget _buildSelectedColleagueChip(String userId) {
    return Chip(
      label: Text(userId),
      onDeleted: () {
        setState(() {
          _selectedColleagues.remove(userId);
        });
      },
    );
  }

  Widget _buildXpInvestmentSection() {
    final state = _communityProvider.state;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'XP Investment',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              'Total Investment: ${state.totalXpInvested} XP',
              style: const TextStyle(fontSize: 16, color: Colors.green),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Investment form
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Support this quest by investing XP:'),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _xpInvestmentController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      hintText: 'Enter XP amount',
                      border: OutlineInputBorder(),
                      suffixText: ' XP',
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _canInvestXp()
                      ? () async {
                          final xpAmount = int.tryParse(_xpInvestmentController.text);
                          if (xpAmount == null || xpAmount <= 0) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Please enter a valid XP amount')),
                            );
                            return;
                          }

                          if (_currentUser.totalXp < xpAmount) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Insufficient XP to invest')),
                            );
                            return;
                          }

                          final investment = XpInvestment(
                            questId: widget.quest.id,
                            investorId: _currentUser.id.toString(),
                            xpAmount: xpAmount,
                            timestamp: DateTime.now(),
                          );
                          await _communityProvider.investXp(investment);
                          _xpInvestmentController.text = '50';
                        }
                      : null,
                  child: const Text('Invest'),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Show investors
            if (state.investments != null && state.investments!.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Investors:'),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    children: state.investments!
                       .map((investment) => _buildInvestorChip(investment))
                       .toList(),
                  ),
                ],
              )
          ],
        ),
      ],
    );
  }

  Widget _buildInvestorChip(XpInvestment investment) {
    return Chip(
      label: Text('${investment.investorId}: ${investment.xpAmount} XP'),
    );
  }

  bool _canInvestXp() {
    final xpAmount = int.tryParse(_xpInvestmentController.text);
    return xpAmount != null && xpAmount > 0 && _currentUser.totalXp >= xpAmount;
  }

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

        // Comment list
        if (state.comments != null && state.comments!.isNotEmpty)
          Column(
            children: state.comments!
               .map((comment) => _buildCommentItem(comment))
               .toList(),
          )
        else if (state.status == CommunityStatus.success)
          const Center(child: Text('No comments yet, be the first to comment!')),

        const SizedBox(height: 20),

        // Post comment
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
                      final comment = Comment(
                        questId: widget.quest.id,
                        userId: _currentUser.id.toString(),
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

  Widget _buildCommentItem(Comment comment) {
    return ListTile(
      title: Text(comment.userId),
      subtitle: Text(comment.content),
      trailing: Text(comment.timestamp.toString()),
    );
  }


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
                reverse: true,
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

  Widget _buildTypingIndicator() {
    return const TypingIndicator();
  }

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

  void _sendMessage(String text, TextEditingController controller, ChatProvider provider) {
    if (text.trim().isEmpty) return;
    controller.clear();
    provider.sendMessage(text);
  }

  double _calculateProgress(Quest quest, QuestProvider provider, ChatProvider? chatProvider) {
    if (quest.type == QuestType.running) {
      final distanceProgress = provider.currentDistance / quest.targetDistance!;
      final timeProgress = provider.elapsedTime.inSeconds / quest.targetDuration!.inSeconds;
      return (distanceProgress + timeProgress) / 2;
    } else if (quest.type == QuestType.mentalHealth) {
      return chatProvider!.elapsedTime.inSeconds / quest.targetDuration!.inSeconds;
    }
    return provider.elapsedTime.inSeconds / quest.targetDuration!.inSeconds;
  }

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

  Future<void> _handleQuestCompletion(QuestProvider provider) async {
    await provider.completeQuest();

    // Get UserProvider instance
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    // Call UserProvider's completeQuest method
    await userProvider.completeQuest(widget.quest);

    setState(() => _showCompletion = true);
  }

  @override
  Widget build(BuildContext context) {
    final questProvider = Provider.of<QuestProvider>(context);
    final chatProvider = widget.quest.type == QuestType.mentalHealth
        ? Provider.of<ChatProvider>(context)
        : null;
    final isCompleted = questProvider.completedQuests.contains(widget.quest);

    if (isCompleted && !_showCompletion) {
      Future.delayed(Duration.zero, () {
        setState(() => _showCompletion = true);
      });
    }

    return Scaffold(
      appBar: AppBar(title: Text(widget.quest.title)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _showCompletion
            ? _buildCompletionScreen(widget.quest)
            : Column(
                children: [
                  widget.quest.type == QuestType.mentalHealth
                      ? _buildChatInterface(chatProvider!, questProvider)
                      : _buildPhysicalQuestScreen(questProvider, widget.quest),
                  const SizedBox(height: 20),
                  if (widget.quest.isPublic) _buildCommunitySection(),
                ],
              ),
      ),
    );
  }
}