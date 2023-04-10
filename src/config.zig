const rl = @cImport({
    @cInclude("raylib.h");
});

// Player
pub const PLAYER_1_NAME = "Player 1";
pub const PLAYER_2_NAME = "Player 2";

//
// Color theme
//
pub const TRON_DARK = rl.Color{ .r = 0x23, .g = 0x21, .b = 0x1B, .a = 0xFF };
pub const TRON_LIGHT_BLUE = rl.Color{ .r = 0xAC, .g = 0xE6, .b = 0xFE, .a = 0xFF };
pub const TRON_BLUE = rl.Color{ .r = 0x6F, .g = 0xC3, .b = 0xDF, .a = 0xFF };
pub const TRON_YELLOW = rl.Color{ .r = 0xFF, .g = 0xE6, .b = 0x4D, .a = 0xFF };
pub const TRON_ORANGE = rl.Color{ .r = 0xFF, .g = 0x9F, .b = 0x1C, .a = 0xFF };
pub const TRON_RED = rl.Color{ .r = 0xF4, .g = 0x47, .b = 0x47, .a = 0xFF };

//
// Game misc settings
//
pub const GAME_FPS = 60;

//
// Game UI settings
//
pub const GAME_UI_INIT_SCREEN_WIDTH = 1300;
pub const GAME_UI_INIT_SCREEN_HEIGHT = 768;
pub const GAME_UI_PADDING = 10.0;
pub const GAME_UI_BACKGROUND_COLOR = TRON_DARK;
pub const GAME_UI_BORDER_COLOR = TRON_LIGHT_BLUE;
pub const GAME_UI_RACKET_COLOR = TRON_ORANGE;

//
// Scoreboard UI settings
//
pub const SCOREBOARD_UI_PADDING = GAME_UI_PADDING;
pub const SCOREBOARD_UI_BORDER_COLOR = TRON_LIGHT_BLUE;
pub const SCOREBOARD_UI_BORDER_HEIGHT_PERCENT = 10;
pub const SCOREBOARD_UI_BORDER_THICKNESS = 2.0;
pub const SCOREBOARD_UI_VS_FONT_SIZE = 30.0;
pub const SCOREBOARD_UI_VS_FONT_SPACE = 10.0;
pub const SCOREBOARD_UI_PLAYER_FONT_SPACE = 5.0;
pub const SCOREBOARD_UI_PLAYER_NAME_FONT_SIZE = 30.0;
pub const SCOREBOARD_UI_PLAYER_SCORE_FONT_SIZE = 50.0;
pub const SCOREBOARD_UI_SPACE_BETWEEN_NAME_AND_BORDER = 50.0;
pub const SCOREBOARD_UI_SPACE_BETWEEN_NAME_AND_SCORE = 50.0;

//
// Table UI settings
//
pub const TABLE_UI_MARGIN = GAME_UI_PADDING;
pub const TABLE_UI_BORDER_COLOR = TRON_LIGHT_BLUE;
pub const TABLE_UI_BORDER_THICKNESS = 2.0;
pub const TABLE_UI_FIRST_START_PROMPT_BORDER_COLOR = TRON_ORANGE;
pub const TABLE_UI_FIRST_START_PROMPT_TEXT_COLOR = TRON_ORANGE;
pub const TABLE_UI_FIRST_START_PROMPT_TEXT = "Press 'Space' to start the game";
pub const TABLE_UI_FIRST_START_PROMPT_FONT_SIZE = 40.0;
pub const TABLE_UI_FIRST_START_PROMPT_FONT_SPACE = 5.0;
pub const TABLE_UI_FIRST_START_PROMPT_CONTAINER_HORIZONTAL_PADDING = 50.0;
pub const TABLE_UI_FIRST_START_PROMPT_CONTAINER_VERTICAL_PADDING = 20.0;
pub const TABLE_UI_PLAYER_WINS_PROMPT_BORDER_COLOR = TRON_ORANGE;
pub const TABLE_UI_PLAYER_WINS_PROMPT_TEXT_COLOR = TRON_ORANGE;
pub const TABLE_UI_PLAYER_WINS_PROMPT_TEXT = " Wins!!!";
pub const TABLE_UI_PLAYER_WINS_PROMPT_FONT_SIZE = 60.0;
pub const TABLE_UI_PLAYER_WINS_PROMPT_FONT_SPACE = 5.0;
pub const TABLE_UI_PLAYER_WINS_PROMPT_CONTAINER_HORIZONTAL_PADDING = 60.0;
pub const TABLE_UI_PLAYER_WINS_PROMPT_CONTAINER_VERTICAL_PADDING = 50.0;
pub const TABLE_UI_PLAYER_WINS_RESTART_TEXT_COLOR = TRON_ORANGE;
pub const TABLE_UI_PLAYER_WINS_RESTART_TEXT = "Press 'Space' to start the game";
pub const TABLE_UI_PLAYER_WINS_RESTART_FONT_SIZE = 20.0;
pub const TABLE_UI_PLAYER_WINS_RESTART_FONT_SPACE = 2.5;
pub const TABLE_UI_PLAYER_WINS_RESTART_CONTAINER_HORIZONTAL_PADDING = 30.0;
pub const TABLE_UI_PLAYER_WINS_RESTART_CONTAINER_VERTICAL_PADDING = 10.0;

//
// Ball UI settings
//
pub const BALL_UI_BALL_COLOR = TRON_LIGHT_BLUE;
pub const BALL_UI_FIREBALL_COLOR = TRON_ORANGE;
pub const BALL_UI_LIGHTNING_BALL_COLOR = TRON_YELLOW;
pub const BALL_UI_LIGHTNING_BALL = "resources/lightning_ball.png";
pub const BALL_UI_BALL_RADIUS = 30.0; // 20.0f // 60.f
pub const BALL_UI_LIGHTING_BALL_RADIUS = 10.0; // 20.0f // 60.f
pub const BALL_UI_BALL_VELOCITY_X = 500.0;
pub const BALL_UI_BALL_VELOCITY_Y = 500.0;
// How many hits before increasing the ball velocity
pub const BALL_UI_HITS_BEFORE_INCREASE_VELOCITY = 2;
// How many velocities increase to enable a fireball
pub const BALL_UI_VELOCITIES_INCREASE_TO_ENABLE_FIREBALL = 4;
// How many velocities increase to enable a lightning ball
pub const BALL_UI_VELOCITIES_INCREASE_TO_ENABLE_LIGHTNING_BALL = 6;
// Velocity acceleration
pub const BALL_UI_VELOCITY_ACCELERATION = 100;
pub const BALL_UI_LIGHTING_TAIL_PARTICLE_COUNT = 50;
// Init `alpha` value, it affects how light the particle at the beginning
pub const BALL_UI_LIGHTING_TAIL_PRATICLE_INIT_ALPHA = 0.8;
// It affects how big the particle will be: how many percentage of the ball
// size: 0.0 ~ 1.0 (0 ~ 100%)
pub const BALL_UI_LIGHTING_TAIL_PRATICLE_SIZE = 0.5;
pub const BALL_UI_LIGHTING_TAIL_PRATICLE_SIZE_FOR_LIGHTNING_BALL = 0.4;

//
// Racket UI settings
//
pub const RACKET_UI_MAX_RACKETS_PER_PLAYER = 5;
pub const RACKET_UI_MARGIN = 20.0;
pub const RACKET_UI_WIDTH = 40.0;
pub const RACKET_UI_HEIGHT = 200.0;
pub const RACKET_UI_COLOR = TRON_LIGHT_BLUE;
pub const RACKET_UI_VELOCITY = 600.0;
pub const RACKET_UI_DRAW_DEBUG_BOUNDARY = false;
// const RACKET_UI_LASER_RACKET_TEXTURE "resources/green_laser.png"
pub const RACKET_UI_LASER_RACKET_TEXTURE = "resources/blue_laser.png";

//
// Player settings
//
pub const PLAYER_1_UP_KEY = rl.KEY_E;
pub const PLAYER_1_DOWN_KEY = rl.KEY_D;
pub const PLAYER_2_UP_KEY = rl.KEY_K;
pub const PLAYER_2_DOWN_KEY = rl.KEY_J;

//
// Sound effects
//
pub const ENABLE_FIREBALL_SOUND_EFFECT = "resources/enable_fireball.wav";
pub const ENABLE_LIGHTNING_BALL_SOUND_EFFECT = "resources/enable_lightning_ball.wav";
pub const BALL_HIT_RACKET_SOUND_EFFECT = "resources/hit_racket.wav";
pub const YOU_WIN_SOUND_EFFECT_1 = "resources/you_win.wav";
pub const YOU_WIN_SOUND_EFFECT_2 = "resources/you_win_2.wav";
