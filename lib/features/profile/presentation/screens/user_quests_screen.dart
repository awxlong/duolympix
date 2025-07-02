// lib/features/profile/presentation/screens/user_quests_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:solo_leveling/features/community/data/presentation/providers/community_provider.dart';
import 'package:solo_leveling/features/profile/data/providers/user_provider.dart';
import 'package:solo_leveling/features/quests/data/models/quest_model.dart';
import 'package:solo_leveling/features/quests/provider/quest_provider.dart';
import 'package:solo_leveling/features/community/data/models/xp_investment.dart';

class UserQuestsScreen extends StatefulWidget {
  final String userId;

  const UserQuestsScreen({super.key, required this.userId});

  @override
  State<UserQuestsScreen> createState() => _UserQuestsScreenState();
}

class _UserQuestsScreenState extends State<UserQuestsScreen> {
  late CommunityProvider _communityProvider;
  late QuestProvider _questProvider;
  late UserProvider _userProvider;
  List<Quest> _completedQuests = [];
  List<Quest> _uncompletedQuests = [];
  final TextEditingController _xpInvestmentController = TextEditingController(text: '50');

  @override
  void initState() {
    super.initState();
    _communityProvider = Provider.of<CommunityProvider>(context, listen: false);
    _questProvider = Provider.of<QuestProvider>(context, listen: false);
    _userProvider = Provider.of<UserProvider>(context, listen: false);
    _fetchUserQuests();
  }

  Future<void> _fetchUserQuests() async {
    // 这里需要实现获取用户已完成和未完成任务的逻辑
    // 假设我们有一个方法可以获取用户的任务列表
    _completedQuests = await _questProvider.getCompletedQuestsByUser(widget.userId);
    _uncompletedQuests = await _questProvider.getUncompletedQuestsByUser(widget.userId);
    setState(() {});
  }

  bool _canInvestXp() {
    final xpAmount = int.tryParse(_xpInvestmentController.text);
    final currentUser = _userProvider.state.user!;
    return xpAmount != null && xpAmount > 0 && currentUser.totalXp >= xpAmount;
  }

  Future<void> _investXp(Quest quest) async {
    final xpAmount = int.tryParse(_xpInvestmentController.text);
    if (xpAmount == null || xpAmount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid XP amount')),
      );
      return;
    }

    final currentUser = _userProvider.state.user!;
    if (currentUser.totalXp < xpAmount) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Insufficient XP to invest')),
      );
      return;
    }

    // Deduct user's XP
    final updatedUser = currentUser.copyWith(totalXp: currentUser.totalXp - xpAmount);
    await _userProvider.updateUser(updatedUser);

    // Increase quest's XP
  final updatedQuest = quest.copyWith(xpReward: quest.xpReward + xpAmount);
  // Update the quest in the QuestProvider
  final index = _uncompletedQuests.indexWhere((q) => q.id == quest.id);
  if (index != -1) {
    _uncompletedQuests[index] = updatedQuest;
    setState(() {});
  }

  final investment = XpInvestment(
    questId: quest.id,
    investorId: currentUser.id.toString(),
    xpAmount: xpAmount,
    timestamp: DateTime.now(),
  );
  await _communityProvider.investXp(investment);
  _xpInvestmentController.text = '50';
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Quests of ${widget.userId}')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Completed Quests',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            if (_completedQuests.isNotEmpty)
              Column(
                children: _completedQuests
                   .map((quest) => ListTile(
                         title: Text(quest.title),
                         subtitle: Text('XP Reward: ${quest.xpReward}'),
                       ))
                   .toList(),
              )
            else
              const Center(child: Text('No completed quests yet.')),
            const SizedBox(height: 20),
            const Text(
              'Uncompleted Quests',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            if (_uncompletedQuests.isNotEmpty)
              Column(
                children: _uncompletedQuests.map((quest) {
                  return Column(
                    children: [
                      ListTile(
                        title: Text(quest.title),
                        subtitle: Text('XP Reward: ${quest.xpReward}'),
                      ),
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
                                ? () => _investXp(quest)
                                : null,
                            child: const Text('Invest'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                    ],
                  );
                }).toList(),
              )
            else
              const Center(child: Text('No uncompleted quests yet.')),
          ],
        ),
      ),
    );
  }
}
