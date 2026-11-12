/// L'unica entità del dominio: un'attività da svolgere.
class Attivita {
  Attivita({
    required this.titolo,
    this.importante = false,
    this.completata = false,
  }) : assert(titolo.trim().isNotEmpty, 'Il titolo è obbligatorio');

  /// Testo obbligatorio che descrive l'attività.
  final String titolo;

  /// Se l'attività è importante (per default no).
  final bool importante;

  /// Stato: `false` = da fare (default), `true` = completata.
  bool completata;
}
