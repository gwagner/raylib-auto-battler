const std = @import("std");
const rl = @import("raylib");
const game = @import("client_game.zig");
const util = @import("util.zig");
const Self = @This();
const LineType = [:0]u8;

allocator: std.mem.Allocator,
game: *game,
active: *bool,
lines: std.ArrayList(LineType),
line_step: i32 = 20,

default_camera_position: rl.Vector3,
default_camera_target: rl.Vector3,
default_camera_up: rl.Vector3,
default_camera_fovy: f32,
update_camera: bool = false,
show_wire_mode: bool = false,

pub fn init(alloc: std.mem.Allocator, g: *game, camera: rl.Camera) !*Self {
    const self = try alloc.create(Self);
    self.* = Self{
        .allocator = alloc,
        .active = &g.debug,
        .game = g,
        .lines = std.ArrayList([:0]u8).init(alloc),

        .default_camera_position = rl.Vector3{
            .x = camera.position.x,
            .y = camera.position.y,
            .z = camera.position.z,
        },
        .default_camera_target = rl.Vector3{
            .x = camera.target.x,
            .y = camera.target.y,
            .z = camera.target.z,
        },
        .default_camera_up = rl.Vector3{
            .x = camera.up.x,
            .y = camera.up.y,
            .z = camera.up.z,
        },
        .default_camera_fovy = g.camera.fovy,
    };

    try self.reset();

    return self;
}

pub fn deinit(self: *Self) void {
    self.lines.deinit();
    self.allocator.destroy(self);
}

pub fn update(self: *Self) !void {
    if (self.active.*) {
        if (rl.isKeyPressed(rl.KeyboardKey.c)) {
            if (self.update_camera) {
                self.update_camera = false;
            } else {
                self.update_camera = true;
            }
        }

        if (rl.isKeyPressed(rl.KeyboardKey.r)) {
            self.update_camera = false;
            self.game.camera.position = self.default_camera_position;
        }

        if (self.update_camera) {
            rl.updateCamera(&self.game.camera, rl.CameraMode.third_person);
        }

        if (rl.isKeyPressed(rl.KeyboardKey.w)) {
            if (self.show_wire_mode) {
                self.show_wire_mode = false;
                rl.gl.rlDisableWireMode();
            } else {
                self.show_wire_mode = true;
                rl.gl.rlEnableWireMode();
            }
        }
    }
}

pub fn reset(self: *Self) !void {
    self.lines.deinit();
    self.lines = std.ArrayList(LineType).init(self.allocator);

    const mousePosition = rl.getMousePosition();
    try self.debug(
        "Screen Size: ({d}, {d})",
        .{ rl.getScreenWidth(), rl.getScreenHeight() },
    );
    try self.debug(
        "Mouse Position: ({d}, {d})",
        .{ mousePosition.x, mousePosition.y },
    );
    try self.debug(
        "Camera FOVY: {d}",
        .{self.game.camera.fovy},
    );
    try self.debug(
        "Camera Position: ({d}, {d}, {d})",
        .{
            self.game.camera.position.x,
            self.game.camera.position.y,
            self.game.camera.position.z,
        },
    );
    try self.debug(
        "Camera Target: ({d}, {d}, {d})",
        .{
            self.game.camera.target.x,
            self.game.camera.target.y,
            self.game.camera.target.z,
        },
    );
    try self.debug(
        "Camera Up: ({d}, {d}, {d})",
        .{
            self.game.camera.up.x,
            self.game.camera.up.y,
            self.game.camera.up.z,
        },
    );
}

pub fn debug(self: *Self, comptime format: []const u8, args: anytype) !void {
    const pos_text = try std.fmt.allocPrintZ(self.allocator, format, args);
    try self.lines.append(pos_text);
}

pub fn draw(self: *Self) !void {
    self.draw_camera_debug_lines();
    rl.drawGrid(200, 20);

    self.game.camera.end();
    self.draw_cursor_lines();
    rl.drawFPS(10, 10);

    // Draw all of the debug text
    var y: i32 = self.line_step + 8;
    for (self.lines.items) |l| {
        defer y += self.line_step;
        rl.drawText(l, 10, y, 20, rl.Color.dark_green);
        self.allocator.free(l);
    }
    self.game.camera.begin();

    try self.reset();
}

pub fn draw_cursor_lines(self: *Self) void {
    const mousePosition = rl.getMousePosition();
    rl.drawLine(
        try util.f_to_i32(mousePosition.x),
        0,
        try util.f_to_i32(mousePosition.x),
        self.game.current_screen_height,
        rl.Color.green,
    );
    rl.drawLine(
        0,
        try util.f_to_i32(mousePosition.y),
        self.game.current_screen_width,
        try util.f_to_i32(mousePosition.y),
        rl.Color.green,
    );
}

pub fn draw_camera_debug_lines(self: *Self) void {
    const label_offset: f32 = 200;

    const x_line_start = rl.Vector3{ .x = -10000, .y = 0, .z = 0 };
    const x_line_end = rl.Vector3{ .x = 10000, .y = 0, .z = 0 };
    const x_line_label_1 = rl.getWorldToScreen(rl.Vector3{ .x = label_offset, .y = 0, .z = 0 }, self.game.camera);
    const x_line_label_2 = rl.getWorldToScreen(rl.Vector3{ .x = -1 * label_offset, .y = 0, .z = 0 }, self.game.camera);
    rl.drawLine3D(x_line_start, x_line_end, rl.Color.blue);

    const y_line_start = rl.Vector3{ .x = 0, .y = -10000, .z = 0 };
    const y_line_end = rl.Vector3{ .x = 0, .y = 10000, .z = 0 };
    const y_line_label_1 = rl.getWorldToScreen(rl.Vector3{ .x = 0, .y = label_offset, .z = 0 }, self.game.camera);
    const y_line_label_2 = rl.getWorldToScreen(rl.Vector3{ .x = 0, .y = -1 * label_offset, .z = 0 }, self.game.camera);
    rl.drawLine3D(y_line_start, y_line_end, rl.Color.green);

    const z_line_start = rl.Vector3{ .x = 0, .y = 0, .z = -10000 };
    const z_line_end = rl.Vector3{ .x = 0, .y = 0, .z = 10000 };
    rl.drawLine3D(z_line_start, z_line_end, rl.Color.red);

    self.game.camera.end();
    rl.drawText("+x", try util.f_to_i32(x_line_label_1.x), try util.f_to_i32(x_line_label_1.y), 20, rl.Color.black);
    rl.drawText("+y", try util.f_to_i32(y_line_label_1.x), try util.f_to_i32(y_line_label_1.y), 20, rl.Color.black);
    rl.drawText("-x", try util.f_to_i32(x_line_label_2.x), try util.f_to_i32(x_line_label_2.y), 20, rl.Color.black);
    rl.drawText("-y", try util.f_to_i32(y_line_label_2.x), try util.f_to_i32(y_line_label_2.y), 20, rl.Color.black);
    self.game.camera.begin();
}
