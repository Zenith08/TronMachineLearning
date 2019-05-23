//Didn't end up using it and haven't deleted it.
//Using this as a test for the genetic algorithm

Pool survivalPool;
Genome topSurvivalGenome;
public int survivalGen = 0;
public int targetSurvival = 0;
ArrayList<SurvivalGame> survivingGames;
int survivalState = genStart;
Button stopSurvival = new Button(new PVector(100, 50), 150, 50, "Stop Training");
boolean geneticsInit = false;

public void initGenetics(){
  if(!geneticsInit){
    survivalPool = new Pool();
    survivalPool.initializePool();
    topSurvivalGenome = new Genome();
    survivingGames = new ArrayList<SurvivalGame>();
  }
  NEAT_Config.setINPUTS(6);
  geneticsInit = true;
}

public void trainSurvival(){
  fill(255);
  text("Generation: " + survivalGen + " target " + targetSurvival, 100, 25);
  
  stopSurvival.isMouseOver(mouseX, mouseY);
  stopSurvival.show();
  
  if(survivalState == genStart){ //If games have not been initialized yet.
    ArrayList<Genome> allGenomes = survivalPool.getAllGenomes(); //Init all games.
    survivingGames.clear();
    for(int i = 0; i+1 < allGenomes.size(); i++){ //Count each genome
      survivingGames.add(new SurvivalGame(new AISurvivalController(allGenomes.get(i)))); //Add genomes to a game
    }
    System.out.println("Generation " + survivalGen + " started"); //Tell us where we are.
    survivalState = genRun; //We are done setup so begin running.
    genTime = 0;
  }else if(survivalState == genRun){ //If we are running
    //System.out.println("Red wins are " + redWins + " blue wins " + blueWins);
    genTime++; //Increment time
    boolean gamesInProgress = false; //Stores if any games are happening
    for(SurvivalGame training : survivingGames){ //Update each game
      if(training.currentState == 1){ //If the game is playing
        gamesInProgress = true; //At least one game is running
        training.update(); //Doesn't run logic on ended games so that it improves performance.
        training.show();
      }else if(training.currentState == 2 && training.scored == false){ //If a game is done then apply fitness logic to it.
        AISurvivalController user = (AISurvivalController)training.user.controller; //Get the genome controllers
        //System.out.println("Setting fitness based on time: " + genTime + " turns: " + training.user.getTurnsMade() + " = " + genTime*training.user.getTurnsMade());
        user.brain.setFitness(genTime*training.user.getTurnsMade());
        
        training.scored = true;
      }
    }
    
    if(!gamesInProgress){ //If all games are done
      System.out.println("Ending current generation."); //End this generation and start the next.
      survivalState = genFinish;
    }else if(genTime > TIME_OUT){ //Otherwise if the current games have timed out
      System.out.println("Generation time out.");
      for(SurvivalGame training : survivingGames){ //Any games in progress get updated
        if(training.currentState == 1){
          AISurvivalController user = (AISurvivalController)training.user.controller;
          user.brain.setFitness(0); //Set fitness to 0 so they do not reproduce.
          commonLosses++;
        }
      }
      survivalState = genFinish; //Then end this generation.
    }
  }else if(survivalState == genFinish){ //If the generation has ended.
    survivalPool.evaluateFitness(new notMuch()); //This is just to make the api work and has no functional benefit.
    System.out.println("Generation " + survivalGen + " top fitness: " + survivalPool.getTopGenome().getPoints()); //Tell us our fitness.
    topSurvivalGenome = survivalPool.getTopGenome(); //Update the top genome
    survivalPool.breedNewGeneration(); //Breed new gen
    survivalGen++; //Increment gen
    survivalState = genStart;
    if(survivalGen > targetSurvival){ //If we have made it to our target number of generations
      gameMode = menue; //Go back to the menue.
    }
  }
}

//The player must survive only against itself for as long as possible. This should lead to better evolution
public class SurvivalGame{
  final int gameStart = 0; //Gamestates for easy tracking.
  final int gameRun = 1;
  final int winUser = 2;
  int currentState = gameStart; //Our current state.
  //The walls around the edge of the field.
  ArrayList<Wall> walls = new ArrayList<Wall>();
  
  //Particles to play when someone dies.
  Player user; //Players in the game currently
  
  public boolean scored = false; //Used for training to see if the game has already been evaluated.
  
  public int gameTime = 0; //How long the player has survived.
  
  //Create a game and set who is controlling each player.
  public SurvivalGame(PlayerController p1){
    //Creates players and sets up other info.
    user = new Player(new PVector(800, 450), p1, color(0, 255, 255));
    //We are running
    currentState = gameRun;
    //Define walls
    walls.add(new Wall(new PVector(0, 0), 1600, 5));
    walls.add(new Wall(new PVector(0, 0), 5, 900));
    walls.add(new Wall(new PVector(1600, 0), 5, 900));
    walls.add(new Wall(new PVector(0, 900), 1600, 5));
  }
  
  public void update(){ //Updates logic
    if(currentState == gameRun){ //If the game is still running
      user.update(); //Move and update players
      gameTime++;
      //System.out.println("Position Up: " + getDistanceUp(user) + " down: " + getDistanceDown(user) + " left: " + getDistanceLeft(user) + " right: " + getDistanceRight(user));
    
      //Kill the player if they die.
      if(user.impactOwnTrail() || collideWalls(user)){
        user.die();
        currentState = winUser;
      }
    }
  }
  
  //Resets the game so the player can play again.
  public void playAgain(){
    currentState = gameRun;
  }
  
  //Draws the game to the screen
  public void show(){
    user.show(); //by drawing the players to the screen.
  }
  //Checks if the player has collided with a wall
  boolean collideWalls(Collider check){
    for(Wall wall : walls){ //For each wall
      if(collides(wall, check)){ //See if it collides
        return true; //If it has say so
      }
    }
    return false; //Otherwise don't.
  }
  
  //This uses ray tracing to give the ai systems "sight" on their distance from colliders.
  public float getDistanceUp(Player player){
    Wall test = new Wall(new PVector(player.position.x, player.position.y-21), 20, 1); //Something to move which can check collisions
    if(player.position.y-21 <= 0){
      return 0;
    }
    float distance = 0; //How far we've gone so far
    while(distance < 500){ //Only go to 500 otherwise performance suffers
      if(collideWalls(test) || user.impactTrail(test)){ //Each of these mean a loss
        return distance; //Return how far until we die
      }
      
      distance++; //Otherwise increment and move wall
      test.position.y-=1;
    }
    return distance;
  }
  //Repeated in all 4 directions.
  public float getDistanceDown(Player player){
    Wall test = new Wall(new PVector(player.position.x, player.position.y+21), 20, 1);
    if(player.position.y+21 >= 900){
      return 0;
    }
    float distance = 0;
    while(distance < 500){
      if(collideWalls(test) || user.impactTrail(test)){
        return distance;
      }
      
      distance++;
      test.position.y+=1;
    }
    return distance;
  }
  
  public float getDistanceLeft(Player player){
    Wall test = new Wall(new PVector(player.position.x-21, player.position.y), 1, 20);
    if(player.position.x-21 <= 0){
      return 0;
    }
    float distance = 0;
    while(distance < 500){
      if(collideWalls(test) || user.impactTrail(test)){
        return distance;
      }
      
      distance++;
      test.position.x-=1;
    }
    return distance;
  }
  
  public float getDistanceRight(Player player){
    Wall test = new Wall(new PVector(player.position.x+21, player.position.y), 1, 20);
    if(player.position.x+21 >= 1600){
      return 0;
    }
    float distance = 0;
    while(distance < 500){
      if(collideWalls(test) || user.impactTrail(test)){
        return distance;
      }
      
      distance++;
      test.position.x+=1;
    }
    return distance;
  }
}