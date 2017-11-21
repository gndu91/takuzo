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
  
  int[][][] grilles = chargerGrilles();
}

/**
 *  Retourne une liste de matrices
 */

////////////////////////////////////////////////////////////////////////////////////////////////////
int[][][] chargerGrilles() {
  ///  Le tableau est déclaré ici, mais pour le momment, nous ne connaissons ni la taille de
  ///    celui-ci, ni les dimensions des grilles qui le composent.
  ///  Ce sera une liste de grilles, et chaque grille sera une liste de deux matrices, une première
  ///    servira à stocker la grille initiale, et l'autre servira à sauvegarder la grille solution
  ///  TODO: Ajouter des sauvegarders/sauvegardes automatiques
  int[][][][] matrices;
  
  String prefix = "grilles\\grilles";
  String suffix_grille = ".tak";
  String suffix_solution = ".tak";

  ///  Lire les fichiers un par un, pour cela, nous allons itérer à travers tout les nombres, 
  ///    jusqu'à qu'il n'y ai plus de fichier correspondant, en commençant par 1
  ///  On va commencer par chercher le nombre de cases à allouer dans notre matrice, donc
  ///    nous allons commencer par une boucle pour déterminer ceci.
  int index = 0;
  ///  Si cette boucle est aussi condensée, c'est qu'elle résume bien ce que je veux:
  ///    1 - On commence par initialiser un compteur à 1, car les grilles commencent avec la 1ere
  ///    2 - A chaque itération, on vérifie si les deux fichiers existent, puis on ne fais rien, et
  ///        on affecte index à la valeur actuelle de i (car comme je l'ai dit plus haut, on commence
  ///        par i = 1, donc s'il n'y en a n, alors la dernière valeur sera n), avant d'incrémenter i,
  ///        pour ensuite recommencer, jusqu'à que la condition ne soit plus vérifiée
  for(int i = 1; (new File(prefix + i + suffix_grille)).canRead() && (new File(prefix + i + suffix_solution)).canRead();index = (i++));
  
  ///  Si nous ne trouvons aucun fichier, alors retourner null, ce qui permettra à la
  ///    fonction appelante de se rendre compte que tout ne s'est pas passé comme prévu
  ///  TODO: Ajouter un polymorphisme permettant de passer si nous le souhaitant un ou
  ///        plusieurs paramètres en cas d'erreur
  if(index == 0) {
    return null;
  }
  
  ///  Maintenant, nous connaissons la taille de notre liste, mais pas encore la taille
  ///    des matrices qui la compose, par conséquent nous ne mettons rien, et nous
  ///    les initialiserons à la lecture du fichier
  matrices = new int[index][2][][];

  ///  TODO: Gérer les exceptions pouvant survenir en cas de changement des fichiers entre
  ///    le "listing" des fichiers et le lecture de ceux-ci, pour l'instant, nous allons
  ///    nous contenter de les laisser à null (s'assurer qu'ils le soit)
  for(int i = 0; i < index; ++i) {
    /// Nous allons commencer par la grille initiale
    File fichier_grille = new File(prefix + i + suffix_grille);
    File fichier_solution = new File(prefix + i + suffix_solution);
    
    /// Nous allons utiliser deux tableaux de chaines de charactères,
    ///    un pour la grille, un pour les solution
    String[] lignes_grille, lignes_solution;
      
    ///  J'ai vu que les grilles possèdent une structure "{taille} // {date}",
    ///    je vais donc stoquer la date dans une variable, au cas où.
    String name;  

    /// Le stockage des tailles est utile pour les comparer
    int taille_grille, taille_solution;

    if(fichier_grille.canRead() && fichier_solution.canRead()) {
      /// Lecture des lignes
      lignes_grille = loadStrings(fichier_grille);
      lignes_solution = loadStrings(fichier_solution);
      
      /// S'assure que les fichiers soit biens lus
      if((lignes_grille != null) && (lignes_solution != null)) {
        /// On lis la premiere ligne
        /// S'il y a un slash, alors le pre
        name = lignes_grille[0].substring(lignes_grille[0].lastIndexOf('/'));
        
        /// Premièrement, on s'assure que les tailles indiquées sont les mêmes
        
      }
    }
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