import 'package:flutter/material.dart';

class ManageTournamentPage extends StatelessWidget {
  final int tournamentId;
  final String tournamentTitle;

  const ManageTournamentPage({
    super.key, 
    required this.tournamentId,
    required this.tournamentTitle
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage: $tournamentTitle'),
      ),
      body: Center(
        child: Text('Managing Tournament ID: $tournamentId. Coming soon!'),
      ),
    );
  }
}
