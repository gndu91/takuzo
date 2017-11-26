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