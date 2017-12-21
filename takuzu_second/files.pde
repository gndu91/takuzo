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