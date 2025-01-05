abstract class NextEventPresenter {
  Stream<NextEventViewModel> get nextEventStream;
  Stream<bool> get isBusyStream;

  void loadNextEvent({required String groupId, bool isReload});
  void reloadNextEvent({required String groupId});
}

final class NextEventViewModel {
  final List<NextEventPlayerViewModel> goalkeepers;
  final List<NextEventPlayerViewModel> players;
  final List<NextEventPlayerViewModel> out;
  final List<NextEventPlayerViewModel> doubt;

  const NextEventViewModel({
    this.players = const [],
    this.goalkeepers = const [],
    this.out = const [],
    this.doubt = const [],
  });
}

final class NextEventPlayerViewModel {
  final String name;
  final String initials;
  final String? position;
  final bool? isConfirmed;
  final String? photo;

  const NextEventPlayerViewModel({
    required this.name,
    required this.initials,
    this.position,
    this.isConfirmed,
    this.photo,
  });
}
