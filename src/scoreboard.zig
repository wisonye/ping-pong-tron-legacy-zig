const rl = @cImport({
    @cInclude("raylib.h");
});
const config = @import("config.zig");
const player = @import("player.zig");

///
///
///
pub const Scoreboard = struct {
    player1: ?*player.Player,
    player2: ?*player.Player,

    ///
    ///
    ///
    pub fn SB_redraw(self: *const Scoreboard) rl.Rectangle {
        _ = self;
    }

    ///
    ///
    ///
    pub fn SB_recalculate_rect() rl.Rectangle {}

    ///
    ///
    ///
    pub fn SB_update_player_1_score(self: *Scoreboard, score: usize) void {
        _ = score;
        _ = self;
    }

    ///
    ///
    ///
    pub fn SB_update_player_2_score(self: *Scoreboard, score: usize) void {
        _ = score;
        _ = self;
    }
};
