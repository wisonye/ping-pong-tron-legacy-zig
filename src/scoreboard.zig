const rl = @cImport({
    @cInclude("raylib.h");
});
const std = @import("std");
const print = std.debug.print;
const config = @import("config.zig");
const player = @import("player.zig");

///
///
///
pub const Scoreboard = struct {
    ///
    ///
    ///
    pub fn recalculate_rect() rl.Rectangle {
        const screen_width = rl.GetScreenWidth();
        const screen_height = rl.GetScreenHeight();

        //
        // Outside border
        //
        const rect = rl.Rectangle{
            .x = config.SCOREBOARD_UI_PADDING,
            .y = config.SCOREBOARD_UI_PADDING,
            .width = @intToFloat(f32, screen_width) - 2.0 * config.SCOREBOARD_UI_PADDING,
            .height = @intToFloat(f32, screen_height) *
                (@intToFloat(f32, config.SCOREBOARD_UI_BORDER_HEIGHT_PERCENT) / 100.0),
        };

        return rect;
    }

    ///
    ///
    ///
    fn draw_player_name_and_score(
        name: []const u8,
        score: isize,
        is_player_1: bool,
        font: *const rl.Font,
        container: *const rl.Rectangle,
        color: rl.Color,
    ) void {
        //
        // Name
        //
        const name_font_size =
            rl.MeasureTextEx(
            font.*,
            @ptrCast([*c]const u8, name),
            config.SCOREBOARD_UI_PLAYER_NAME_FONT_SIZE,
            config.SCOREBOARD_UI_PLAYER_FONT_SPACE,
        );

        const name_point = rl.Vector2{
            .x = if (is_player_1) container.x + config.SCOREBOARD_UI_SPACE_BETWEEN_NAME_AND_BORDER else container.x + container.width - config.SCOREBOARD_UI_SPACE_BETWEEN_NAME_AND_BORDER - name_font_size.x,
            .y = container.y + ((container.height - name_font_size.y) / 2.0),
        };
        rl.DrawTextEx(
            font.*,
            @ptrCast([*c]const u8, name),
            name_point,
            config.SCOREBOARD_UI_PLAYER_NAME_FONT_SIZE,
            config.SCOREBOARD_UI_PLAYER_FONT_SPACE,
            color,
        );

        //
        // Score (double digits)
        //
        var score_buf = [_:0]u8{0} ** 10;
        // std.mem.set(u8, &score_buf, 0);
        const score_str = if (score < 10) std.fmt.bufPrint(
            &score_buf,
            "0{d}",
            .{score},
        ) catch "" else std.fmt.bufPrint(
            &score_buf,
            "{d}",
            .{score},
        ) catch "";

        const score_font_size =
            rl.MeasureTextEx(
            font.*,
            @ptrCast([*c]const u8, score_str),
            config.SCOREBOARD_UI_PLAYER_SCORE_FONT_SIZE,
            config.SCOREBOARD_UI_PLAYER_FONT_SPACE,
        );
        const score_font_point = rl.Vector2{
            .x = if (is_player_1) name_point.x + name_font_size.x + config.SCOREBOARD_UI_SPACE_BETWEEN_NAME_AND_SCORE else name_point.x - config.SCOREBOARD_UI_SPACE_BETWEEN_NAME_AND_SCORE - score_font_size.x,
            .y = container.y + ((container.height - score_font_size.y) / 2),
        };

        rl.DrawTextEx(
            font.*,
            @ptrCast([*c]const u8, score_str),
            score_font_point,
            config.SCOREBOARD_UI_PLAYER_SCORE_FONT_SIZE,
            config.SCOREBOARD_UI_PLAYER_FONT_SPACE,
            color,
        );
    }

    ///
    ///
    ///
    pub fn redraw(
        self: *const Scoreboard,
        player1: *const player.Player,
        player2: *const player.Player,
    ) rl.Rectangle {
        _ = self;
        const screen_width = rl.GetScreenWidth();
        const screen_height = rl.GetScreenHeight();

        //
        // Outside border
        //
        const rect = rl.Rectangle{
            .x = config.SCOREBOARD_UI_PADDING,
            .y = config.SCOREBOARD_UI_PADDING,
            .width = @intToFloat(f32, screen_width) - 2 * config.SCOREBOARD_UI_PADDING,
            .height = @intToFloat(f32, screen_height) *
                (@intToFloat(
                f32,
                config.SCOREBOARD_UI_BORDER_HEIGHT_PERCENT,
            ) / 100.0),
        };

        // TraceLog(LOG_DEBUG, ">>> [ SB_redraw ] - rect: %f, %f, %f, %f", rect.x,
        // rect.y, rect.width, rect.height);

        rl.DrawRectangleLinesEx(
            rect,
            config.SCOREBOARD_UI_BORDER_THICKNESS,
            config.SCOREBOARD_UI_BORDER_COLOR,
        );

        //
        // `VS`
        //
        const font = rl.GetFontDefault();
        const vs_font_size = rl.MeasureTextEx(
            font,
            "VS",
            config.SCOREBOARD_UI_VS_FONT_SIZE,
            config.SCOREBOARD_UI_VS_FONT_SPACE,
        );
        // TraceLog(LOG_DEBUG, ">>> [ SB_redraw ] - vs_font_size: %f, %f",
        // vs_font_size.x, vs_font_size.y);

        const vs_font_draw_x = rect.x + ((rect.width - vs_font_size.x) / 2);
        const vs_font_draw_y = rect.y + ((rect.height - vs_font_size.y) / 2);
        const vs_font_point = rl.Vector2{
            .x = vs_font_draw_x,
            .y = vs_font_draw_y,
        };
        rl.DrawTextEx(
            font,
            "VS",
            vs_font_point,
            config.SCOREBOARD_UI_VS_FONT_SIZE,
            config.SCOREBOARD_UI_VS_FONT_SPACE,
            config.SCOREBOARD_UI_BORDER_COLOR,
        );
        // TraceLog(LOG_DEBUG, ">>> [ SB_redraw ] - vs_font_point: %f, %f",
        // vs_font_point.x, vs_font_point.y);

        //
        // Player
        //
        draw_player_name_and_score(
            player1.name,
            player1.score,
            true,
            &font,
            &rect,
            config.SCOREBOARD_UI_BORDER_COLOR,
        );
        draw_player_name_and_score(
            player2.name,
            player2.score,
            false,
            &font,
            &rect,
            config.SCOREBOARD_UI_BORDER_COLOR,
        );

        return rect;
    }

    ///
    ///
    ///
    pub fn update_player_1_score(self: *Scoreboard, score: usize) void {
        _ = score;
        _ = self;
    }

    ///
    ///
    ///
    pub fn update_player_2_score(self: *Scoreboard, score: usize) void {
        _ = score;
        _ = self;
    }
};
