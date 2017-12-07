/**
 @author Ghoul Nadir
 */
////////////////////////////////////////////////////////////////////////////////
// Variables globales
int[][][]   grilles;
boolean[][] modifiable;

int[] grilleCourante;
boolean[] mCourante;
int indexCourant;

/// Paramètres
ArrayList<PImage> images;

float[] dimensionsGrilles;
// 0 Modifiable -> 0 Constant -> 1 Modifiable -> 1 constant -> Vide modifiable # -> Vide constant 
PImage[] cases;

/**
 *  Fonction chargée de l'allocation mémoire, d'après la documentation,
 *      elle est appellée avant setup
 *  
 *  @see https://processing.org/reference/settings_.html
 */
void settings() {
  /// Le code qui suit servira à se placer dans le bon dossier, au lieu de démarrer dans le dossier d'installation de processing
  /// https://processing.github.io/processing-javadocs/core/
  String AppSketchPath = sketchPath();
  if (System.setProperty("user.dir", AppSketchPath) == null) {
    throw new RuntimeException("Erreur, impossible de se placer dans le bon répertoire");
  }
  size(500, 500);
}

/**
 Fonction d'initialisation, elle sera appelée au début du programme
 */
void setup() {
  init();
  /// @see https://processing.github.io/processing-javadocs/core/processing/core/PSurface.html
  surface.setResizable(true);
  surface.setTitle("Takuzo");

  function();
}

/**
 Fonction draw: appelée à intervalle régulier
 */
void draw() {
  background(255);
  // update();
  afficherGrille();
  redrawCirleFromMemory();

  if (positions == null) {
    positions = new PVector[10];
    positions[current_++ % positions.length] = new PVector(1, 1);
  }
  if (texts == null) {
    texts = new String[10];
    texts[current_++ % positions.length] = "null";
  }
  if (colors == null) {
    colors = new color[10];
    for (int i = 0; i < positions.length; ++i) {
      colors[i] = #111111;
    }
  }
  for (int i = 0; i < positions.length; ++i) {
    if (positions[i] != null) {
      putCircle("circle", positions[i], new PVector(1, 1), colors[i], texts[i] == null ? "null" : texts[i]);
    }
  }
}
float dimensions_grille_w, dimensions_grille_h, dimensions_grille_x, dimensions_grille_y;

color[] grille_couleurs;
String grille_affichage_type;
boolean grille_affichage_afficherChiffres;
/**
 * Servira à initialiser les variables et paramètres
 */
void init() {

  if (!loadConfig()) {
    /// FLAG:INITIALISATION
    dimensions_grille_w = 0.75;
    dimensions_grille_h = 0.75;
    dimensions_grille_x = 0.125;
    dimensions_grille_y = 0.125;

    grille_affichage_type = "couleurs";

    grille_couleurs = new color[] {#990000, #ff0000, #009900, #00ff00, #ffffff};

    /// TODO: Initialiser les variables ici, puis
    ///  saveConfig()
  }


  /*images = parametres.getJSONObject("grille").getJSONObject("affichage").getString("type").equals("images") ? new ArrayList<PImage>() {{
   add(loadImage(parametres.getJSONObject("grille").getJSONObject("images").getString("0")));
   add(loadImage(parametres.getJSONObject("grille").getJSONObject("images").getString("1")));
   add(loadImage(parametres.getJSONObject("grille").getJSONObject("images").getString("0#")));
   add(loadImage(parametres.getJSONObject("grille").getJSONObject("images").getString("1#")));
   add(loadImage(parametres.getJSONObject("grille").getJSONObject("images").getString("void")));
   }} : null;*/

  grilles = chargerGrilles();
  modifiable = modifiable(grilles);

  grilleCourante = grilles[0][0];
  mCourante = modifiable[0];
  indexCourant = 0;
}

/**
 *  Affiche la matrice
 *
 *  @param dimensions: x, y, w, h: flottants entre 0 et 1
 *  
 *  TODO: Plusieurs layouts
 */
void afficherGrille(int[] grille, boolean[] modifiable, PImage[] images) {
  int taille = (int) sqrt(grille.length);
  if (taille*taille != grille.length) {
    throw new RuntimeException("Grille non carrée");
  }

  float w = dimensions_grille_w * (width / taille);
  float h = dimensions_grille_h * (height / taille);

  float x0 = dimensions_grille_x * width;
  float y0 = dimensions_grille_y * height;

  for (int i = 0; i < taille; ++i)
    for (int j = 0; j < taille; ++j) {
      int index = i + (taille*j);
      int etat = (grille[index] > 1 ? 4 : (grille[index]*2 + int(modifiable[index])));
      float x = x0 + (i * w);
      float y = y0 + (j * h);
      fill(grille_couleurs[etat]);
      rect(x, y, w, h);
    }
}


void mousePressed() {
  int taille = (int) sqrt(grilleCourante.length);

  float w = dimensions_grille_w * (width / taille);
  float h = dimensions_grille_h * (height / taille);

  float x0 = dimensions_grille_x * width;
  float y0 = dimensions_grille_y * height;


  int i = (int) ((mouseX - x0) / w);
  int j = (int) ((mouseY - y0) / h);

  int index = i + (taille * j);

  if (i > -1 && i < taille) {
    if (j > -1 && j < taille) {
      if (mCourante[index]) {
        grilleCourante[index] = (grilleCourante[index] + 1) % 3;
      }
      println(i, j);
    }
  }
}
void mouseWheel(MouseEvent event) {
  float agrandissement = float(event.getCount()) / 10;
  
  println(agrandissement);
  
  dimensions_grille_x += dimensions_grille_w / 2;
  dimensions_grille_y += dimensions_grille_h / 2;
  
  dimensions_grille_w *= (1 - agrandissement);
  dimensions_grille_h *= (1 - agrandissement);
  
  dimensions_grille_x -= dimensions_grille_w / 2;
  dimensions_grille_y -= dimensions_grille_h / 2;
}


void keyPressed() {
  if (key == BACKSPACE) {
    for (int i = 0; i < mCourante.length; ++i) {
      if (mCourante[i]) {
        grilleCourante[i] = 2;
      }
    }
  } else if (key == ENTER) {
    indexCourant = (indexCourant + 1) % grilles.length;
    /// TODO: Vérifier l'égalité des tailles
    grilleCourante = grilles[indexCourant][0];
    mCourante = modifiable[indexCourant];
  } else if (key == TAB) {
    dumbSolverOneStep();
  } else if (key >= '1' && key <= '9') {
    float _x = ((float) (mouseX)) / width;
    float _y = ((float) (mouseY)) / height;

    if (key == '1' || key == '4' || key == '7') {
      dimensions_grille_w += dimensions_grille_x - _x;
      dimensions_grille_x = _x;
    }
    if (key == '7' || key == '8' || key == '9') {
      dimensions_grille_h += dimensions_grille_y - _y;
      dimensions_grille_y = _y;
    }      

    if (key == '9' || key == '6' || key == '3') {
      dimensions_grille_w = _x - dimensions_grille_x;
    }
    if (key == '3' || key == '2' || key == '1') {
      dimensions_grille_h = _y - dimensions_grille_y;
    }

    if (key == '5') {
      float ratio = float(width) / height;

      float mean = ((dimensions_grille_h / ratio) + (dimensions_grille_w)) / 2;
      mean = min(dimensions_grille_w, dimensions_grille_h, mean);

      dimensions_grille_x += dimensions_grille_w / 2;
      dimensions_grille_y += dimensions_grille_h / 2;

      dimensions_grille_h = mean * ratio;
      dimensions_grille_w = mean;//  / ratio;

      dimensions_grille_x -= dimensions_grille_w / 2;
      dimensions_grille_y -= dimensions_grille_h / 2;
    }
  } else if (key == 'm') {
    dimensions_grille_x = (((float) (mouseX)) / width) - (dimensions_grille_w / 2);
    dimensions_grille_y = (((float) (mouseY)) / height) - (dimensions_grille_h / 2);
  } else if (key == '+' || key == '-') {
    float step = (key == '-' ? -1 : 1) * 0.01;
    dimensions_grille_x = dimensions_grille_x - step;
    dimensions_grille_y = dimensions_grille_y - step;
    dimensions_grille_w = dimensions_grille_w + 2 * step;
    dimensions_grille_h = dimensions_grille_h + 2 * step;
  } else if (key == CODED && ((keyCode == UP) || (keyCode == DOWN) || (keyCode == RIGHT) || (keyCode == LEFT))) {
    float step = 0.01;
    dimensions_grille_x = (dimensions_grille_x + ((keyCode == LEFT) ? -step : (keyCode == RIGHT) ? step : 0));
    dimensions_grille_y = (dimensions_grille_y + ((keyCode == UP) ? -step : (keyCode == DOWN) ? step : 0));
  } else if (key == 'f') {

    surface.placeWindow(new int[] {0, 0}, new int[] {0, 0});
    surface.setSize(displayWidth, displayHeight);
  }
}


void afficherGrille() {
  afficherGrille(grilleCourante, mCourante, cases);
}

/**
 *  Retourne un tableau de boolean, qui va être utilisé pour savoir si nous pouvons
 *    modifier une case, c'est à dire si la case vaut 2, ce tableau sera utile
 *    quand l'utilisateur aura commencé à modifier la grille
 */
boolean[] modifiable(int[] grille) {
  boolean[] retour = new boolean[grille.length];
  for (int i = 0; i < grille.length; ++i) {
    retour[i] = grille[i] == 2;
  }
  return retour;
}
/**
 *  Equivalent de la fonction précédente, optimisée pour 
 */
boolean[][] modifiable(int[][][] grilles) {
  boolean[][] retour = new boolean[grilles.length][];
  for (int i = 0; i < grilles.length; ++i) {
    retour[i] = modifiable(grilles[i][0]);
  }
  return retour;
}


/**
 *  Retourne une liste de matrices
 */
////////////////////////////////////////////////////////////////////////////////////////////////////
int[][][] chargerGrilles(String path, String prefix) {
  ///  Le tableau est déclaré ici, mais pour le momment, nous ne connaissons ni la taille de
  ///    celui-ci, ni les dimensions des grilles qui le composent.
  ///  Ce sera une liste de grilles, et chaque grille sera une liste de deux listes, une première
  ///    servira à stocker la grille initiale, et l'autre servira à sauvegarder la grille solution
  ///  TODO: Ajouter des sauvegarders/sauvegardes automatiques
  int[][][] grilles;

  /// Je joins les deux dossiers
  if (path != null && prefix != null && path.length() > 0 && prefix.length() > 0) {
    prefix = path + ("/\\".contains(path.substring(path.length() - 1)) ? "\\" : "") + prefix;
  } else if (prefix == null || prefix.length() == 0) {
    prefix = path;
  }

  ///  Pour une raison que j'ignore, File ne peut pas lire les fichiers ayant été défini par un
  ///    chemin relatif, mais il peux donner leurs chemins absolu, des chemins qu'il pourra
  ///    donc traiter.
  prefix = new File(prefix).getAbsolutePath();


  String suffix_grille = ".tak";
  String suffix_solution = ".sol";

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
  for (int i = 1; (new File(prefix + i + suffix_grille)).canRead() && (new File(prefix + i + suffix_solution)).canRead(); index = (i++));

  ///  Si nous ne trouvons pas assez de fichiers, alors demander le dossier
  if (index < 5) {
    /// Afficher les fichiers, pour voir ce qui coince
    for (int i = 1; i < 6; i++) {
      File init = new File(prefix + i + suffix_grille), soluce = new File(prefix + i + suffix_solution);
      init = (new File(init.getAbsolutePath()));
      soluce = (new File(soluce.getAbsolutePath()));
      println();
      println(init.getAbsolutePath(), init.exists() ? "existe" : "n'existe pas");
      println(soluce.getAbsolutePath(), soluce.exists() ? "existe" : "n'existe pas");
      println();
      println(init.getAbsolutePath(), init.canRead() ? "peut" : "ne peut pas", "être lu");
      println(soluce.getAbsolutePath(), soluce.canRead() ? "peut" : "ne peut pas", "être lu");
    }
    throw new RuntimeException("Les grilles n'ont pas été trouvées, (prefix='" + prefix + "', suffix_solution='" + suffix_solution + "', suffix_grille='" + suffix_grille + "').");
  }

  ///  Maintenant, nous connaissons la taille de notre liste, mais pas encore la taille
  ///    des matrices qui la compose, par conséquent nous ne mettons rien, et nous
  ///    les initialiserons à la lecture du fichier
  grilles = new int[index][2][];

  ///  TODO: Gérer les exceptions pouvant survenir en cas de changement des fichiers entre
  ///    le "listing" des fichiers et le lecture de ceux-ci, pour l'instant, nous allons
  ///    nous contenter de les laisser à null (s'assurer qu'ils le soit)
  for (int i = 0; i < index; ++i) {
    ///  Nous allons commencer par la grille initiale, en se rappelant que les fichiers
    ///    commencent avec l'index 1
    File fichier_grille = new File(prefix + (i + 1) + suffix_grille);
    File fichier_solution = new File(prefix + (i + 1) + suffix_solution);

    /// Nous allons utiliser deux tableaux de chaines de charactères,
    ///    un pour la grille, un pour les solution
    String[] lignes_grille, lignes_solution;

    ///  J'ai vu que les grilles possèdent une structure "{taille} // {date}",
    ///    je vais donc stoquer la date dans une variable, au cas où.
    ///  Les deux chaines de caractères serviront à la lecture en parallèle des
    ///    lignes des fichiers.
    String name, ligne_grille, ligne_solution;

    /// Le stockage des tailles est utile pour les comparer
    int taille_grille, taille_solution;

    /// Vérification peut-être superflue, mais on n'est jamais trop sûr
    if (!fichier_grille.canRead() || !fichier_solution.canRead()) {
      println();
      println(fichier_grille.getAbsolutePath(), fichier_grille.exists() ? "existe" : "n'existe pas");
      println(fichier_solution.getAbsolutePath(), fichier_solution.exists() ? "existe" : "n'existe pas");
      println();
      println(fichier_grille.getAbsolutePath(), fichier_grille.canRead() ? "peut" : "ne peut pas", "être lu");
      println(fichier_solution.getAbsolutePath(), fichier_solution.canRead() ? "peut" : "ne peut pas", "être lu");
      throw new RuntimeException("Les grilles ne sont pas lisibles");
    } else {
      /// Lecture des lignes
      lignes_grille = loadStrings(fichier_grille);
      lignes_solution = loadStrings(fichier_solution);

      /// S'assure que les fichiers soit biens lus
      if ((lignes_grille != null) && (lignes_solution != null)) {
        /// On lis la premiere ligne des deux fichiers
        ligne_grille = lignes_grille[0];
        ligne_solution = lignes_solution[0];

        ////////////////////////////////////////////////////////////////////////80 chars
        ///  D'abord la solution, ce qui sera simple, vu que je ne lirai que
        ///    la taille de la grille, je prendrai tout ce qui se trouve
        ///    avant le "//" s'il y en a un, et je supprimerai les espaces
        ///    pour pouvoir convertir en int
        taille_solution = int((ligne_solution.contains("//") ?
          ligne_solution.substring(0, ligne_solution.indexOf("//")) :
          ligne_solution).trim());

        ////////////////////////////////////////////////////////////////////////80 chars
        ///  Cette erreur n'est jamais censé se produire, c'est pour cela que
        ///    je me permets d'envoyer une exception, car si elle survient, il
        ///    est nécéssaire de revérifier si les fichiers n'ont pas d'erreurs
        if (taille_solution == 0) {
          throw new RuntimeException("Grille solution étonemment vide pour le fichier " +
            fichier_solution.getAbsolutePath()  + " (ligne:\"" +
            ligne_solution.replaceAll("\\p{Blank}", "") + "\")");
        }

        ////////////////////////////////////////////////////////////////////////80 chars
        /// Ensuite, on passe à la grille initiale
        int slashIndex = lignes_grille[0].indexOf("//");
        /// S'il y a un double slash:
        if (slashIndex > -1) {
          ///  alors le prendre ce qu'il y a à gauche, en supprimant les espaces,
          ///    ce qui revient à prendre la sous chaine de charactères de la
          ///    ligne actuelle commençant au début et ayant slashIndex lettres,
          ///    car s'il n'y a qu'une lettre avant le double slash, la variable
          ///    vaudra 1. Après avoir découpé la partie que nous souhaitons avoir,
          ///    nous allons supprimer les espaces, pour les raisons exprimées plus
          ///    tôt dans cette fonction.
          taille_grille = int(ligne_grille.substring(0, slashIndex).trim());

          //////////////////////////////////////////////////////////////////////80 chars
          ///  Nous allons prendre la seconde partie, pour cela, nous allons
          ///    commencer par prendre la partie de droite, puis ...
          ligne_grille.substring(slashIndex);
          do {
            /// ... nous retirons la première lettre ...
            ligne_grille.substring(1);
            /// ... tant qu'elle nous ne conviens pas;
          } while (ligne_grille.startsWith("\\p{Blank}|/"));

          /// TODO: Utiliser cette variable
          name = "Grille n°" + i + " " + ligne_grille;
        } else {/// Sinon, cela signifie que la taille est la seule information disponible
          /// Voir précédente occurence de cette ligne, un peu plus tôt, dans le if
          taille_grille = int(ligne_grille.substring(0, slashIndex).trim());
          name = "Grille n°" + i;
        }

        //////////////////////////////////////////////////////////////////////80 chars
        ///  Premièrement, on s'assure que les tailles indiquées sont les mêmes,
        ///    comme dit précédemment, cette erreur ne devrais pas apparaître 
        if (taille_grille != taille_solution) {
          throw new RuntimeException(
            "Les tailles de grilles sont différentes (" +
            fichier_grille.getAbsolutePath() + ", " + 
            fichier_solution.getAbsolutePath() + ")");
        }

        /// On alloue l'espace nécessaire pour sauvegarder les grilles
        grilles[i] = new int[2][taille_grille * taille_grille];

        //////////////////////////////////////////////////////////////////////80 chars
        ///  On va maintenant les remplir, en commençant par la grille
        ///    initiale, pour ce faire, on parcours le tableau en commençant
        ///    par la seconde ligne
        for (int ligne = 1; ligne < lignes_grille.length; ++ligne) {

          ///  On utilise la variable créée précédemment, et on s'assure
          ///    d'effacer tout les éventuels espaces
          ligne_grille = lignes_grille[ligne].trim();

          /// Si la ligne a un nombre incorrect de symboles
          if (taille_grille != ligne_grille.length()) {
            throw new RuntimeException(
              "Inconsistence trouvé dans le fichier \"" +
              fichier_grille.getAbsolutePath() + "\", ligne " +
              ligne + ", la taille devrait être de " + taille_grille 
              + ", mais elle est de " + ligne_grille.length() + ".");
          }

          ///  Un par un, nous allons sauvegarder la valeur des différents
          ///    charactères, en nous assurant qu'ils soient valable
          for (int colonne = 0; colonne < taille_grille; ++colonne) {
            ///  La colonne actuelle est colonne, mais la ligne actuelle
            ///    est ligne - 1 car nous avons commencé à ligne = 1.
            ///  Nous faisons i - '0' pour obtenir le chiffre associé
            grilles[i][0][colonne + ((ligne - 1) * taille_grille)] =
              ligne_grille.charAt(colonne) - '0';

            /// Si le chiffre n'est pas dans {0, 1, 2}
            if (grilles[i][0][colonne + ((ligne - 1) * taille_grille)] < 0 || 
              grilles[i][0][colonne + ((ligne - 1) * taille_grille)] > 2) {
              throw new RuntimeException(
                "Inconsistence trouvé dans le fichier \"" +
                fichier_grille.getAbsolutePath() + "\", ligne " +
                ligne + ", colonne " + colonne + ", le caractère '" + 
                + ligne_grille.charAt(colonne) +
                "' n'est pas dans {'0', '1', '2'}.");
            }
          }
        }

        //////////////////////////////////////////////////////////////////////80 chars
        ///  On va ensuite faire de même pour la grille solution
        for (int ligne = 1; ligne < lignes_solution.length; ++ligne) {
          ligne_solution = lignes_solution[ligne].trim();
          if (taille_grille != ligne_solution.length()) {
            throw new RuntimeException(
              "Inconsistence trouvé dans le fichier \"" +
              fichier_solution.getAbsolutePath() + "\", ligne " +
              ligne + ", la taille devrait être de " + taille_solution
              + ", mais elle est de " + ligne_solution.length() + ".");
          }
          for (int colonne = 0; colonne < taille_solution; ++colonne) {
            grilles[i][1][colonne + ((ligne - 1) * taille_solution)] =
              ligne_solution.charAt(colonne) - '0';
            if ((grilles[i][1][colonne + ((ligne - 1) * taille_solution)] < 0) || 
              (grilles[i][1][colonne + ((ligne - 1) * taille_solution)] > 2)) {
              throw new RuntimeException(
                "Inconsistence trouvé dans le fichier \"" +
                fichier_solution.getAbsolutePath() + "\", ligne " +
                ligne + ", colonne " + colonne + ", le caractère '" + 
                + ligne_solution.charAt(colonne) +
                "' n'est pas dans {'0', '1', '2'}.");
            }
          }
        }
        /// Normalement, c'est fini
      }
    }
  }
  return grilles;
}

/// Les valeurs par défaut n'étant pas autorisées sous processing.js, j'utiliserai le polymorphisme
int[][][] chargerGrilles() {
  return chargerGrilles("data\\grilles\\", "grille");
}

/// En cas de problème, cette fonction est appelée, avec un fichier et un pointeur vers le tableau à modifier
int[][][] chargerGrilles(File file, int[][][] target) {
  return (target = chargerGrilles(file.getAbsolutePath(), "grille"));
}


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

ArrayList<ArrayList<Integer>> lignesPossibles;


void function() {
  int taille = (int) sqrt(grilleCourante.length);

  lignesPossibles = new ArrayList<ArrayList<Integer>>();
  for (int i = 0; i < pow(2, taille); ++i) {
  }
  /*for (int i = 0; i < taille; ++i) {
   insert(creerLigne(taille), taille * i);
   }
   for (int i = 0; i < mCourante.length; ++i) {
   mCourante[i] = true;
   }*/
}


int indeeeeex = 0;
ArrayList<ArrayList<ArrayList<Integer>>> matricePossibles;

void update(int index) {
  for (int prefix = 0; prefix < 2; prefix++) {
    for (ArrayList<Integer> l : lignesPossibles) {
      if (l.get(index) == prefix) {
        for (ArrayList<Integer> t : lignesPossibles) {
        }
      }
    }
  }
}

ArrayList<Object[]> circleRemembered = new ArrayList();

void putCircleAndRemember(Object...args) {
  circleRemembered.add(args);
    putCircle((String)args[0], (PVector)args[1], (PVector)args[2], (color)args[3], (String)args[4]);
}

void redrawCirleFromMemory() {
  for(Object[] i:circleRemembered) {
    putCircle((String)i[0], (PVector)i[1], (PVector)i[2], (color)i[3], (String)i[4]);
  }
}

void forgetAllCircles() {
  circleRemembered = new ArrayList();
}

void putCircle(String type, PVector pos, PVector dim, color couleur, String texte) {
  try {
    if (type.equals("circle")) {
      int size = (int) sqrt(grilleCourante.length);
      fill(couleur);
      ellipse(
        ///        centré   centré      
        map(pos.x, 0 - 0.5, size - 0.5, dimensions_grille_x * width, (dimensions_grille_x + dimensions_grille_w) * width), 
        map(pos.y, 0 - 0.5, size - 0.5, dimensions_grille_y * height, (dimensions_grille_y + dimensions_grille_h) * height), 
        dim.x * dimensions_grille_w * width / size, 
        dim.y * dimensions_grille_h * height / size 
        );
      filter(INVERT);
      textMode(CENTER);
      text(
        texte, 
        map(pos.x, 0 - 0.5, size - 0.5, dimensions_grille_x * width, (dimensions_grille_x + dimensions_grille_w) * width), 
        map(pos.y, 0 - 0.5, size - 0.5, dimensions_grille_y * height, (dimensions_grille_y + dimensions_grille_h) * height)
        );
      filter(INVERT);
      /// Lors du rediementionnement,
    }
  } 
  catch(ArrayIndexOutOfBoundsException e) {
  }
}

PVector positions[] = null;
color colors[] = null;
String texts[] = null;
int current_ = 0;

/// Coût: lenght * 2 tests

boolean dumbSolverOneStep() {
  forgetAllCircles();
  
  ArrayList<Integer> test0 = new ArrayList<Integer>();
  ArrayList<Integer> test1 = new ArrayList<Integer>();
  int taille = (int) sqrt(grilleCourante.length);
  
  boolean marche0, marche1;
  boolean touched = false;
  /// Copie intégrale
  for (int i = 0; i < grilleCourante.length; ++i) {
    test0.add(grilleCourante[i]);
    test1.add(grilleCourante[i]);
  }
  for (int i = 0; i < grilleCourante.length; ++i) {
    if (mCourante[i]) {
      /// On modifie
      test0.set(i, 0);
      test1.set(i, 1);

      marche0 = grilleCorrecte(test0);
      marche1 = grilleCorrecte(test1);
      
      if(!marche0 || !marche1) {
        // println("i: " + i);
      }
      if(marche0 && marche1) {
        println("i: " + i, grilleCorrecte(test0), grilleCorrecte(test1));
        putCircleAndRemember("circle", new PVector(i % taille, i / taille), new PVector(0.5, 0.5), #00ff00, "All");
      }

      if (marche0 != marche1) {
        touched = true;
        if (marche0) {
          grilleCourante[i] = 0;
        } else {
          grilleCourante[i] = 1;
        }
      }

      test0.set(i, grilleCourante[i]);
      test1.set(i, grilleCourante[i]);
    }
  }
  return touched;
}

/// BUG in '5' when w < h

boolean grilleCorrecte(ArrayList<Integer>grille) {
  return grilleCorrecte(grille, false);
}
boolean grilleCorrecte(ArrayList<Integer>grille, boolean verboseTrue) {
  ArrayList<ArrayList<Integer>> lignes, colonnes;
  int size = int(sqrt(grilles.length));

  lignes = new ArrayList<ArrayList<Integer>>(size);
  colonnes = new ArrayList<ArrayList<Integer>>(size);
  for (int i = 0; i < size; ++i) {
    lignes.add(new ArrayList<Integer>(size));
    colonnes.add(new ArrayList<Integer>(size));
    for (int j = 0; j < size; ++j) {
      lignes.get(i).add(-1);
      colonnes.get(i).add(-1);
    }
  }
  for (int i = 0; i < size; ++i) {
    for (int j = 0; j < size; ++j) {
      lignes.get(i).set(j, grille.get(j + (i * size)));
      colonnes.get(j).set(i, grille.get(j + (i * size)));
    }
  }


  /// Chaque ligne/colonne est unique et possède autant de 0 que de 1
  for (ArrayList<Integer> ligne : lignes) {
    int _0 = 0, _1 = 0;
    for (Integer i : ligne) {
      if (i==0)_0++;
      else if (i==1)_1++;
      if (_0 > 2 || _1 > 2) {
        print("Contiguité");
        return false;
      }
    }

    if (java.util.Collections.frequency(ligne, 0) > size / 2) {
      println("trop de 0: " + java.util.Collections.frequency(ligne, 0));
      return false;
    }
    if (java.util.Collections.frequency(ligne, 1) > size / 2) {
      println("trop de 1: " + java.util.Collections.frequency(ligne, 1));
      return false;
    }
    /// Au début cela peut être normal
    /*if (java.util.Collections.frequency(lignes, ligne) != 1) {
      println("dupli");
      return false;
    }*/
  }
  for (ArrayList<Integer> colonne : colonnes) {
    int _0 = 0, _1 = 0;
    for (Integer i : colonne) {
      if (i==0) {
        _0++;
        _1=0;
      } else if (i==1) {
        _1++;
        _0=0;
      }
      if (_0 > 2 || _1 > 2) {
        println(_0, _1);
        print("Contiguité");
        return false;
      }
    }

    if (java.util.Collections.frequency(colonne, 0) > size / 2) {
      println("trop de 0: " + java.util.Collections.frequency(colonne, 0));
      return false;
    }
    if (java.util.Collections.frequency(colonne, 1) > size / 2) {
      println("trop de 1: " + java.util.Collections.frequency(colonne, 1));
      return false;
    }
    /// Au début cela peut être normal
    /*if (java.util.Collections.frequency(colonnes, colonne) != 1) {
      println("dupli");
      return false;
    }*/
  }
  return true;
}