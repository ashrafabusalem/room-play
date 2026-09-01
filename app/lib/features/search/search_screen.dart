import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../data/search_repository.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../widgets/avatar.dart';
import '../auth/auth_controller.dart';
import '../profile/public_profile_screen.dart';
import '../rooms/room_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});
  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final controller = TextEditingController();
  SearchResults? results;
  bool loading = false;

  Future<void> _search() async {
    final query = controller.text.trim();
    if (query.length < 2) return;
    setState(() => loading = true);
    try {
      final auth = AuthScope.of(context);
      final value = await SearchRepository(
        auth.api,
        currentUserId: auth.publicId,
      ).search(query);
      if (mounted) setState(() => results = value);
    } catch (_) {
      if (mounted) {
        setState(() => results = const SearchResults(users: [], rooms: []));
      }
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final empty =
        results != null && results!.users.isEmpty && results!.rooms.isEmpty;
    return Scaffold(
      appBar: AppBar(title: Text(l.searchTitle)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: controller,
              autofocus: true,
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => _search(),
              decoration: InputDecoration(
                hintText: l.searchHint,
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: IconButton(
                  onPressed: _search,
                  icon: const Icon(Icons.arrow_forward_rounded),
                ),
              ),
            ),
          ),
          if (loading) const LinearProgressIndicator(),
          Expanded(
            child: empty
                ? Center(child: Text(l.searchEmpty))
                : ListView(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                    children: [
                      if (results?.users.isNotEmpty == true) ...[
                        Text(
                          l.searchPeople,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        for (final user in results!.users)
                          Material(
                            color: AppColors.surface,
                            child: ListTile(
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (_) =>
                                      PublicProfileScreen(userId: user.id),
                                ),
                              ),
                              leading: AvatarCircle(user: user, size: 42),
                              title: Text(user.name),
                              subtitle: Text(l.searchUserId(user.id)),
                            ),
                          ),
                      ],
                      if (results?.rooms.isNotEmpty == true) ...[
                        const SizedBox(height: 20),
                        Text(
                          l.searchRooms,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        for (final room in results!.rooms)
                          Material(
                            color: AppColors.surface,
                            child: ListTile(
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (_) => RoomScreen(room: room),
                                ),
                              ),
                              leading: const CircleAvatar(
                                child: Icon(Icons.graphic_eq_rounded),
                              ),
                              title: Text(room.name),
                              subtitle: Text(
                                l.searchRoomDetails(
                                  room.numericId,
                                  room.memberCount,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
