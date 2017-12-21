/**
 @author Ghoul Nadir
 */

///////////////////////////////////////////////////////////////////////////////////////////////////////////
/* NOTES A PROPOS DES OBJECTS:
 Dans le sujet, l'usage d'objects n'est pas interdit, j'ai donc décidé de les utiliser pour
 représenter par exemple des grilles, mais j'ai décidé de n'utiliser que des "structures" dans le
 sens ou les objets ne contiendron que des attributs et non des méthodes.
 Dans le programme, j'utilise Object... dans le but de pouvoir réappeler une fonction, par
 exemple pour dessiner les cercles, il fallait que je demande à dumbSolver et à draw de communiquer
 les cercles à dessiner, j'ai trouvé que la plus simple manière de le faire est d'appeler une fonction
 dont le seul but sera de sauvegarder les paramètres, dans le but de les réutiliser à chasue effacement
 de l'écran.
 */
class Grille {
  int[] ruban;
  int[] solution;
  boolean[] modifiables;
  int taille;
  String description;
  int index;
  Grille suivante;
};
abstract class Bouton {
  String text;
  abstract void onClick();
  boolean over = false;
};
class Switch extends Bouton {
  /// 0    1   2
  /// Off->On->Disabled
  color[] couleurs = {#00ff00, #ff0000, #999999};
  int etat;
  void onClick() {
    if (etat < 2) {
      etat = (etat + 1) % 2;
    }
  }
}

class Menu {
  Bouton[] boutons;
  float offset = 0;
  float granularite = 68;
  String nom;
  float tailleFinale = 256;
  float taille = 0;
}

Menu menuPrincipal() {
  Menu menu = new Menu();
  menu.nom = "Menu Principal";
  menu.boutons = new Bouton[6];
  int index = 0;
  ////////////////////////////////
  menu.boutons[index] = new Bouton() {
    public void onClick() {
      println("Resetting...");
      cleanBoard();
      forgetAllCircles();
    }
  };
  menu.boutons[index].text = "Clear Board";
  index++;////////////////////////
  ////////////////////////////////
  menu.boutons[index] = new Bouton() {
    public void onClick() {
      println("Resetting...");
      cleanBoard();
    }
  };
  menu.boutons[index].text = "Clear Board - cases";
  index++;////////////////////////
  ////////////////////////////////
  menu.boutons[index] = new Bouton() {
    public void onClick() {
      println("Resetting drafts...");
      forgetAllCircles();
    }
  };
  menu.boutons[index].text = "Clear Board - drafts";
  index++;////////////////////////
  ////////////////////////////////
  menu.boutons[index] = new Bouton() {
    public void onClick() {
      println("Opening...");
    }
  };
  menu.boutons[index].text = "Open";
  index++;////////////////////////
  ////////////////////////////////
  menu.boutons[index] = new Bouton() {
    public void onClick() {
      println("Thinking...");
      dumbSolverOneStep();
    }
  };
  menu.boutons[index].text = "Play";
  index++;////////////////////////
  ////////////////////////////////
  menu.boutons[index] = new Bouton() {
    public void onClick() {
      println("Opening...");
    }
  };
  menu.boutons[index].text = "Close";
  index++;////////////////////////
  ////////////////////////////////

  return menu;
}

Menu lateralRight = menuPrincipal();
///////////////////////////////////////////////////////////////////////////////////////////////////////////

/// TODO: ChangeListe

// Variables globales
ArrayList<Grille> grilles;
Grille courante;

/// Paramètres
ArrayList<PImage> images;

// 0 Modifiable -> 0 Constant -> 1 Modifiable -> 1 constant -> Vide modifiable # -> Vide constant 
PImage[] cases;

/// Offset entre (0, 0) de la fenêtre et le (0, 0) du canvas
PVector offset;

/**
 *  Fonction chargée de l'allocation mémoire, d'après la documentation,
 *      elle est appellée avant setup
 *  
 *  @see https://processing.org/reference/settings_.html
 */
void settings() {
  /// Le code qui suit servira à se placer dans le bon dossier, au lieu de démarrer dans le dossier d'installation de processing
  /// https://processing.github.io/processing-javadocs/core/
  if (System.setProperty("user.dir", sketchPath()) == null) {
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
  setState(FLAG_RESIZABLE, true);
  surface.setTitle("Takuzo");
  //////////////////////////////////
  setState(VIEW_GAME, true);
  setState(CURRENTLY_PLAYING, true);
  setState(ALWAYS_CENTERED, true);

  setState(SHOW_LATERAL_RIGHT, true);

  put_bubble(0, "Welcome");
}

/**
 Fonction draw: appelée à intervalle régulier
 */
void draw() {
  background(255);
  fill(200);
  /// TODO: Each call will have to specify rectMode
  rectMode(CORNERS);
  rect(origin()[0], origin()[1], dimEcran()[0] - origin()[2], dimEcran()[1] - origin()[3]);
  rectMode(CORNER);
  updateDims();
  if (getState(LATERAL_RIGHT_SHOWN)) {
    afficherLateralDroit();
  }
  if (getState(SHOW_GRID)) {
    afficherGrille();
  }
  drawBubbles();
  debug();
}

/// L'index du menu associé à un PVectore 
int getIndex(PVector mouse) {
  PVector[][] pos = getPositions();
  for (int index = 0; index < pos.length; index++) {
    PVector[]i = pos[index];
    if (mouse.x > i[0].x && mouse.y > i[0].y) {
      if (mouse.y < i[1].y && mouse.y < i[1].y) {
        return index;
      }
    }
  }
  return -1;
}
/// Points a, b, dimensions
PVector[][] getPositions() {
  PVector[][] pos = new PVector[lateralRight.boutons.length][3];
  float margins = lateralRight.taille / 10;
  for (int index = 0; index < lateralRight.boutons.length; ++index) {
    pos[index] = new PVector[] {
      new PVector(dimEcran()[0] + margins, (lateralRight.granularite * index + 16) - lateralRight.offset), 
      new PVector(), 
      new PVector(lateralRight.taille - (2 * margins), 64)
    };
    pos[index][1] = PVector.add(pos[index][0], pos[index][2]);
  }
  return pos;
}

boolean mouseInLateral() {
  return (width - mouseX) < lateralRight.taille;
}

void afficherLateralDroit() {
  PVector[][] positions = getPositions();
  for (int index = 0; index < lateralRight.boutons.length; ++index) {
    Bouton i = lateralRight.boutons[index];
    /// TODO: Onover
    fill(i.over ? #00ff00: 128);
    rect(positions[index][0].x, positions[index][0].y, positions[index][2].x, positions[index][2].y);
    textAlign(CENTER, CENTER);
    fill(0);
    text(i.text, positions[index][0].x + (positions[index][2].x / 2), positions[index][0].y + (positions[index][2].y / 2));
  }
}

/// /////////////////////////////////////////////////////////////////////////////////////////
/// Fonctions et variables relatives aux dimensions
///
float dimensions_grille_w, dimensions_grille_h, dimensions_grille_x, dimensions_grille_y;

/// Les variables du dessous devront être mises à jour en fonction de celles du dessus
float dimensions_grille_abs_x_0, dimensions_grille_abs_y_0;
float dimensions_grille_abs_x_1, dimensions_grille_abs_y_1;
float dimensions_grille_abs_w, dimensions_grille_abs_h;
float dimensions_grille_abs_unit_w, dimensions_grille_abs_unit_h;/// Taille d'une case
void updateDims() {
  if (getState(ALWAYS_SQUARE)) 
    reSquare();
  if (getState(ALWAYS_CENTERED))
    reCenterGrill();
  if (getState(ALWAYS_FULL))
    fullSize();
  /// Affiche progressivement le menu latéral, si l'animation est 
  int animation_speed = 1;
  if (getState(LATERAL_RIGHT_ANIMATION)) {
  }
  if (getState(SHOW_LATERAL_RIGHT)) {
    setState(LATERAL_RIGHT_SHOWN, true);
    if (lateralRight.taille < lateralRight.tailleFinale) {
      surface.setSize(width + animation_speed, height);
      lateralRight.taille += animation_speed;
    }
  } else {
    if (lateralRight.taille > -1) {
      surface.setSize(width - animation_speed, height);
      lateralRight.taille -= animation_speed;
    } else {
      setState(LATERAL_RIGHT_SHOWN, false);
    }
  }
  dimensions_grille_abs_x_0 = (dimEcran()[0] * dimensions_grille_x);
  dimensions_grille_abs_y_0 = (height * dimensions_grille_y);
  dimensions_grille_abs_x_1 = dimensions_grille_abs_x_0 + dimEcran()[0] * dimensions_grille_w;
  dimensions_grille_abs_y_1 = dimensions_grille_abs_y_0 + height * dimensions_grille_h;
  dimensions_grille_abs_w = dimEcran()[0] * dimensions_grille_w;
  dimensions_grille_abs_h = height * dimensions_grille_h;
  dimensions_grille_abs_unit_w = dimensions_grille_abs_w / courante.taille;
  dimensions_grille_abs_unit_h = dimensions_grille_abs_h / courante.taille;
}
void zoom(float agrandissement) {
  dimensions_grille_x += dimensions_grille_w / 2;
  dimensions_grille_y += dimensions_grille_h / 2;
  dimensions_grille_w *= (1 - agrandissement);
  dimensions_grille_h *= (1 - agrandissement);
  dimensions_grille_x -= dimensions_grille_w / 2;
  dimensions_grille_y -= dimensions_grille_h / 2;
  updateDims();
}
void shiftRel(float x, float y) {
  dimensions_grille_x += x;
  dimensions_grille_y += y;
  updateDims();
}
void shiftAbs(float x, float y) {
  dimensions_grille_x += x * dimEcran()[0];
  dimensions_grille_y += y * height;
  updateDims();
}
void relocate(int x, int y) {  
  dimensions_grille_x += x / dimEcran()[0];
  dimensions_grille_y += y / height;
  updateDims();
}
void reCenterGrill() {
  dimensions_grille_x = (1 - dimensions_grille_w) / 2;
  dimensions_grille_y = (1 - dimensions_grille_h) / 2;
}
void fullSize() {
  // If width > height
  /*if (canvas[5] > canvas[5]) {
   }*/
}
void initOffSet() {
  offset = new PVector( -4.0, -23.0, 0.0 );
}
void updateOffset() {
  java.awt.Window window = javax.swing.FocusManager.getCurrentManager().getActiveWindow();
  java.awt.Point mouseAbsolutePosition = java.awt.MouseInfo.getPointerInfo().getLocation();
  if (window != null) {
    /// On recupere les deux valeurs relatives
    /// Leaky sum
    float ratio = 0.001;
    float newX = ((float) (float(mouseX) - (mouseAbsolutePosition.getX() - window.getX())));
    float newY = ((float) (float(mouseY) - (mouseAbsolutePosition.getY() - window.getY())));
    offset.x = (offset.x * (1 - ratio)) + (newX * ratio);
    offset.y = (offset.y * (1 - ratio)) + (newY * ratio);
  }
  ///offset.x = -8;
  ///offset.y = -31;
  println(offset);
}
void reSquare() {
  float ratio = float(dimEcran()[0]) / height;

  float mean = ((dimensions_grille_h / ratio) + (dimensions_grille_w)) / 2;

  dimensions_grille_x += dimensions_grille_w / 2;
  dimensions_grille_y += dimensions_grille_h / 2;

  dimensions_grille_h = mean * ratio;
  dimensions_grille_w = mean;//  / ratio;

  dimensions_grille_x -= dimensions_grille_w / 2;
  dimensions_grille_y -= dimensions_grille_h / 2;
}
float[][] getLocations() {
  /// [x0, y0, x1, y1, w, h] -> en pixels
  float[][] locations = new float[courante.taille][6];
  for (int i = 0; i < courante.taille; ++i) {
    locations[i][0] = dimensions_grille_abs_x_0 + ((i % courante.taille) * dimensions_grille_abs_unit_w);
    locations[i][1] = dimensions_grille_abs_y_0 + ((i / courante.taille) * dimensions_grille_abs_unit_h);

    locations[i][4] = dimensions_grille_abs_unit_w;
    locations[i][5] = dimensions_grille_abs_unit_h;

    locations[i][2] = locations[i][0] + locations[i][4];
    locations[i][3] = locations[i][1] + locations[i][5];
  }
  return locations;
}
int[] dimEcran() {
  return new int[]{width - int(lateralRight.taille), height};
}
int[] origin() {
  return new int[]{10, 10, 10, 10};
}
/// /////////////////////////////////////////////////////////////////////////////////////////


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
    initOffSet();
    
    init_bubbles();
    setState(ALWAYS_SQUARE, true);

    /// TODO: Initialiser les variables ici, puis
    ///  saveConfig()
  }

  grilles = chargerGrilles();

  courante = grilles.get(0);
}

/**
 *  Affiche la matrice
 *
 *  @param dimensions: x, y, w, h: flottants entre 0 et 1
 *  
 *  TODO: Plusieurs layouts
 */
void afficherGrille(Grille grille, PImage[] images) {
  float w = dimensions_grille_w * (dimEcran()[0] / grille.taille);
  float h = dimensions_grille_h * (dimEcran()[1] / grille.taille);
  for (int i = 0; i < grille.taille; ++i)
    for (int j = 0; j < grille.taille; ++j) {
      int index = i + (grille.taille*j);
      int etat = (grille.ruban[index] > 1 ? 4 : (grille.ruban[index]*2 + int(grille.modifiables[index])));
      float x = dimensions_grille_abs_x_0 + (i * w);
      float y = dimensions_grille_abs_y_0 + (j * h);
      fill(grille_couleurs[etat]);
      rect(x, y, w, h);
    }
}
void afficherGrille() {
  afficherGrille(courante, cases);
}


void mouseMoved() {
  updateOffset();
  if (getState(LATERAL_RIGHT_SHOWN)) {
    int index = getIndex(new PVector(mouseX, mouseY));
    for (int i = 0; i < lateralRight.boutons.length; ++i) {
      lateralRight.boutons[i].over = (i == index);
    }
  }
}


void mousePressed() {
  if (getState(LATERAL_RIGHT_SHOWN)) {
    int index = getIndex(new PVector(mouseX, mouseY));
    if (index > -1 && index < lateralRight.boutons.length) {
      lateralRight.boutons[index].onClick();
    }
  }
  if (getState(VIEW_GAME) && getState(CURRENTLY_PLAYING)) {
    /// Nous allons prendre les coordonées de la souris, puis nous allons les remapper, en partant de
    ///  leurs positions en pixels, et en les "castant" dans les dimensions de la grille, puis nous
    ///  récupérons l'index, en voyant la grille comme étant un ruban qui dépasse par la droite et
    ///  qui se prolonge dans la ligne d'après, à gauche. Nous nous assurons que nous soyons bien dans
    ///  la ligne, puis nous vérifions si nous avons le pouvoir de la modifier, enfin, nous incrémentons
    ///  la valeur de la case, % 3 pour passer successivement de 0 à 1, puis à 2, puis à 0, etc.    
    int i = (int) map(mouseX, dimensions_grille_abs_x_0, dimensions_grille_abs_x_1, 0, courante.taille);
    int j = (int) map(mouseY, dimensions_grille_abs_y_0, dimensions_grille_abs_y_1, 0, courante.taille);
    int index = i + (courante.taille * j);
    if (i > -1 && j > -1 && i < courante.taille && j < courante.taille && courante.modifiables[index])
      courante.ruban[index] = (courante.ruban[index] + 1) % 3;
  }
}

void mouseWheel(MouseEvent event) {
  if (mouseInLateral()) {
    lateralRight.offset += lateralRight.granularite * event.getCount();
  } else {
    zoom(float(event.getCount()) / 10);
  }
}

void cleanBoard() {
  for (int i = 0; i < courante.modifiables.length; ++i) 
    if (courante.modifiables[i]) 
      courante.ruban[i] = 2;
}

void keyPressed() {
  if (key == '*') {
    changeState(SHOW_LATERAL_RIGHT);
  } else
    if (getState(VIEW_GAME) && getState(EDIT_MODE)) {
      if (key == BACKSPACE) {
        cleanBoard();
      } else if (key == ENTER) {
        courante = courante.suivante;
      } else if (key == TAB) {
        dumbSolverOneStep();
      } else if (key >= '1' && key <= '9') {
        float _x = ((float) (mouseX)) / dimEcran()[0];
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
          reSquare();
        }
      } else if (key == 'm') {
        changeState(FLAG_GRID_FOLLOWS_MOUSE);
      } else if (key == '+' || key == '-') {
        zoom(key == '+' ? -0.1 : 0.1);
      } else if (key == CODED && ((keyCode == UP) || (keyCode == DOWN) || (keyCode == RIGHT) || (keyCode == LEFT))) {
        float step = 0.01;
        shiftRel(((keyCode == LEFT) ? -step : (keyCode == RIGHT) ? step : 0), ((keyCode == UP) ? -step : (keyCode == DOWN) ? step : 0));
      } else if (key == 'f') {
        changeState(FLAG_FULLSCREEN);
      } else if (key == 's') {
        changeState(FLAG_SHAKE_WINDOW);
      } else if (key == '.' && false) {
        changeState(FLAG_WINDOW_FOLLOWS_MOUSE);
      } else if (key == '.') {
        changeState(FLAG_WINDOW_CENTERED_ON_GRID);
      }
    }
}


Grille chargerGrille(String path, int index) {
  /// On déclare les variables
  File fichier_grille = null;
  File fichier_solution = null;

  String suffix_grille = ".tak";
  String suffix_solution = ".sol";

  /// Nous allons utiliser deux tableaux de chaines de charactères, un pour la grille, un pour les solution
  String[] lignes_grille, lignes_solution;

  ///  Les deux chaines de caractères serviront à la lecture en parallèle des
  ///    lignes des fichiers.
  String ligne_grille, ligne_solution;

  /// Le stockage des tailles est utile pour les comparer
  int taille_grille, taille_solution;

  Grille grille = new Grille();
  grille.index = index - 1;

  ///  Nous allons commencer par la grille initiale, en se rappelant que les fichiers commencent avec l'index 1
  fichier_grille = new File(path + suffix_grille);
  fichier_solution = new File(path + suffix_solution);

  /// Vérification peut-être superflue, mais on n'est jamais trop sûr
  if (!fichier_grille.canRead() || !fichier_solution.canRead()) {
    return null;
  }

  /// Lecture des lignes
  lignes_grille = loadStrings(fichier_grille);
  lignes_solution = loadStrings(fichier_solution);

  /// S'assure que les fichiers soit biens lus
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
  if (taille_solution == 0) {
    throw new RuntimeException("Grille solution étonemment vide pour le fichier " +
      fichier_solution.getAbsolutePath() + " (ligne:\"" +
      ligne_solution.trim() + "\")");
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

    ///  J'ai vu que les grilles possèdent une structure "{taille} // {date}",
    ///    je vais donc stoquer la date dans une variable, au cas où.
    grille.description = "Grille n°" + index + " " + ligne_grille;
  } else {/// Sinon, cela signifie que la taille est la seule information disponible
    /// Voir précédente occurence de cette ligne, un peu plus tôt, dans le if
    taille_grille = int(ligne_grille.substring(0, slashIndex).trim());
    ///  J'ai vu que les grilles possèdent une structure "{taille} // {date}",
    ///    je vais donc stoquer la date dans une variable, au cas où.
    grille.description = "Grille n°" + index;
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
  grille.taille = taille_grille;

  //////////////////////////////////////////////////////////////////////80 chars
  ///  On va maintenant les remplir, en commençant par la grille
  ///    initiale, pour ce faire, on parcours le tableau en commençant
  ///    par la seconde ligne
  grille.ruban = new int[grille.taille * grille.taille];
  grille.modifiables = new boolean[grille.taille * grille.taille];
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
      grille.ruban[colonne + ((ligne - 1) * taille_grille)] =
        ligne_grille.charAt(colonne) - '0';
      grille.modifiables[colonne + ((ligne - 1) * taille_grille)] =
        ligne_grille.charAt(colonne) == '2';

      /// Si le chiffre n'est pas dans {0, 1, 2}
      if (grille.ruban[colonne + ((ligne - 1) * taille_grille)] < 0 || 
        grille.ruban[colonne + ((ligne - 1) * taille_grille)] > 2) {
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
  grille.solution = new int[grille.taille * grille.taille];
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
      grille.solution[colonne + ((ligne - 1) * taille_solution)] =
        ligne_solution.charAt(colonne) - '0';
      if ((grille.solution[colonne + ((ligne - 1) * taille_solution)] < 0) || 
        (grille.solution[colonne + ((ligne - 1) * taille_solution)] > 2)) {
        throw new RuntimeException(
          "Inconsistence trouvé dans le fichier \"" +
          fichier_solution.getAbsolutePath() + "\", ligne " +
          ligne + ", colonne " + colonne + ", le caractère '" + 
          + ligne_solution.charAt(colonne) +
          "' n'est pas dans {'0', '1', '2'}.");
      }
    }
  }
  return grille;
}

/**
 *  Retourne une liste de matrices
 */
////////////////////////////////////////////////////////////////////////////////////////////////////
ArrayList<Grille> chargerGrilles(String path, String prefix) {
  ArrayList<Grille> grilles = new ArrayList<Grille>();
  ///  TODO: Ajouter des sauvegarders/sauvegardes automatiques

  ////// Etape 1: On se place dans le dossier, et on gère les eventuels erreurs liées aux chemins

  /// Je joins les deux dossiers, pour cela je m'assure d'avoir des chaines de caractères, puis je joins les bouts
  prefix = java.nio.file.Paths.get((path == null) ? "" : path, (prefix == null) ? "" : prefix).toAbsolutePath().toString();

  /// On remplace les séparaeurs en / pour linux et \\ pour windows entre autres
  prefix = prefix.replace('/', java.io.File.separator.charAt(0));
  prefix = prefix.replace('\\', java.io.File.separator.charAt(0));

  Grille grille = null;
  int index = 1;
  while ((grille = chargerGrille(prefix + index, index++)) != null) {
    grilles.add(grille);
  }

  ///  Si nous ne trouvons pas assez de fichiers, alors il y a une erreur
  if (grilles.size() < 5) {
    throw new RuntimeException("Les grilles n'ont pas été trouvées, (prefix='" + prefix + ").");
  }
  /// On crée les liens
  for (int i = 0; i < grilles.size(); ++i) {
    grilles.get(i).suivante = grilles.get((i + 1) % grilles.size());
  }
  return grilles;
}

/// Les valeurs par défaut n'étant pas autorisées sous processing.js, j'utiliserai le polymorphisme
ArrayList<Grille> chargerGrilles() {
  return chargerGrilles("data\\grilles\\", "grille");
}

ArrayList<Grille> chargerGrillesAPartirDeDossier(File file) {
  return chargerGrilles(file.getAbsolutePath(), "grille");
}

Grille chargerGrille(File file) {
  String path = file.getAbsolutePath();
  /// .sol or .tak prennent 4 cases
  return chargerGrille(path.substring(0, path.length() - 4), 0);
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

ArrayList<Object[]> circleRemembered = new ArrayList();

void putCircleAndRemember(Object...args) {
  circleRemembered.add(args);
  putCircle((String)args[0], (PVector)args[1], (PVector)args[2], (color)args[3], (String)args[4]);
}

void redrawCirleFromMemory() {
  for (Object[] i : circleRemembered) {
    putCircle((String)i[0], (PVector)i[1], (PVector)i[2], (color)i[3], (String)i[4]);
  }
}

void forgetAllCircles() {
  circleRemembered = new ArrayList();
}

void putCircle(String type, PVector pos, PVector dim, color couleur, String texte) {
  try {
    if (type.equals("circle")) {
      fill(couleur);
      ellipse(
        ///        centré   centré      
        map(pos.x, 0 - 0.5, courante.taille - 0.5, dimensions_grille_x * dimEcran()[0], (dimensions_grille_x + dimensions_grille_w) * dimEcran()[0]), 
        map(pos.y, 0 - 0.5, courante.taille - 0.5, dimensions_grille_y * height, (dimensions_grille_y + dimensions_grille_h) * height), 
        dim.x * dimensions_grille_w * dimEcran()[0] / courante.taille, 
        dim.y * dimensions_grille_h * height / courante.taille 
        );
      filter(INVERT);
      text(
        texte, 
        map(pos.x, 0 - 0.5, courante.taille - 0.5, dimensions_grille_x * dimEcran()[0], (dimensions_grille_x + dimensions_grille_w) * dimEcran()[0]), 
        map(pos.y, 0 - 0.5, courante.taille - 0.5, dimensions_grille_y * height, (dimensions_grille_y + dimensions_grille_h) * height)
        );
      filter(INVERT);
      /// Lors du rediementionnement,
    }
  } 
  catch(ArrayIndexOutOfBoundsException e) {
  }
}

/// Liste chainée de bulles
class Bubble {
  float x;
  float y;
  float timeout;
  float timestamp;
  String[] message;
  Bubble next;
}

void init_bubbles() {
  bubbles = new ArrayList<Bubble>();
}

Bubble new_bubble(float x, float y, String...lignes) {
  Bubble bulle = new Bubble();
  bulle.x = x;
  bulle.y = y;
  bulle.message = lignes;
  bulle.timestamp = millis();
  bulle.timeout = millis() + 5000;
  return bulle;
}

ArrayList<Bubble> bubbles;

void put_bubble(float x, float y, String...lignes) {
  bubbles.add(new_bubble(x, y, lignes));
}

void put_bubble(int index, String message) {
  float x = map(index % courante.taille, 0 - 0.5, courante.taille - 0.5, dimensions_grille_x * dimEcran()[0], (dimensions_grille_x + dimensions_grille_w) * dimEcran()[0]);
  float y = map(index % courante.taille, 0 - 0.5, courante.taille - 0.5, dimensions_grille_y * height, (dimensions_grille_y + dimensions_grille_h) * height);
  put_bubble(x, y, message);
}
int TEXT_SIZE = 16;


void drawBubbles() {
  textSize(16);
  noStroke();
  
  
  
  for(Bubble bulle:bubbles) {
    
    
    
    int alpha = 255;
    if(map(millis(), bulle.timestamp, bulle.timeout, 0, 100) > 50) {
      alpha = 255 - (int) map(millis(), bulle.timestamp, bulle.timeout, 0, 255);
    }
    
    fill(#ffffff, alpha);
    float w = 0, h = bulle.message.length * 1.5;
    for (String text : bulle.message) {
      if(text.length() > w) {
        w = text.length();
      }
    }
    rect( bulle.x, bulle.y,
          w * 16, h * 16);
    for (String text : bulle.message) {
      fill(#000000, alpha);
      text(text, bulle.x + ((16 / 2) * text.length()), bulle.y + (16 / 2));
    }
    bulle = bulle.next;
  }
  
  stroke(0);
  textSize(TEXT_SIZE);
}



/// Coût: lenght * 2 tests

boolean dumbSolverOneStep() {
  forgetAllCircles();

  ArrayList<Integer> test0 = new ArrayList<Integer>();
  ArrayList<Integer> test1 = new ArrayList<Integer>();
  int taille = (int) sqrt(courante.ruban.length);

  boolean marche0, marche1;
  boolean touched = false;
  /// Copie intégrale
  for (int i = 0; i < courante.ruban.length; ++i) {
    test0.add(courante.ruban[i]);
    test1.add(courante.ruban[i]);
  }
  for (int i = 0; i < courante.ruban.length; ++i) {
    if (courante.modifiables[i]) {
      /// On modifie
      test0.set(i, 0);
      test1.set(i, 1);

      marche0 = grilleCorrecte(test0);
      marche1 = grilleCorrecte(test1);

      if (!marche0 || !marche1) {
        putCircleAndRemember("circle", new PVector(i % taille, i / taille), new PVector(0.5, 0.5), #0000ff, "One");
      }
      if (!marche0 && !marche1) {
        putCircleAndRemember("circle", new PVector(i % taille, i / taille), new PVector(0.5, 0.5), #ff0000, "None");
      }
      if (marche0 && marche1) {
        println("i: " + i, grilleCorrecte(test0), grilleCorrecte(test1));
        putCircleAndRemember("circle", new PVector(i % taille, i / taille), new PVector(0.5, 0.5), #00ff00, "All");
      }

      if (marche0 != marche1) {
        touched = true;
        if (marche0) {
          courante.ruban[i] = 0;
        } else {
          courante.ruban[i] = 1;
        }
      }

      test0.set(i, courante.ruban[i]);
      test1.set(i, courante.ruban[i]);
    } // else putCircleAndRemember("circle", new PVector(i % taille, i / taille), new PVector(0.5, 0.5), #000000, "nope");
  }
  return touched;
}
// int positionX = 0, positionY = 0;


/// BUG in '5' when w < h

boolean grilleCorrecte(ArrayList<Integer>grille) {
  ArrayList<ArrayList<Integer>> lignes, colonnes;
  int size = int(sqrt(courante.ruban.length));

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

/// ////////////////////////////////////////////////////////////////////////////////////
/// ////////////////////////////////////////////////////////////////////////////////////
/// ////////////////////////////////////////////////////////////////////////////////////
/// ////////////////////////////////////////////////////////////////////////////////////
/// ////////////////////////////////////////////////////////////////////////////////////
/// ////////////////////////////////////////////////////////////////////////////////////
void debug() {
  redrawCirleFromMemory();

  /// Get states
  java.awt.Window window = javax.swing.FocusManager.getCurrentManager().getActiveWindow();
  java.awt.Point mouseAbsolutePosition = java.awt.MouseInfo.getPointerInfo().getLocation();
  if (window != null) {
    /// Récupère la position de la fenêtre
    float newX = window.getX();
    float newY = window.getY();
    if (true) {
    } else
      if (getState(FLAG_GRID_FOLLOWS_MOUSE)) {
        dimensions_grille_x = ((mouseAbsolutePosition.getLocation().x + offset.x - newX) / dimEcran()[0]) - (dimensions_grille_w / 2);
        dimensions_grille_y = ((mouseAbsolutePosition.getLocation().y + offset.y - newY) / height) - (dimensions_grille_h / 2);
      }
    if (true) {
    } else
      if (getState(FLAG_WINDOW_CENTERED_ON_GRID)) {
        /// We take the relative position, then we substract 1 / 2 to have a location relative to the center
        ///  NOTE: ((a + b) / 2) + (c / 2) = (a + b + c) / 2
        float relativeOffsetX = ((dimensions_grille_x + dimensions_grille_x + dimensions_grille_w - 1) / 2);
        float relativeOffsetY = ((dimensions_grille_y + dimensions_grille_y + dimensions_grille_h - 1) / 2);

        newX += relativeOffsetX * dimEcran()[0];
        newY += relativeOffsetY * height;

        dimensions_grille_x -= relativeOffsetX;
        dimensions_grille_y -= relativeOffsetY;
      }
    if (true) {
    } else
      if (getState(FLAG_WINDOW_FULLY_INSIDE_SCREEN)) {
        newX = max(0, min(newX, displayWidth - dimEcran()[0]));
        newY = max(0, min(newY, displayHeight - height));
      }
    if (true) {
    } else
      if (getState(FLAG_SHAKE_WINDOW)) {
        float a = 0.5;
        float w = float(dimEcran()[0]) - (random(-100, 100) > 0 ? a : -a);
        float h = float(height)- (random(-100, 100) > 0 ? a : -a);
        w = (w + w + w + h) / 4;
        h = (w + h + h + h) / 4;
        surface.setSize(int(w), int(h));
        newX += random(-a, a);
        newY += random(-a, a);
      }
    /*if (true) {
     } else
     if (getState(FLAG_WINDOW_FOLLOWS_MOUSE)) {
     /// Valeur absolue de la souris, même si elle se trouve à l'exterieur
     int a = 50;
     newX = ((a * positionX) + mouseAbsolutePosition.getLocation().x - dimEcran()[0] / 2) / (a + 1);
     newY = ((a * positionY) + mouseAbsolutePosition.getLocation().y - height / 2) / (a + 1);
     }*/
    surface.placeWindow(new int[] {int(newX), int(newY)}, new int[] {0, 0});
  }
}
/// ////////////////////////////////////////////////////////////////////////////////////
/// ////////////////////////////////////////////////////////////////////////////////////
/// ////////////////////////////////////////////////////////////////////////////////////
/// ////////////////////////////////////////////////////////////////////////////////////
/// ////////////////////////////////////////////////////////////////////////////////////

/**
 Paramètres généraux, un seul long, simple à sauvegarder, et ne nécéssitant que
 la déclaration d'une variable et de constantes, cela pourra aussi être utile
 d'utiliser cela pour pouvoir intercepter les modifications, par exemple afficher
 tout les changements d'une variable en cas de compotement inhabituel.
 Pour assigner aux flags une valeur, et pour m'assurer qu'il n'y aura pas deux fois
 la même valeur, je peux les initialiser de deux manières:
 1/ A la main:
 a = 0b0000000000000000000000000000000000000000000000000000000000000001L
 b = 0b0000000000000000000000000000000000000000000000000000000000000010L
 c = 0b0000000000000000000000000000000000000000000000000000000000000100L
 2/ Automatiquement
 cur = 1L;
 a = cur;
 b = (cur << 1);
 c = (cur << 1);
 */
long current_state = 0b0000000000000000000000000000000000000000000000000000000000000000L;
long flag_cursor   = 1L; // Représente, si différent de 1, le nombre de flags au total
///  S'il est vrai, la fenetre sera située de manière à ce que la grille ne dépasse pas,
///    pour l'instant, nous nous contenterons de placer la fenetre pour que la grille
///    soit au centre
///  XXX: Mettre à jour ce commentaire en cas de changement de méthode
final long FLAG_SHALL_NOT_GO_OUT = flag_cursor;
final long FLAG_GRID_FOLLOWS_MOUSE = (flag_cursor <<= 1);
final long FLAG_WINDOW_CENTERED_ON_GRID = (flag_cursor <<= 1);
final long FLAG_WINDOW_FULLY_INSIDE_SCREEN = (flag_cursor <<= 1);
final long FLAG_SHAKE_WINDOW = (flag_cursor <<= 1);
final long FLAG_WINDOW_FOLLOWS_MOUSE = (flag_cursor <<= 1);
final long FLAG_FULLSCREEN = (flag_cursor <<= 1);
final long FLAG_RESIZABLE = (flag_cursor <<= 1);

/// Vues
final long EDIT_MODE = (flag_cursor <<= 1);
final long CURRENTLY_PLAYING = (flag_cursor <<= 1);
final long ALWAYS_SQUARE = (flag_cursor <<= 1);
final long ALWAYS_CENTERED = (flag_cursor <<= 1);
final long LATERAL_RIGHT_ANIMATION = (flag_cursor <<= 1);
final long ALWAYS_FULL = (flag_cursor <<= 1);

/// Widgets
final long SHOW_GRID = (flag_cursor <<= 1);
final long SHOW_SCORE = (flag_cursor <<= 1);
final long SHOW_LATERAL_RIGHT = (flag_cursor <<= 1);
final long LATERAL_RIGHT_SHOWN = (flag_cursor <<= 1);
/// Menus (ensembles de widgets)
final long VIEW_HOME = (flag_cursor <<= 1);
final long VIEW_GAME = (flag_cursor <<= 1) | SHOW_GRID | SHOW_SCORE;
/// Slots libres
final long FREE_SLOT_20 = (flag_cursor <<= 1);
final long FREE_SLOT_21 = (flag_cursor <<= 1);
final long FREE_SLOT_22 = (flag_cursor <<= 1);
final long FREE_SLOT_23 = (flag_cursor <<= 1);
final long FREE_SLOT_24 = (flag_cursor <<= 1);
final long FREE_SLOT_25 = (flag_cursor <<= 1);
final long FREE_SLOT_26 = (flag_cursor <<= 1);
final long FREE_SLOT_27 = (flag_cursor <<= 1);
final long FREE_SLOT_28 = (flag_cursor <<= 1);
final long FREE_SLOT_29 = (flag_cursor <<= 1);
final long FREE_SLOT_30 = (flag_cursor <<= 1);
final long FREE_SLOT_31 = (flag_cursor <<= 1);
final long FREE_SLOT_32 = (flag_cursor <<= 1);
final long FREE_SLOT_33 = (flag_cursor <<= 1);
final long FREE_SLOT_34 = (flag_cursor <<= 1);
final long FREE_SLOT_35 = (flag_cursor <<= 1);
final long FREE_SLOT_36 = (flag_cursor <<= 1);
final long FREE_SLOT_37 = (flag_cursor <<= 1);
final long FREE_SLOT_38 = (flag_cursor <<= 1);
final long FREE_SLOT_39 = (flag_cursor <<= 1);
final long FREE_SLOT_40 = (flag_cursor <<= 1);
final long FREE_SLOT_41 = (flag_cursor <<= 1);
final long FREE_SLOT_42 = (flag_cursor <<= 1);
final long FREE_SLOT_43 = (flag_cursor <<= 1);
final long FREE_SLOT_44 = (flag_cursor <<= 1);
final long FREE_SLOT_45 = (flag_cursor <<= 1);
final long FREE_SLOT_46 = (flag_cursor <<= 1);
final long FREE_SLOT_47 = (flag_cursor <<= 1);
final long FREE_SLOT_48 = (flag_cursor <<= 1);
final long FREE_SLOT_49 = (flag_cursor <<= 1);
final long FREE_SLOT_50 = (flag_cursor <<= 1);
final long FREE_SLOT_51 = (flag_cursor <<= 1);
final long FREE_SLOT_52 = (flag_cursor <<= 1);
final long FREE_SLOT_53 = (flag_cursor <<= 1);
final long FREE_SLOT_54 = (flag_cursor <<= 1);
final long FREE_SLOT_55 = (flag_cursor <<= 1);
final long FREE_SLOT_56 = (flag_cursor <<= 1);
final long FREE_SLOT_57 = (flag_cursor <<= 1);
final long FREE_SLOT_58 = (flag_cursor <<= 1);
final long FREE_SLOT_59 = (flag_cursor <<= 1);
final long FREE_SLOT_60 = (flag_cursor <<= 1);
final long FREE_SLOT_61 = (flag_cursor <<= 1);
final long FREE_SLOT_62 = (flag_cursor <<= 1);
final long FREE_SLOT_63 = (flag_cursor <<= 1);
/// If this fails, there is too many flags
{
  assert flag_cursor != 0;
}

/// //////////////////////////////////////////////////////////////////////////////////////////////////
/// Pour faire une vue, il nous faut un certain nombre de parametres, et cette fois ci, nous testerons
///  toutes les "composantes" pour savoir si le "flag" est activé
boolean getState(long flag) {
  return (flag & current_state) == flag;
}

void setState(long flag, boolean newState) {
  if((current_state & FLAG_RESIZABLE) == FLAG_RESIZABLE) {
    surface.setResizable(newState);
  }
  if (newState) {
    current_state |= flag;
  } else {
    current_state &= ~flag;
  }
}

/// Change the state and return the new state,
///  nous ne nous embeterons pas à savoir quoi
///  activer, nous allons juste activer si un
///  des bit est à 0, sinon, nous allons désactiver
boolean changeState(long flag) {
  if ((flag & FLAG_FULLSCREEN) != 0) {
    // surface.getNative();
  }
  if (getState(flag)) {
    setState(flag, false);
    return false;
  } else {
    setState(flag, true);
    return true;
  }
}

long[] broken = {FLAG_WINDOW_FOLLOWS_MOUSE};