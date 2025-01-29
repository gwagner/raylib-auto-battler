const std = @import("std");
const rl = @import("raylib");
const container = @import("layout_container.zig");
const card = @import("card.zig");
const game = @import("client_game.zig");
const hand = @import("player_hand.zig");
const layout = @import("layout.zig");
const shop = @import("player_shop.zig");
const Self = @This();

allocator: std.mem.Allocator,
game: *game,
hand: *hand = undefined,
shop: *shop = undefined,
container: *container.NewContainer(*layout) = undefined,

// Tracks if the player is currently selecting a card via a click
has_card_selected: bool = false,

pub fn init(alloc: std.mem.Allocator, g: *game) !*Self {
    const self: *Self = try alloc.create(Self);
    self.* = Self{
        .allocator = alloc,
        .game = g,
    };

    self.hand = try hand.init(alloc, self);
    self.shop = try shop.init(alloc, g, self);

    return self;
}

pub fn load(self: *Self) !void {
    try self.shop.load();
    try self.hand.load();
}

pub fn update(self: *Self) !void {
    try self.shop.update();
    try self.hand.update();
}

pub fn draw(self: *Self) void {
    self.shop.draw();
    self.hand.draw();
}
