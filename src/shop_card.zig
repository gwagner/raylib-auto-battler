const std = @import("std");
const card = @import("card.zig");
const game = @import("client_game.zig");
const Self = @This();

allocator: std.mem.Allocator,
game: *game,

index: usize = undefined,
card: *card,
locked: bool = false,
purchased: bool = false,

pub fn init(alloc: std.mem.Allocator, c: *game) !*Self {
    const self: *Self = try alloc.create(Self);
    self.* = Self{
        .allocator = alloc,
        .game = c,
        .card = try card.init(alloc, c),
    };

    return self;
}

pub fn load(self: *Self) !void {
    try self.card.load();
}
