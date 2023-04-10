const std = @import("std");
const rl = @cImport({
    @cInclude("raylib.h");
});
const config = @import("config.zig");

///
///
///
const PlayerType = enum {
    PT_LEFT,
    PT_RIGHT,
};

///
///
///
const RacketUpdateType = enum {
    RUT_MOVE_UP,
    RUT_MOVE_DOWN,
    RUT_RESET,
};

///
///
///
const Racket = struct {
    color: rl.Color,
    rect: rl.Rectangle,
    rect_texture: rl.Texture2D,
};

///
///
///
const Player = struct {
    type: PlayerType,
    // name: *const[]u8,
    name: []const u8,
    score: isize,
    level: usize,
    // The default one
    default_racket: Racket,
    // Player may have many rackets after level-up
    // rackets: [config.RACKET_UI_MAX_RACKETS_PER_PLAYER]Racket,
};

// ///
// ///
// ///
// void Player_win(Player *player) {
//     if (player == NULL) return;
//
//     player->score += 1;
// }
//
// ///
// ///
// ///
// void Player_lose(Player *player) {
//     if (player == NULL) return;
//
//     player->score = player->score - 1 < 0 ? 0 : player->score - 1;
// }
//
// ///
// ///
// ///
// void Player_racket_redraw(Player *player) {
//     if (player == NULL) return;
//
//     Rectangle racket_rect = player->default_racket.rect;
//
//     // DrawRectangleRec(player->default_racket.rect,
//     // player->default_racket.color);
//
//     // BeginBlendMode(BLEND_ADDITIVE);
//     DrawTexturePro(
//         player->default_racket.rect_texture,
//         // Texture rect to draw from
//         (Rectangle){.x = 0.0f,
//                     .y = 0.0f,
//                     .width = RACKET_UI_WIDTH,
//                     .height = RACKET_UI_HEIGHT},
//         // Target rect to draw (orgin is TopLeft by default!!!)
//         racket_rect,
//         // Origin offset of the target rect to draw (TopLeft by default)
//         (Vector2){.x = (float)(0.0f), .y = (float)(0.0f)}, 0.0f,
//         RACKET_UI_COLOR);
//     // EndBlendMode();
//
//     if (RACKET_UI_DRAW_DEBUG_BOUNDARY) {
//         DrawRectangleRec(player->default_racket.rect,
//                          Fade(player->default_racket.color, 0.5f));
//     }
// }
//
// ///
// ///
// ///
// void Player_update_racket_after_screen_size_changed(Player *player,
//                                                     Rectangle *container,
//                                                     Rectangle *old_container) {
//     float old_y = player->default_racket.rect.y;
//     float ratio_y = old_y / old_container->height;
//
//     player->default_racket.rect.x =
//         player->type == PT_LEFT ? container->x + RACKET_UI_MARGIN
//                                 : container->x + container->width -
//                                       RACKET_UI_MARGIN - RACKET_UI_WIDTH;
//     player->default_racket.rect.y = container->height * ratio_y;
// }
//
// ///
// ///
// ///
// void Player_update_racket(Player *player, Rectangle *container,
//                           RacketUpdateType rut) {
//     if (player == NULL) return;
//
//     switch (rut) {
//         //
//         // Center `y`
//         //
//         case RUT_RESET:
//             player->default_racket.rect = (Rectangle){
//                 .x = player->type == PT_LEFT
//                          ? container->x + RACKET_UI_MARGIN
//                          : container->x + container->width - RACKET_UI_MARGIN -
//                                RACKET_UI_WIDTH,
//                 .y =
//                     container->y + ((container->height - RACKET_UI_HEIGHT) / 2),
//                 .width = RACKET_UI_WIDTH,
//                 .height = RACKET_UI_HEIGHT,
//             };
//             TraceLog(LOG_DEBUG, "[ Player_update_racket ] - RUT_RESET");
//             break;
//         //
//         // Apply velocity to `y`
//         //
//         case RUT_MOVE_UP: {
//             float new_y = player->default_racket.rect.y -
//                           RACKET_UI_VELOCITY * GetFrameTime();
//             if (new_y >= container->y) {
//                 player->default_racket.rect.y = new_y;
//             }
//             break;
//         }
//         case RUT_MOVE_DOWN: {
//             float new_y = player->default_racket.rect.y +
//                           RACKET_UI_VELOCITY * GetFrameTime();
//             if (new_y + RACKET_UI_HEIGHT <= container->y + container->height) {
//                 player->default_racket.rect.y = new_y;
//             }
//             break;
//         }
//         default: {
//         }
//     }
// }
