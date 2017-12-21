/// Liste chainée de bulles
class Bubble {
  float x;
  float y;
  float timeout;
  float timestamp;
  String[] message;
  Bubble next;
}

void init_bubbles() {
  bubbles = new ArrayList<Bubble>();
}

Bubble new_bubble(float x, float y, String...lignes) {
  Bubble bulle = new Bubble();
  bulle.x = x;
  bulle.y = y;
  bulle.message = lignes;
  bulle.timestamp = millis();
  bulle.timeout = millis() + 5000;
  return bulle;
}

ArrayList<Bubble> bubbles;

void put_bubble(float x, float y, String...lignes) {
  bubbles.add(new_bubble(x, y, lignes));
}

void put_bubble(int index, String message) {
  float x = map(index % courante.taille, 0 - 0.5, courante.taille - 0.5, dimensions_grille_x * dimEcran()[0], (dimensions_grille_x + dimensions_grille_w) * dimEcran()[0]);
  float y = map(index % courante.taille, 0 - 0.5, courante.taille - 0.5, dimensions_grille_y * height, (dimensions_grille_y + dimensions_grille_h) * height);
  put_bubble(x, y, message);
}
int TEXT_SIZE = 16;


void drawBubbles() {
  textSize(16);
  noStroke();
  
  
  
  for(Bubble bulle:bubbles) {
    
    
    
    int alpha = 255;
    if(map(millis(), bulle.timestamp, bulle.timeout, 0, 100) > 50) {
      alpha = 255 - (int) map(millis(), bulle.timestamp, bulle.timeout, 0, 255);
    }
    
    fill(#ffffff, alpha);
    float w = 0, h = bulle.message.length * 1.5;
    for (String text : bulle.message) {
      if(text.length() > w) {
        w = text.length();
      }
    }
    rect( bulle.x, bulle.y,
          w * 16, h * 16);
    for (String text : bulle.message) {
      fill(#000000, alpha);
      text(text, bulle.x + ((16 / 2) * text.length()), bulle.y + (16 / 2));
    }
    bulle = bulle.next;
  }
  
  stroke(0);
  textSize(TEXT_SIZE);
}