import 'package:flutter/material.dart';

import '../models/attivita.dart';

/// Schermata di creazione di una nuova attività (scenario S1).
///
/// Restituisce l'[Attivita] creata con `Navigator.pop` quando l'utente
/// conferma; se l'utente torna indietro senza confermare restituisce `null`.
class NuovaAttivitaPage extends StatefulWidget {
  const NuovaAttivitaPage({super.key});

  @override
  State<NuovaAttivitaPage> createState() => _NuovaAttivitaPageState();
}

class _NuovaAttivitaPageState extends State<NuovaAttivitaPage> {
  final _titoloController = TextEditingController();
  bool _importante = false;
  String? _erroreTitolo;

  @override
  void dispose() {
    _titoloController.dispose();
    super.dispose();
  }

  void _onTitoloChanged(String valore) {
    // L'errore scompare appena l'utente corregge il titolo.
    if (_erroreTitolo != null && valore.trim().isNotEmpty) {
      setState(() => _erroreTitolo = null);
    }
  }

  void _conferma() {
    final titolo = _titoloController.text.trim();
    if (titolo.isEmpty) {
      setState(() => _erroreTitolo = 'Il titolo è obbligatorio');
      return;
    }
    Navigator.pop(context, Attivita(titolo: titolo, importante: _importante));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nuova attività')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            key: const Key('campoTitolo'),
            controller: _titoloController,
            autofocus: true,
            textCapitalization: TextCapitalization.sentences,
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(
              labelText: 'Titolo',
              border: const OutlineInputBorder(),
              errorText: _erroreTitolo,
            ),
            onChanged: _onTitoloChanged,
            onSubmitted: (_) => _conferma(),
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            key: const Key('switchImportante'),
            title: const Text('Importante'),
            secondary: Icon(
              _importante ? Icons.star : Icons.star_border,
              color: _importante ? Colors.amber : null,
            ),
            value: _importante,
            onChanged: (valore) => setState(() => _importante = valore),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            key: const Key('bottoneConferma'),
            onPressed: _conferma,
            icon: const Icon(Icons.check),
            label: const Text('Aggiungi'),
          ),
        ],
      ),
    );
  }
}
