import 'package:advanced_flutter/presentation/presenters/next_event_presenter.dart';
import 'package:advanced_flutter/ui/widgets/player_photo.dart';
import 'package:advanced_flutter/ui/widgets/player_position.dart';
import 'package:advanced_flutter/ui/widgets/player_status.dart';
import 'package:awesome_flutter_extensions/awesome_flutter_extensions.dart';
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
    widget.presenter.isBusyStream
        .listen((isBusy) => isBusy ? showLoading() : hideLoading());
    super.initState();
  }

  void showLoading() => showDialog(
        context: context,
        builder: (context) => SimpleDialog(
          children: [
            Column(
              children: [
                Text('Aguarde...', style: context.textStyles.labelLarge),
                const SizedBox(height: 16),
                const CircularProgressIndicator(),
              ],
            ),
          ],
        ),
      );

  void hideLoading() => Navigator.of(context).maybePop();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Próximo Jogo'),
      ),
      body: StreamBuilder<NextEventViewModel>(
        stream: widget.presenter.nextEventStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.active) {
            return Center(child: const CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Algo errado aconteceu. Tente novamente.',
                    style: context.textStyles.bodyLarge,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      widget.presenter.loadNextEvent(
                        groupId: widget.groupId,
                        isReload: true,
                      );
                    },
                    child: Text(
                      'RECARREGAR',
                      style: context.textStyles.labelLarge,
                    ),
                  ),
                ],
              ),
            );
          }

          final viewModel = snapshot.data!;
          return RefreshIndicator(
            onRefresh: () async {
              widget.presenter.loadNextEvent(
                groupId: widget.groupId,
                isReload: true,
              );
            },
            child: ListView(
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
            ),
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
        Padding(
          padding: const EdgeInsets.only(
            left: 16,
            right: 16,
            bottom: 8,
            top: 32,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: context.textStyles.titleSmall,
                ),
              ),
              Text(
                items.length.toString(),
                style: context.textStyles.titleSmall,
              ),
            ],
          ),
        ),
        Divider(),
        ...items
            .map(
              (player) => Container(
                color: context.colors.scheme.onSurface
                    .withAlpha((0.03 * 255).toInt()),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    PlayerPhoto(initials: player.initials, photo: player.photo),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            player.name,
                            style: context.textStyles.labelLarge,
                          ),
                          PlayerPosition(position: player.position),
                        ],
                      ),
                    ),
                    PlayerStatus(isConfirmed: player.isConfirmed),
                  ],
                ),
              ),
            )
            .separatedBy(const Divider(
              indent: 82,
            )),
        const Divider(),
      ],
    );
  }
}
