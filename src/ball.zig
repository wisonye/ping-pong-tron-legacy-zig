const rl = @cImport({
    @cInclude("raylib.h");
});
const std = @import("std");
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
        // DrawCircleV(self.center, self.radius, self.color);

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
        // if (self.enabled_lightning_ball) {
        //     BeginBlendMode(BLEND_ALPHA);

        //     DrawTexturePro(
        //         self.lightning_ball,
        //         (Rectangle){0.0f, 0.0f, (float)self.lightning_self.width,
        //                     (float)self.lightning_self.height},
        //         (Rectangle){self.center.x, self.center.y, 2 * self.radius,
        //                     2 * self.radius},
        //         (Vector2){(float)(self.radius), (float)(self.radius)},
        //         self.lightning_ball_rotation_angle,
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
            // particles[i].color = self.color;

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

        //
        // Next ball position
        //
        self.center.x += rl.GetFrameTime() * self.velocity_x;
        self.center.y += rl.GetFrameTime() * self.velocity_y;

        //
        // Ball bouncing in table
        //

        // If `ball` hit the top of `table_rect`
        if (self.center.y - self.radius <= table_rect.y) {
            self.center.y = table_rect.y + self.radius;
            self.velocity_y *= -1; // Flip the velocity_y direction
        }
        // If `ball` hit the bottom of `table_rect`
        else if (self.center.y + self.radius >=
            table_rect.y + table_rect.height)
        {
            self.center.y = table_rect.y + table_rect.height - self.radius;
            self.velocity_y *= -1; // Flip the velocity_y direction
        }

        //
        // Win or lose
        //

        // If `ball` hit the left of `table_rect`
        if (self.center.x <= table_rect.x) {
            is_player2_win.* = true;
            return;
        }
        // If `ball` hit the right of `table_rect`
        else if (self.center.x >= table_rect.x + table_rect.width) {
            is_player1_win.* = true;
            return;
        }

        //
        // Hit player's racket to increase the velocity
        //
        const ball_left_point = rl.Vector2{
            .x = self.center.x - self.radius,
            .y = self.center.y,
        };
        const ball_right_point = rl.Vector2{
            .x = self.center.x + self.radius,
            .y = self.center.y,
        };

        // If `ball` hit the left player's racket
        if (rl.CheckCollisionPointRec(ball_left_point, player1.default_racket.rect)) {
            rl.TraceLog(rl.LOG_DEBUG, ">>> [ Ball_update ] - Hit player 1 racket");
            self.center.x = player1.default_racket.rect.x +
                player1.default_racket.rect.width + self.radius;
            self.velocity_x *= -1; // Flip the velocity_x direction
            self.current_hits += 1;
            if (self.hit_racket_sound_effect) |sound| {
                rl.PlaySound(sound);
            }
        }
        // If `ball` hit the right player's racket
        else if (rl.CheckCollisionPointRec(ball_right_point, player2.default_racket.rect)) {
            rl.TraceLog(rl.LOG_DEBUG, ">>> [ Ball_update ] - Hit player 2 racket");
            self.center.x = player2.default_racket.rect.x - self.radius;
            self.velocity_x *= -1; // Flip the velocity_x direction
            self.current_hits += 1;
            if (self.hit_racket_sound_effect) |sound| {
                rl.PlaySound(sound);
            }
        }

        if (self.current_hits >= config.BALL_UI_HITS_BEFORE_INCREASE_VELOCITY) {
            // Increase `current_velocities_increase `
            self.current_velocities_increase += 1;

            // Reset
            self.current_hits = 0;

            // Increase speed
            self.velocity_x = if (self.velocity_x > 0) self.velocity_x + config.BALL_UI_VELOCITY_ACCELERATION else self.velocity_x - config.BALL_UI_VELOCITY_ACCELERATION;
            self.velocity_y = if (self.velocity_y > 0) self.velocity_y + config.BALL_UI_VELOCITY_ACCELERATION else self.velocity_y - config.BALL_UI_VELOCITY_ACCELERATION;

            var hit_debug_buf = [_:0]u8{0} ** 200;
            const hit_debug_str = std.fmt.bufPrint(
                &hit_debug_buf,
                "{d} hits happens, increase velocity to (x: {d:.2}, y: {d:.2}), current_velocities_increase: {d}",
                .{
                    config.BALL_UI_HITS_BEFORE_INCREASE_VELOCITY,
                    self.velocity_x,
                    self.velocity_y,
                    self.current_velocities_increase,
                },
            ) catch "";
            rl.TraceLog(
                rl.LOG_DEBUG,
                ">>> [ Ball_update ] - %s",
                @ptrCast([*c]const u8, hit_debug_str),
            );

            //
            // Enable fireball
            //
            if (!self.enabled_fireball and
                self.current_velocities_increase >=
                config.BALL_UI_VELOCITIES_INCREASE_TO_ENABLE_FIREBALL)
            {
                self.enabled_fireball = true;
                if (self.enable_fireball_sound_effect) |sound| {
                    rl.PlaySound(sound);
                }
                rl.TraceLog(rl.LOG_DEBUG, ">>> [ Ball_update ] - Enabled fireball");
            }

            //
            // Enable lightning ball
            //
            if (!self.enabled_lightning_ball and
                self.current_velocities_increase >=
                config.BALL_UI_VELOCITIES_INCREASE_TO_ENABLE_LIGHTNING_BALL)
            {
                self.enabled_lightning_ball = true;
                if (self.enable_lightning_ball_sound_effect) |sound| {
                    rl.PlaySound(sound);
                }
                rl.TraceLog(rl.LOG_DEBUG, ">>> [ Ball_update ] - Enabled lightning ball");

                // Reduce ball radius
                self.radius = config.BALL_UI_LIGHTING_BALL_RADIUS;

                // Reduce the tail particle size
                var particles = self.lighting_tail.particles;
                var i: usize = 0;
                while (i < config.BALL_UI_LIGHTING_TAIL_PARTICLE_COUNT) {
                    // It affects how big the particle will be: how many percentage
                    // of the ball size: 0.0 ~ 1.0 (0 ~ 100%)
                    particles[i].size =
                        config.BALL_UI_LIGHTING_TAIL_PRATICLE_SIZE_FOR_LIGHTNING_BALL;

                    i += 1;
                }
            }
        }

        //
        // Update lightning ball attriubtes
        //
        if (self.enabled_lightning_ball) {
            self.lightning_ball_rotation_angle += 32.0;
            if (self.lightning_ball_rotation_angle > 360) {
                self.lightning_ball_rotation_angle = 0;
            }
        }
    }

    ///
    ///
    ///
    pub fn update_lighting_tail(self: *Ball) void {
        //
        // Activate one particle every frame and Update active particles
        // NOTE: Particles initial position should be mouse position when
        // activated NOTE: Particles fall down with gravity and rotation... and
        // disappear after 2 seconds (alpha = 0) NOTE: When a particle
        // disappears, active = false and it can be reused.
        //
        var particles = self.lighting_tail.particles;

        var i: usize = 0;
        while (i < config.BALL_UI_LIGHTING_TAIL_PARTICLE_COUNT) {
            if (!particles[i].active) {
                particles[i].active = true;
                particles[i].alpha = config.BALL_UI_LIGHTING_TAIL_PRATICLE_INIT_ALPHA;
                particles[i].position = self.center;
                i = config.BALL_UI_LIGHTING_TAIL_PARTICLE_COUNT;
            }
            i += 1;
        }

        var index: usize = 0;
        while (index < config.BALL_UI_LIGHTING_TAIL_PARTICLE_COUNT) {
            if (particles[index].active) {
                // particles[i].position.y += gravity / 2;
                particles[index].alpha -= 0.05;

                if (particles[index].alpha <= 0.0) particles[index].active = false;
            }

            index += 1;
        }
    }
};
