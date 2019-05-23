//A player in a game.
class Player implements Collider{
  final PVector origin; //Where we started
  PVector position; //Where we are
  PVector velocity; //How fast we're going
  float accel = 1.0; //The rate of acceleration
  float frict = 0.9; //The rate of normal deceleration if no input is applied.
  PlayerController controller; //Who is controlling this player?
  color col; //Colour to show
  final float size = 20; //How big the player is.
  
  //Holding the enemey player helps the ai player controller to have information.
  Player enemy;
  
  LightTrail trail; //The trail that will follow the player to block the opponent.
  
  boolean alive = true; //Checks if the player is alive.
  
  //Constructors
  public Player(PVector start, PlayerController action, color team){
    origin = start.copy(); //The origin is where we start
    position = start.copy(); //We also start there
    velocity = new PVector(0, 0); //Start at 0 velocity.
    controller = action; //The player controller will tell this player where to go.
    col = team;
    trail = new LightTrail(col, position); //Init the light trail
    //System.out.println("Starting at " + origin.x + ", " + origin.y);
  }
  
  //Updates logic
  public void update(){
    if(alive){ //If we are alive
      int input = controller.getDirection(this); //Ask the controller which way to go
      if(input == 0){ //Then act based on it.
        velocity.x += accel; //Right
        velocity.y = 0;
      }else if(input == 1){
        velocity.x -= accel; //Left
        velocity.y = 0;
      }else if(input == 2){
        velocity.y += accel; //Down
        velocity.x = 0;
      }else if(input == 3){
        velocity.y -= accel; //Up
        velocity.x = 0;
      }
      //Then move the player.
      position.add(velocity);
      velocity.mult(frict);
    
      //Then run the trail
      trail.update(position, input);
    }
  }
  
  public void show(){ //Draws to screen
    noStroke(); //Might enable for visability.
    fill(col);
    if(alive){ //Only render if we are alive
      rect(position.x-size/2, position.y-size/2, size, size);
    }
    trail.showAll(); //But always show the trail.
  }
  
  //Used to check if the opponent has hit this player
  public boolean impactPlayer(Collider check){
    if(collides(check, this)){
      return true;
    }else{
      return false;
    }
  }
  
  //Used to check if the opponent has hit this trail
  public boolean impactTrail(Collider check){
   if(trail.overlap(check)){
      return true;
    }else{
      return false;
    } 
  }
  
  //Used to check if we have hit our own trail.
  public boolean impactOwnTrail(){
    if(trail.collideOwn(this)){
      return true;
    }else{
      return false;
    }
  }
  
  public int getTurnsMade(){
    return trail.trail.size();
  }
  
  //Kills the player and sets it up for respawn.
  void die(){
    alive = false;
    position = origin.copy();
  }
  
  //Implements collision logic.
  @Override
  public float getX(){
    return position.x-size/2;
  }
  
  @Override
  public float getY(){
    return position.y-size/2;
  }
  
  @Override
  public float getX2(){
    return position.x + size/2;
  }
  
  @Override
  public float getY2(){
    return position.y + size/2;
  }
  
  //Supposed to calculate how far the player has gone but doesn't work.
  public float getDistance(){
    float x = fAbs(position.x-origin.x);
    float y = fAbs(position.y-origin.y);
    double hsq = Math.pow(x, 2) + Math.pow(y, 2);
    return (float) Math.sqrt(hsq);
  }
  
  public float fAbs(float fin){
    if(fin < 0){
      return -fin;
    }else{
      return fin;
    }
  }
}