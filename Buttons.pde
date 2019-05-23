public class Button{ //Basic button again from processing tutorial
  PVector position; //where
  float sizeX, sizeY; //how big
  String text; //saying what
  public boolean mouseOver = false; //is mouse over
  //Basic constructor
  public Button(PVector where, float w, float h, String line){
    position = where.copy();
    sizeX = w;
    sizeY = h;
    text = line;
  }
  //2d collision logic!
  public boolean isMouseOver(int mX, int mY){
    if(mX >= position.x && mX <= position.x+sizeX && mY >= position.y && mY <= position.y+sizeY){
      mouseOver = true;
    }else{
      mouseOver = false;
    }
    return mouseOver;
  }
  //renders to screen
  public void show(){
    fill(0);
    //If mouse is over change colour.
    if(mouseOver){
      stroke(0, 255, 0);
    }else{
      stroke(0, 0, 255);
    }
    //draw to screen.
    rect(position.x, position.y, sizeX, sizeY);
    stroke(0, 0, 255);
    fill(0, 0, 255);
    textSize(24);
    text(text, position.x, position.y+sizeY/2);
  }
}