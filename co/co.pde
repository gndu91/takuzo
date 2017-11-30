void setup() {
  int _length = 8;

  int[][] partial = new int[_length][_length];
}

boolean lineIsCorrect(char[] line) {
  /// State: 0->0; 1->1; 2->00; 3->11; 4->.
  char state = 4, _0 = 0, _1 = 0;
  for (int i = 0; i < line.length; ++i) {
    if (line[i] == 0) {
      _0++;
    } else {
      _1++;
    }
    /// If neutral state or different state
    if (state == 4 || (state & 1) != (line[i] & 1))
      state = line[i];
    else if ((state += 2) > 3) {
      /// Go from 0 to 2 or 1 to 3
      return false;
    }
  }
  return _0 == _1;
}
boolean dumbSolverOneStep() {
  return dumbSolverOneStep(grilleCourante, mCourante);
}
void dumbSolver(int[] t, boolean[] p) {
}

void update() {
  int nombre = 0;
  int taille = (int) sqrt(grilleCourante.length);
  ArrayList<ArrayList<Integer>> indexes = new ArrayList<ArrayList<Integer>>();

  ///  Lister toutes les combinaisons d'index possibles, pour cela nous appliquons quelques
  ///    filtres préliminaires pour nous assurer d'avoir le moins possibles d'assortiments
}


void insert(int[] t, int pos) {
  for (int i = 0; i + pos < grilleCourante.length && i < t.length; ++i) {
    grilleCourante[pos + i] = t[i];
  }
}

void insert(ArrayList<Integer> t, int pos) {
  for (int i = 0; i + pos < grilleCourante.length && i < t.size(); ++i) {
    grilleCourante[pos + i] = t.get(i);
  }
}

int[] extract(int pos, int len) {
  int[] t = new int[len];
  for (int i = 0; i + pos < grilleCourante.length && i < t.length; ++i) {
    t[i] = grilleCourante[pos + i];
  }
  return t;
}

int[] increment(int[] t) {
  for (int i = t.length - 1; i > -1; --i) {
    if (t[i] == 0) {
      t[i] = 1;
      return t;
    }
    t[i] = 0;
  }
  return t;
}

/// Crée une ligne de taille l
int[] creerLigne(int l) {
  int[] retour = new int[l];
  for (int i = 0; i < retour.length; ++i) {
    retour[i] = 0;
  }
  return retour;
}

ArrayList<Integer> convert(int[] t) {
  ArrayList<Integer> list = new ArrayList<Integer>();
  for (int i : t)list.add(i);
  return list;
}

int[] convert(ArrayList<Integer> t) {
  int[] list = new int[t.size()];
  for (int i = 0; i < t.size(); ++i) {
    list[i] = t.get(i);
  }
  return list;
}

/// TODO:Verification
/// Crée une ligne de taille l et l'initialiser à n
int[] creerLigne(int l, int n) {
  int[] retour = new int[l];
  for (int i = l - 1; i > -1; --i) {
    retour[i] = n % 2;
    n >>= 1;
  }
  return retour;
}
int decode(int[]t) {
  int retour = 0;

  for (int i = t.length - 1, x = 0; i > -1; --i, ++x) {
    retour += t[i] << x;
  }
  return retour;
}


/// Vérifie si une ligne est considérée comme correcte
boolean correct(int[] line) {
  int nb0 = 0, nb1 = 0;
  int nb0Alignes = 0, nb1alignes = 0;
  for (int i : line) {
    if (i == 0) {
      nb0++;
      nb1alignes = 0;
      nb0Alignes++;
      if (nb0Alignes > 2) {
        return false;
      }
    } else if (i == 1) {
      nb1++;
      nb0Alignes = 0;
      nb1alignes++;
      if (nb1alignes > 2) {
        return false;
      }
    } else throw new RuntimeException(i + " n'est pas binaire");
  } /// for
  return nb0 == nb1;
}
