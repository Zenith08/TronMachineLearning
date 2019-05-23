interface PlayerController{ //An interface lets me provide lots of options on how to deal with input without requiring much else.
  public int getDirection(Player owner);
}

//A human controller using the WASD keys.
public class HumanPlayerController implements PlayerController{
  @Override
  public int getDirection(Player owner){ //Just gets keyboard inputs and feeds it back.
      if(keyIsDown(87)){ //W
        return 3;
      }else if(keyIsDown(83)){ //A
        return 2;
      }else if(keyIsDown(65)){ //S
        return 1;
      }else if(keyIsDown(68)){ //D
        return 0;
      }
    return 5;
  }
}

//Another human controller using the Arrow keys.
public class HumanController2 implements PlayerController{
  @Override
  public int getDirection(Player owner){ //Gets keyboard inputs and feeds it back.
      if(keyIsDown(38)){ //Up
        return 3;
      }else if(keyIsDown(40)){ //Down
        return 2;
      }else if(keyIsDown(37)){ //Left
        return 1;
      }else if(keyIsDown(39)){ //Right
        return 0;
      }
    return 5;
  }
}

//An ai player controller uses an evolving genome to controll itself.
public class AIPlayerController implements PlayerController{
  public Genome brain; //The genome to use for logic.
  
  //Constructor needs a genome to work with.
  public AIPlayerController(Genome player){
    brain = player;  
  }

  //Gets the genome, feeds it inputs and then acts based on it. The player is used to get position information.
  @Override
  public int getDirection(Player owner){
    float[] inputs = new float[]{game.getDistanceUp(owner), game.getDistanceDown(owner), game.getDistanceLeft(owner), game.getDistanceRight(owner), owner.enemy.position.x, owner.enemy.position.y, owner.position.x, owner.position.y};
    float output = brain.evaluateNetwork(inputs)[0];

    //The mapping change from normal prevents the red ais from just targeting the wall.
    //Genomes normally return values from 0 <= out <= 1 so this maps it to the direction system 0 <= direction <= 3.
    if(output <= 0.25f){
      return 1;
    }else if(output > 0.25f && output <= 0.5f){
      return 3;
    }else if(output > 0.5f && output <= 0.75f){
      return 2;
    }else if(output > 0.75f && output <= 1.0f){
      return 0;
    }else{
      return 5; //If the genome returned a different resut just stop.
    }
  }
}

//An ai player controller uses an evolving genome to controll itself.
public class AISurvivalController implements PlayerController{
  public Genome brain; //The genome to use for logic.
  
  //Constructor needs a genome to work with.
  public AISurvivalController(Genome player){
    brain = player;  
  }

  //Gets the genome, feeds it inputs and then acts based on it. The player is used to get position information.
  @Override
  public int getDirection(Player owner){
    float[] inputs = new float[]{game.getDistanceUp(owner), game.getDistanceDown(owner), game.getDistanceLeft(owner), game.getDistanceRight(owner), owner.position.x, owner.position.y};
    float output = brain.evaluateNetwork(inputs)[0];

    //The mapping change from normal prevents the red ais from just targeting the wall.
    //Genomes normally return values from 0 <= out <= 1 so this maps it to the direction system 0 <= direction <= 3.
    if(output <= 0.25f){
      return 1;
    }else if(output > 0.25f && output <= 0.5f){
      return 3;
    }else if(output > 0.5f && output <= 0.75f){
      return 2;
    }else if(output > 0.75f && output <= 1.0f){
      return 0;
    }else{
      return 5; //If the genome returned a different resut just stop.
    }
  }
}