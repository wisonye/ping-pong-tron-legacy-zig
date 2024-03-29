const std = @import("std");
const rl = @cImport({
    @cInclude("raylib.h");
});
const config = @import("config.zig");
const player = @import("player.zig");
const Scoreboard = @import("scoreboard.zig").Scoreboard;
const print = std.debug.print;
const GameState = @import("types.zig").GameState;
const Ball = @import("ball.zig").Ball;
const BallLightingTail = Ball.BallLightingTail;
const BallTailParticle = Ball.BallTailParticle;
const table = @import("table.zig");
const utils = @import("utils.zig");

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
    scoreboard: Scoreboard,
    table_rect_before_screen_changed: rl.Rectangle,
    table_rect: rl.Rectangle,
    ball: Ball,
    state: GameState,
    is_fullscreen: bool,
    is_player1_wins_last_round: bool,
    you_win_sound_effect: ?rl.Sound,

    ///
    ///
    ///
    pub fn create_game(
        player_1_name: []const u8,
        player_2_name: []const u8,
        ball_radius: f32,
    ) !Game {
        var result = Game{
            .player1 = player.Player{
                .type = player.PlayerType.PT_LEFT,
                .name = player_1_name,
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
                .name = player_2_name,
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
            .scoreboard = Scoreboard{},
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
            .ball = Ball{
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
                .lighting_tail = BallLightingTail{
                    .particles = [1]BallTailParticle{BallTailParticle{
                        .position = rl.Vector2{
                            .x = 0.0,
                            .y = 0.0,
                        },
                        .alpha = 0.0,
                        .size = 0.0,
                        .active = false,
                    }} ** config.BALL_UI_LIGHTING_TAIL_PARTICLE_COUNT,
                },

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

        return result;
    }

    ///
    ///
    ///
    fn toggle_fullscreen(self: *Game) void {
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
            @intFromFloat(self.ball.radius * 2),
            @intFromFloat(self.ball.radius * 2),
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

        self.print_debug_info();
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
    fn logic(self: *Game) void {
        //
        // Press 'ctrl+f' to toggle fullscreen
        //
        if (rl.IsKeyDown(rl.KEY_LEFT_CONTROL) and rl.IsKeyPressed(rl.KEY_F)) {
            // Save the `table_rect` before toggling fullscreen
            self.table_rect_before_screen_changed = self.table_rect;

            //
            toggle_fullscreen(self);
            rl.TraceLog(
                rl.LOG_DEBUG,
                ">>> [ Game_logic ] - Toggle fullscreen, screen_width: %d, screen_height: %d",
                rl.GetScreenWidth(),
                rl.GetScreenHeight(),
            );

            //
            // Update `game.table_rect`
            //
            const new_sb_rect = Scoreboard.recalculate_rect();
            self.table_rect = table.Table.recalculate_rect(&new_sb_rect);

            //
            // Sync racket position
            //
            self.player1.update_racket_after_screen_size_changed(
                &self.table_rect,
                &self.table_rect_before_screen_changed,
            );
            self.player2.update_racket_after_screen_size_changed(
                &self.table_rect,
                &self.table_rect_before_screen_changed,
            );
        }

        //
        // Press 'space' to start game
        //
        if (rl.IsKeyPressed(rl.KEY_SPACE) and
            (self.state == GameState.GS_BEFORE_START or self.state == GameState.GS_PLAYER_WINS))
        {
            self.state = GameState.GS_PLAYING;
            self.ball.restart(&self.table_rect);
            self.player1.update_racket(
                &self.table_rect,
                player.RacketUpdateType.RUT_RESET,
            );
            self.player2.update_racket(
                &self.table_rect,
                player.RacketUpdateType.RUT_RESET,
            );
            self.print_debug_info();
        }

        //
        // Game is playing, update all states
        //
        if (self.state == GameState.GS_PLAYING) {
            // Update ball
            var is_player1_win = false;
            var is_player2_win = false;
            self.ball.update(
                &self.table_rect,
                &self.player1,
                &self.player2,
                &is_player1_win,
                &is_player2_win,
            );
            if (is_player1_win) {
                self.player1.score += 1;
                self.state = GameState.GS_PLAYER_WINS;
                self.is_player1_wins_last_round = true;
                if (self.you_win_sound_effect) |sound| {
                    rl.PlaySound(sound);
                }
                return;
            } else if (is_player2_win) {
                self.player2.score += 1;
                self.state = GameState.GS_PLAYER_WINS;
                self.is_player1_wins_last_round = false;
                if (self.you_win_sound_effect) |sound| {
                    rl.PlaySound(sound);
                }
                return;
            }

            // Update lighting tail
            self.ball.update_lighting_tail();

            //
            // Update racket postion
            //
            if (rl.IsKeyDown(config.PLAYER_2_UP_KEY)) {
                self.player2.update_racket(
                    &self.table_rect,
                    player.RacketUpdateType.RUT_MOVE_UP,
                );
            }
            if (rl.IsKeyDown(config.PLAYER_2_DOWN_KEY)) {
                self.player2.update_racket(
                    &self.table_rect,
                    player.RacketUpdateType.RUT_MOVE_DOWN,
                );
            }
            if (rl.IsKeyDown(config.PLAYER_1_UP_KEY)) {
                self.player1.update_racket(
                    &self.table_rect,
                    player.RacketUpdateType.RUT_MOVE_UP,
                );
            }
            if (rl.IsKeyDown(config.PLAYER_1_DOWN_KEY)) {
                self.player1.update_racket(
                    &self.table_rect,
                    player.RacketUpdateType.RUT_MOVE_DOWN,
                );
            }
        }

        //
        // Player wins, update score
        //
        if (self.state == GameState.GS_PLAYING) {}
    }

    ///
    ///
    ///
    fn redraw(self: *Game) void {

        //
        // Scoreboard
        //
        const sb_rect = self.scoreboard.redraw(&self.player1, &self.player2);

        //
        // Table
        //
        const table_rect = table.Table.redraw(
            self.state,
            self.is_player1_wins_last_round,
            self.player1.name,
            self.player2.name,
            &sb_rect,
        );

        //
        // Player rackets
        //
        self.player1.redraw();
        self.player2.redraw();

        //
        // Ball
        //
        self.ball.redraw();

        //
        // Update `game.table_rect` if changed
        //
        // TraceLog(LOG_DEBUG,
        //          ">>> [ Game_redraw ] - table_rect: {x: %.2f, y: %.2f, width: "
        //          "%.2f, height: %.2f}",
        //          table_rect.x, table_rect.y, table_rect.width,
        //          table_rect.height);
        if (table_rect.x != self.table_rect.x or
            table_rect.y != self.table_rect.y or
            table_rect.width != self.table_rect.width or
            table_rect.height != self.table_rect.height)
        {
            self.table_rect = table_rect;

            rl.TraceLog(rl.LOG_DEBUG, ">>> [ Game_redraw ] - Update 'game.table_rect'");
        }
    }

    ///
    ///
    ///
    pub fn run(self: *Game) void {
        while (!rl.WindowShouldClose()) {

            //
            // Update game logic
            //
            self.logic();

            rl.BeginDrawing();

            //
            // Clean last frame
            //
            rl.ClearBackground(config.GAME_UI_BACKGROUND_COLOR);

            //
            // Redraw the entire game
            //
            self.redraw();

            rl.EndDrawing();
        }

        rl.TraceLog(rl.LOG_DEBUG, ">>> [ Game.run ] - Exit the game loop");
    }

    ///
    ///
    ///
    fn print_debug_info(self: *const Game) void {
        //
        // Game state
        //
        var state_buf: [20]u8 = undefined;
        const state_str = switch (self.state) {
            GameState.GS_UNINIT => std.fmt.bufPrint(&state_buf, "GS_UNINIT", .{}) catch "",
            GameState.GS_INIT => std.fmt.bufPrint(&state_buf, "GS_INIT", .{}) catch "",
            GameState.GS_BEFORE_START => std.fmt.bufPrint(&state_buf, "GS_BEFORE_START", .{}) catch "",
            GameState.GS_PLAYING => std.fmt.bufPrint(&state_buf, "GS_PLAYING", .{}) catch "",
            GameState.GS_PLAYER_WINS => std.fmt.bufPrint(&state_buf, "GS_PLAYER_WINS", .{}) catch "",
            GameState.GS_PAUSE => std.fmt.bufPrint(&state_buf, "GS_PAUSE", .{}) catch "",
        };

        //
        // Player1
        //
        var player_1_buf: [300]u8 = undefined;
        const player_1_str = utils.get_player_string(&self.player1, &player_1_buf);
        // print("\n >>>> player_1_str: {s}", .{player_1_str});

        //
        // Player2
        //
        var player_2_buf: [300]u8 = undefined;
        const player_2_str = utils.get_player_string(&self.player2, &player_2_buf);
        // print("\n >>>> player_2_str: {s}", .{player_2_str});

        //
        // Table rect
        //
        var table_rect_buf = [_:0]u8{0} ** 100;
        const table_rect_str = std.fmt.bufPrint(
            &table_rect_buf,
            "\ttable_rect: {{x: {d:.2}, y: {d:.2}, width: {d:.2}, height: {d:.2}}}",
            .{
                self.table_rect.x,
                self.table_rect.y,
                self.table_rect.width,
                self.table_rect.height,
            },
        ) catch "AAA";

        //
        // Ball
        //
        var ball_buf: [1024]u8 = undefined;
        var ball_color_buf: [10]u8 = undefined;
        var fireball_color_buf: [10]u8 = undefined;

        const ball_color_str = std.fmt.bufPrint(
            &ball_color_buf,
            "0x{X:0>2}{X:0>2}{X:0>2}{X:0>2}",
            .{
                config.BALL_UI_BALL_COLOR.r,
                config.BALL_UI_BALL_COLOR.g,
                config.BALL_UI_BALL_COLOR.b,
                config.BALL_UI_BALL_COLOR.a,
            },
        ) catch "";
        const fireball_color_str = std.fmt.bufPrint(
            &fireball_color_buf,
            "0x{X:0>2}{X:0>2}{X:0>2}{X:0>2}",
            .{
                config.BALL_UI_FIREBALL_COLOR.r,
                config.BALL_UI_FIREBALL_COLOR.g,
                config.BALL_UI_FIREBALL_COLOR.b,
                config.BALL_UI_FIREBALL_COLOR.a,
            },
        ) catch "";

        const ball_str = std.fmt.bufPrint(
            &ball_buf,
            "\tball: {{\n\t\tcenter: {{ x: {d:.2}, y: {d:.2} }}\n\t\tradius: " ++
                "{d:.2}\n\t\tcolor: {s}\n\t\tfireball color: {s}\n\t\tvelocity_x: " ++
                "{d:.2}\n\t\tvelocity_y: {d:.2}\n\t\thits_before_increase_velocity: " ++
                "{}\n\t\tvelocities_increase_to_enable_fireball: " ++
                "{}\n\t\tvelocity_acceleration: " ++
                "{}\n\t\tlighting_tail_particle_count: " ++
                "{}\n\t\tlighting_tail_particle_init_alpha: " ++
                "{d:.2}\n\t\tlighting_tail_particle_size: {d:.2}\n\t}}",
            .{
                self.ball.center.x,
                self.ball.center.y,
                self.ball.radius,
                ball_color_str,
                fireball_color_str,
                config.BALL_UI_BALL_VELOCITY_X,
                config.BALL_UI_BALL_VELOCITY_Y,
                config.BALL_UI_HITS_BEFORE_INCREASE_VELOCITY,
                config.BALL_UI_VELOCITIES_INCREASE_TO_ENABLE_FIREBALL,
                config.BALL_UI_VELOCITY_ACCELERATION,
                config.BALL_UI_LIGHTING_TAIL_PARTICLE_COUNT,
                config.BALL_UI_LIGHTING_TAIL_PRATICLE_INIT_ALPHA,
                config.BALL_UI_LIGHTING_TAIL_PRATICLE_SIZE,
            },
        ) catch "";
        // print("\n >>>> ball_str: {s}", .{ball_str});

        //
        // Debug info
        //
        var debug_buf = [_:0]u8{0} ** 1024;
        var debug_str = std.fmt.bufPrint(&debug_buf, "\n{{\n\tstate: {s}\n{s}\n{s}\n{s}\n{s}\n}}", .{
            state_str,
            table_rect_str,
            player_1_str,
            player_2_str,
            ball_str,
        }) catch "";

        rl.TraceLog(
            rl.LOG_DEBUG,
            ">>> [ Game.print_debug_info ] - %s",
            @as([*c]const u8, @ptrCast(debug_str)),
        );
    }
};
