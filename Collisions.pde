public interface Collider{ //Interfaces allow each implementing class to choose how these functions will work but they all serve the same function
  float getX();
  float getY();
  float getX2();
  float getY2();
}
//Collider which takes advantage of interface abstraction.
public boolean collides(Collider c1, Collider c2){
  if(c1.getX2() < c2.getX() || c1.getX() > c2.getX2() || c1.getY2() < c2.getY() || c1.getY() > c2.getY2()){
    return false;
  }else{
    return true;
  }
}
//A wall is a basic collider for edge purposes. Does not need to be rendered.
public class Wall implements Collider{
  PVector position; //Where
  float sizeX, sizeY; //how big
  //constructors!
  public Wall(PVector where, float x, float y){
    position = where.copy();
    sizeX = x;
    sizeY = y;
  }
  //Implements interface
  //Makes processing look more like eclispe.
  @Override
  float getX(){
    return position.x;
  }
  
  @Override
  float getY(){
    return position.y;
  }
  
  @Override
  float getX2(){
    return position.x + sizeX;
  }
  
  @Override
  float getY2(){
    return position.y + sizeY;
  }
}