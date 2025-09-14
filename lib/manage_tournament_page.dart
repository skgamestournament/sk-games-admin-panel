import 'package:flutter/material.dart';
import 'main.dart'; // To access supabase

class ManageTournamentPage extends StatefulWidget {
  final int tournamentId;
  final String tournamentTitle;

  const ManageTournamentPage({
    super.key,
    required this.tournamentId,
    required this.tournamentTitle,
  });

  @override
  State<ManageTournamentPage> createState() => _ManageTournamentPageState();
}

class _ManageTournamentPageState extends State<ManageTournamentPage> {
  bool _isLoading = true;
  Map<String, dynamic>? _tournamentDetails;
  List<Map<String, dynamic>> _participants = [];
  String? _selectedWinnerId;

  final _roomIdController = TextEditingController();
  final _roomPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    try {
      final tDetails = await supabase.from('tournaments').select().eq('id', widget.tournamentId).single();
      final pList = await supabase.from('participants').select('*, users(username)').eq('tournament_id', widget.tournamentId);
      
      if (mounted) {
        setState(() {
          _tournamentDetails = tDetails;
          _participants = pList;
          _roomIdController.text = _tournamentDetails?['room_id'] ?? '';
          _roomPasswordController.text = _tournamentDetails?['room_password'] ?? '';
        });
      }
    } catch (e) {
      _showErrorSnackBar('Error fetching data');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
  
  Future<void> _updateRoomDetails() async {
    try {
      await supabase.from('tournaments').update({
        'room_id': _roomIdController.text.trim(),
        'room_password': _roomPasswordController.text.trim(),
        'status': 'live' // Mark the tournament as live
      }).eq('id', widget.tournamentId);
      _showSuccessSnackBar('Room details updated and tournament is LIVE!');
      _fetchData();
    } catch (e) {
      _showErrorSnackBar('Error updating room details');
    }
  }

  Future<void> _declareWinnerAndEndMatch() async {
    if (_selectedWinnerId == null) {
      _showErrorSnackBar('Please select a winner first.');
      return;
    }

    // Confirmation Dialog
    final confirm = await showDialog<bool>(context: context, builder: (context) => AlertDialog(
      title: const Text('Confirm Winner'),
      content: const Text('Are you sure? This will end the match and distribute the prize. This action cannot be undone.'),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
        TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Confirm')),
      ],
    ));

    if (confirm != true) return;
    
    setState(() => _isLoading = true);
    try {
      await supabase.rpc('declare_winner', params: {
        'p_tournament_id': widget.tournamentId,
        'p_winner_user_id': _selectedWinnerId,
      });
      _showSuccessSnackBar('Winner declared successfully!');
      Navigator.of(context).pop(); // Go back to tournament list
    } catch (e) {
       _showErrorSnackBar('Error declaring winner');
    } finally {
       if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showErrorSnackBar(String message) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.red));
  void _showSuccessSnackBar(String message) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.green));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Manage: ${widget.tournamentTitle}')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(24),
              children: [
                // Section 1: Room Details
                Card(child: Padding(padding: const EdgeInsets.all(16.0), child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Room Details', style: Theme.of(context).textTheme.headlineSmall),
                    const SizedBox(height: 16),
                    TextField(controller: _roomIdController, decoration: const InputDecoration(labelText: 'Room ID')),
                    const SizedBox(height: 12),
                    TextField(controller: _roomPasswordController, decoration: const InputDecoration(labelText: 'Room Password')),
                    const SizedBox(height: 16),
                    SizedBox(width: double.infinity, child: ElevatedButton(onPressed: _updateRoomDetails, child: const Text('UPDATE & GO LIVE'))),
                  ],
                ))),
                const SizedBox(height: 24),

                // Section 2: Declare Winner
                if(_tournamentDetails?['status'] != 'completed')
                Card(child: Padding(padding: const EdgeInsets.all(16.0), child: Column(
                   crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Declare Winner', style: Theme.of(context).textTheme.headlineSmall),
                    const SizedBox(height: 16),
                    if (_participants.isNotEmpty) DropdownButtonFormField<String>(
                      value: _selectedWinnerId,
                      hint: const Text('Select a participant'),
                      items: _participants.map((p) => DropdownMenuItem(value: p['users']['id'], child: Text(p['users']['username']))).toList(),
                      onChanged: (value) => setState(() => _selectedWinnerId = value),
                    ) else const Text('No participants have joined yet.'),
                    const SizedBox(height: 16),
                    SizedBox(width: double.infinity, child: ElevatedButton(onPressed: _declareWinnerAndEndMatch, style: ElevatedButton.styleFrom(backgroundColor: Colors.green), child: const Text('DECLARE WINNER & END MATCH'))),
                  ],
                ))),
                const SizedBox(height: 24),

                // Section 3: Participant List
                Card(child: Padding(padding: const EdgeInsets.all(16.0), child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                     Text('Participants (${_participants.length})', style: Theme.of(context).textTheme.headlineSmall),
                    const SizedBox(height: 16),
                    if (_participants.isEmpty) const Text('No one has joined this tournament yet.'),
                    ..._participants.map((p) => ListTile(
                      leading: const Icon(Icons.person_outline),
                      title: Text(p['users']['username']),
                      subtitle: Text('In-Game ID: ${p['user_game_id_name']}'),
                    )).toList(),
                  ],
                ))),
              ],
            ),
    );
  }
}
