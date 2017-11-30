/// Variables globales
int E_MENU_PRINCIPAL  = 0b10000000000000000000000000000000;
int E_JEU             = 0b01000000000000000000000000000000;
int etatGeneral       = E_MENU_PRINCIPAL;

void setup() {
}

void draw() {
  background(0); /// TODO: Ajouter currentBackground pour pouvoir personnaliser
  switch(etatGeneral) {
  case E_MENU_PRINCIPAL:
  afficherMenuPrincipal();
  }
}