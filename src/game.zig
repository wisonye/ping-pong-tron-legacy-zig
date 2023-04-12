const std = @import("std");
const config = @import("config.zig");
const player = @import("player.zig");
const print = std.debug.print;
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
    // ball: Ball,
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
            // ball: Ball,
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
    pub fn init(self: *const Game) void {
        _ = self;
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
    }

    ///
    ///
    ///
    pub fn exit(self: *const Game) void {
        _ = self;
        rl.CloseAudioDevice();
        rl.CloseWindow();
        print("\n>>> [ Game.exit ] Unload raylib resources [Done]", .{});
    }
};
