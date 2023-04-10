const std = @import("std");
const config = @import("config.zig");
const player = @import("player.zig");
const game = @import("game.zig");
const print = std.debug.print;

const rl = @cImport({
    @cInclude("raylib.h");
});

///
///
///
pub fn main() !void {
    const my_game = game.create_game();
    game.init(&my_game);
    defer game.exit(&my_game);
    game.run(&my_game);
}

// test "simple test" {
//     var list = std.ArrayList(i32).init(std.testing.allocator);
//     defer list.deinit(); // try commenting this out and see if zig detects the memory leak!
//     try list.append(42);
//     try std.testing.expectEqual(@as(i32, 42), list.pop());
// }
