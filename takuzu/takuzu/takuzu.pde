/// Variables globales

/// Etat général, sert entre autre à diviser la procédure draw
final int E_MENU_PRINCIPAL  = 0b10000000000000000000000000000000;
final int E_JEU             = 0b01000000000000000000000000000000;
int etatGeneral             = E_MENU_PRINCIPAL;

/// Variables associées au menu principal
///  Paramètres:
///    Affichage:
///      Full Screen
///      Resizable
///      Styles:
///        Boutons
///        Boutons
///    Languages
///  

HashMap<String, Object> menus;

void setup() {
  surface.setSize(500, 500);
  initialiserMenus();
}

void draw() {
  /// TODO: Ajouter currentBackground pour pouvoir personnaliser
  background(255);

  switch(etatGeneral) {
  case E_MENU_PRINCIPAL:
    afficherMenus();
    break;
  }
}

void afficherMenus() {
  ///  PLAY - SETTINGS - 

  println(mouseX, mouseY);
  if (!appelerFonction("f"));
}
void initialiserMenus() {
  /// TODO: Sauvegarder dans fichiers json
}

/// Fonctions diverses et variées servant à simplifier le code plus haut


void f() {
  
}

///  Appelle une fontion, avec ou sans paramètres, et retourne true si l'on a réussi
///  Sources:
///    https://docs.oracle.com/javase/tutorial/reflect/member/methodInvocation.html
///    https://stackoverflow.com/questions/9309536/how-can-i-expand-arguments-in-java
///    https://stackoverflow.com/questions/160970/how-do-i-invoke-a-java-method-when-given-the-method-name-as-a-string

boolean appelerFonction(String nom, Object... args) {
  try {
    java.lang.reflect.Method method = null;

    for (java.lang.reflect.Method m : getClass().getMethods()) {
      if (method == null && m.getName().equals(nom)) {
        method = m;
      }
    }

    if (method == null) {
      throw new NoSuchMethodException("caca");
    }
    if (args.length == 0) {
      method.invoke(this);
    } else if (args.length == 1) {
      method.invoke(this, args[0]);
    } else if (args.length == 2) {
      method.invoke(this, args[0], args[1]);
    } else if (args.length == 3) {
      method.invoke(this, args[0], args[1], args[2]);
    } else if (args.length == 4) {
      method.invoke(this, args[0], args[1], args[2], args[3]);
    } else throw new IllegalArgumentException("Too much");
  } 
  catch (SecurityException e) { 
    e.printStackTrace();
    return false;
  }
  catch (NoSuchMethodException e) { 
    e.printStackTrace();
    return false;
  } 
  catch (IllegalArgumentException e) { 
    e.printStackTrace();
    return false;
  }
  catch (IllegalAccessException e) { 
    e.printStackTrace();
    return false;
  }
  catch (java.lang.reflect.InvocationTargetException e) {
    e.printStackTrace();
    return false;
  }
  return true;
}