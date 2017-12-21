
/// ////////////////////////////////////////////////////////////////////////////////////
/// ////////////////////////////////////////////////////////////////////////////////////
/// ////////////////////////////////////////////////////////////////////////////////////
/// ////////////////////////////////////////////////////////////////////////////////////
/// ////////////////////////////////////////////////////////////////////////////////////

/**
 Paramètres généraux, un seul long, simple à sauvegarder, et ne nécéssitant que
 la déclaration d'une variable et de constantes, cela pourra aussi être utile
 d'utiliser cela pour pouvoir intercepter les modifications, par exemple afficher
 tout les changements d'une variable en cas de compotement inhabituel.
 Pour assigner aux flags une valeur, et pour m'assurer qu'il n'y aura pas deux fois
 la même valeur, je peux les initialiser de deux manières:
 1/ A la main:
 a = 0b0000000000000000000000000000000000000000000000000000000000000001L
 b = 0b0000000000000000000000000000000000000000000000000000000000000010L
 c = 0b0000000000000000000000000000000000000000000000000000000000000100L
 2/ Automatiquement
 cur = 1L;
 a = cur;
 b = (cur << 1);
 c = (cur << 1);
 */
long current_state = 0b0000000000000000000000000000000000000000000000000000000000000000L;
long flag_cursor   = 1L; // Représente, si différent de 1, le nombre de flags au total
///  S'il est vrai, la fenetre sera située de manière à ce que la grille ne dépasse pas,
///    pour l'instant, nous nous contenterons de placer la fenetre pour que la grille
///    soit au centre
///  XXX: Mettre à jour ce commentaire en cas de changement de méthode
/*
final long FLAG_SHALL_NOT_GO_OUT = flag_cursor;
final long FLAG_GRID_FOLLOWS_MOUSE = (flag_cursor <<= 1);
final long FLAG_WINDOW_CENTERED_ON_GRID = (flag_cursor <<= 1);
final long FLAG_WINDOW_FULLY_INSIDE_SCREEN = (flag_cursor <<= 1);
final long FLAG_SHAKE_WINDOW = (flag_cursor <<= 1);
final long FLAG_WINDOW_FOLLOWS_MOUSE = (flag_cursor <<= 1);
final long FLAG_FULLSCREEN = (flag_cursor <<= 1);
*/

final long FLAG_RESIZABLE = (flag_cursor <<= 1);
/// Vues
final long EDIT_MODE = (flag_cursor <<= 1);
final long CURRENTLY_PLAYING = (flag_cursor <<= 1);
final long ALWAYS_SQUARE = (flag_cursor <<= 1);
final long ALWAYS_CENTERED = (flag_cursor <<= 1);
final long LATERAL_RIGHT_ANIMATION = (flag_cursor <<= 1);
final long ALWAYS_FULL = (flag_cursor <<= 1);

/// Widgets
final long SHOW_GRID = (flag_cursor <<= 1);
final long SHOW_SCORE = (flag_cursor <<= 1);
final long SHOW_LATERAL_RIGHT = (flag_cursor <<= 1);
final long LATERAL_RIGHT_SHOWN = (flag_cursor <<= 1);

/// Menus (ensembles de widgets)
final long VIEW_HOME = (flag_cursor <<= 1);
final long VIEW_GAME = (flag_cursor <<= 1) | SHOW_GRID | SHOW_SCORE;

/// Actions prédéfinies
final long ACTION_OPEN_NEW_GRILL = (flag_cursor <<= 1);

final long ACTION_CLEAR_GRILL = (flag_cursor <<= 1);
final long ACTION_CLEAR_DRAFT = (flag_cursor <<= 1);
final long ACTION_CLEAR_BUBBLES = (flag_cursor <<= 1);
final long ACTION_CLEAR_BOARD = ACTION_CLEAR_GRILL | ACTION_CLEAR_DRAFT | ACTION_CLEAR_BUBBLES;

final long ACTION_RESET_TIMER = (flag_cursor <<= 1);

final long ACTION_RESTART = ACTION_RESET_TIMER | ACTION_RESET_TIMER;

final long ACTION_AI_ONE_MOVE = (flag_cursor <<= 1);

final long ACTION_GRILL_RESQUARE = (flag_cursor <<= 1);

final long ACTION_GRILL_SHOW_NEXT = (flag_cursor <<= 1);
final long BUGGED_ACTION_GRILL_SHOW_PREVIOUS = (flag_cursor <<= 1);

/// Slots libres
final long FREE_SLOT_24 = (flag_cursor <<= 1);
final long FREE_SLOT_25 = (flag_cursor <<= 1);
final long FREE_SLOT_26 = (flag_cursor <<= 1);
final long FREE_SLOT_27 = (flag_cursor <<= 1);
final long FREE_SLOT_28 = (flag_cursor <<= 1);
final long FREE_SLOT_29 = (flag_cursor <<= 1);
final long FREE_SLOT_30 = (flag_cursor <<= 1);
final long FREE_SLOT_31 = (flag_cursor <<= 1);
final long FREE_SLOT_32 = (flag_cursor <<= 1);
final long FREE_SLOT_33 = (flag_cursor <<= 1);
final long FREE_SLOT_34 = (flag_cursor <<= 1);
final long FREE_SLOT_35 = (flag_cursor <<= 1);
final long FREE_SLOT_36 = (flag_cursor <<= 1);
final long FREE_SLOT_37 = (flag_cursor <<= 1);
final long FREE_SLOT_38 = (flag_cursor <<= 1);
final long FREE_SLOT_39 = (flag_cursor <<= 1);
final long FREE_SLOT_40 = (flag_cursor <<= 1);
final long FREE_SLOT_41 = (flag_cursor <<= 1);
final long FREE_SLOT_42 = (flag_cursor <<= 1);
final long FREE_SLOT_43 = (flag_cursor <<= 1);
final long FREE_SLOT_44 = (flag_cursor <<= 1);
final long FREE_SLOT_45 = (flag_cursor <<= 1);
final long FREE_SLOT_46 = (flag_cursor <<= 1);
final long FREE_SLOT_47 = (flag_cursor <<= 1);
final long FREE_SLOT_48 = (flag_cursor <<= 1);
final long FREE_SLOT_49 = (flag_cursor <<= 1);
final long FREE_SLOT_50 = (flag_cursor <<= 1);
final long FREE_SLOT_51 = (flag_cursor <<= 1);
final long FREE_SLOT_52 = (flag_cursor <<= 1);
final long FREE_SLOT_53 = (flag_cursor <<= 1);
final long FREE_SLOT_54 = (flag_cursor <<= 1);
final long FREE_SLOT_55 = (flag_cursor <<= 1);
final long FREE_SLOT_56 = (flag_cursor <<= 1);
final long FREE_SLOT_57 = (flag_cursor <<= 1);
final long FREE_SLOT_58 = (flag_cursor <<= 1);
final long FREE_SLOT_59 = (flag_cursor <<= 1);
final long FREE_SLOT_60 = (flag_cursor <<= 1);
final long FREE_SLOT_61 = (flag_cursor <<= 1);
final long FREE_SLOT_62 = (flag_cursor <<= 1);
final long FREE_SLOT_63 = (flag_cursor <<= 1);
/// If this fails, there is too many flags
{
  assert flag_cursor != 0;
}

/// //////////////////////////////////////////////////////////////////////////////////////////////////
/// Pour faire une vue, il nous faut un certain nombre de parametres, et cette fois ci, nous testerons
///  toutes les "composantes" pour savoir si le "flag" est activé
boolean getState(long flag) {
  return (flag & current_state) == flag;
}

void setState(long flag, boolean newState) {
  if((current_state & FLAG_RESIZABLE) == FLAG_RESIZABLE) {
    surface.setResizable(newState);
  }
  if (newState) {
    current_state |= flag;
  } else {
    current_state &= ~flag;
  }
}

/// Change the state and return the new state,
///  nous ne nous embeterons pas à savoir quoi
///  activer, nous allons juste activer si un
///  des bit est à 0, sinon, nous allons désactiver
boolean changeState(long flag) {
  if (getState(flag)) {
    setState(flag, false);
    return false;
  } else {
    setState(flag, true);
    return true;
  }
}