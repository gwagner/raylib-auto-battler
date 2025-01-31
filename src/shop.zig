const std = @import("std");
const card = @import("card.zig");
const game = @import("client_game.zig");
const shop_card = @import("shop_card.zig");
const Texture = @import("textures.zig").Cards;
const Self = @This();

alloc: std.mem.Allocator,
game: *game,
pool: std.ArrayList(*shop_card),
rng: std.rand.DefaultPrng,

pub fn init(alloc: std.mem.Allocator, g: *game) !*Self {
    const self = try alloc.create(Self);
    self.* = Self{
        .alloc = alloc,
        .game = g,
        .pool = std.ArrayList(*shop_card).init(alloc),
        .rng = std.rand.DefaultPrng.init(@as(u64, @bitCast(std.time.milliTimestamp()))),
    };
    return self;
}

pub fn load(self: *Self) !void {
    try self.pool.append(try shop_card.init(self.alloc, self.game, Texture.Archie_Card));
    try self.pool.append(try shop_card.init(self.alloc, self.game, Texture.Jasper_Card));
    try self.pool.append(try shop_card.init(self.alloc, self.game, Texture.McCormick_Card));
    try self.pool.append(try shop_card.init(self.alloc, self.game, Texture.Archie_Card));
    try self.pool.append(try shop_card.init(self.alloc, self.game, Texture.Jasper_Card));
    try self.pool.append(try shop_card.init(self.alloc, self.game, Texture.McCormick_Card));
    try self.pool.append(try shop_card.init(self.alloc, self.game, Texture.Archie_Card));
    try self.pool.append(try shop_card.init(self.alloc, self.game, Texture.Jasper_Card));
    try self.pool.append(try shop_card.init(self.alloc, self.game, Texture.McCormick_Card));
    try self.pool.append(try shop_card.init(self.alloc, self.game, Texture.Archie_Card));
    try self.pool.append(try shop_card.init(self.alloc, self.game, Texture.Jasper_Card));
    try self.pool.append(try shop_card.init(self.alloc, self.game, Texture.McCormick_Card));
    try self.pool.append(try shop_card.init(self.alloc, self.game, Texture.Archie_Card));
    try self.pool.append(try shop_card.init(self.alloc, self.game, Texture.Jasper_Card));
    try self.pool.append(try shop_card.init(self.alloc, self.game, Texture.McCormick_Card));
    try self.pool.append(try shop_card.init(self.alloc, self.game, Texture.Archie_Card));
    try self.pool.append(try shop_card.init(self.alloc, self.game, Texture.Jasper_Card));
    try self.pool.append(try shop_card.init(self.alloc, self.game, Texture.McCormick_Card));
    try self.pool.append(try shop_card.init(self.alloc, self.game, Texture.Archie_Card));
    try self.pool.append(try shop_card.init(self.alloc, self.game, Texture.Jasper_Card));
    try self.pool.append(try shop_card.init(self.alloc, self.game, Texture.McCormick_Card));
    try self.pool.append(try shop_card.init(self.alloc, self.game, Texture.Archie_Card));
    try self.pool.append(try shop_card.init(self.alloc, self.game, Texture.Jasper_Card));
    try self.pool.append(try shop_card.init(self.alloc, self.game, Texture.McCormick_Card));
    try self.pool.append(try shop_card.init(self.alloc, self.game, Texture.Archie_Card));
    try self.pool.append(try shop_card.init(self.alloc, self.game, Texture.Jasper_Card));
    try self.pool.append(try shop_card.init(self.alloc, self.game, Texture.McCormick_Card));
    try self.pool.append(try shop_card.init(self.alloc, self.game, Texture.Archie_Card));
    try self.pool.append(try shop_card.init(self.alloc, self.game, Texture.Jasper_Card));
    try self.pool.append(try shop_card.init(self.alloc, self.game, Texture.McCormick_Card));
    try self.pool.append(try shop_card.init(self.alloc, self.game, Texture.Archie_Card));
    try self.pool.append(try shop_card.init(self.alloc, self.game, Texture.Jasper_Card));
    try self.pool.append(try shop_card.init(self.alloc, self.game, Texture.McCormick_Card));
    try self.pool.append(try shop_card.init(self.alloc, self.game, Texture.Archie_Card));
    try self.pool.append(try shop_card.init(self.alloc, self.game, Texture.Jasper_Card));
    try self.pool.append(try shop_card.init(self.alloc, self.game, Texture.McCormick_Card));
    try self.pool.append(try shop_card.init(self.alloc, self.game, Texture.Archie_Card));
    try self.pool.append(try shop_card.init(self.alloc, self.game, Texture.Jasper_Card));
    try self.pool.append(try shop_card.init(self.alloc, self.game, Texture.McCormick_Card));
    try self.pool.append(try shop_card.init(self.alloc, self.game, Texture.Archie_Card));
    try self.pool.append(try shop_card.init(self.alloc, self.game, Texture.Jasper_Card));
    try self.pool.append(try shop_card.init(self.alloc, self.game, Texture.McCormick_Card));
    try self.pool.append(try shop_card.init(self.alloc, self.game, Texture.Archie_Card));
    try self.pool.append(try shop_card.init(self.alloc, self.game, Texture.Jasper_Card));
    try self.pool.append(try shop_card.init(self.alloc, self.game, Texture.McCormick_Card));
    try self.pool.append(try shop_card.init(self.alloc, self.game, Texture.Archie_Card));
    try self.pool.append(try shop_card.init(self.alloc, self.game, Texture.Jasper_Card));
    try self.pool.append(try shop_card.init(self.alloc, self.game, Texture.McCormick_Card));
    try self.pool.append(try shop_card.init(self.alloc, self.game, Texture.Archie_Card));
    try self.pool.append(try shop_card.init(self.alloc, self.game, Texture.Jasper_Card));
    try self.pool.append(try shop_card.init(self.alloc, self.game, Texture.McCormick_Card));
    try self.pool.append(try shop_card.init(self.alloc, self.game, Texture.Archie_Card));
    try self.pool.append(try shop_card.init(self.alloc, self.game, Texture.Jasper_Card));
    try self.pool.append(try shop_card.init(self.alloc, self.game, Texture.McCormick_Card));
    try self.pool.append(try shop_card.init(self.alloc, self.game, Texture.Archie_Card));
    try self.pool.append(try shop_card.init(self.alloc, self.game, Texture.Jasper_Card));
    try self.pool.append(try shop_card.init(self.alloc, self.game, Texture.McCormick_Card));
    try self.pool.append(try shop_card.init(self.alloc, self.game, Texture.Archie_Card));
    try self.pool.append(try shop_card.init(self.alloc, self.game, Texture.Jasper_Card));
    try self.pool.append(try shop_card.init(self.alloc, self.game, Texture.McCormick_Card));
    try self.pool.append(try shop_card.init(self.alloc, self.game, Texture.Archie_Card));
    try self.pool.append(try shop_card.init(self.alloc, self.game, Texture.Jasper_Card));
    try self.pool.append(try shop_card.init(self.alloc, self.game, Texture.McCormick_Card));

    for (0..self.pool.items.len, self.pool.items) |i, c| {
        c.index = i;
        try c.load();
    }
}

// FIXME: Absolutely not thread safe in any way which is fine for local testing, but will need to consider
// thread safety once more than one player rolls
pub fn roll(self: *Self, num_cards: u32) ![]*shop_card {
    var ret = std.ArrayList(*shop_card).init(self.alloc);
    defer ret.deinit();

    for (0..num_cards) |_| {
        const index = try self.get_random_unlocked_card_index();
        self.pool.items[index].locked = true;
        try ret.append(self.pool.items[index]);
    }

    return try ret.toOwnedSlice();
}

pub fn return_cards(_: *Self, cards: []*shop_card) !void {
    for (cards) |c| {
        c.locked = false;
    }
}

pub fn purchase_card(self: *Self, idx: usize) !void {
    self.pool.items[idx].purchased = true;
}

pub fn get_random_unlocked_card_index(self: *Self) !usize {
    var ittr: i32 = 0;
    while (true) {
        ittr += 1;
        const index = @mod(self.rng.random().int(u32), self.pool.items.len);
        if (!self.pool.items[@intCast(index)].locked and !self.pool.items[@intCast(index)].purchased) {
            return @intCast(index);
        }

        if (ittr > self.pool.items.len) {
            return error.NoValidCardsInShop;
        }
    }
}
