/**
 * Servira à charger les variables/paramètres à partir du futur fichier de configuration
 */
boolean loadConfig() {
  /** J'ai choisi de toujours utiliser des variables, même pour les constantes */
  final String fileName = "config.txt";

  /** On ouvre le fichier et énumère toutes les raisons de penser que le fichier ne pourra pas être lu */
  File file = new File(fileName);
  if (!file.exists()) {
    return false;
  }
  if (!file.isFile()) {
    return false;
  }
  if (!file.canRead()) {
    return false;
  }
  /// TODO: Lire le fichier ici
  return false;
}