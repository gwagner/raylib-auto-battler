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
container: *container.NewContainer(*layout) = undefined,
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
    self.container = self.game.layout.shop;

    const cards = try self.player.game.shop.roll(3);
    try self.cards.appendSlice(cards);
}

pub fn update(self: *Self) !void {
    try self.refresh_shop();
    try self.update_card_cords();
    for (self.cards.items) |c| {
        try c.card.update();
    }
    self.check_card_hover();
    try self.check_card_selected();
}

pub fn update_card_cords(self: *Self) !void {
    const card_padding: f32 = 20;

    // Get the center of the screen
    const h_center_cord: f32 = try util.i_to_f32(@divFloor(self.container.getWidthPx(), 2));

    // Add up the total width of all cards in their current state
    var total_width: f32 = 0.0;
    for (self.cards.items) |c| {
        total_width += c.card.getScaledWidth() + card_padding;
    }

    var accumulated_width: f32 = 0.0;

    for (self.cards.items) |sc| {
        const c = sc.card;
        var animation_time: f32 = 0.15;
        if (c.selected) {
            animation_time = 0;
            const mouse_position = rl.getMousePosition();

            try c.destination.update_x(mouse_position.x, animation_time);
            try c.destination.update_y(mouse_position.y, animation_time);
            try c.destination.update_width(c.getScaledWidth(), animation_time);
            try c.destination.update_height(c.getScaledHeight(), animation_time);
            try c.destination.update_rotation(0, animation_time);
            continue;
        }

        try c.destination.update_x(h_center_cord - (total_width / 2) + accumulated_width + (c.getScaledWidth() / 3), animation_time);
        try c.destination.update_y(@floatFromInt(self.container.offsetY + @divFloor(self.container.getHeightPx(), 2)), animation_time);
        try c.destination.update_width(c.getScaledWidth(), animation_time);
        try c.destination.update_height(c.getScaledHeight(), animation_time);

        accumulated_width += c.getScaledWidth() + card_padding;
    }
}

pub fn check_card_hover(self: *Self) void {
    var hover_idx: i32 = -1;

    if (self.card_selected_index() == -1) {
        for (0..self.cards.items.len, self.cards.items) |i, c| {

            // remove center offset from the rect
            var rect = c.card.destination.get_raylib_rectangle();
            rect.x = rect.x - c.card.getCenterOrigin().x;
            rect.y = rect.y - c.card.getCenterOrigin().y;

            if (rl.checkCollisionPointRec(rl.getMousePosition(), rect)) {
                hover_idx = @intCast(i);
                break;
            }
        }
    }

    if (!self.player.has_card_selected) {
        for (0..self.cards.items.len, self.cards.items) |i, c| {
            if (@as(i32, @intCast(i)) == hover_idx) {
                c.card.set_hover();
                continue;
            }

            c.card.reset_hover();
        }
    }
}

pub fn check_card_selected(self: *Self) !void {
    if (!rl.isMouseButtonDown(rl.MouseButton.left)) {
        // check for card puchase
        const card_idx = self.card_selected_index();
        if (card_idx < 0) {
            return;
        }

        const c = self.cards.items[@intCast(card_idx)];
        if (c.card.destination.get_y() > try util.i_to_f32(self.container.offsetY + self.container.getHeightPx())) {
            try self.player.hand.hand.append(c.card);
            _ = self.cards.orderedRemove(@intCast(card_idx));
            try self.game.shop.purchase_card(c.index);
            // need to remove from shop
        }

        self.player.has_card_selected = false;
        c.card.reset_selected();
        return;
    }

    const hover_idx = self.card_hover_index();
    if (hover_idx < 0) {
        return;
    }

    self.cards.items[@intCast(hover_idx)].card.set_selected();
    self.player.has_card_selected = true;
}

pub fn card_hover_index(self: *Self) i32 {
    for (0..self.cards.items.len, self.cards.items) |i, c| {
        if (c.card.hover) return @intCast(i);
    }

    return -1;
}

pub fn card_selected_index(self: *Self) i32 {
    for (0..self.cards.items.len, self.cards.items) |i, c| {
        if (c.card.selected) return @intCast(i);
    }

    return -1;
}

pub fn refresh_shop(self: *Self) !void {
    if (rl.isKeyPressed(rl.KeyboardKey.r)) {
        try self.game.shop.return_cards(self.cards.items);
        self.cards.deinit();
        self.cards = std.ArrayList(*shop_card).init(self.alloc);
        const cards = try self.player.game.shop.roll(3);
        try self.cards.appendSlice(cards);
    }
}

pub fn draw(self: *Self) void {
    // start by drawing the hand
    for (self.cards.items) |c| {
        c.card.draw(c.card.getCenterOrigin());
    }
}
