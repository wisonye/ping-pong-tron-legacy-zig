const std = @import("std");
const config = @import("config.zig");
const player = @import("player.zig");
const print = std.debug.print;
const rl = @cImport({
    @cInclude("raylib.h");
});

pub const Game = struct {};

///
///
///
pub fn create_game() Game {
    return Game{};
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
