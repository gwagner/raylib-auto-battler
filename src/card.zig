const std = @import("std");
const rl = @import("raylib");
const game = @import("client_game.zig");
const tween = @import("tween.zig");
const Texture = @import("textures.zig").Cards;
const util = @import("util.zig");
const Self = @This();
pub const default_width: f32 = 150;
pub const default_height: f32 = 200;
pub const default_length: f32 = 5;

allocator: std.mem.Allocator,
game: *game,

model: rl.Model = undefined,

max_width: f32 = 120,
width: f32 = undefined,
height: f32 = undefined,

parent_position: *tween.Cube = undefined,
position: *tween.Cube,
mouse_collision: util.FrameCheck(bool) = util.frameCheck(false),
is_hovering: util.FrameCheck(bool) = util.frameCheck(false),
is_selected: util.FrameCheck(bool) = util.frameCheck(false),

pub fn init(alloc: std.mem.Allocator, g: *game, n: []const u8) !*Self {
    const model = try g.models.get_model(n);

    const self: *Self = try alloc.create(Self);
    self.* = Self{
        .allocator = alloc,
        .game = g,
        .model = model,
        .position = try tween.Cube.init_zero(alloc),
    };

    try self.position.update_width(Self.default_width, 0);
    try self.position.update_height(Self.default_height, 0);
    try self.position.update_length(Self.default_length, 0);

    return self;
}

pub fn load(self: *Self) !void {
    _ = self;
}

pub fn update(self: *Self) !void {
    try self.check_hover();
    try self.check_selected();

    // std.log.debug("Hover State: {}", .{self.is_hovering.val});
    try self.update_hover_size();
    if (self.is_selected.val) {
        try self.update_selected_position();
    }

    try self.position.tween();
}

pub fn check_mouse_collision(self: *Self) bool {
    if (self.mouse_collision.isValid()) {
        return self.mouse_collision.val;
    }

    // Always check if we are hovering
    const ray = rl.getScreenToWorldRay(rl.getMousePosition(), self.game.camera);
    var bb = rl.getModelBoundingBox(self.model);
    bb.min.x = self.position.get_x() + bb.min.x;
    bb.min.y = self.position.get_y() + bb.min.y;
    bb.min.z = self.position.get_z() + bb.min.z;
    bb.max.x = self.position.get_x() + bb.max.x;
    bb.max.y = self.position.get_y() + bb.max.y;
    bb.max.z = self.position.get_z() + bb.max.z;

    const collision = rl.getRayCollisionBox(ray, bb);
    self.mouse_collision.update(collision.hit);
    return self.mouse_collision.val;
}

pub fn check_hover(self: *Self) !void {
    if (self.is_hovering.isValid()) {
        return;
    }

    self.is_hovering.update(self.check_mouse_collision());
}

pub fn update_hover_size(self: *Self) !void {

    // If we have a card selected, do not do a hover check
    if (self.game.current_player.has_card_selected or self.is_selected.val) {
        return;
    }

    if (!self.is_hovering.val) {
        try self.position.update_width(Self.default_width, 0.15);
        try self.position.update_height(Self.default_height, 0.15);
        try self.position.update_z(self.parent_position.get_z() + 10, 0.15);

        return;
    }

    try self.position.update_width(Self.default_width * 1.15, 0.15);
    try self.position.update_height(Self.default_height * 1.15, 0.15);
    try self.position.update_z(self.parent_position.get_z() + 20, 0.15);
}

pub fn check_selected(self: *Self) !void {
    // if there is no collision, we can never be selecting a card
    if (!self.is_hovering.val) {
        return;
    }

    // if we already ran this check this frame, move on
    if (self.is_selected.isValid()) {
        return;
    }

    // if we currently have nothing selected
    if (!self.game.current_player.has_card_selected and !self.is_selected.val) {

        // and we are trying to select something
        if (rl.isMouseButtonDown(rl.MouseButton.left) and self.check_mouse_collision()) {
            std.log.debug("Set Selected State", .{});
            self.is_selected.update(true);
            self.is_hovering.update(false);
            self.game.current_player.has_card_selected = true;
            return;
        }
    }

    // if we think we have something selected, but the mouse button is not depressed
    if (self.game.current_player.has_card_selected and !rl.isMouseButtonDown(rl.MouseButton.left)) {
        std.log.debug("Set Deselected State", .{});
        self.is_selected.update(false);
        self.game.current_player.has_card_selected = false;
        return;
    }

    if (self.game.current_player.has_card_selected and !rl.isWindowFocused()) {
        std.log.debug("Set Deselected State: Loose Focus", .{});
        self.is_selected.update(false);
        self.game.current_player.has_card_selected = false;
        return;
    }
}

// FIXME: this should live somewhere else
fn get_board_bounding_box(self: *Self) rl.BoundingBox {
    var bb = rl.getModelBoundingBox(self.game.layout.background_cube);
    bb.min.x = self.game.layout.background_dims.get_x() + bb.min.x;
    bb.min.y = self.game.layout.background_dims.get_y() + bb.min.y;

    // FIXME: probably really jank to add a static 50 here
    bb.min.z = (self.game.layout.shop_dims.get_z() + 50) + bb.min.z;
    bb.max.x = self.game.layout.background_dims.get_x() + bb.max.x;
    bb.max.y = self.game.layout.background_dims.get_y() + bb.max.y;

    // FIXME: probably really jank to add a static 50 here
    bb.max.z = (self.game.layout.shop_dims.get_z() + 50) + bb.max.z;

    return bb;
}
pub fn update_selected_position(self: *Self) !void {
    const ray = rl.getScreenToWorldRay(rl.getMousePosition(), self.game.camera);
    const intersection = rl.getRayCollisionBox(ray, self.get_board_bounding_box());

    try self.position.update_x(intersection.point.x, 0);
    try self.position.update_y(intersection.point.y, 0);
    try self.position.update_z(self.parent_position.get_z() + 50, 0.15);
}

pub fn draw(self: *Self) void {
    self.model.drawEx(
        self.position.get_raylib_position_vec3(),
        rl.Vector3{
            .x = 0,
            .y = 0,
            .z = 1,
        },
        self.position.get_rotation_y(),
        rl.Vector3{
            .x = self.position.get_width() / Self.default_width,
            .y = self.position.get_height() / Self.default_height,
            .z = 1,
        },
        rl.Color.white,
    );
}
