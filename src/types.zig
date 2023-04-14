///
///
///
pub const GameState = enum(u8) {
    GS_UNINIT = 0x01,
    GS_INIT = 0x02,
    GS_BEFORE_START = 0x03,
    GS_PLAYING = 0x04,
    GS_PLAYER_WINS = 0x05,
    GS_PAUSE = 0x06,
};
