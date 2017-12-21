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