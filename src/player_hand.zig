const std = @import("std");
const rl = @import("raylib");
const card = @import("card.zig");
const container = @import("layout_container.zig");
const layout = @import("layout.zig");
const player = @import("player.zig");
const tween = @import("tween.zig");
const util = @import("util.zig");
const Self = @This();

allocator: std.mem.Allocator,
container: *container.NewContainer(*layout) = undefined,
player: *player,

hand: std.ArrayList(*card) = undefined,

pub fn init(alloc: std.mem.Allocator, p: *player) !*Self {
    const self: *Self = try alloc.create(Self);
    self.* = Self{
        .allocator = alloc,
        .player = p,
        .hand = std.ArrayList(*card).init(alloc),
    };

    return self;
}

pub fn load(self: *Self) !void {
    self.container = self.player.game.layout.current_player;
    // const cards = try self.player.game.shop.roll(3);
    // std.log.debug("Got {d} cards", .{cards.len});
    // try self.hand.appendSlice(cards);
}

pub fn update(self: *Self) !void {
    for (self.hand.items) |c| {
        try c.update();
    }
    try self.update_hand_coordinates();
    try self.update_hand_coordinates_card_hover();
    try self.check_card_selected();
}

const card_rotation: i32 = 1;
pub fn update_hand_coordinates(self: *Self) !void {
    const card_overlap: f32 = 0.4;

    // Get the center of the screen
    const h_center_cord: f32 = try util.i_to_f32(@divFloor(self.container.getWidthPx(), 2));

    // Add up the total width of all cards in their current state
    var total_width: f32 = 0.0;
    for (self.hand.items) |c| {
        total_width += c.getScaledWidth() * card_overlap;
    }

    var accumulated_width: f32 = 0.0;

    for (0..self.hand.items.len, self.hand.items) |i, c| {
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

        // Calculate a vertical offset like holding a hand of cards
        const verticalOffset: i32 = @as(i32, @intCast(@abs((-1 * (@as(i32, @intCast(self.hand.items.len / 2)) - @as(i32, @intCast(i))))))) * 2;

        try c.destination.update_x(h_center_cord - (total_width / 2) + accumulated_width + (c.getScaledWidth() / 3), animation_time);
        try c.destination.update_y(@floatFromInt(self.container.offsetY + @as(i32, @intFromFloat(c.height / 2.0)) + verticalOffset), animation_time);
        try c.destination.update_width(c.getScaledWidth(), animation_time);
        try c.destination.update_height(c.getScaledHeight(), animation_time);

        const rot: i32 = (-1 * (@as(i32, @intCast(self.hand.items.len / 2)) - @as(i32, @intCast(i)))) * card_rotation;
        c.rotation = @floatFromInt(rot);
        try c.destination.update_rotation(@floatFromInt(rot), animation_time);

        accumulated_width += c.getScaledWidth() * card_overlap;
    }
}

pub fn update_hand_coordinates_card_hover(self: *Self) !void {
    const mouse_position = rl.getMousePosition();
    var hover_idx: i32 = -1;

    // Do not hover when a card is selected
    if (self.card_selected_index() == -1) {
        for (0..2) |z| {
            const zIndex = 1 - z;
            for (0..self.hand.items.len) |i| {
                // Reverses the index to go largest to smallest
                const idx = self.hand.items.len - 1 - i;
                const c = self.hand.items[idx];

                // Check the cards that are closer first
                if (c.zIndex != zIndex) {
                    continue;
                }

                if (self.player.game.debug) {
                    util.drawRotatedRectangle(
                        c.destination.get_x() - c.getCenterOrigin().x,
                        c.destination.get_y() - c.getCenterOrigin().y,
                        c.getScaledWidth(),
                        c.getScaledHeight(),
                        c.destination.get_rotation() + c.hover_rectangle.get_rotation(),
                    );
                }

                if (util.pointInRotatedRectangle(
                    mouse_position.x,
                    mouse_position.y,
                    c.destination.get_x() - c.getCenterOrigin().x,
                    c.destination.get_y() - c.getCenterOrigin().y,
                    c.getScaledWidth(),
                    c.getScaledHeight(),
                    c.destination.get_rotation() + c.hover_rectangle.get_rotation(),
                ) and hover_idx < 0) {
                    hover_idx = @intCast(idx);
                }
            }
        }
    }

    if (!self.player.has_card_selected) {
        for (0..self.hand.items.len, self.hand.items) |i, c| {
            // currently hovered card
            if (i == hover_idx) {
                c.set_hover();
                continue;
            }

            // un-hover everyone else
            c.reset_hover();
        }
    }
}

pub fn card_hover_index(self: *Self) i32 {
    for (0..self.hand.items.len, self.hand.items) |i, c| {
        if (c.hover) return @intCast(i);
    }

    return -1;
}

pub fn check_card_selected(self: *Self) !void {
    if (!rl.isMouseButtonDown(rl.MouseButton.left)) {
        for (self.hand.items) |c| {
            if (c.selected) c.reset_selected();
        }
        return;
    }

    const hover_idx = self.card_hover_index();
    if (hover_idx < 0) {
        return;
    }

    self.hand.items[@intCast(hover_idx)].set_selected();
}

pub fn card_selected_index(self: *Self) i32 {
    for (0..self.hand.items.len, self.hand.items) |i, c| {
        if (c.selected) return @intCast(i);
    }

    return -1;
}

pub fn draw(self: *Self) void {
    // start by drawing the hand
    for (0..2) |i| {
        for (self.hand.items) |c| {
            if (c.zIndex == i)
                c.draw(c.getCenterOrigin());
        }
    }
}
