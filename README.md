# Tron 2D Light Cycles
#### Featuring Neuroevolution
![Banner](/docs/tron-banner.png)
After hearing about the possabilities of machine learning and seeing examples of the applications of this technology, I was looking for a way to use the techology myself. The solution was to make a simple 2D game, based on the Tron movies, where a player moves around an arena leaving a lethal trail behind them. Then, using a slightly modified form of the [Evoneat Library](https://github.com/nistath/evoneat), I was able to connect the games AI controller to the neural networks.
### Training
![Training](/docs/tron-training.png)
The *NEAT* algorithm attempts to simulate evolution, so a system was created where two AIs would play each other at random. They would be scored on how long they lasted, complexity of maneuvers, and whether or not the AI won. In principal, this made sense. In practice however, because each AI only played one other, AIs would lose points if their random opponent lost too early into the game. After 1500 generations of evoltion, some collision avoidance began to develop, but only in some directions.
### Survival Mode
![Survival](/docs/tron-survival.png)
In an attempt to resolve the issues of two AIs impacting each other's scores, a survival mode was created where each AI only had to last as long as it could without leaving the bounds of the screan, or crossing their own path. This had better results but ultimatly, this problem is not easily modeled with a neural network and they still struggled.
