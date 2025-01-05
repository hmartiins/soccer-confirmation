import 'package:advanced_flutter/presentation/presenters/next_event_presenter.dart';
import 'package:advanced_flutter/ui/widgets/player_photo.dart';
import 'package:advanced_flutter/ui/widgets/player_position.dart';
import 'package:advanced_flutter/ui/widgets/player_status.dart';
import 'package:flutter/material.dart';

final class NextEventPage extends StatefulWidget {
  final NextEventPresenter presenter;
  final String groupId;

  const NextEventPage({
    super.key,
    required this.presenter,
    required this.groupId,
  });

  @override
  State<NextEventPage> createState() => _NextEventPageState();
}

class _NextEventPageState extends State<NextEventPage> {
  @override
  void initState() {
    widget.presenter.loadNextEvent(groupId: widget.groupId);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<NextEventViewModel>(
        stream: widget.presenter.nextEventStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.active) {
            return const CircularProgressIndicator();
          }
          if (snapshot.hasError) {
            return const Text('Erro');
          }

          final viewModel = snapshot.data!;
          return ListView(
            children: [
              if (viewModel.goalkeepers.isNotEmpty)
                ListSection(
                  title: 'DENTRO - GOLEIROS',
                  items: viewModel.goalkeepers,
                ),
              if (viewModel.players.isNotEmpty)
                ListSection(
                  title: 'DENTRO - JOGADORES',
                  items: viewModel.players,
                ),
              if (viewModel.out.isNotEmpty)
                ListSection(
                  title: 'FORA',
                  items: viewModel.out,
                ),
              if (viewModel.doubt.isNotEmpty)
                ListSection(
                  title: 'DÚVIDA',
                  items: viewModel.doubt,
                ),
            ],
          );
        },
      ),
    );
  }
}

final class ListSection extends StatelessWidget {
  final String title;
  final List<NextEventPlayerViewModel> items;

  const ListSection({
    super.key,
    required this.title,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(title),
        Text(items.length.toString()),
        ...items.map(
          (player) => Row(
            children: [
              PlayerPhoto(
                initials: player.initials,
                photo: player.photo,
              ),
              Text(player.name),
              PlayerPosition(position: player.position),
              PlayerStatus(isConfirmed: player.isConfirmed),
            ],
          ),
        ),
      ],
    );
  }
}
