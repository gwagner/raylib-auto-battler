const std = @import("std");
const rl = @import("raylib");
const fps = @import("client_game.zig").targetFPS;
pub const Rectangle = @import("tween_rectangle.zig");
pub const Cube = @import("tween_cube.zig");

const Direction = enum { Increase, Decrease, Static };

pub fn Tween(comptime T: type) type {
    return struct {
        initial: T = 0,
        final: T = 0,
        current: f32 = 0,
        step: f32 = 0,
        direction: Direction = .Static,
        frame_counter: i32 = 0,

        const Self = @This();

        pub fn tween(self: *Self) !T {
            if (try self.finished()) return self.get_ret_val();

            self.frame_counter += 1;
            self.current += self.step;

            return self.get_ret_val();
        }

        pub fn update(self: *Self, f: T, d: f32) !void {
            // If we have are resetting a duplicate final value, then take no action
            switch (@typeInfo(T)) {
                .Float => if (std.math.approxEqRel(T, f, self.final, 0.001)) return,
                .Int => if (f == self.final) return,
                else => error.InvalidTypeProvided,
            }

            // if we are updating with the same value and duration, do nothing
            if (f == self.final) {
                return;
            }

            var direction: Direction = .Increase;
            if (self.current > self.to_f32(f)) {
                direction = .Decrease;
            }

            if (d == 0) {
                direction = .Static;
            }

            // handles static
            var step: f32 = 0;
            var current: f32 = switch (@typeInfo(T)) {
                .Float => f,
                .Int => @as(f32, @floatFromInt(f)),
                else => error.InvalidTypeProvided,
            };

            // update the vals to handle not static
            if (direction != .Static) {
                step = switch (@typeInfo(T)) {
                    .Float => (f - self.current) / (d * fps),
                    .Int => (self.to_f32(f) - self.current) / (d * fps),
                    else => error.InvalidTypeProvided,
                };

                current = self.current;
            }

            switch (@typeInfo(T)) {
                .Float => self.initial = self.current,
                .Int => self.initial = @intFromFloat(self.current),
                else => unreachable,
            }

            self.frame_counter = 0;
            self.current = current;
            self.step = step;
            self.final = f;
            self.direction = direction;
        }

        pub fn finished(self: *Self) !bool {
            if (self.direction == .Static) {
                return true;
            }

            if (std.math.approxEqRel(f32, self.current, try self.f32final(), 0.001)) {
                self.direction = .Static;
                self.current = try self.f32final();
                return true;
            }

            if (self.direction == .Increase and self.current + self.step > try self.f32final()) {
                self.direction = .Static;
                self.current = try self.f32final();
                return true;
            }

            if (self.direction == .Decrease and self.current + self.step < try self.f32final()) {
                self.direction = .Static;
                self.current = try self.f32final();
                return true;
            }

            return false;
        }

        fn get_ret_val(self: *Self) T {
            return switch (@typeInfo(T)) {
                .Float => self.current,
                .Int => switch (self.direction) {
                    .Increase => @as(T, @intFromFloat(std.math.ceil(self.current))),
                    .Decrease => @as(T, @intFromFloat(std.math.floor(self.current))),
                    .Static => @as(T, @intFromFloat(std.math.round(self.current))),
                },
                else => unreachable,
            };
        }

        fn f32final(self: *Self) !f32 {
            return self.to_f32(self.final);
        }

        fn to_f32(_: *Self, num: anytype) f32 {
            return switch (@typeInfo(T)) {
                .Float => num,
                .Int => @as(f32, @floatFromInt(num)),
                else => unreachable,
            };
        }

        pub fn debug(self: *Self) void {
            std.log.err("Initial: {d} | Final: {d} | Current: {d} | Step: {d} | Direction: {s} | FC: {d}", .{
                self.initial, self.final, self.current, self.step, @tagName(self.direction), self.frame_counter,
            });
        }
    };
}

pub fn init(comptime T: type, i: T, f: T, d: f32) Tween(T) {
    var t: Tween(T) = .{ .initial = i };
    t.update(f, d) catch {
        unreachable;
    };

    return t;
}

test "tween_float" {
    const tolerance: f32 = 0.001;

    var initial: f32 = 0;
    var final: f32 = 10;
    var duration: f32 = 2;
    var step: f32 = (final - initial) / (fps * duration);
    var res: f32 = 0;
    var tw = init(f32, initial, final, duration);

    try std.testing.expectEqual(tw.initial, initial);
    try std.testing.expectEqual(tw.final, final);
    try std.testing.expectEqual(tw.step, step);
    try std.testing.expectEqual(tw.direction, .Increase);

    for (0..120) |i| {
        try std.testing.expectApproxEqRel(step * @as(f32, @floatFromInt(i)), tw.current, tolerance);
        try std.testing.expectApproxEqRel(step * @as(f32, @floatFromInt(i)), res, tolerance);
        res = try tw.tween();
    }

    try std.testing.expectEqual(true, tw.finished());

    initial = 10;
    final = 22;
    duration = 5;
    step = (final - initial) / (fps * duration);
    try tw.update(final, duration);

    try std.testing.expectApproxEqRel(initial, tw.initial, tolerance);
    try std.testing.expectEqual(final, tw.final);
    try std.testing.expectApproxEqRel(step, tw.step, tolerance);
    try std.testing.expectEqual(.Increase, tw.direction);

    for (0..300) |i| {
        try std.testing.expectApproxEqRel(initial + step * @as(f32, @floatFromInt(i)), tw.current, tolerance);
        try std.testing.expectApproxEqRel(initial + step * @as(f32, @floatFromInt(i)), res, tolerance);
        res = try tw.tween();
    }

    try std.testing.expectEqual(true, tw.finished());

    initial = 22;
    final = 0;
    duration = 5;
    step = (final - initial) / (fps * duration);
    try tw.update(final, duration);

    try std.testing.expectApproxEqRel(initial, tw.initial, 0.001);
    try std.testing.expectEqual(final, tw.final);
    try std.testing.expectApproxEqRel(step, tw.step, 0.001);
    try std.testing.expectEqual(.Decrease, tw.direction);

    for (0..300) |i| {
        try std.testing.expectApproxEqRel(
            initial + (step * @as(f32, @floatFromInt(i))),
            tw.current,
            tolerance,
        );
        try std.testing.expectApproxEqRel(
            initial + (step * @as(f32, @floatFromInt(i))),
            res,
            tolerance,
        );
        res = try tw.tween();
    }

    try std.testing.expectEqual(true, tw.finished());
}

test "tween_int" {
    const tolerance: f32 = 0.001;

    var initial: i32 = 0;
    var final: i32 = 10;
    var duration: f32 = 2;
    var step: f32 = @as(f32, @floatFromInt(final - initial)) / (fps * duration);
    var res: i32 = 0;
    var next: f32 = 0;
    var tw = init(i32, initial, final, duration);

    try std.testing.expectEqual(tw.initial, initial);
    try std.testing.expectEqual(tw.final, final);
    try std.testing.expectApproxEqRel(step, tw.step, tolerance);
    try std.testing.expectEqual(tw.direction, .Increase);

    for (0..120) |_| {
        try std.testing.expectApproxEqRel(next, tw.current, tolerance);
        try std.testing.expectEqual(@as(i32, @intFromFloat(std.math.ceil(next))), res);
        next = tw.current + step;
        res = try tw.tween();
    }

    try std.testing.expectEqual(true, tw.finished());

    initial = 10;
    final = 22;
    duration = 5;
    step = @as(f32, @floatFromInt(final - initial)) / (fps * duration);
    try tw.update(final, duration);

    try std.testing.expectEqual(initial, tw.initial);
    try std.testing.expectEqual(final, tw.final);
    try std.testing.expectApproxEqRel(step, tw.step, 0.001);
    try std.testing.expectEqual(.Increase, tw.direction);

    for (0..300) |_| {
        try std.testing.expectApproxEqRel(next, tw.current, tolerance);
        try std.testing.expectEqual(@as(i32, @intFromFloat(std.math.ceil(next))), res);
        next = tw.current + step;
        res = try tw.tween();
    }

    try std.testing.expectEqual(true, tw.finished());

    initial = 22;
    final = 0;
    duration = 5;
    step = @as(f32, @floatFromInt(final - initial)) / (fps * duration);
    try tw.update(final, duration);

    try std.testing.expectEqual(initial, tw.initial);
    try std.testing.expectEqual(final, tw.final);
    try std.testing.expectApproxEqRel(step, tw.step, 0.001);
    try std.testing.expectEqual(.Decrease, tw.direction);

    for (0..300) |_| {
        try std.testing.expectApproxEqRel(next, tw.current, tolerance);
        try std.testing.expectEqual(@as(i32, @intFromFloat(std.math.floor(next))), res);
        next = tw.current + step;
        res = try tw.tween();
    }

    try std.testing.expectEqual(true, tw.finished());
}
