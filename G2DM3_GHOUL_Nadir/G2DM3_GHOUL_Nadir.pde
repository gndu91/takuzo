/**
  @author Ghoul Nadir
*/

/**
 *  Fonction chargée de l'allocation mémoire, d'après la documentation,
 *      elle est appellée avant setup
 *  
 *  @see https://processing.org/reference/settings_.html
 */
void settings() {
  init();

}

/**
  Fonction d'initialisation, elle sera appelée au début du programme
*/
void setup() {
  
}

/**
  Fonction draw: appelée à intervalle régulier
*/
void draw() {
}

/**
 * Servira à initialiser les variables et paramètres
 */
void init() {
  
  if(!loadConfig()) {
    /// TODO: Initialiser les variables ici, puis
    ///  saveConfig()
  }
}

/**
 * Servira à charger les variables/paramètres à partir du futur fichier de configuration
 */
boolean loadConfig() {
  /** J'ai choisi de toujours utiliser des variables, même pour les constantes */
  final String fileName = "config.txt";
  
  /** On ouvre le fichier et énumère toutes les raisons de penser que le fichier ne pourra pas être lu */
  File file = new File(fileName);
  if(!file.exists()) {
    return false;
  }
  if(!file.isFile()) {
    return false;
  }
  if(!file.canRead()) {
    return false;
  }
  /// TODO: Lire le fichier ici
  return false;
}