const rl = @cImport({
    @cInclude("raylib.h");
});
const config = @import("config.zig");
const player = @import("player.zig");

///
///
///
pub const Ball = struct {
    center: rl.Vector2,
    radius: f32,
    velocity_x: f32,
    velocity_y: f32,
    lightning_ball_rotation_angle: f32,
    current_hits: usize,
    current_velocities_increase: usize,
    enabled_fireball: bool,
    enabled_lightning_ball: bool,
    alpha_mask: ?rl.Texture2D,
    lightning_ball: ?rl.Texture2D,
    enable_fireball_sound_effect: ?rl.Sound,
    enable_lightning_ball_sound_effect: ?rl.Sound,
    hit_racket_sound_effect: ?rl.Sound,
    lighting_tail: ?BallLightingTail,

    ///
    /// Particle structure with basic data
    ///
    pub const BallTailParticle = struct {
        position: rl.Vector2,
        // Color color,
        alpha: f32,
        size: f32,
        active: bool, // NOTE: Use it to activate/deactive particle
    };

    ///
    /// The lighting tail that follows by the moving ball
    ///
    pub const BallLightingTail = struct {
        particles: [config.BALL_UI_LIGHTING_TAIL_PARTICLE_COUNT]BallTailParticle,
    };

    ///
    ///
    ///
    pub fn redraw(self: *const Ball) void {
        _ = self;
    }

    ///
    ///
    ///
    pub fn restart(self: *const Ball, table_rect: *const rl.Rectangle) void {
        _ = table_rect;
        _ = self;
    }

    ///
    ///
    ///
    pub fn update(
        self: *Ball,
        table_rect: *const rl.Rectangle,
        player1: *const player.Player,
        player2: *const player.Player,
        is_player1_win: bool,
        is_player2_win: bool,
    ) void {
        _ = is_player2_win;
        _ = is_player1_win;
        _ = player2;
        _ = player1;
        _ = table_rect;
        _ = self;
    }

    ///
    ///
    ///
    pub fn update_lighting_tail(self: *Ball) void {
        _ = self;
    }
};
