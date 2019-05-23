// A class to describe a group of Particles
// An ArrayList is used to manage the list of Particles 
class ParticleSystem {
  ArrayList<Particle> particles; //Each individual particle
  PVector origin; //The starting position of all particles
  PVector velocity; //The speed and direction the particles are moving.
  color player; //The colour of the particles

  //Setup everything
  ParticleSystem(PVector position, PVector speed, int numParticles, color col) {
    origin = position.copy();
    particles = new ArrayList<Particle>();
    velocity = speed.copy();
    player = col;
    //Create as many particles as requested
    for(int i = 0; i < numParticles; i++){
      addParticle();
    }
  }

  //Creates a single particle for the game.
  void addParticle() {
    particles.add(new Particle(origin, velocity, player));
  }

  //Updates moving the particle along and renders it.
  void run() {
    for (int i = particles.size()-1; i >= 0; i--) {
      Particle p = particles.get(i);
      p.run();
      if (p.isDead()) { //If it has outlived its usefulness.
        particles.remove(i);
      }
    }
  }
}


// A simple Particle class
class Particle { //Simplified from Processing Tutorial
  PVector position;
  PVector velocity;
  float lifespan;
  color player;

  //Constructor where l is the location of the particle and speed is the rough speed of where it's going.
  Particle(PVector l, PVector speed, color col) {
    //Applying the randoms makes the particles spread out.
    velocity = new PVector(speed.x + random(-1.5, 1.5), speed.y + random(-1.5, 1.5));
    position = l.copy();
    lifespan = 64.0; //Last 64 frames.
    player = col;
  }

  //Run logic!
  void run() {
    update();
    display();
  }

  // Method to update position
  void update() {
    position.add(velocity);
    lifespan -= 1.0;
  }

  // Method to display
  void display() {
    //Using lifespan means the particles are always a little transparent.
    stroke(player, lifespan);
    fill(player, lifespan);
    rect(position.x, position.y, 8, 8);
  }

  // Is the particle still useful?
  boolean isDead() {
    if (lifespan < 0.0) { //If we have lived the entire lifespan
      return true; //We are dead.
    } else {
      return false;
    }
  }
}