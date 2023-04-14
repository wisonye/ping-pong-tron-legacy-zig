const std = @import("std");
const print = std.debug.print;
const rl = @cImport({
    @cInclude("raylib.h");
});
const config = @import("config.zig");
const types = @import("types.zig");

///
///
///
pub const Table = struct {
    ///
    ///
    ///
    pub fn recalculate_rect(sb_rect: *const rl.Rectangle) rl.Rectangle {
        const screen_width = rl.GetScreenWidth();
        const screen_height = rl.GetScreenHeight();

        //
        // Outside border
        //
        const sb_rect_bottom = sb_rect.y + sb_rect.height;
        const rect = rl.Rectangle{
            .x = config.TABLE_UI_MARGIN,
            .y = sb_rect_bottom + config.TABLE_UI_MARGIN,
            .width = @intToFloat(u32, screen_width) - 2 * config.TABLE_UI_MARGIN,
            .height = @intToFloat(u32, screen_height) - sb_rect_bottom - 2 * config.TABLE_UI_MARGIN,
        };

        return rect;
    }

    ///
    ///
    ///
    pub fn redraw(
        game_state: types.GameState,
        is_player1_wins_last_round: bool,
        player_1_name: []const u8,
        player_2_name: []const u8,
        sb_rect: *const rl.Rectangle,
    ) rl.Rectangle {
        const screen_width = rl.GetScreenWidth();
        const screen_height = rl.GetScreenHeight();
        const font = rl.GetFontDefault();

        //
        // Outside border
        //
        const sb_rect_bottom = sb_rect.y + sb_rect.height;
        const rect = rl.Rectangle{
            .x = config.TABLE_UI_MARGIN,
            .y = sb_rect_bottom + config.TABLE_UI_MARGIN,
            .width = @intToFloat(f32, screen_width) - 2 * config.TABLE_UI_MARGIN,
            .height = @intToFloat(f32, screen_height) - sb_rect_bottom - 2 * config.TABLE_UI_MARGIN,
        };

        rl.DrawRectangleLinesEx(
            rect,
            config.TABLE_UI_BORDER_THICKNESS,
            config.TABLE_UI_BORDER_COLOR,
        );

        //
        // GS_BEFORE_START
        //
        if (game_state == types.GameState.GS_BEFORE_START) {
            // outside border
            const start_prompt_font_size =
                rl.MeasureTextEx(
                font,
                config.TABLE_UI_FIRST_START_PROMPT_TEXT,
                config.TABLE_UI_FIRST_START_PROMPT_FONT_SIZE,
                config.TABLE_UI_FIRST_START_PROMPT_FONT_SPACE,
            );

            const start_prompt_rect_width =
                start_prompt_font_size.x +
                2 * config.TABLE_UI_FIRST_START_PROMPT_CONTAINER_HORIZONTAL_PADDING;
            const start_prompt_rect_height =
                start_prompt_font_size.y +
                2 * config.TABLE_UI_FIRST_START_PROMPT_CONTAINER_VERTICAL_PADDING;
            const start_prompt_rect = rl.Rectangle{
                .x = rect.x + ((rect.width - start_prompt_rect_width) / 2),
                .y = rect.y + ((rect.height - start_prompt_rect_height) / 2),
                .width = start_prompt_rect_width,
                .height = start_prompt_rect_height,
            };
            rl.DrawRectangleLinesEx(
                start_prompt_rect,
                config.TABLE_UI_BORDER_THICKNESS,
                config.TABLE_UI_FIRST_START_PROMPT_BORDER_COLOR,
            );

            // Text
            const start_prompt_font_draw_x =
                start_prompt_rect.x +
                config.TABLE_UI_FIRST_START_PROMPT_CONTAINER_HORIZONTAL_PADDING;
            const start_prompt_font_draw_y =
                start_prompt_rect.y +
                config.TABLE_UI_FIRST_START_PROMPT_CONTAINER_VERTICAL_PADDING;
            const start_prompt_font_point = rl.Vector2{
                .x = start_prompt_font_draw_x,
                .y = start_prompt_font_draw_y,
            };
            rl.DrawTextEx(
                font,
                config.TABLE_UI_FIRST_START_PROMPT_TEXT,
                start_prompt_font_point,
                config.TABLE_UI_FIRST_START_PROMPT_FONT_SIZE,
                config.TABLE_UI_FIRST_START_PROMPT_FONT_SPACE,
                config.TABLE_UI_FIRST_START_PROMPT_TEXT_COLOR,
            );
        }
        //
        // GS_PLAYER_WINS
        //
        else if (game_state == types.GameState.GS_PLAYER_WINS) {
            // Last winner's name
            var last_winner_name_buf = [_:0]u8{0} ** 100;
            const last_winner_name_str = std.fmt.bufPrint(&last_winner_name_buf, "{s}{s}", .{ if (is_player1_wins_last_round) player_1_name else player_2_name, config.TABLE_UI_PLAYER_WINS_PROMPT_TEXT }) catch "";

            // outside border
            const win_prompt_font_size = rl.MeasureTextEx(
                font,
                @ptrCast([*c]const u8, last_winner_name_str),
                config.TABLE_UI_PLAYER_WINS_PROMPT_FONT_SIZE,
                config.TABLE_UI_PLAYER_WINS_PROMPT_FONT_SPACE,
            );

            const restart_font_size =
                rl.MeasureTextEx(
                font,
                config.TABLE_UI_PLAYER_WINS_RESTART_TEXT,
                config.TABLE_UI_PLAYER_WINS_RESTART_FONT_SIZE,
                config.TABLE_UI_PLAYER_WINS_RESTART_FONT_SPACE,
            );

            const wins_prompt_rect_width =
                win_prompt_font_size.x +
                2 * config.TABLE_UI_PLAYER_WINS_PROMPT_CONTAINER_HORIZONTAL_PADDING;
            const wins_prompt_rect_height =
                win_prompt_font_size.y + restart_font_size.y +
                2 * config.TABLE_UI_PLAYER_WINS_PROMPT_CONTAINER_VERTICAL_PADDING +
                2 * config.TABLE_UI_PLAYER_WINS_RESTART_CONTAINER_VERTICAL_PADDING;
            const wins_prompt_rect = rl.Rectangle{
                .x = rect.x + ((rect.width - wins_prompt_rect_width) / 2),
                .y = rect.y + ((rect.height - wins_prompt_rect_height) / 2),
                .width = wins_prompt_rect_width,
                .height = wins_prompt_rect_height,
            };
            rl.DrawRectangleLinesEx(
                wins_prompt_rect,
                config.TABLE_UI_BORDER_THICKNESS,
                config.TABLE_UI_PLAYER_WINS_PROMPT_BORDER_COLOR,
            );

            // Text
            const wins_prompt_font_draw_x =
                wins_prompt_rect.x +
                config.TABLE_UI_PLAYER_WINS_PROMPT_CONTAINER_HORIZONTAL_PADDING;
            const wins_prompt_font_draw_y =
                wins_prompt_rect.y +
                config.TABLE_UI_PLAYER_WINS_PROMPT_CONTAINER_VERTICAL_PADDING;
            const wins_prompt_font_point = rl.Vector2{
                .x = wins_prompt_font_draw_x,
                .y = wins_prompt_font_draw_y,
            };
            rl.DrawTextEx(
                font,
                @ptrCast([*c]const u8, last_winner_name_str),
                wins_prompt_font_point,
                config.TABLE_UI_PLAYER_WINS_PROMPT_FONT_SIZE,
                config.TABLE_UI_PLAYER_WINS_PROMPT_FONT_SPACE,
                config.TABLE_UI_PLAYER_WINS_PROMPT_TEXT_COLOR,
            );

            const restart_font_draw_x =
                wins_prompt_rect.x +
                ((wins_prompt_rect.width - restart_font_size.x) / 2);
            const restart_font_draw_y =
                wins_prompt_font_draw_y + win_prompt_font_size.y +
                config.TABLE_UI_PLAYER_WINS_PROMPT_CONTAINER_VERTICAL_PADDING;
            const restart_font_point = rl.Vector2{
                .x = restart_font_draw_x,
                .y = restart_font_draw_y,
            };
            rl.DrawTextEx(
                font,
                config.TABLE_UI_PLAYER_WINS_RESTART_TEXT,
                restart_font_point,
                config.TABLE_UI_PLAYER_WINS_RESTART_FONT_SIZE,
                config.TABLE_UI_PLAYER_WINS_RESTART_FONT_SPACE,
                config.TABLE_UI_PLAYER_WINS_RESTART_TEXT_COLOR,
            );
        }

        return rect;
    }
};
