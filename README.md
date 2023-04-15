# Ping pong game TronLegacy version (Zig)

Rewritten my [`ping-pong-tron-legacy`](https://github.com/wisonye/ping-pong-tron-legacy) in `Zig`

**Make sure to enable the audio to feel the amazing sound effects:)**

https://user-images.githubusercontent.com/3477321/228088346-1d4179e2-a3f7-4826-9c7b-abb443675c45.mov

</br>

Free feel to change the default settings in [`src/config.zig`](src/config.zig).

Some settings you might care about when playing the game:

```c
//
// Player settings
//
pub const PLAYER_1_UP_KEY = rl.KEY_E;
pub const PLAYER_1_DOWN_KEY = rl.KEY_D;
pub const PLAYER_2_UP_KEY = rl.KEY_K;
pub const PLAYER_2_DOWN_KEY = rl.KEY_J;

//
// Ball UI settings
//
// How many hits before increasing the ball velocity
pub const BALL_UI_HITS_BEFORE_INCREASE_VELOCITY = 2;
// How many velocities increase to enable a fireball
pub const BALL_UI_VELOCITIES_INCREASE_TO_ENABLE_FIREBALL = 4;
// How many velocities increase to enable a lightning ball
pub const BALL_UI_VELOCITIES_INCREASE_TO_ENABLE_LIGHTNING_BALL = 6;
// Velocity acceleration
pub const BALL_UI_VELOCITY_ACCELERATION = 100;
```

</br>

## Before you run the game

- How to install `raylib` ?

    [MacOS](https://github.com/raysan5/raylib/wiki/Working-on-macOS)

    [Windows](https://github.com/raysan5/raylib/wiki/Working-on-Windows)

    [Linux](https://github.com/raysan5/raylib/wiki/Working-on-GNU-Linux)

    Or visit their [`WIKI`](https://github.com/raysan5/raylib/wiki)

</br>

## How to run

```bash
# Custom player name and use stand ball radius (`30.0f`)
PLAYER_1_NAME=Dad PLAYER_2_NAME=Mom zig build run

# Use bigger ball for beginner level
BALL_RADIUS=60.0 PLAYER_1_NAME='Ball game killer' PLAYER_2_NAME='Blow your mind' zig build run
```

</br>

If you don't provide the above env vars, it uses the default settings:

```bash
PLAYER_1_NAME=Player 1
PLAYER_2_NAME=Player 2
```

</br>



