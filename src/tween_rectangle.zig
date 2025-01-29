const std = @import("std");
const rl = @import("raylib");
const tw = @import("tween.zig");
const Self = @This();

x: tw.Tween(f32),
y: tw.Tween(f32),
height: tw.Tween(f32),
width: tw.Tween(f32),
rotation: tw.Tween(f32),

pub fn init(alloc: std.mem.Allocator, x: f32, y: f32, h: f32, w: f32, r: f32) !*Self {
    const self = try alloc.create(Self);
    self.* = Self{
        .x = tw.init(f32, x, x, 0),
        .y = tw.init(f32, y, y, 0),
        .height = tw.init(f32, h, h, 0),
        .width = tw.init(f32, w, w, 0),
        .rotation = tw.init(f32, r, r, 0),
    };

    return self;
}

pub fn update_rect(self: *Self, x: f32, y: f32, h: f32, w: f32, r: f32, d: f32) !void {
    try self.x.update(x, d);
    try self.y.update(y, d);
    try self.height.update(h, d);
    try self.width.update(w, d);
    try self.rotation.update(r, d);
}

pub fn update_x(self: *Self, x: f32, d: f32) !void {
    try self.x.update(x, d);
}

pub fn update_y(self: *Self, y: f32, d: f32) !void {
    try self.y.update(y, d);
}

pub fn update_height(self: *Self, h: f32, d: f32) !void {
    try self.height.update(h, d);
}

pub fn update_width(self: *Self, w: f32, d: f32) !void {
    try self.width.update(w, d);
}

pub fn update_rotation(self: *Self, r: f32, d: f32) !void {
    try self.rotation.update(r, d);
}

pub fn tween(self: *Self) !void {
    _ = try self.x.tween();
    _ = try self.y.tween();
    _ = try self.height.tween();
    _ = try self.width.tween();
    _ = try self.rotation.tween();
}

pub fn get_raylib_rectangle(self: *Self) rl.Rectangle {
    return .{
        .x = self.get_x(),
        .y = self.get_y(),
        .width = self.get_width(),
        .height = self.get_height(),
    };
}

pub fn get_x(self: *Self) f32 {
    return self.x.current;
}
pub fn get_y(self: *Self) f32 {
    return self.y.current;
}
pub fn get_height(self: *Self) f32 {
    return self.height.current;
}
pub fn get_width(self: *Self) f32 {
    return self.width.current;
}
pub fn get_rotation(self: *Self) f32 {
    return self.rotation.current;
}
