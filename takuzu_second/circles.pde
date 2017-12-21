ArrayList<Object[]> circleRemembered = new ArrayList();

void rememberCircle(Object...args) {
  circleRemembered.add(args);
}

void invert() {
  try {
    filter(INVERT);
  } 
  catch(ArrayIndexOutOfBoundsException e) {
  }
}

void redrawCirleFromMemory() {
  for (Object[] i : circleRemembered) {
    String type = (String)i[0];
    PVector dim = (PVector)i[2];
    color couleur = (color)i[3];
    PVector pos = centreDeCase((int)i[1]);// index
    float dimX = dim.x * dimensions_grille_w * dimEcran()[0] / courante.taille;
    float dimY = dim.y * dimensions_grille_h * dimEcran()[1] / courante.taille;
    fill(couleur);
    if (type.equals("circle")) {
      ellipse(pos.x, pos.y, dimX, dimY);
    }
  }
  textSize(8);
  invert();
  for (Object[] i : circleRemembered) {
    String texte = (String)i[4];
    PVector pos = centreDeCase((int)i[1]);// index
    text(texte, pos.x, pos.y);
  }
  invert();
}