const std = @import("std");
const rl = @import("raylib");
const game = @import("client_game.zig");
const tween = @import("tween.zig");
const Texture = @import("textures.zig").Cards;
const util = @import("util.zig");
const Self = @This();

allocator: std.mem.Allocator,
game: *game,

// Setup the dims
base_texture: Texture,
texture: rl.Texture = undefined,
texture_height: f32 = undefined,
texture_width: f32 = undefined,

max_width: f32 = 120,
width: f32 = undefined,
height: f32 = undefined,

destination: *tween.Rectangle,
rotation: f32,

offsetX: f32 = 0,
offsetY: f32 = 0,
zIndex: i32 = 0,

hover: bool = false,
hover_rectangle: *tween.Rectangle,
on_hover_scale: f32 = 0.2,
on_hover_animation: f32 = 0.15,
off_hover_animation: f32 = 0.05,

selected: bool = false,

pub fn init(alloc: std.mem.Allocator, c: *game, t: Texture) !*Self {
    const self: *Self = try alloc.create(Self);
    self.* = Self{
        .allocator = alloc,
        .game = c,
        .base_texture = t,
        .rotation = 0,
        .destination = try tween.Rectangle.init(alloc, 0.0, 0.0, 0.0, 0.0, 0.0),
        .hover_rectangle = try tween.Rectangle.init(alloc, 0.0, 0.0, 0.0, 0.0, 0.0),
    };

    return self;
}

pub fn load(self: *Self) !void {
    self.texture = try self.game.textures.get_card_by_id(self.base_texture);
    self.texture_height = @floatFromInt(self.texture.height);
    self.texture_width = @floatFromInt(self.texture.width);
}

pub fn update(self: *Self) !void {
    self.width = self.texture_width / self.getScaleDivisor();
    self.height = self.texture_height / self.getScaleDivisor();

    // Tween to the destination
    try self.destination.tween();
    try self.hover_rectangle.tween();
}

pub fn getScaleDivisor(self: *Self) f32 {
    const max_width = self.max_width * self.game.getScale();
    if (self.texture_width == max_width) {
        return 1;
    }

    return self.texture_width / max_width;
}

pub fn getScaledHeight(self: *Self) f32 {
    return (self.texture_height / self.getScaleDivisor()) + self.hover_rectangle.get_height();
}

pub fn getScaledWidth(self: *Self) f32 {
    return (self.texture_width / self.getScaleDivisor()) + self.hover_rectangle.get_width();
}

pub fn getSource(self: *Self) rl.Rectangle {
    return .{
        .x = 0,
        .y = 0,
        .height = self.texture_height,
        .width = self.texture_width,
    };
}

pub fn getOrigin(self: *Self) rl.Vector2 {
    return .{
        .x = 0 + self.hover_x_tween.current,
        .y = 0 + self.hover_y_tween.current,
    };
}

pub fn getCenterOrigin(self: *Self) rl.Vector2 {
    return .{
        .x = (self.getScaledWidth() / 2) + self.hover_rectangle.get_x(),
        .y = (self.getScaledHeight() / 2) + self.hover_rectangle.get_y(),
    };
}

pub fn ftoi(f: f32) i32 {
    return @intFromFloat(f);
}

pub fn set_hover(self: *Self) void {
    // already setup for hovering
    if (self.hover) {
        return;
    }

    self.hover = true;
    self.zIndex = 1;
    try self.hover_rectangle.update_rect(
        (self.width * self.on_hover_scale) / 4,
        (self.height * self.on_hover_scale) / 2,
        self.height * self.on_hover_scale,
        self.height * self.on_hover_scale,
        -1 * self.destination.get_rotation(),
        self.on_hover_animation,
    );
}

pub fn reset_hover(self: *Self) void {
    self.hover = false;
    self.zIndex = 0;
    try self.hover_rectangle.update_rect(0, 0, 0, 0, 0, self.off_hover_animation);
}

pub fn set_selected(self: *Self) void {
    self.selected = true;
    self.reset_hover();
}

pub fn reset_selected(self: *Self) void {
    self.selected = false;
    self.reset_hover();
}

pub fn draw(self: *Self, origin: rl.Vector2) void {
    rl.drawTexturePro(
        self.texture,
        self.getSource(),
        self.destination.get_raylib_rectangle(),
        origin,
        self.rotation + self.hover_rectangle.get_rotation(),
        rl.Color.white,
    );
}
