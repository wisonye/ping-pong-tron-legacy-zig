const std = @import("std");
const config = @import("config.zig");
const player = @import("player.zig");

///
///
///
pub fn get_player_string(p: *const player.Player, out_buffer: []u8) []const u8 {
    var player_type_buf: [10]u8 = undefined;
    const player_type_str = std.fmt.bufPrint(
        &player_type_buf,
        "{s}",
        .{if (p.type == player.PlayerType.PT_LEFT) "LEFT" else "RIGHT"},
    ) catch "";

    const color = p.default_racket.color;

    return std.fmt.bufPrint(
        out_buffer,
        "\tplayer: {{\n\t\ttype: {s}\n\t\tname: {s}\n\t\tscore: {}\n\t\tdefault_racket: {{\n\t\t\tcolor: 0x{X:0>2}{X:0>2}{X:0>2}{X:0>2}\n\t\t\tvelocity: {d:.2}\n\t\t}}\n\t}}",
        .{
            player_type_str, p.name, p.score, color.r, color.g, color.b, color.a, config.RACKET_UI_VELOCITY,
        },
    ) catch "";
}
