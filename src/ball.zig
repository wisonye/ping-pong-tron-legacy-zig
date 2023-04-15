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
    lighting_tail: BallLightingTail,

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
        if (self.center.x == -1 or self.center.y == -1) return;

        //
        // // Color blending modes (pre-defined)
        // typedef enum {
        // BLEND_ALPHA = 0,         // Blend textures considering alpha (default)
        // BLEND_ADDITIVE,          // Blend textures adding colors
        // BLEND_MULTIPLIED,        // Blend textures multiplying colors
        // BLEND_ADD_COLORS,        // Blend textures adding colors (alternative)
        // BLEND_SUBTRACT_COLORS,   // Blend textures subtracting colors
        // (alternative) BLEND_ALPHA_PREMULTIPLY, // Blend premultiplied textures
        // considering alpha BLEND_CUSTOM             // Blend textures using custom
        // src/dst factors (use rlSetBlendMode()) } BlendMode;
        //
        //
        // Above is the supported `blend mode` which affects how blending works,
        // `BLEND_ADDTIVE` is the only effect I wanted.
        //
        rl.BeginBlendMode(rl.BLEND_ADDITIVE);

        //
        // Draw lighting tail
        //
        const particles = self.lighting_tail.particles;

        var ball_and_lighting_tail_color = if (self.enabled_fireball) config.BALL_UI_FIREBALL_COLOR else config.BALL_UI_BALL_COLOR;

        if (self.enabled_lightning_ball) {
            ball_and_lighting_tail_color = config.BALL_UI_LIGHTNING_BALL_COLOR;
        }

        var i: usize = 0;
        while (i < config.BALL_UI_LIGHTING_TAIL_PARTICLE_COUNT) {
            if (self.lighting_tail.particles[i].active)
                // TraceLog(LOG_DEBUG,
                //          ">>> [ Ball_redraw ] - draw lighting ball particle, "
                //          "index: {%u}",
                //          i);
                rl.DrawTexturePro(
                    self.alpha_mask.?,
                    rl.Rectangle{
                        .x = 0.0,
                        .y = 0.0,
                        .width = @intToFloat(f32, self.alpha_mask.?.width),
                        .height = @intToFloat(f32, self.alpha_mask.?.height),
                    },
                    rl.Rectangle{
                        .x = particles[i].position.x,
                        .y = particles[i].position.y,
                        .width = @intToFloat(
                            f32,
                            self.alpha_mask.?.width,
                        ) * particles[i].size,
                        .height = @intToFloat(
                            f32,
                            self.alpha_mask.?.height,
                        ) * particles[i].size,
                    },
                    rl.Vector2{
                        .x = @intToFloat(
                            f32,
                            self.alpha_mask.?.width,
                        ) * particles[i].size / 2.0,
                        .y = @intToFloat(
                            f32,
                            self.alpha_mask.?.height,
                        ) * particles[i].size / 2.0,
                    },
                    0.0,

                    rl.Fade(ball_and_lighting_tail_color, particles[i].alpha),
                );
            i += 1;
        }

        //
        // Draw solid circle
        //
        // DrawCircleV(ball.center, ball.radius, ball.color);

        //
        // Draw ball with alpha mask
        //
        rl.DrawTexturePro(
            self.alpha_mask.?,
            rl.Rectangle{
                .x = 0.0,
                .y = 0.0,
                .width = @intToFloat(f32, self.alpha_mask.?.width),
                .height = @intToFloat(f32, self.alpha_mask.?.height),
            },
            rl.Rectangle{
                .x = self.center.x,
                .y = self.center.y,
                .width = @intToFloat(f32, self.alpha_mask.?.width),
                .height = @intToFloat(f32, self.alpha_mask.?.height),
            },
            rl.Vector2{
                .x = @intToFloat(f32, self.alpha_mask.?.width) / 2.0,
                .y = @intToFloat(f32, self.alpha_mask.?.height) / 2.0,
            },
            0.0,
            ball_and_lighting_tail_color,
        );

        rl.EndBlendMode();

        //
        // Draw lightning ball with texture png version
        //
        // if (ball.enabled_lightning_ball) {
        //     BeginBlendMode(BLEND_ALPHA);

        //     DrawTexturePro(
        //         ball.lightning_ball,
        //         (Rectangle){0.0f, 0.0f, (float)ball.lightning_ball.width,
        //                     (float)ball.lightning_ball.height},
        //         (Rectangle){ball.center.x, ball.center.y, 2 * ball.radius,
        //                     2 * ball.radius},
        //         (Vector2){(float)(ball.radius), (float)(ball.radius)},
        //         ball.lightning_ball_rotation_angle,
        //         (Color){.r = 0xFF, .g = 0xFF, .b = 0xFF, .a = 0xFF});

        //     EndBlendMode();
        // }
    }

    ///
    ///
    ///
    pub fn restart(self: *Ball, table_rect: *const rl.Rectangle) void {
        self.center = rl.Vector2{
            .x = table_rect.x + ((table_rect.width - self.radius) / 2),
            .y = table_rect.y + ((table_rect.height - self.radius) / 2),
        };

        self.velocity_x = config.BALL_UI_BALL_VELOCITY_X;
        self.velocity_y = config.BALL_UI_BALL_VELOCITY_Y;
        self.current_hits = 0;
        self.current_velocities_increase = 0;
        self.enabled_fireball = false;
        self.enabled_lightning_ball = false;

        var particles = self.lighting_tail.particles;

        var i: usize = 0;
        while (i < config.BALL_UI_LIGHTING_TAIL_PARTICLE_COUNT) {
            particles[i].position = rl.Vector2{ .x = 0, .y = 0 };
            // particles[i].color = ball.color;

            // Init `alpha` value, it affects how light the particle at the
            // beginning
            particles[i].alpha = config.BALL_UI_LIGHTING_TAIL_PRATICLE_INIT_ALPHA;

            // It affects how big the particle will be: how many percentage of the
            // ball size: 0.0 ~ 1.0 (0 ~ 100%)
            particles[i].size = config.BALL_UI_LIGHTING_TAIL_PRATICLE_SIZE;
            particles[i].active = false;

            i += 1;
        }
    }

    ///
    ///
    ///
    pub fn update(
        self: *Ball,
        table_rect: *const rl.Rectangle,
        player1: *const player.Player,
        player2: *const player.Player,
        is_player1_win: *bool,
        is_player2_win: *bool,
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
