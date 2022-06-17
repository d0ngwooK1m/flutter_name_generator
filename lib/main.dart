import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  runApp(const ProviderScope(
    child: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
        title: 'Startup Name Generator', home: RandomWords());
  }
}

class RandomWords extends ConsumerStatefulWidget {
  const RandomWords({
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState createState() => _RandomWordsState();
}

class _RandomWordsState extends ConsumerState<RandomWords> {
  @override
  Widget build(BuildContext context) {
    final suggestions = ref.watch(suggestionStateNotifierProvider);
    final saved = ref.watch(savedStateNotifierProvider);
    const biggerFont = TextStyle(fontSize: 18);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Startup Name Generator'),
        actions: [
          IconButton(
            icon: const Icon(Icons.list),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) => const FavoriteList()));
            },
            tooltip: 'Saved Suggestions',
          ),
        ],
      ),
      body: ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemBuilder: (context, i) {
            // itemCount가 없는 건 무한히 만들어 가겠다는 뜻
            // i는 divider 포함한 widget(divider, ListTile)들의 수
            // 스크롤 함에 따라 builder가 item을 만들어가고, builder는 index를 기억하고 있음. builder의 아이템이 추가한 단어수와 같아질때 (실제 마지막 단어일 때) 추가를 한다.
            if (i.isOdd) {
              return const Divider();
            }
            final index = i ~/ 2;
            if (index >= suggestions.length) {
              suggestions.addAll(generateWordPairs().take(10));
            }
            final alreadySaved = saved
                .contains(suggestions[index]);
            return ListTile(
              title: Text(
                suggestions[index].asPascalCase,
                style: biggerFont,
              ),
              trailing: Icon(
                alreadySaved ? Icons.favorite : Icons.favorite_border,
                color: alreadySaved ? Colors.red : null,
                semanticLabel: alreadySaved ? 'Remove from saved' : 'Save',
              ),
              onTap: () {
                if (alreadySaved) {
                  ref
                      .read(savedStateNotifierProvider.notifier)
                      .remove(suggestions[index]);
                } else {
                  ref
                      .read(savedStateNotifierProvider.notifier)
                      .add(suggestions[index]);
                }
              },
            );
          }),
    );
  }
}

class FavoriteList extends ConsumerWidget {
  const FavoriteList({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final saved = ref.watch(savedStateNotifierProvider);
    const biggerFont = TextStyle(fontSize: 18);
    final tiles = saved.map((pair) {
      return ListTile(
        title: Text(
          pair.asPascalCase,
          style: biggerFont,
        ),
      );
    });
    final divided = tiles.isNotEmpty
        ? ListTile.divideTiles(
      context: context,
      tiles: tiles,
      color: Colors.black,
    ).toList()
        : <Widget>[];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Suggestion'),
      ),
      body: ListView(
        children: divided,
      ),
    );
  }
}

final suggestionStateNotifierProvider =
StateNotifierProvider<SuggestionStateNotifier, List<WordPair>>(
        (_) => SuggestionStateNotifier());

class SuggestionStateNotifier extends StateNotifier<List<WordPair>> {
  SuggestionStateNotifier() : super([]);

  void addAll() {
    state = [...state, ...generateWordPairs().take(10)];
  }
}

final savedStateNotifierProvider =
StateNotifierProvider<SavedStatedNotifier, Set<WordPair>>(
        (_) => SavedStatedNotifier());

class SavedStatedNotifier extends StateNotifier<Set<WordPair>> {
  SavedStatedNotifier() : super({});

  void add(WordPair word) {
    state = {...state, word};
  }

  void remove(WordPair word) {
    state = state.where((element) => element != word).toSet();
  }
}
