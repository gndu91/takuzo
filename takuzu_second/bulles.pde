/// Liste chainée de bulles
class Bubble {
  float x;
  float y;
  float timeout;
  float timestamp;
  float fade_after;
  String[] message;
  Bubble next;
}

Bubble new_bubble(PVector pos, String...lignes) {
  Bubble bulle = new Bubble();
  bulle.x = pos.x;
  bulle.y = pos.y;
  bulle.message = lignes;
  bulle.timestamp = millis();
  bulle.timeout = millis() + 5000;
  bulle.fade_after = millis() + 2500;
  return bulle;
}

ArrayList<Bubble> bubbles;

void put_bubble(PVector pos, String...lignes) {
  bubbles.add(new_bubble(pos, lignes));
}

void put_bubble(int index, String message) {
  put_bubble(centreDeCase(index), message);
}

int TEXT_SIZE = 16;


void drawBubbles() {
  textSize(16);
  noStroke();
  
  
  
  for(Bubble bulle:bubbles) {
    
    
    
    int alpha = 255;
    if(millis() > bulle.fade_after) {
      alpha = 255 - (int) map(millis(), bulle.fade_after, bulle.timeout, 0, 255);
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