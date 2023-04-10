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
fn unload_raylib_resources() void {
    rl.CloseAudioDevice();
    rl.CloseWindow();
    print("\n>>> Unload raylib resources [Done]", .{});
}

///
///
///
pub fn main() !void {
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
    defer unload_raylib_resources();

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

// test "simple test" {
//     var list = std.ArrayList(i32).init(std.testing.allocator);
//     defer list.deinit(); // try commenting this out and see if zig detects the memory leak!
//     try list.append(42);
//     try std.testing.expectEqual(@as(i32, 42), list.pop());
// }
