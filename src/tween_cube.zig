const std = @import("std");
const rl = @import("raylib");
const tw = @import("tween.zig");
const util = @import("util.zig");
const Self = @This();

tweening: bool = false,

x: tw.Tween(f32),
y: tw.Tween(f32),
z: tw.Tween(f32),
height: tw.Tween(f32),
width: tw.Tween(f32),
length: tw.Tween(f32),
rotation_x: tw.Tween(f32),
rotation_y: tw.Tween(f32),
rotation_z: tw.Tween(f32),
positions: std.ArrayList(Position),

pub fn init_zero(alloc: std.mem.Allocator) !*Self {
    return Self.init(alloc, 0, 0, 0, 0, 0, 0, 0, 0);
}

pub fn init(alloc: std.mem.Allocator, x: f32, y: f32, z: f32, h: f32, w: f32, l: f32, rx: f32, ry: f32, rz: f32) !*Self {
    const self = try alloc.create(Self);
    self.* = Self{
        .x = tw.init(f32, x, x, 0),
        .y = tw.init(f32, y, y, 0),
        .z = tw.init(f32, z, z, 0),
        .height = tw.init(f32, h, h, 0),
        .width = tw.init(f32, w, w, 0),
        .length = tw.init(f32, l, l, 0),
        .rotation_x = tw.init(f32, rx, rx, 0),
        .rotation_y = tw.init(f32, ry, ry, 0),
        .rotation_z = tw.init(f32, rz, rz, 0),
        .positions = std.ArrayList(Position).init(alloc),
    };

    return self;
}

pub fn deinit(self: *Self) void {
    self.positions.deinit();
}

pub fn update_cube(self: *Self, x: f32, y: f32, h: f32, w: f32, rx: f32, ry: f32, rz: f32, d: f32) !void {
    try self.x.update(x, d);
    try self.y.update(y, d);
    try self.z.update(y, d);
    try self.height.update(h, d);
    try self.width.update(w, d);
    try self.length.update(w, d);
    try self.rotation_x.update(rx, d);
    try self.rotation_y.update(ry, d);
    try self.rotation_z.update(rz, d);
}

pub fn update_x(self: *Self, x: f32, d: f32) !void {
    try self.x.update(x, d);
}

pub fn update_y(self: *Self, y: f32, d: f32) !void {
    try self.y.update(y, d);
}

pub fn update_z(self: *Self, z: f32, d: f32) !void {
    try self.z.update(z, d);
}

pub fn update_height(self: *Self, h: f32, d: f32) !void {
    try self.height.update(h, d);
}

pub fn update_width(self: *Self, w: f32, d: f32) !void {
    try self.width.update(w, d);
}

pub fn update_length(self: *Self, l: f32, d: f32) !void {
    try self.width.update(l, d);
}

pub fn update_rotation_x(self: *Self, r: f32, d: f32) !void {
    try self.rotation_x.update(r, d);
}
pub fn update_rotation_y(self: *Self, r: f32, d: f32) !void {
    try self.rotation_y.update(r, d);
}
pub fn update_rotation_z(self: *Self, r: f32, d: f32) !void {
    try self.rotation_z.update(r, d);
}

pub fn tween(self: *Self) !void {
    _ = try self.x.tween();
    _ = try self.y.tween();
    _ = try self.z.tween();
    _ = try self.height.tween();
    _ = try self.width.tween();
    _ = try self.length.tween();
    _ = try self.rotation_x.tween();
    _ = try self.rotation_y.tween();
    _ = try self.rotation_z.tween();

    // Check if all tweens are compelted
    self.tweening = false;
    inline for (std.meta.fields(@TypeOf(self.*))) |field| {
        if (@TypeOf(@field(self, field.name)) == tw.Tween(f32)) {
            if (try @field(self, field.name).finished() == false) {
                self.tweening = true;
                break;
            }
        }
    }

    if (self.positions.items.len > 0 and !self.tweening) {
        const next_position = self.positions.orderedRemove(0);
        if (next_position.x != null) {
            try self.x.update(next_position.x orelse unreachable, next_position.duration);
        }
        if (next_position.y != null) {
            try self.y.update(next_position.y orelse unreachable, next_position.duration);
        }
        if (next_position.z != null) {
            try self.z.update(next_position.z orelse unreachable, next_position.duration);
        }
        if (next_position.width != null) {
            try self.width.update(next_position.width orelse unreachable, next_position.duration);
        }
        if (next_position.height != null) {
            try self.height.update(next_position.height orelse unreachable, next_position.duration);
        }
        if (next_position.length != null) {
            try self.length.update(next_position.length orelse unreachable, next_position.duration);
        }
        if (next_position.rotation_x != null) {
            try self.rotation_x.update(next_position.rotation_x orelse unreachable, next_position.duration);
        }
        if (next_position.rotation_y != null) {
            try self.rotation_y.update(next_position.rotation_y orelse unreachable, next_position.duration);
        }
        if (next_position.rotation_z != null) {
            try self.rotation_z.update(next_position.rotation_z orelse unreachable, next_position.duration);
        }

        self.tweening = true;
    }
}

pub fn get_raylib_position_vec3(self: *Self) rl.Vector3 {
    return .{
        .x = self.get_x(),
        .y = self.get_y(),
        .z = self.get_z(),
    };
}

pub fn get_raylib_final_position_vec3(self: *Self) rl.Vector3 {
    return .{
        .x = self.x.final,
        .y = self.y.final,
        .z = self.z.final,
    };
}

pub fn get_raylib_size_vec3(self: *Self) rl.Vector3 {
    return .{
        .x = self.get_width(),
        .y = self.get_height(),
        .z = self.get_length(),
    };
}

pub fn get_raylib_final_size_vec3(self: *Self) rl.Vector3 {
    return .{
        .x = self.width.final,
        .y = self.height.final,
        .z = self.length.final,
    };
}

pub fn get_raylib_rotation_vec3(self: *Self) rl.Vector3 {
    return .{
        .x = self.get_rotation_x(),
        .y = self.get_rotation_y(),
        .z = self.get_rotation_z(),
    };
}

pub fn get_raylib_final_rotation_vec3(self: *Self) rl.Vector3 {
    return .{
        .x = self.rotation_x.final,
        .y = self.rotation_y.final,
        .z = self.rotation_z.final,
    };
}

pub fn get_cube_vec3(self: *Self) Cube {
    return .{
        .position = self.get_raylib_position_vec3(),
        .dimension = self.get_raylib_size_vec3(),
        .rotation = self.get_raylib_rotation_vec3(),
    };
}
pub fn get_x(self: *Self) f32 {
    return self.x.current;
}
pub fn get_y(self: *Self) f32 {
    return self.y.current;
}
pub fn get_z(self: *Self) f32 {
    return self.z.current;
}
pub fn get_height(self: *Self) f32 {
    return self.height.current;
}
pub fn get_width(self: *Self) f32 {
    return self.width.current;
}
pub fn get_length(self: *Self) f32 {
    return self.length.current;
}
pub fn get_rotation_x(self: *Self) f32 {
    return self.rotation_x.current;
}
pub fn get_rotation_y(self: *Self) f32 {
    return self.rotation_y.current;
}
pub fn get_rotation_z(self: *Self) f32 {
    return self.rotation_z.current;
}
const Cube = struct {
    position: rl.Vector3,
    dimension: rl.Vector3,
    rotation: rl.Vector3,
};

pub const Position = struct {
    x: ?f32 = undefined,
    y: ?f32 = undefined,
    z: ?f32 = undefined,
    height: ?f32 = undefined,
    width: ?f32 = undefined,
    length: ?f32 = undefined,
    rotation_x: ?f32 = undefined,
    rotation_y: ?f32 = undefined,
    rotation_z: ?f32 = undefined,
    duration: f32,
};
