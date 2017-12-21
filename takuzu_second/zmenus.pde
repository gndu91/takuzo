class Bouton {
  String text;
  boolean over = false;
  long actions = 0L;
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

Bouton nouveauBouton(String text, long actions) {
  Bouton b = new Bouton();
  b.text = text;
  b.actions = actions;
  return b;
}

Menu nouveauMenu(String nom, Bouton[] boutons) {
  Menu menu = new Menu();
  menu.nom = nom;
  menu.boutons = boutons;
  return menu;
}

Menu lateralRight = nouveauMenu("Menu Principal", new Bouton[] {
  nouveauBouton("Clear Board", ACTION_CLEAR_BOARD), 
  nouveauBouton("Clear Board - cases", ACTION_CLEAR_GRILL), 
  nouveauBouton("Clear Board - draft", ACTION_CLEAR_DRAFT), 
  nouveauBouton("Open...", ACTION_OPEN_NEW_GRILL), 
  nouveauBouton("Play one move", ACTION_AI_ONE_MOVE), 
  nouveauBouton("Clear Board - draft", ACTION_CLEAR_DRAFT)
  });