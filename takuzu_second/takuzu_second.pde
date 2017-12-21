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
    offset.x = (float) ((offset.x * (1 - ratio)) + (ratio * (float(mouseX) - (mouseAbsolutePosition.getX() - window.getX())));
    offset.y = (float) ((offset.y * (1 - ratio)) + (ratio * (float(mouseY) - (mouseAbsolutePosition.getY() - window.getY())));
  }
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
      if((lateralRight.boutons[index].actions & ACTION_OPEN_NEW_GRILL) == ACTION_OPEN_NEW_GRILL) {
              
      }
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
      } else if (key == '+' || key == '-') {
        zoom(key == '+' ? -0.1 : 0.1);
      } else if (key == CODED && ((keyCode == UP) || (keyCode == DOWN) || (keyCode == RIGHT) || (keyCode == LEFT))) {
        float step = 0.01;
        shiftRel(((keyCode == LEFT) ? -step : (keyCode == RIGHT) ? step : 0), ((keyCode == UP) ? -step : (keyCode == DOWN) ? step : 0));
      }
    }
}



/// Coût: lenght * 2 tests

// int positionX = 0, positionY = 0;


/// BUG in '5' when w < h


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
  if (window != null) {
    /// Récupère la position de la fenêtre
    float newX = window.getX();
    float newY = window.getY();
    surface.placeWindow(new int[] {int(newX), int(newY)}, new int[] {0, 0});
  }
}