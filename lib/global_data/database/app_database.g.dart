// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// **************************************************************************
// FloorGenerator
// **************************************************************************

abstract class $AppDatabaseBuilderContract {
  /// Adds migrations to the builder.
  $AppDatabaseBuilderContract addMigrations(List<Migration> migrations);

  /// Adds a database [Callback] to the builder.
  $AppDatabaseBuilderContract addCallback(Callback callback);

  /// Creates the database and initializes it.
  Future<AppDatabase> build();
}

// ignore: avoid_classes_with_only_static_members
class $FloorAppDatabase {
  /// Creates a database builder for a persistent database.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static $AppDatabaseBuilderContract databaseBuilder(String name) =>
      _$AppDatabaseBuilder(name);

  /// Creates a database builder for an in memory database.
  /// Information stored in an in memory database disappears when the process is killed.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static $AppDatabaseBuilderContract inMemoryDatabaseBuilder() =>
      _$AppDatabaseBuilder(null);
}

class _$AppDatabaseBuilder implements $AppDatabaseBuilderContract {
  _$AppDatabaseBuilder(this.name);

  final String? name;

  final List<Migration> _migrations = [];

  Callback? _callback;

  @override
  $AppDatabaseBuilderContract addMigrations(List<Migration> migrations) {
    _migrations.addAll(migrations);
    return this;
  }

  @override
  $AppDatabaseBuilderContract addCallback(Callback callback) {
    _callback = callback;
    return this;
  }

  @override
  Future<AppDatabase> build() async {
    final path = name != null
        ? await sqfliteDatabaseFactory.getDatabasePath(name!)
        : ':memory:';
    final database = _$AppDatabase();
    database.database = await database.open(
      path,
      _migrations,
      _callback,
    );
    return database;
  }
}

class _$AppDatabase extends AppDatabase {
  _$AppDatabase([StreamController<String>? listener]) {
    changeListener = listener ?? StreamController<String>.broadcast();
  }

  UserDao? _userDaoInstance;

  QuestHistoryDao? _questHistoryDaoInstance;

  LeaderboardDao? _leaderboardDaoInstance;

  CommentDao? _commentDaoInstance;

  ColleagueRelationDao? _colleagueRelationDaoInstance;

  XpInvestmentDao? _xpInvestmentDaoInstance;

  Future<sqflite.Database> open(
    String path,
    List<Migration> migrations, [
    Callback? callback,
  ]) async {
    final databaseOptions = sqflite.OpenDatabaseOptions(
      version: 1,
      onConfigure: (database) async {
        await database.execute('PRAGMA foreign_keys = ON');
        await callback?.onConfigure?.call(database);
      },
      onOpen: (database) async {
        await callback?.onOpen?.call(database);
      },
      onUpgrade: (database, startVersion, endVersion) async {
        await MigrationAdapter.runMigrations(
            database, startVersion, endVersion, migrations);

        await callback?.onUpgrade?.call(database, startVersion, endVersion);
      },
      onCreate: (database, version) async {
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `User` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `username` TEXT NOT NULL UNIQUE, `email` TEXT, `age` INTEGER, `gender` TEXT, `weight` REAL, `height` REAL, `profilePicture` TEXT, `totalXp` INTEGER NOT NULL, `level` INTEGER NOT NULL, `streak` INTEGER NOT NULL, `totalQuestsCompleted` INTEGER NOT NULL, `password` TEXT NOT NULL, `INTEGER` INTEGER NOT NULL)');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `QuestHistory` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `userId` INTEGER NOT NULL, `questId` TEXT NOT NULL, `INTEGER` INTEGER NOT NULL, `xpEarned` INTEGER NOT NULL, `durationInSeconds` INTEGER, `distance` REAL, `repetitions` INTEGER)');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `comments` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `questId` TEXT NOT NULL, `username` TEXT NOT NULL, `content` TEXT NOT NULL, `timestamp` INTEGER NOT NULL)');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `LeaderboardEntry` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `userId` TEXT NOT NULL, `rankingType` INTEGER NOT NULL, `score` INTEGER NOT NULL, `rank` INTEGER NOT NULL, `INTEGER` INTEGER NOT NULL, `isCurrentUser` INTEGER NOT NULL)');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `colleague_relations` (`questId` TEXT NOT NULL, `colleagueId` TEXT NOT NULL, PRIMARY KEY (`questId`, `colleagueId`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `xp_investments` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `questId` TEXT NOT NULL, `investorId` TEXT NOT NULL, `xpAmount` INTEGER NOT NULL, `timestamp` INTEGER NOT NULL)');

        await callback?.onCreate?.call(database, version);
      },
    );
    return sqfliteDatabaseFactory.openDatabase(path, options: databaseOptions);
  }

  @override
  UserDao get userDao {
    return _userDaoInstance ??= _$UserDao(database, changeListener);
  }

  @override
  QuestHistoryDao get questHistoryDao {
    return _questHistoryDaoInstance ??=
        _$QuestHistoryDao(database, changeListener);
  }

  @override
  LeaderboardDao get leaderboardDao {
    return _leaderboardDaoInstance ??=
        _$LeaderboardDao(database, changeListener);
  }

  @override
  CommentDao get commentDao {
    return _commentDaoInstance ??= _$CommentDao(database, changeListener);
  }

  @override
  ColleagueRelationDao get colleagueRelationDao {
    return _colleagueRelationDaoInstance ??=
        _$ColleagueRelationDao(database, changeListener);
  }

  @override
  XpInvestmentDao get xpInvestmentDao {
    return _xpInvestmentDaoInstance ??=
        _$XpInvestmentDao(database, changeListener);
  }
}

class _$UserDao extends UserDao {
  _$UserDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _userInsertionAdapter = InsertionAdapter(
            database,
            'User',
            (User item) => <String, Object?>{
                  'id': item.id,
                  'username': item.username,
                  'email': item.email,
                  'age': item.age,
                  'gender': item.gender,
                  'weight': item.weight,
                  'height': item.height,
                  'profilePicture': item.profilePicture,
                  'totalXp': item.totalXp,
                  'level': item.level,
                  'streak': item.streak,
                  'totalQuestsCompleted': item.totalQuestsCompleted,
                  'password': item.password,
                  'INTEGER': _dateTimeConverter.encode(item.lastActive)
                }),
        _userUpdateAdapter = UpdateAdapter(
            database,
            'User',
            ['id'],
            (User item) => <String, Object?>{
                  'id': item.id,
                  'username': item.username,
                  'email': item.email,
                  'age': item.age,
                  'gender': item.gender,
                  'weight': item.weight,
                  'height': item.height,
                  'profilePicture': item.profilePicture,
                  'totalXp': item.totalXp,
                  'level': item.level,
                  'streak': item.streak,
                  'totalQuestsCompleted': item.totalQuestsCompleted,
                  'password': item.password,
                  'INTEGER': _dateTimeConverter.encode(item.lastActive)
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<User> _userInsertionAdapter;

  final UpdateAdapter<User> _userUpdateAdapter;

  @override
  Future<User?> findUserById(int id) async {
    return _queryAdapter.query('SELECT * FROM User WHERE id = ?1',
        mapper: (Map<String, Object?> row) => User(
            id: row['id'] as int?,
            username: row['username'] as String,
            email: row['email'] as String?,
            age: row['age'] as int?,
            gender: row['gender'] as String?,
            weight: row['weight'] as double?,
            height: row['height'] as double?,
            profilePicture: row['profilePicture'] as String?,
            totalXp: row['totalXp'] as int,
            level: row['level'] as int,
            streak: row['streak'] as int,
            totalQuestsCompleted: row['totalQuestsCompleted'] as int,
            lastActive: _dateTimeConverter.decode(row['INTEGER'] as int),
            password: row['password'] as String),
        arguments: [id]);
  }

  @override
  Future<User?> findUserByUsername(String username) async {
    return _queryAdapter.query('SELECT * FROM User WHERE username = ?1',
        mapper: (Map<String, Object?> row) => User(
            id: row['id'] as int?,
            username: row['username'] as String,
            email: row['email'] as String?,
            age: row['age'] as int?,
            gender: row['gender'] as String?,
            weight: row['weight'] as double?,
            height: row['height'] as double?,
            profilePicture: row['profilePicture'] as String?,
            totalXp: row['totalXp'] as int,
            level: row['level'] as int,
            streak: row['streak'] as int,
            totalQuestsCompleted: row['totalQuestsCompleted'] as int,
            lastActive: _dateTimeConverter.decode(row['INTEGER'] as int),
            password: row['password'] as String),
        arguments: [username]);
  }

  @override
  Future<User?> findUserByEmail(String email) async {
    return _queryAdapter.query('SELECT * FROM User WHERE email = ?1',
        mapper: (Map<String, Object?> row) => User(
            id: row['id'] as int?,
            username: row['username'] as String,
            email: row['email'] as String?,
            age: row['age'] as int?,
            gender: row['gender'] as String?,
            weight: row['weight'] as double?,
            height: row['height'] as double?,
            profilePicture: row['profilePicture'] as String?,
            totalXp: row['totalXp'] as int,
            level: row['level'] as int,
            streak: row['streak'] as int,
            totalQuestsCompleted: row['totalQuestsCompleted'] as int,
            lastActive: _dateTimeConverter.decode(row['INTEGER'] as int),
            password: row['password'] as String),
        arguments: [email]);
  }

  @override
  Future<void> insertUser(User user) async {
    await _userInsertionAdapter.insert(user, OnConflictStrategy.ignore);
  }

  @override
  Future<void> updateUser(User user) async {
    await _userUpdateAdapter.update(user, OnConflictStrategy.abort);
  }
}

class _$QuestHistoryDao extends QuestHistoryDao {
  _$QuestHistoryDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _questHistoryInsertionAdapter = InsertionAdapter(
            database,
            'QuestHistory',
            (QuestHistory item) => <String, Object?>{
                  'id': item.id,
                  'userId': item.userId,
                  'questId': item.questId,
                  'INTEGER': _dateTimeConverter.encode(item.completionDate),
                  'xpEarned': item.xpEarned,
                  'durationInSeconds': item.durationInSeconds,
                  'distance': item.distance,
                  'repetitions': item.repetitions
                }),
        _questHistoryDeletionAdapter = DeletionAdapter(
            database,
            'QuestHistory',
            ['id'],
            (QuestHistory item) => <String, Object?>{
                  'id': item.id,
                  'userId': item.userId,
                  'questId': item.questId,
                  'INTEGER': _dateTimeConverter.encode(item.completionDate),
                  'xpEarned': item.xpEarned,
                  'durationInSeconds': item.durationInSeconds,
                  'distance': item.distance,
                  'repetitions': item.repetitions
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<QuestHistory> _questHistoryInsertionAdapter;

  final DeletionAdapter<QuestHistory> _questHistoryDeletionAdapter;

  @override
  Future<List<QuestHistory>> findAllByUserId(int userId) async {
    return _queryAdapter.queryList(
        'SELECT * FROM QuestHistory WHERE userId = ?1 ORDER BY completionDate DESC',
        mapper: (Map<String, Object?> row) => QuestHistory(id: row['id'] as int?, userId: row['userId'] as int, questId: row['questId'] as String, completionDate: _dateTimeConverter.decode(row['INTEGER'] as int), xpEarned: row['xpEarned'] as int, durationInSeconds: row['durationInSeconds'] as int?, distance: row['distance'] as double?, repetitions: row['repetitions'] as int?),
        arguments: [userId]);
  }

  @override
  Future<QuestHistory?> findByQuestIdAndUserId(
    String questId,
    int userId,
  ) async {
    return _queryAdapter.query(
        'SELECT * FROM QuestHistory WHERE questId = ?1 AND userId = ?2',
        mapper: (Map<String, Object?> row) => QuestHistory(
            id: row['id'] as int?,
            userId: row['userId'] as int,
            questId: row['questId'] as String,
            completionDate: _dateTimeConverter.decode(row['INTEGER'] as int),
            xpEarned: row['xpEarned'] as int,
            durationInSeconds: row['durationInSeconds'] as int?,
            distance: row['distance'] as double?,
            repetitions: row['repetitions'] as int?),
        arguments: [questId, userId]);
  }

  @override
  Future<int?> countByUserId(int userId) async {
    return _queryAdapter.query(
        'SELECT COUNT(*) FROM QuestHistory WHERE userId = ?1',
        mapper: (Map<String, Object?> row) => row.values.first as int,
        arguments: [userId]);
  }

  @override
  Future<int?> sumXpByUserId(int userId) async {
    return _queryAdapter.query(
        'SELECT SUM(xpEarned) FROM QuestHistory WHERE userId = ?1',
        mapper: (Map<String, Object?> row) => row.values.first as int,
        arguments: [userId]);
  }

  @override
  Future<void> insertQuestHistory(QuestHistory questHistory) async {
    await _questHistoryInsertionAdapter.insert(
        questHistory, OnConflictStrategy.abort);
  }

  @override
  Future<void> deleteQuestHistory(QuestHistory questHistory) async {
    await _questHistoryDeletionAdapter.delete(questHistory);
  }
}

class _$LeaderboardDao extends LeaderboardDao {
  _$LeaderboardDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _leaderboardEntryInsertionAdapter = InsertionAdapter(
            database,
            'LeaderboardEntry',
            (LeaderboardEntry item) => <String, Object?>{
                  'id': item.id,
                  'userId': item.userId,
                  'rankingType': item.rankingType.index,
                  'score': item.score,
                  'rank': item.rank,
                  'INTEGER': _dateTimeConverter.encode(item.updatedAt),
                  'isCurrentUser': item.isCurrentUser ? 1 : 0
                }),
        _leaderboardEntryUpdateAdapter = UpdateAdapter(
            database,
            'LeaderboardEntry',
            ['id'],
            (LeaderboardEntry item) => <String, Object?>{
                  'id': item.id,
                  'userId': item.userId,
                  'rankingType': item.rankingType.index,
                  'score': item.score,
                  'rank': item.rank,
                  'INTEGER': _dateTimeConverter.encode(item.updatedAt),
                  'isCurrentUser': item.isCurrentUser ? 1 : 0
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<LeaderboardEntry> _leaderboardEntryInsertionAdapter;

  final UpdateAdapter<LeaderboardEntry> _leaderboardEntryUpdateAdapter;

  @override
  Future<List<LeaderboardEntry>> getTopEntries(
    RankingType type,
    int limit,
  ) async {
    return _queryAdapter.queryList(
        'SELECT * FROM LeaderboardEntry WHERE rankingType = ?1 ORDER BY rank ASC LIMIT ?2',
        mapper: (Map<String, Object?> row) => LeaderboardEntry(id: row['id'] as int?, userId: row['userId'] as String, rankingType: RankingType.values[row['rankingType'] as int], score: row['score'] as int, rank: row['rank'] as int, updatedAt: _dateTimeConverter.decode(row['INTEGER'] as int), isCurrentUser: (row['isCurrentUser'] as int) != 0),
        arguments: [type.index, limit]);
  }

  @override
  Future<LeaderboardEntry?> getUserEntry(
    int userId,
    RankingType type,
  ) async {
    return _queryAdapter.query(
        'SELECT * FROM LeaderboardEntry WHERE userId = ?1 AND rankingType = ?2',
        mapper: (Map<String, Object?> row) => LeaderboardEntry(
            id: row['id'] as int?,
            userId: row['userId'] as String,
            rankingType: RankingType.values[row['rankingType'] as int],
            score: row['score'] as int,
            rank: row['rank'] as int,
            updatedAt: _dateTimeConverter.decode(row['INTEGER'] as int),
            isCurrentUser: (row['isCurrentUser'] as int) != 0),
        arguments: [userId, type.index]);
  }

  @override
  Future<void> insertEntry(LeaderboardEntry entry) async {
    await _leaderboardEntryInsertionAdapter.insert(
        entry, OnConflictStrategy.abort);
  }

  @override
  Future<void> updateEntry(LeaderboardEntry entry) async {
    await _leaderboardEntryUpdateAdapter.update(
        entry, OnConflictStrategy.abort);
  }
}

class _$CommentDao extends CommentDao {
  _$CommentDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _commentInsertionAdapter = InsertionAdapter(
            database,
            'comments',
            (Comment item) => <String, Object?>{
                  'id': item.id,
                  'questId': item.questId,
                  'username': item.username,
                  'content': item.content,
                  'timestamp': _dateTimeConverter.encode(item.timestamp)
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<Comment> _commentInsertionAdapter;

  @override
  Future<List<Comment>> getCommentsByQuestId(String questId) async {
    return _queryAdapter.queryList(
        'SELECT * FROM comments WHERE questId = ?1 ORDER BY timestamp DESC',
        mapper: (Map<String, Object?> row) => Comment(
            id: row['id'] as int?,
            questId: row['questId'] as String,
            username: row['username'] as String,
            content: row['content'] as String,
            timestamp: _dateTimeConverter.decode(row['timestamp'] as int)),
        arguments: [questId]);
  }

  @override
  Future<void> deleteCommentsByQuestId(String questId) async {
    await _queryAdapter.queryNoReturn('DELETE FROM comments WHERE questId = ?1',
        arguments: [questId]);
  }

  @override
  Future<int> insertComment(Comment comment) {
    return _commentInsertionAdapter.insertAndReturnId(
        comment, OnConflictStrategy.abort);
  }
}

class _$ColleagueRelationDao extends ColleagueRelationDao {
  _$ColleagueRelationDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _colleagueRelationInsertionAdapter = InsertionAdapter(
            database,
            'colleague_relations',
            (ColleagueRelation item) => <String, Object?>{
                  'questId': item.questId,
                  'colleagueId': item.colleagueId
                }),
        _colleagueRelationDeletionAdapter = DeletionAdapter(
            database,
            'colleague_relations',
            ['questId', 'colleagueId'],
            (ColleagueRelation item) => <String, Object?>{
                  'questId': item.questId,
                  'colleagueId': item.colleagueId
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<ColleagueRelation> _colleagueRelationInsertionAdapter;

  final DeletionAdapter<ColleagueRelation> _colleagueRelationDeletionAdapter;

  @override
  Future<List<ColleagueRelation>> getColleaguesByQuestId(String questId) async {
    return _queryAdapter.queryList(
        'SELECT * FROM colleague_relations WHERE questId = ?1',
        mapper: (Map<String, Object?> row) => ColleagueRelation(
            questId: row['questId'] as String,
            colleagueId: row['colleagueId'] as String),
        arguments: [questId]);
  }

  @override
  Future<List<ColleagueRelation>> getColleaguesByUserId(String userId) async {
    return _queryAdapter.queryList(
        'SELECT * FROM colleague_relations WHERE colleagueId = ?1',
        mapper: (Map<String, Object?> row) => ColleagueRelation(
            questId: row['questId'] as String,
            colleagueId: row['colleagueId'] as String),
        arguments: [userId]);
  }

  @override
  Future<void> insertColleagueRelation(ColleagueRelation relation) async {
    await _colleagueRelationInsertionAdapter.insert(
        relation, OnConflictStrategy.abort);
  }

  @override
  Future<void> deleteColleagueRelation(ColleagueRelation relation) async {
    await _colleagueRelationDeletionAdapter.delete(relation);
  }
}

class _$XpInvestmentDao extends XpInvestmentDao {
  _$XpInvestmentDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _xpInvestmentInsertionAdapter = InsertionAdapter(
            database,
            'xp_investments',
            (XpInvestment item) => <String, Object?>{
                  'id': item.id,
                  'questId': item.questId,
                  'investorId': item.investorId,
                  'xpAmount': item.xpAmount,
                  'timestamp': _dateTimeConverter.encode(item.timestamp)
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<XpInvestment> _xpInvestmentInsertionAdapter;

  @override
  Future<List<XpInvestment>> getInvestmentsByQuestId(String questId) async {
    return _queryAdapter.queryList(
        'SELECT * FROM xp_investments WHERE questId = ?1 ORDER BY timestamp DESC',
        mapper: (Map<String, Object?> row) => XpInvestment(id: row['id'] as int?, questId: row['questId'] as String, investorId: row['investorId'] as String, xpAmount: row['xpAmount'] as int, timestamp: _dateTimeConverter.decode(row['timestamp'] as int)),
        arguments: [questId]);
  }

  @override
  Future<int?> getTotalXpInvestedByQuestId(String questId) async {
    return _queryAdapter.query(
        'SELECT SUM(xpAmount) FROM xp_investments WHERE questId = ?1',
        mapper: (Map<String, Object?> row) => row.values.first as int,
        arguments: [questId]);
  }

  @override
  Future<void> deleteInvestmentsByQuestId(String questId) async {
    await _queryAdapter.queryNoReturn(
        'DELETE FROM xp_investments WHERE questId = ?1',
        arguments: [questId]);
  }

  @override
  Future<int> insertXpInvestment(XpInvestment investment) {
    return _xpInvestmentInsertionAdapter.insertAndReturnId(
        investment, OnConflictStrategy.abort);
  }
}

// ignore_for_file: unused_element
final _dateTimeConverter = DateTimeConverter();
