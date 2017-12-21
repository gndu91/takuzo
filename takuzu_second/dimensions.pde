
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
    execute(ACTION_GRILL_RESQUARE);
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
    offset.x = (float) ((offset.x * (1 - ratio)) + (ratio * (float(mouseX) - (mouseAbsolutePosition.getX() - window.getX()))));
    offset.y = (float) ((offset.y * (1 - ratio)) + (ratio * (float(mouseY) - (mouseAbsolutePosition.getY() - window.getY()))));
  }
}

int[] dimEcran() {
  return new int[]{width - int(lateralRight.taille), height};
}
int[] origin() {
  return new int[]{10, 10, 10, 10};
}
/// /////////////////////////////////////////////////////////////////////////////////////////
PVector centreDeCase(int index) {
  return new PVector(
    map((index % courante.taille) + 0.5, 0, courante.taille, dimensions_grille_x * dimEcran()[0], (dimensions_grille_x + dimensions_grille_w) * dimEcran()[0]),
    map((index / courante.taille) + 0.5, 0, courante.taille, dimensions_grille_y * dimEcran()[1], (dimensions_grille_y + dimensions_grille_h) * dimEcran()[1])
  );
}