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