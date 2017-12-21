
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
    fill(lateralRight.boutons[index].couleur);
    rect(positions[index][0].x, positions[index][0].y, positions[index][2].x, positions[index][2].y);
    textAlign(CENTER, CENTER);
    fill(0);
    text(i.text, positions[index][0].x + (positions[index][2].x / 2), positions[index][0].y + (positions[index][2].y / 2));
  }
}