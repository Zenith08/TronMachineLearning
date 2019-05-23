import com.evo.NEAT.*;
import com.evo.NEAT.com.evo.NEAT.config.*;
import examples.*;

//The game used for playing against a human or an ai. Not for training. This constructor is not actually used and just prevents null errors.
GamePlay game = new GamePlay(new AIPlayerController(new Genome()), new HumanController2());

//The number of generations to train each time the button is clicked.
final int TRAIN_GENERATIONS = 250;
int targetGenerations = 0; //How many generations for the training to go until on the next target.

//How long before the generation times out. 3000 frames = 50 seconds.
final int TIME_OUT = 3000;

//Allows game modes
final int menue = 0; //Choosing another game mode
final int trainAI = 1; //Runs the AI through several generations to prep it.
final int playAI = 2; //Allows the player to go against the best AI
final int playPlayer = 3; //Allows a player to go against another player.
final int aiSurvival = 4; //A testing mode for the AI surviving against itself.
int gameMode = 0; //Current Game Mode.

//EvoNeat handling
Pool pool; //The pool of genomes.
Genome topGenome; //The current best genome.
final int genStart = 0; //Indicates a generation has started and needs to have games created
final int genRun = 1; //Indicates games are created and are running
final int genFinish = 2; //Indicates all games are done and we should set up for the next gen.
int genState = genStart; //Current state
int generation = 0; //Current gen starts at 0.
//A list of all games the AIs will train in.
public ArrayList<GamePlay> trainingGames = new ArrayList<GamePlay>();

//How many times each colour has won in training this generation.
int redWins = 0;
int blueWins = 0;
int commonLosses = 0;

//Because we need to check if a key is being pressed at any time, this lets us store that information using only the pressed and released events.  
HashMap<Integer, Boolean> keypress = new HashMap<Integer, Boolean>();

//Buttons to be used. Must be global because the mousePress method must be able to access them
//Menue buttons allow choosing the game modes.
Button playUsr = new Button(new PVector(1600/2-75, 350), 150, 50, "Play Live");
Button playTopAI = new Button(new PVector(1600/2-75, 425), 150, 50, "Play AI");
Button aiTraining = new Button(new PVector(1600/2-75, 500), 150, 50, "Train AI");
Button survival = new Button(new PVector(1600/2-75, 575), 150, 50, "AI Survival");
//Buttons to show at the end of the game so you can play again.
Button playAgain = new Button(new PVector(1600/2-75, 750), 150, 50, "Play Again");
Button back = new Button(new PVector(1600/2-75, 825), 150, 50, "Go Back");
//Button in training to stop training after the current generation ends.
Button stopTraining = new Button(new PVector(100, 50), 150, 50, "Stop Training");

//Sets up the basics of the program.
void setup(){
  size(1600, 900, FX2D); //FX2D = Better performance
  rectMode(CORNER); //For consistency
  ellipseMode(CORNER);
  frameRate(60);
  NEAT_Config.setINPUTS(8); //Indicates that each neural network will take 8 inputs for Tron by default.
  
  pool = new Pool(); //Initalize EvoNeat so it will work
  pool.initializePool();
  topGenome = new Genome(); //topGenome is the one the player will go against if they choose to play against an ai.
}
//The length of time this generation has run for.
//Used to time out the generation
float genTime = 0.0F;

void draw(){
  background(0); //Default to black screen.
  if(gameMode == 0){
    //Draw menue.
    //Draws the title to the screen. Duplicate text creates a cool shadow effect.
    fill(0, 0, 255);
    textSize(124);
    text("TRON", 1600/2-175, 200);
    fill(0);
    textSize(120);
    text("TRON", 1600/2-175, 200);
    //Update each of the buttons and then draw them to the screen.
    playUsr.isMouseOver(mouseX, mouseY);
    playUsr.show();
    playTopAI.isMouseOver(mouseX, mouseY);
    playTopAI.show();
    aiTraining.isMouseOver(mouseX, mouseY);
    aiTraining.show();
    survival.isMouseOver(mouseX, mouseY);
    survival.show();
    //End menue drawing.
  }else if(gameMode == 1){ //Runs the ai training system for a specified number of generations
    trainAI();
  }else if(gameMode == 2 || gameMode == 3){ //Whether you're playing an ai or a human this just updates the game.
    playGame();
  }else if(gameMode == 4){
    trainSurvival();
  }
}

void mousePressed() { //Mouse pressed event to handle buttons.
  if (playUsr.isMouseOver(mouseX, mouseY)) { //If the mouse is pressed
    game = new GamePlay(new HumanPlayerController(), new HumanController2()); //Set up for a game and run it.
    gameMode = playPlayer;
  }else if (playTopAI.isMouseOver(mouseX, mouseY)) { //If the player chose ai
    System.out.println("Playing AI with fitness " + topGenome.getPoints()); //Tell us what ai they are playing against
    game = new GamePlay(new HumanPlayerController(), new AIPlayerController(topGenome)); //And then run the game.
    gameMode = playAI;
  }else if(aiTraining.isMouseOver(mouseX, mouseY)){
    targetGenerations += TRAIN_GENERATIONS; //We need to train for TRAIN_GENERATIONS more generations.
    NEAT_Config.setINPUTS(8); //Indicates that each neural network will take 6 inputs.
    gameMode = trainAI; //Then run it.
  }else if(playAgain.mouseOver){
    game.playAgain(); //Allows playing again at the end of the game.
    playAgain.mouseOver = false;
  }else if(back.mouseOver){
    gameMode = menue; //Allows returning to the main menue after a game.
    back.mouseOver = false;
  }else if(stopTraining.mouseOver){
    targetGenerations = generation; //Ends the training at the current generation and then returns to the menue.
    stopTraining.mouseOver = false;
  }else if(survival.isMouseOver(mouseX, mouseY)){
    initGenetics();
    targetSurvival += TRAIN_GENERATIONS;
    gameMode = aiSurvival;
  }else if(stopSurvival.mouseOver){
    targetSurvival = survivalGen;
    stopSurvival.mouseOver = false;
  }
}

//For 1v1 games just updates and draws the game.
void playGame(){
  game.update();
  game.show();
}

//Handles ai training.
void trainAI(){
  //Check if the button to stop training has been pressed
  stopTraining.isMouseOver(mouseX, mouseY);
  stopTraining.show();
  
  fill(255);
  text("Generation: " + generation + " target " + targetGenerations, 100, 25);
  
  if(genState == genStart){ //If games have not been initialized yet.
    ArrayList<Genome> allGenomes = pool.getAllGenomes(); //Init all games.
    trainingGames.clear();
    for(int i = 0; i+1 < allGenomes.size(); i+=2){ //Count by 2 and
      trainingGames.add(new GamePlay(new AIPlayerController(allGenomes.get(i)), new AIPlayerController(allGenomes.get(i+1)))); //Add genomes to a game
    }
    System.out.println("Generation " + generation + " started"); //Tell us where we are.
    genTime = 0; //Set time to 0 so we can keep track how long this takes.
    genState = genRun; //We are done setup so begin running.
    redWins = 0;
    blueWins = 0;
    commonLosses = 0;
  }else if(genState == genRun){ //If we are running
    //System.out.println("Red wins are " + redWins + " blue wins " + blueWins);
    genTime++; //Increment time
    boolean gamesInProgress = false; //Stores if any games are happening
    for(GamePlay training : trainingGames){ //Update each game
      if(training.currentState == 1){ //If the game is playing
        gamesInProgress = true; //At least one game is running
        training.update(); //Doesn't run logic on ended games so that it improves performance.
        training.show();
      }else if((training.currentState == 2 || training.currentState == 3 || training.currentState == 4) && training.scored == false){ //If a game is done then apply fitness logic to it.
        AIPlayerController user = (AIPlayerController)training.user.controller; //Get the genome controllers
        AIPlayerController opp = (AIPlayerController)training.opponent.controller;
        if(training.currentState == 2){ //If the user won
          user.brain.setFitness((100000-genTime)*training.user.getTurnsMade()*(training.user.getDistance()/2)); //Set fitness accordingly
          opp.brain.setFitness(genTime/2*training.opponent.getTurnsMade()*(training.opponent.getDistance()/2));
          blueWins++;
        }else if(training.currentState == 3){ //The opponent won.
          opp.brain.setFitness((100000-genTime)*training.opponent.getTurnsMade()*(training.opponent.getDistance()/2));
          user.brain.setFitness(genTime/2*training.user.getTurnsMade()*(training.user.getDistance()/2));
          redWins++;
        }else if(training.currentState == 4){ //Both players lost
          opp.brain.setFitness(genTime/2*training.opponent.getTurnsMade()*(training.opponent.getDistance()/2)); //Functionally a loss
          user.brain.setFitness(genTime/2*training.user.getTurnsMade()*(training.user.getDistance()/2));
          commonLosses++;
        }
        
        training.scored = true;
      }
    }
    
    if(!gamesInProgress){ //If all games are done
      System.out.println("Ending current generation."); //End this generation and start the next.
      genState = genFinish;
    }else if(genTime > TIME_OUT){ //Otherwise if the current games have timed out
      System.out.println("Generation time out.");
      for(GamePlay training : trainingGames){ //Any games in progress get updated
        if(training.currentState == 1){
          AIPlayerController user = (AIPlayerController)training.user.controller;
          AIPlayerController opp = (AIPlayerController)training.opponent.controller;
          user.brain.setFitness(0); //Set fitness to 0 so they do not reproduce.
          opp.brain.setFitness(0);
          commonLosses++;
        }
      }
      genState = genFinish; //Then end this generation.
    }
  }else if(genState == genFinish){ //If the generation has ended.
    pool.evaluateFitness(new notMuch()); //This is just to make the api work and has no functional benefit.
    System.out.println("Generation " + generation + " top fitness: " + pool.getTopGenome().getPoints()); //Tell us our fitness.
    System.out.println("Generation statistics: Red Wins " + redWins + " Blue Wins: " + blueWins + " No Win Games: " + commonLosses);
    topGenome = pool.getTopGenome(); //Update the top genome
    pool.breedNewGeneration(); //Breed new gen
    generation++; //Increment gen
    genState = genStart;
    if(generation > targetGenerations){ //If we have made it to our target number of generations
      gameMode = menue; //Go back to the menue.
    }
  }
}

//Handles keyboard input smoothly
//Stores the value of a key to be pressed so we can check it later.
void keyPressed() {
  //System.out.println("Key Pressed " + keyCode);
  keypress.put(Integer.valueOf(keyCode), Boolean.valueOf(true));
}

//Indicates a key has been released so it does not show up later.
void keyReleased(){
  keypress.put(Integer.valueOf(keyCode), Boolean.valueOf(false));  
}

//Allows checking for keypresses to be asynchronous rither than recieving the event thread in keyPressed/keyReleased.
boolean keyIsDown(int checkKey){
  if(keypress.containsKey(Integer.valueOf(checkKey))){ //Check if the key has been pressed. Otherwise we might get a nullPointerException.
    return keypress.get(Integer.valueOf(checkKey));
  }else{
    return false;
  }
}

//Game state runs a game between two player controllers.
public class GamePlay{
  final int gameStart = 0; //Gamestates for easy tracking.
  final int gameRun = 1;
  final int winUser = 2;
  final int winOpp = 3;
  final int loseBoth = 4;
  int currentState = gameStart; //Our current state.
  //The walls around the edge of the field.
  ArrayList<Wall> walls = new ArrayList<Wall>();
  
  //Particles to play when someone dies.
  ParticleSystem diedParticles = new ParticleSystem(new PVector(0, 0), new PVector(0, 0), 0, color(0));
  Player user; //Players in the game currently
  Player opponent;
  
  public boolean scored = false; //Used for training to see if the game has already been evaluated.
  
  //Create a game and set who is controlling each player.
  public GamePlay(PlayerController p1, PlayerController p2){
    //Creates players and sets up other info.
    user = new Player(new PVector(100, 450), p1, color(0, 0, 255));
    opponent = new Player(new PVector(1500, 450), p2, color(255, 0, 0));
    //We are running
    currentState = gameRun;
    //Define walls
    walls.add(new Wall(new PVector(0, 0), 1600, 5));
    walls.add(new Wall(new PVector(0, 0), 5, 900));
    walls.add(new Wall(new PVector(1600, 0), 5, 900));
    walls.add(new Wall(new PVector(0, 900), 1600, 5));
    //Finish variables.
    user.enemy = opponent;
    opponent.enemy = user;
  }
  
  public void update(){ //Updates logic
    if(currentState == gameRun){ //If the game is still running
      user.update(); //Move and update players
      opponent.update();
      
      //System.out.println("Position Up: " + getDistanceUp(user) + " down: " + getDistanceDown(user) + " left: " + getDistanceLeft(user) + " right: " + getDistanceRight(user));
    
      //Prevent head on collisions
      if(user.impactPlayer(opponent)){
        diedParticles = new ParticleSystem(user.position.copy(), new PVector(0, 0), 50, color(255, 255, 255));
        opponent.die();
        user.die();
        currentState = loseBoth;
      }else if(user.impactTrail(opponent) || collideWalls(opponent) || opponent.impactOwnTrail()){  //Check each of the losing conditions. Hitting a wall, hitting your opponents trail, hitting your own trail.
        diedParticles = new ParticleSystem(opponent.position.copy(), opponent.velocity, 50, opponent.col);
        opponent.die();
        currentState = winUser;
      }else if(opponent.impactTrail(user) || collideWalls(user) || user.impactOwnTrail()){ //Same but for the other player.
        diedParticles = new ParticleSystem(user.position.copy(), user.velocity, 50, user.col);
        user.die();
        currentState = winOpp;
      }
      
    //Checks if the game has ended
    }else if((gameMode == playPlayer || gameMode == playAI) && (currentState == winOpp || currentState == winUser || currentState == loseBoth)){
      //Update and show the end game buttons.
      playAgain.isMouseOver(mouseX, mouseY);
      playAgain.show();
      back.isMouseOver(mouseX, mouseY);
      back.show();
    }
    //Runs the death particles always so they don't get removed unintentionally.
    diedParticles.run();
  }
  //Resets the game so the player can play again.
  public void playAgain(){
    //Reset the player
    user = new Player(new PVector(100, 450), new HumanPlayerController(), color(0, 0, 255));
    if(gameMode == playAI){ //If the opponent is an ai set it to be an ai
      opponent = new Player(new PVector(1500, 450), new AIPlayerController(topGenome), color(255, 0, 0));
    }else{ //Otherwise set it as a human controller.
      opponent = new Player(new PVector(1500, 450), new HumanController2(), color(255, 0, 0));
    }
    //Finish arguments in reset.
    user.enemy = opponent;
    opponent.enemy = user;
    currentState = gameRun;
  }
  
  //Draws the game to the screen
  public void show(){
    user.show(); //by drawing the players to the screen.
    opponent.show();
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
      if(collideWalls(test) || user.impactTrail(test) || opponent.impactTrail(test)){ //Each of these mean a loss
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
      if(collideWalls(test) || user.impactTrail(test) || opponent.impactTrail(test)){
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
      if(collideWalls(test) || user.impactTrail(test) || opponent.impactTrail(test)){
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
      if(collideWalls(test) || user.impactTrail(test) || opponent.impactTrail(test)){
        return distance;
      }
      
      distance++;
      test.position.x+=1;
    }
    return distance;
  }
}

public class notMuch implements Environment{
  public void evaluateFitness(ArrayList<Genome> population){
    //Nope
  }
}