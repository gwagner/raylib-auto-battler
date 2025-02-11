const std = @import("std");
const card = @import("card.zig");
const game = @import("client_game.zig");
const tween = @import("tween.zig");
const Texture = @import("textures.zig").Cards;
const Self = @This();

allocator: std.mem.Allocator,
game: *game,

index: usize = undefined,
card: *card,
locked: bool = false,
purchased: bool = false,

pub fn init(alloc: std.mem.Allocator, g: *game, c: []const u8) !*Self {
    const self: *Self = try alloc.create(Self);
    self.* = Self{
        .allocator = alloc,
        .game = g,
        .card = try card.init(alloc, g, c),
    };

    return self;
}

pub fn update(self: *Self) !void {
    try self.card.update();
}

pub fn load(self: *Self) !void {
    try self.card.load();
}
