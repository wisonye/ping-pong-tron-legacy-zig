const std = @import("std");
const rl = @cImport({
    @cInclude("raylib.h");
});
const config = @import("config.zig");

///
///
///
pub const PlayerType = enum {
    PT_LEFT,
    PT_RIGHT,
};

///
///
///
pub const RacketUpdateType = enum {
    RUT_MOVE_UP,
    RUT_MOVE_DOWN,
    RUT_RESET,
};

///
///
///
pub const Racket = struct {
    color: rl.Color,
    rect: rl.Rectangle,
    rect_texture: ?rl.Texture2D,
};

///
///
///
pub const Player = struct {
    type: PlayerType,
    // name: *const[]u8,
    name: []const u8,
    score: isize,
    // level: usize,
    // The default one
    default_racket: Racket,
    // Player may have many rackets after level-up
    // rackets: [config.RACKET_UI_MAX_RACKETS_PER_PLAYER]Racket,

    const Self = @This();

    ///
    ///
    ///
    pub fn redraw(self: *const Self) void {
        const racket_rect = self.default_racket.rect;

        rl.DrawTexturePro(
            self.default_racket.rect_texture.?,
            // Texture rect to draw from
            rl.Rectangle{ .x = 0.0, .y = 0.0, .width = config.RACKET_UI_WIDTH, .height = config.RACKET_UI_HEIGHT },
            // Target rect to draw (orgin is TopLeft by default!!!)
            racket_rect,
            // Origin offset of the target rect to draw (TopLeft by default)
            rl.Vector2{ .x = 0.0, .y = 0.0 },
            0.0,
            config.RACKET_UI_COLOR,
        );
        // EndBlendMode();

        if (config.RACKET_UI_DRAW_DEBUG_BOUNDARY) {
            rl.DrawRectangleRec(self.default_racket.rect, rl.Fade(self.default_racket.color, 0.5));
        }
    }

    ///
    ///
    ///
    pub fn update_racket_after_screen_size_changed(
        self: *Self,
        container: *const rl.Rectangle,
        old_container: *const rl.Rectangle,
    ) void {
        const old_y = self.default_racket.rect.y;
        const ratio_y = old_y / old_container.height;

        self.default_racket.rect.x =
            if (self.type == PlayerType.PT_LEFT) container.x + config.RACKET_UI_MARGIN else container.x + container.width - config.RACKET_UI_MARGIN - config.RACKET_UI_WIDTH;
        self.default_racket.rect.y = container.height * ratio_y;
    }

    ///
    ///
    ///
    pub fn update_racket(
        self: *Self,
        container: *const rl.Rectangle,
        rut: RacketUpdateType,
    ) void {
        switch (rut) {
            //
            // Center `y`
            //
            RacketUpdateType.RUT_RESET => {
                self.default_racket.rect = rl.Rectangle{
                    .x = if (self.type == PlayerType.PT_LEFT) container.x + config.RACKET_UI_MARGIN else container.x + container.width - config.RACKET_UI_MARGIN - config.RACKET_UI_WIDTH,
                    .y = container.y + ((container.height - config.RACKET_UI_HEIGHT) / 2),
                    .width = config.RACKET_UI_WIDTH,
                    .height = config.RACKET_UI_HEIGHT,
                };
                rl.TraceLog(rl.LOG_DEBUG, "[ Player_update_racket ] - RUT_RESET");
            },
            //
            // Apply velocity to `y`
            //
            RacketUpdateType.RUT_MOVE_UP => {
                const new_y = self.default_racket.rect.y - config.RACKET_UI_VELOCITY * rl.GetFrameTime();
                if (new_y >= container.y) {
                    self.default_racket.rect.y = new_y;
                }
            },
            RacketUpdateType.RUT_MOVE_DOWN => {
                const new_y = self.default_racket.rect.y +
                    config.RACKET_UI_VELOCITY * rl.GetFrameTime();
                if (new_y + config.RACKET_UI_HEIGHT <= container.y + container.height) {
                    self.default_racket.rect.y = new_y;
                }
            },
        }
    }
};
