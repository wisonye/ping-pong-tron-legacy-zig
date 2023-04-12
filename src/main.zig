const std = @import("std");
const config = @import("config.zig");
const player = @import("player.zig");
const game_module = @import("game.zig").Game;
const print = std.debug.print;

///
///
///
pub fn main() !void {
    var my_game = game_module.create_game();
    my_game.init();
    defer my_game.exit();
    my_game.run();
}

// test "simple test" {
//     var list = std.ArrayList(i32).init(std.testing.allocator);
//     defer list.deinit(); // try commenting this out and see if zig detects the memory leak!
//     try list.append(42);
//     try std.testing.expectEqual(@as(i32, 42), list.pop());
// }
