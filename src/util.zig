const std = @import("std");
const rl = @import("raylib");
const game = @import("client_game.zig");

pub fn f_to_i32(f: anytype) !i32 {
    const t = @typeInfo(@TypeOf(f));
    return switch (t) {
        .Float => @as(i32, @intFromFloat(f)),
        else => error.InvalidTypeProvided,
    };
}

pub fn i_to_f32(i: anytype) !f32 {
    const t = @typeInfo(@TypeOf(i));
    return switch (t) {
        .Int => @as(f32, @floatFromInt(i)),
        else => error.InvalidTypeProvided,
    };
}

pub fn print_vector_to_console(title: []const u8, v: rl.Vector3) void {
    std.log.debug("{s}: {d},{d},{d}", .{ title, v.x, v.y, v.z });
}

/// Returns true if the point (px, py) is inside (or on the boundary of)
/// a rectangle of width w and height h, centered at (cx, cy),
/// rotated by theta radians about its center.
pub fn pointInRotatedRectangle(
    px: f64,
    py: f64,
    cx: f64,
    cy: f64,
    w: f64,
    h: f64,
    theta: f64,
) bool {

    // 1) Translate the point so the rectangle center is at (0,0)
    const center_x = cx + w * 0.5;
    const center_y = cy + h * 0.5;
    const tx = px - center_x;
    const ty = py - center_y;

    // 2) Rotate by -theta to align rectangle with axes
    const sinTheta = std.math.sin(theta * (std.math.pi / 180.0));
    const cosTheta = std.math.cos(theta * (std.math.pi / 180.0));
    const rx = tx * cosTheta - ty * sinTheta;
    const ry = tx * sinTheta + ty * cosTheta;

    // 3) Check if the rotated point lies within half-width/half-height
    const halfW = w / 2.0;
    const halfH = h / 2.0;

    return (rx >= -halfW and rx <= halfW) and (ry >= -halfH and ry <= halfH);
}

/// Returns true if the point (px, py) is inside (or on the boundary of)
/// a rectangle of width w and height h, centered at (cx, cy),
/// rotated by theta radians about its center.
pub fn drawRotatedRectangle(
    cx: f64,
    cy: f64,
    w: f64,
    h: f64,
    theta: f64,
) void {

    // 2) Rotate by -theta to align rectangle with axes
    const sinTheta = std.math.sin(theta * (std.math.pi / 180.0));
    const cosTheta = std.math.cos(theta * (std.math.pi / 180.0));

    const localCorners = [_]rl.Vector2{
        .{ .x = 0, .y = 0 },
        .{ .x = @floatCast(w), .y = 0 },
        .{ .x = @floatCast(w), .y = @floatCast(h) },
        .{ .x = 0, .y = @floatCast(h) },
        .{ .x = 0, .y = 0 }, // loop around to the first point to reduce logic down below
    };

    const colors = [4]rl.Color{
        rl.Color.green,
        rl.Color.blue,
        rl.Color.red,
        rl.Color.orange,
    };

    for (0..4) |i| {
        rl.drawLine(
            @intFromFloat((localCorners[i].x * cosTheta - localCorners[i].y * sinTheta) + cx),
            @intFromFloat((localCorners[i].x * sinTheta + localCorners[i].y * cosTheta) + cy),
            @intFromFloat((localCorners[i + 1].x * cosTheta - localCorners[i + 1].y * sinTheta) + cx),
            @intFromFloat((localCorners[i + 1].x * sinTheta + localCorners[i + 1].y * cosTheta) + cy),
            colors[i],
        );
    }
}

pub fn getScreenDimensionsAtDepth(camera: rl.Camera) rl.Vector3 {
    const a_deg: f32 = camera.fovy / 2;
    const c_len: f32 = camera.position.z;

    // 180 - 90 - half_fov
    const b_deg: f32 = 90; // Always 90
    const c_deg: f32 = 180 - (b_deg + a_deg);

    // const b_len: f32 = (c_len * std.math.sin(b_deg * std.math.rad_per_deg)) / std.math.sin(c_deg * std.math.rad_per_deg);
    const a_len: f32 = (c_len * std.math.sin(a_deg * std.math.rad_per_deg)) / std.math.sin(c_deg * std.math.rad_per_deg);
    // 960*sinb

    // std.log.debug("Angles: {d} X {d} X {d} | Lengths: {d} X {d} X {d}", .{ a_deg, b_deg, c_deg, a_len, b_len, c_len });
    return rl.Vector3{
        .y = a_len,
        .x = a_len,
        .z = c_len,
    };
}

// pub fn scaleWorldDimensionsToScreenProjection(w: f32, h: f32, l: f32, camera: rl.Camera) void {
//     const fov: f32 = camera.fovy;
//     const fov_rad: f32 = fov * (std.math.pi / 180.0);
//     const depth: f32 = camera.position.z;
//
//
//     const screen_width: f32 = try Self.i_to_f32(game.defaultScreenWidth);
//     const screen_height: f32 = try Self.i_to_f32(game.defaultScreenHeight);
//     const screen_aspect: f32 = screen_width / screen_height;
//
//
//
//
// }

// pub fn getWorldToScreen(x: f32, y: f32, z: f32, camera: rl.Camera) rl.Vector3 {
//     return getWorldToScreenByVec3(
//         rl.Vector3{
//             .x = x,
//             .y = y,
//             .z = z,
//         },
//         camera,
//     );
// }

// pub fn getWorldToScreenByVec3(vec3: rl.Vector3, camera: rl.Camera) rl.Vector3 {
//     const screen_width: f32 = try Self.i_to_f32(game.defaultScreenWidth);
//     const screen_height: f32 = try Self.i_to_f32(game.defaultScreenHeight);
//     const screen_aspect: f32 = screen_width / screen_height;
//
//     const screen_half_width = screen_width / 2;
//     const screen_half_height = screen_height / 2;
//
//     const normalized_x: f32 = (2.0 * screen_half_width / screen_width) - 1.0;
//     const normalized_y: f32 = 1.0 - (2.0 * screen_half_height / screen_height);
//
//     const fov: f32 = camera.fovy;
//     const half_fov: f32 = fov / 2;
//     const tan_half_fov: f32 = std.math.tan(half_fov);
//
//     const x_cam = normalized_x * tan_half_fov * screen_aspect;
//     const y_cam = normalized_y * tan_half_fov;
//     const z_cam = -1;
//
//     var ray_cam = rl.Vector3{ .x = x_cam, .y = y_cam, .z = z_cam };
//     ray_cam = ray_cam.normalize();
//
//     const camera_pos = camera.position;
//     const ray_world = ray_cam;
//
//     if (@abs(ray_world.z) < 1e-6) {
//         unreachable;
//     }
//
//     const t = (vec3.z - camera_pos.z) / ray_world.z;
//     const intersection = camera_pos.add(ray_world.scale(t));
//
//     const ret = rl.Vector3{
//         .x = intersection.x,
//         .y = intersection.y,
//         .z = intersection.z,
//     };
//
//     std.log.debug("getWorldToScreenByVec3: ({d}, {d}, {d})", .{ ret.x, ret.y, ret.z });
//     return ret;
// }

pub fn FrameCheck(comptime T: type) type {
    return struct {
        val: T,
        frame: f64 = 0,

        const Self = @This();

        pub fn isValid(self: *Self) bool {
            if (std.math.approxEqAbs(f64, game.current_frame_time, self.frame, 0.001)) {
                return true;
            }

            return false;
        }

        pub fn update(self: *Self, v: T) void {
            self.val = v;
            self.frame = game.current_frame_time;
        }
    };
}

pub fn frameCheck(val: anytype) FrameCheck(@TypeOf(val)) {
    return .{
        .val = val,
    };
}
