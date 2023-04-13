const std = @import("std");
const config = @import("config.zig");
const player = @import("player.zig");
const game_module = @import("game.zig").Game;
const print = std.debug.print;
// const c = @cImport({
//     @cInclude("stdio.h");
//     @cInclude("stdlib.h");
// });

///
///
///
pub fn main() !void {
    //
    // Read env
    //
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    const env_map = try arena.allocator().create(std.process.EnvMap);
    env_map.* = try std.process.getEnvMap(arena.allocator());
    defer env_map.deinit();

    const name1 = env_map.get("PLAYER_1_NAME") orelse config.PLAYER_1_NAME;
    const name2 = env_map.get("PLAYER_2_NAME") orelse config.PLAYER_2_NAME;
    const radius = env_map.get("BALL_RADIUS");
    const ball_radius = if (radius) |str_value| std.fmt.parseFloat(f32, str_value) catch config.BALL_UI_BALL_RADIUS else config.BALL_UI_BALL_RADIUS;

    //
    // `name1` and `name2` actually just a slice, you have to make a string
    // copy to avoid the point to destroyed memory location!!!
    //
    var name1_buf = [_:0]u8{0} ** 20;
    var name2_buf = [_:0]u8{0} ** 20;
    const player_1_name = std.fmt.bufPrint(&name1_buf, "{s}", .{name1}) catch "";
    const player_2_name = std.fmt.bufPrint(&name2_buf, "{s}", .{name2}) catch "";

    //
    // Because of `name1_buf` and `name2_buf` have the entire program lifetime,
    // that's why it's safe to `player_1_name` and `player_2_name` slices:)
    //
    var my_game = try game_module.create_game(
        player_1_name,
        player_2_name,
        ball_radius,
    );
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
