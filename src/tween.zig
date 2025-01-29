const std = @import("std");
const rl = @import("raylib");
const fps = @import("client_game.zig").targetFPS;
pub const Rectangle = @import("tween_rectangle.zig");

const Direction = enum { Increase, Decrease, Static };

pub fn Tween(comptime T: type) type {
    return struct {
        initial: T,
        final: T,
        current: f32,
        step: f32,
        direction: Direction,
        frame_counter: i32 = 0,

        const Self = @This();

        pub fn tween(self: *Self) !T {
            if (try self.finished()) return self.get_ret_val();

            self.frame_counter += 1;
            self.current += self.step;

            return self.get_ret_val();
        }

        pub fn update(self: *Self, f: T, d: f32) !void {
            var direction: Direction = .Increase;
            if (self.current > f) {
                direction = .Decrease;
            }

            if (d == 0) {
                direction = .Static;
            }

            var current: f32 = switch (@typeInfo(T)) {
                .Float => f,
                .Int => @as(f32, @floatFromInt(f)),
                else => error.InvalidTypeProvided,
            };

            var step: f32 = 0;
            if (direction != .Static) {
                step = switch (@typeInfo(T)) {
                    .Float => (f - self.current) / (d * fps),
                    .Int => @as(f32, @floatFromInt(f - self.current)) / (d * fps),
                    else => error.InvalidTypeProvided,
                };

                current = switch (@typeInfo(T)) {
                    .Float => self.current,
                    .Int => @as(f32, @floatFromInt(self.current)),
                    else => error.InvalidTypeProvided,
                };
            }

            self.frame_counter = 0;
            self.current = current;
            self.step = step;
            self.final = f;
            self.direction = direction;
        }

        fn get_ret_val(self: *Self) !T {
            return switch (@typeInfo(T)) {
                .Float => self.current,
                .Int => @as(T, @intFromFloat(self.current)),
                else => error.InvalidTypeProvided,
            };
        }

        pub fn finished(self: *Self) !bool {
            return switch (self.direction) {
                .Decrease => {
                    if (self.current > try self.f32final()) return false else return true;
                },
                .Increase => {
                    if (self.current < try self.f32final()) return false else return true;
                },
                .Static => true,
            };
        }

        fn f32final(self: *Self) !f32 {
            return switch (@typeInfo(T)) {
                .Float => self.final,
                .Int => @as(f32, @floatFromInt(self.final)),
                else => error.InvalidTypeProvided,
            };
        }
    };
}

pub fn init(comptime T: type, i: T, f: T, d: f32) Tween(T) {
    var direction: Direction = .Increase;
    if (i > f) {
        direction = .Decrease;
    }

    const current: f32 = switch (@typeInfo(T)) {
        .Float => i,
        .Int => @as(f32, @floatFromInt(i)),
        else => error.InvalidTypeProvided,
    };

    var step: f32 = 0;
    if (d != 0) {
        step = switch (@typeInfo(T)) {
            .Float => (f - i) / (d * fps),
            .Int => @as(f32, @floatFromInt(f - i)) / (d * fps),
            else => error.InvalidTypeProvided,
        };
    }

    return .{
        .initial = i,
        .final = f,
        .current = current,
        .step = step,
        .direction = direction,
    };
}
