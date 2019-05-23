class LightTrail{ //The trail which follows behind the player.
  ArrayList<TrailingRect> trail = new ArrayList<TrailingRect>(); //A list of each rectangle which makes up the trail.
  color col; //Colour for the trail
  PVector lastPosition; //The last position the player was.
  //The last direction the player went.
  int lastDirection = 0;
  //Constructor needs to know where the player starts and what colour they are
  public LightTrail(color team, PVector origin){
    col = team;
    lastPosition = origin.copy();
    trail.add(new TrailingRect(lastPosition.copy(), lastPosition.copy(), col)); //Create first rectangle.
  }
  //Run logic.
  public void update(PVector position, int direction){
      if(direction == lastDirection || direction == 5){ //If the player is going in the same direction as last time
        trail.get(trail.size()-1).updateEndPos(position); //Adjust the newest rectangle
      }else{ //They have changed direction.
        trail.add(new TrailingRect(position, position, col)); //Create a new rectangle.
      }
    lastDirection = direction; //Keep the latest information available.
  }
  //Draw all rects.
  public void showAll(){
    for(TrailingRect rect : trail){
      rect.show();
    }
  }
  
  //Checks if the provided collider overlaps any of the existing trail
  public boolean overlap(Collider collide){
    for(TrailingRect rect : trail){
      if(collides(rect, collide)){
        return true;
      }
    }
    return false;
  }
  
  //Checks if a player has overlapped their own trail
  public boolean collideOwn(Collider collide){
    for(int i = 0; i < trail.size()-2; i++){ //size-2 prevents the 2 newest rects from overlapping. This prevents issues with the rectangle technically being underneath the player while it's being made.
      if(collides(trail.get(i), collide)){ //Collider interfaces!
        return true;
      }
    }
    return false;
  }
}

//A rectangle to create behind the player
class TrailingRect implements Collider{
  PVector startPos; //Position to start and end
  PVector endPos;
  color col; //Also colour for rendering.
  
  public TrailingRect(PVector start, PVector end, color team){ //Default sets up basics
    startPos = start.copy();
    endPos = end.copy();
    col = team;
  }
  
  //Draws to screen using both sets of coordinates and calculating width and height.
  public void show(){
    stroke(col);
    strokeWeight(4);
    fill(col, 200);
    rect(startPos.x, startPos.y, endPos.x-startPos.x, endPos.y-startPos.y);
  }
  
  //Moves the end position based on when the player moves.
  public void updateEndPos(PVector newEnd){
    endPos = newEnd.copy();
  }
  
  //Implement interfaces
  @Override
  public float getX(){
    if(endPos.x < startPos.x){ //Handles if this cube is upside down or not.
      return endPos.x; //If it is we switch our initial and final position. Otherwise 2d collision does not work.
    }else{
      return startPos.x;
    }
  }
  
  //Now do it for the rest of the functions.
  @Override
  public float getY(){
    if(endPos.y < startPos.y){
      return endPos.y;
    }else{
      return startPos.y;
    }
  }
  
  @Override
  public float getX2(){
    if(endPos.x < startPos.x){
      return startPos.x;
    }else{
      return endPos.x;
    }
  }
  
  @Override
  public float getY2(){
    if(endPos.y < startPos.y){
      return startPos.y;
    }else{
      return endPos.y;
    }
  }
}