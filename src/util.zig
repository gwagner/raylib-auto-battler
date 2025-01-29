const std = @import("std");
const rl = @import("raylib");

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
