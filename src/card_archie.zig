const std = @import("std");
const rl = @import("raylib");
const compose_card = @import("compose_card.zig");
const archie_bytes = @embedFile("assets/archie.jpg");
const Self = @This();

id: []const u8 = "archie",
texture: rl.Texture,

pub fn init(alloc: std.mem.Allocator) !*Self {
    const composition = compose_card.ComposedTexture{
        .dimensions = rl.Vector2{ .x = 150, .y = 200 },
        .images = ([_]rl.Image{
            try rl.loadImageFromMemory(".jpg", archie_bytes),
            try rl.loadImageFromMemory(".png", compose_card.PURPLE_CARD_FRONT_bytes),
        })[0..],
        .position = ([_]rl.Vector2{
            .{
                .x = 20,
                .y = 10,
            },
        })[0..],
    };

    const self = try alloc.create(Self);
    self.* = Self{
        .texture = try compose_card.compose(composition),
    };

    return self;
}
