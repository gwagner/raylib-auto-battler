const std = @import("std");
const rl = @import("raylib");
const game = @import("client_game.zig");
const texture = @import("textures.zig").Texture;
const Self = @This();

alloc: std.mem.Allocator,
artwork: *texture = undefined,
card_frame: *texture = undefined,

game: *game,

pub fn init(alloc: std.mem.Allocator, g: *game) !*Self {
    const self = alloc.create(Self);
    self.* = Self{
        .alloc = alloc,
        .game = g,
        .artwork = g.textures.get_texture_by_id(game.Textures.ARCHIE),
        .card_frame = g.textures.get_texture_by_id(game.Textures.PURPLE_CARD_FRONT),
    };
}
