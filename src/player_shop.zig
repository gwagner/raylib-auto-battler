const std = @import("std");
const rl = @import("raylib");
const container = @import("layout_container.zig");
const game = @import("client_game.zig");
const layout = @import("layout.zig");
const player = @import("player.zig");
const shop_card = @import("shop_card.zig");
const util = @import("util.zig");
const Self = @This();

alloc: std.mem.Allocator,
game: *game,
player: *player,

cards: std.ArrayList(*shop_card),

pub fn init(alloc: std.mem.Allocator, g: *game, p: *player) !*Self {
    const self = try alloc.create(Self);
    self.* = Self{
        .alloc = alloc,
        .cards = std.ArrayList(*shop_card).init(alloc),
        .game = g,
        .player = p,
    };

    return self;
}

pub fn load(self: *Self) !void {
    try self.refresh_shop();
}

pub fn update(self: *Self) !void {
    if (rl.isKeyPressed(rl.KeyboardKey.r)) {
        try self.refresh_shop();
    }
    try self.update_card_cords();
    for (self.cards.items) |c| {
        try c.update();
    }
}

pub fn update_card_cords(self: *Self) !void {
    const shop_dims = self.game.layout.shop_dims;
    const shop_position = shop_dims.get_raylib_position_vec3();
    const card_padding: f32 = 20;

    var total_width: f32 = 0.0;
    for (self.cards.items) |c| {
        if (c.card.is_selected.val) continue;
        total_width += c.card.position.get_width() + card_padding;
    }

    var accumulated_width: f32 = 0.0;
    for (self.cards.items) |sc| {
        const c = sc.card;
        const animation_time: f32 = 0.15;

        if (c.is_selected.val) {
            // setup to follow the mouse

            continue;
        }

        try c.position.update_x(
            (0 - (total_width / 2)) + accumulated_width + (c.position.get_width() / 2),
            animation_time,
        );
        try c.position.update_y(
            shop_position.y,
            animation_time,
        );

        accumulated_width += c.position.get_width() + card_padding;
    }

    // const card_padding: f32 = 20;
    //
    // // Get the center of the screen
    // const h_center_cord: f32 = try util.i_to_f32(@divFloor(self.container.getWidthPx(), 2));
    //
    // // Add up the total width of all cards in their current state
    // var total_width: f32 = 0.0;
    // for (self.cards.items) |c| {
    //     total_width += c.card.getScaledWidth() + card_padding;
    // }
    //
    // var accumulated_width: f32 = 0.0;
    //
    // for (self.cards.items) |sc| {
    //     const c = sc.card;
    //     var animation_time: f32 = 0.15;
    //     if (c.selected) {
    //         animation_time = 0;
    //         const mouse_position = rl.getMousePosition();
    //
    //         try c.destination.update_x(mouse_position.x, animation_time);
    //         try c.destination.update_y(mouse_position.y, animation_time);
    //         try c.destination.update_width(c.getScaledWidth(), animation_time);
    //         try c.destination.update_height(c.getScaledHeight(), animation_time);
    //         try c.destination.update_rotation(0, animation_time);
    //         continue;
    //     }
    //
    //     try c.destination.update_x(h_center_cord - (total_width / 2) + accumulated_width + (c.getScaledWidth() / 3), animation_time);
    //     try c.destination.update_y(@floatFromInt(self.container.offsetY + @divFloor(self.container.getHeightPx(), 2)), animation_time);
    //     try c.destination.update_width(c.getScaledWidth(), animation_time);
    //     try c.destination.update_height(c.getScaledHeight(), animation_time);
    //
    //     accumulated_width += c.getScaledWidth() + card_padding;
    // }
}

pub fn card_selected_index(self: *Self) i32 {
    for (0..self.cards.items.len, self.cards.items) |i, c| {
        if (c.card.is_selected) return @intCast(i);
    }

    return -1;
}

pub fn refresh_shop(self: *Self) !void {
    try self.game.shop.return_cards(self.cards.items);
    self.cards.deinit();
    self.cards = std.ArrayList(*shop_card).init(self.alloc);
    const cards = try self.player.game.shop.roll(7);
    try self.cards.appendSlice(cards);

    // FIXME: Probs want to set an initial position here after we get cards to stop some of the flashing
    for (self.cards.items) |c| {
        try c.card.position.update_z(self.game.layout.shop_dims.get_z() + 10, 0);
        c.card.parent_position = self.game.layout.shop_dims;
    }
}

pub fn draw(self: *Self) void {
    // start by drawing the hand
    for (self.cards.items) |c| {
        // c.card.draw(c.card.getCenterOrigin());
        c.card.draw();
    }
}
