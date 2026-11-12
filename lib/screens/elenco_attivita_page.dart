import 'package:flutter/material.dart';

import '../models/attivita.dart';
import 'nuova_attivita_page.dart';

/// Schermata principale: elenco delle attività (scenari S2, S3, S4).
class ElencoAttivitaPage extends StatefulWidget {
  const ElencoAttivitaPage({super.key});

  @override
  State<ElencoAttivitaPage> createState() => _ElencoAttivitaPageState();
}

class _ElencoAttivitaPageState extends State<ElencoAttivitaPage> {
  final List<Attivita> _attivita = [];

  int get _numeroCompletate => _attivita.where((a) => a.completata).length;

  // S1 – Aggiungere un'attività
  Future<void> _aggiungiAttivita() async {
    final nuova = await Navigator.push<Attivita>(
      context,
      MaterialPageRoute(builder: (_) => const NuovaAttivitaPage()),
    );
    // Rinuncia: nessuna attività creata, nessun messaggio.
    if (nuova == null || !mounted) return;

    setState(() => _attivita.add(nuova));
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text('Attività "${nuova.titolo}" aggiunta')),
      );
  }

  // S3 – Aggiornare lo stato di un'attività
  void _cambiaStato(Attivita attivita, bool completata) {
    setState(() => attivita.completata = completata);
  }

  // S4 – Eliminare un'attività
  Future<void> _eliminaAttivita(Attivita attivita) async {
    final confermato = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminare l\'attività?'),
        content: Text('"${attivita.titolo}" verrà eliminata definitivamente.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annulla'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Elimina'),
          ),
        ],
      ),
    );
    // Rinuncia (Annulla o chiusura del dialogo): l'attività resta invariata.
    if (confermato != true) return;

    setState(() => _attivita.remove(attivita));
  }

  @override
  Widget build(BuildContext context) {
    final colori = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Le mie attività'),
        backgroundColor: colori.inversePrimary,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(32),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              '$_numeroCompletate di ${_attivita.length} completate',
              key: const Key('conteggio'),
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
        ),
      ),
      body: _attivita.isEmpty ? _buildElencoVuoto(context) : _buildElenco(),
      floatingActionButton: FloatingActionButton.extended(
        key: const Key('bottoneAggiungi'),
        onPressed: _aggiungiAttivita,
        icon: const Icon(Icons.add),
        label: const Text('Nuova'),
      ),
    );
  }

  // S2 – Variante: nessuna attività
  Widget _buildElencoVuoto(BuildContext context) {
    final testo = Theme.of(context).textTheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.checklist, size: 72, color: Theme.of(context).disabledColor),
            const SizedBox(height: 16),
            Text('Nessuna attività', style: testo.titleLarge),
            const SizedBox(height: 8),
            Text(
              'Tocca il pulsante "+ Nuova" in basso per aggiungerne una.',
              textAlign: TextAlign.center,
              style: testo.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  // S2 – Elenco con titolo, stato e importanza ben distinguibili
  Widget _buildElenco() {
    return ListView.separated(
      padding: const EdgeInsets.only(bottom: 88), // spazio per il FAB
      itemCount: _attivita.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final attivita = _attivita[index];
        final testo = Theme.of(context).textTheme;
        return ListTile(
          key: ObjectKey(attivita),
          leading: Checkbox(
            value: attivita.completata,
            onChanged: (valore) => _cambiaStato(attivita, valore ?? false),
          ),
          title: Text(
            attivita.titolo,
            style: testo.bodyLarge?.copyWith(
              decoration:
                  attivita.completata ? TextDecoration.lineThrough : null,
              color: attivita.completata ? Theme.of(context).disabledColor : null,
              fontWeight: attivita.importante ? FontWeight.bold : null,
            ),
          ),
          subtitle: Text(attivita.completata ? 'Completata' : 'Da fare'),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (attivita.importante)
                const Tooltip(
                  message: 'Importante',
                  child: Icon(Icons.star, color: Colors.amber),
                ),
              IconButton(
                tooltip: 'Elimina',
                icon: const Icon(Icons.delete_outline),
                onPressed: () => _eliminaAttivita(attivita),
              ),
            ],
          ),
          onTap: () => _cambiaStato(attivita, !attivita.completata),
        );
      },
    );
  }
}
