const std = @import("std");
const config = @import("config.zig");
const player = @import("player.zig");
const print = std.debug.print;
const ball = @import("ball.zig");
const rl = @cImport({
    @cInclude("raylib.h");
});

///
///
///
const GameState = enum(u8) {
    GS_UNINIT = 0x01,
    GS_INIT = 0x02,
    GS_BEFORE_START = 0x03,
    GS_PLAYING = 0x04,
    GS_PLAYER_WINS = 0x05,
    GS_PAUSE = 0x06,
};

///
///
///
const MiscSettings = struct {
    game_fps: usize,
};

///
///
///
pub const Game = struct {
    player1: player.Player,
    player2: player.Player,
    // scoreboard: Scoreboard,
    table_rect_before_screen_changed: rl.Rectangle,
    table_rect: rl.Rectangle,
    ball: ball.Ball,
    state: GameState,
    is_fullscreen: bool,
    is_player1_wins_last_round: bool,
    you_win_sound_effect: ?rl.Sound,

    ///
    ///
    ///
    pub fn create_game() Game {
        // var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
        // defer arena.deinit();
        //
        // const env_map = try arena.allocator().create(std.process.EnvMap);
        // env_map.* = try std.process.getEnvMap(arena.allocator());
        // defer env_map.deinit(); // technically unnecessary when using ArenaAllocator

        // const name = env_map.get("HELLO") orelse "world";
        const ball_radius = config.BALL_UI_BALL_RADIUS;
        return Game{
            .player1 = player.Player{
                .type = player.PlayerType.PT_LEFT,
                .name = config.PLAYER_1_NAME,
                .score = 0,
                // .rackets = {0},
                .default_racket = player.Racket{
                    .color = config.RACKET_UI_COLOR,
                    .rect = rl.Rectangle{
                        .x = 0,
                        .y = 0,
                        .width = 0,
                        .height = 0,
                    },
                    .rect_texture = null,
                },
            },
            .player2 = player.Player{
                .type = player.PlayerType.PT_RIGHT,
                .name = config.PLAYER_2_NAME,
                .score = 0,
                // .rackets = {0},
                .default_racket = player.Racket{
                    .color = config.RACKET_UI_COLOR,
                    .rect = rl.Rectangle{
                        .x = 0,
                        .y = 0,
                        .width = 0,
                        .height = 0,
                    },
                    .rect_texture = null,
                },
            },
            // scoreboard: Scoreboard,
            .table_rect_before_screen_changed = rl.Rectangle{
                .x = 0,
                .y = 0,
                .width = 0,
                .height = 0,
            },
            .table_rect = rl.Rectangle{
                .x = 0,
                .y = 0,
                .width = 0,
                .height = 0,
            },
            .ball = ball.Ball{
                .center = rl.Vector2{ .x = -1.0, .y = -1.0 },
                .radius = ball_radius,
                .velocity_x = config.BALL_UI_BALL_VELOCITY_X,
                .velocity_y = config.BALL_UI_BALL_VELOCITY_Y,
                .lightning_ball_rotation_angle = 0.0,
                .current_hits = 0,
                .current_velocities_increase = 0,
                .enabled_fireball = false,
                .enabled_lightning_ball = false,
                .lightning_ball = null,
                .enable_fireball_sound_effect = null,
                .enable_lightning_ball_sound_effect = null,
                .hit_racket_sound_effect = null,
                .lighting_tail = null,

                //
                // `alpha_mask` is a black and white color image that uses for
                // blending operations, it HAS TO be created after the
                // `InitWindow` call. That means it creates inside
                // `Game_init()`, not here!!!
                //
                .alpha_mask = null,
            },
            .state = GameState.GS_UNINIT,
            .is_fullscreen = false,
            .is_player1_wins_last_round = false,
            .you_win_sound_effect = null,
        };
    }

    ///
    ///
    ///
    fn toggle_fullscreen(self: *const Game) void {
        if (!self.is_fullscreen) {
            const monitor = rl.GetCurrentMonitor();
            rl.SetWindowSize(
                rl.GetMonitorWidth(monitor),
                rl.GetMonitorHeight(monitor),
            );
            rl.ToggleFullscreen();
            self.is_fullscreen = true;
        } else {
            rl.ToggleFullscreen();
            rl.SetWindowSize(
                config.GAME_UI_INIT_SCREEN_WIDTH,
                config.GAME_UI_INIT_SCREEN_HEIGHT,
            );
            self.is_fullscreen = false;
        }
    }

    ///
    ///
    ///
    pub fn init(self: *Game) void {
        rl.InitWindow(
            config.GAME_UI_INIT_SCREEN_WIDTH,
            config.GAME_UI_INIT_SCREEN_HEIGHT,
            "Ping pong tron legacy",
        );

        // Window states: No frame and buttons
        rl.SetWindowState(rl.FLAG_WINDOW_UNDECORATED);

        // Set our game FPS (frames-per-second)
        rl.SetTargetFPS(config.GAME_FPS);

        // Initialize audio device
        rl.InitAudioDevice();

        //
        // Load sound effects
        //
        // self.you_win_sound_effect = LoadSound(YOU_WIN_SOUND_EFFECT_1);
        self.you_win_sound_effect = rl.LoadSound(config.YOU_WIN_SOUND_EFFECT_2);
        self.ball.enable_fireball_sound_effect = rl.LoadSound(config.ENABLE_FIREBALL_SOUND_EFFECT);
        self.ball.enable_lightning_ball_sound_effect = rl.LoadSound(config.ENABLE_LIGHTNING_BALL_SOUND_EFFECT);
        self.ball.hit_racket_sound_effect = rl.LoadSound(config.BALL_HIT_RACKET_SOUND_EFFECT);

        // Set tracing log level
        rl.SetTraceLogLevel(rl.LOG_DEBUG);

        // self.print_debug_info();

        // Hide the cursor
        rl.HideCursor();

        // Set to `GS_BEFORE_START`
        self.state = GameState.GS_BEFORE_START;

        //
        // As I want to draw the ball with gradient visual effects (like a halo)
        // and a lighting trail that follows the moving ball, that's why do I need
        // to create an alpha mask image (with black and white color) as the
        // blending mask.
        //
        // - The `density` affects the halo border length!!!
        //
        // - The size of the alpha mask must be the same size of the ball
        //
        // - The lighting tail is just a bunch of particle instances, each particle
        //   has the init alpha value and size, and the size should be smaller than
        //   the ball to make it looks nicer.
        //
        const density = 0.5;
        const ball_alpha_mask_image = rl.GenImageGradientRadial(
            @floatToInt(c_int, self.ball.radius * 2),
            @floatToInt(c_int, self.ball.radius * 2),
            density,
            rl.WHITE,
            rl.BLACK,
        );
        self.ball.alpha_mask = rl.LoadTextureFromImage(ball_alpha_mask_image);
        rl.UnloadImage(ball_alpha_mask_image);

        //
        // Lightning ball
        //
        const lightning_ball_image = rl.LoadImage(config.BALL_UI_LIGHTNING_BALL);
        self.ball.lightning_ball = rl.LoadTextureFromImage(lightning_ball_image);
        rl.UnloadImage(lightning_ball_image);

        //
        // Racket gradient texture
        //
        var racket_image = rl.LoadImage(config.RACKET_UI_LASER_RACKET_TEXTURE);
        rl.ImageResize(&racket_image, config.RACKET_UI_WIDTH, config.RACKET_UI_HEIGHT);
        self.player1.default_racket.rect_texture =
            rl.LoadTextureFromImage(racket_image);
        self.player2.default_racket.rect_texture =
            rl.LoadTextureFromImage(racket_image);
        rl.UnloadImage(racket_image);

        rl.TraceLog(rl.LOG_DEBUG, ">>> [ Game.init ] - Game initialization [ done ]");
    }

    ///
    ///
    ///
    pub fn exit(self: *const Game) void {
        if (self.ball.alpha_mask) |value| rl.UnloadTexture(value);
        if (self.ball.lightning_ball) |value| rl.UnloadTexture(value);
        if (self.you_win_sound_effect) |sound| rl.UnloadSound(sound);
        if (self.ball.enable_fireball_sound_effect) |value| rl.UnloadSound(value); // Unload sound data
        if (self.ball.enable_lightning_ball_sound_effect) |value| rl.UnloadSound(value);
        if (self.ball.hit_racket_sound_effect) |value| rl.UnloadSound(value); // Unload sound data
        if (self.player1.default_racket.rect_texture) |value| rl.UnloadTexture(value);
        if (self.player2.default_racket.rect_texture) |value| rl.UnloadTexture(value);
        rl.CloseAudioDevice();

        //
        // Close window and OpenGL context
        //
        rl.CloseWindow();
        rl.TraceLog(rl.LOG_DEBUG, ">>> [ Game.exit ] - Unload raylib resources [Done]");
    }

    ///
    ///
    ///
    pub fn run(self: *const Game) void {
        _ = self;
        while (!rl.WindowShouldClose()) {
            rl.BeginDrawing();

            //
            // Clean last frame
            //
            rl.ClearBackground(config.GAME_UI_BACKGROUND_COLOR);

            //
            // Redraw the entire game
            //
            rl.DrawRectangle(10, 10, 100, 100, config.TRON_ORANGE);

            rl.EndDrawing();
        }

        rl.TraceLog(rl.LOG_DEBUG, ">>> [ Game.run ] - Exit the game loop");
    }
};