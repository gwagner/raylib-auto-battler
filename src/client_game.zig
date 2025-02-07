const std = @import("std");
const rl = @import("raylib");
const dbg = @import("debug.zig");
const lo = @import("layout.zig");
const sh = @import("shop.zig");
const tex = @import("textures.zig");
const util = @import("util.zig");
pub const Textures = @import("textures.zig").Textures;
const player = @import("player.zig");

const Self = @This();
pub const defaultScreenHeight: i32 = 1080;
pub const defaultScreenWidth: i32 = 1920;
pub const screenRatio: f32 = defaultScreenWidth / defaultScreenHeight;
pub var windowTitle: *const [12:0]u8 = "Auto Battler";
pub const targetFPS: i32 = 60;

// Meta
parent_allocator: std.mem.Allocator,
allocator: std.mem.Allocator,
arena: *std.heap.ArenaAllocator,

// GUI vars
current_screen_height: i32 = 0,
current_screen_width: i32 = 0,

// Camera
camera: rl.Camera3D,

// layout
layout: *lo,

// Textures
textures: *tex,

// Shop
shop: *sh,

// Game Play
state: game_state = game_state.GAME_STARTED,

current_player: *player,
current_opponent: *player = undefined,
opponents: [7]*player,

debug: bool = false,
debug_view: *dbg,

const game_state = enum {
    GAME_STARTED,
    SHOP,
};

pub fn init(alloc: std.mem.Allocator) !*Self {
    rl.setTargetFPS(targetFPS);
    rl.gl.rlSetClipPlanes(0.01, 10000);
    rl.gl.rlEnableDepthMask();
    rl.gl.rlEnableDepthTest();

    // Create the game arena and allocator off the stack
    var arena = try alloc.create(std.heap.ArenaAllocator);
    errdefer alloc.destroy(arena);

    arena.* = std.heap.ArenaAllocator.init(alloc);

    const camera = get_default_camera();

    const self: *Self = try alloc.create(Self);
    self.* = Self{
        .parent_allocator = alloc,
        .allocator = arena.allocator(),
        .arena = arena,
        .camera = get_default_camera(),
        .debug_view = try dbg.init(arena.allocator(), self, camera),
        .layout = try lo.init(arena.allocator(), self),
        .shop = try sh.init(arena.allocator(), self),
        .textures = try tex.init(arena.allocator()),
        .current_player = try player.init(arena.allocator(), self),
        .current_opponent = try player.init(arena.allocator(), self),
        .opponents = .{
            try player.init(arena.allocator(), self),
            try player.init(arena.allocator(), self),
            try player.init(arena.allocator(), self),
            try player.init(arena.allocator(), self),
            try player.init(arena.allocator(), self),
            try player.init(arena.allocator(), self),
            try player.init(arena.allocator(), self),
        },
    };

    self.current_opponent = self.opponents[0];
    return self;
}

pub fn allocator(self: *Self) std.mem.Allocator {
    return self.allocator;
}

pub fn deinit(self: *Self) void {
    try self.textures.deinit();
    self.debug_view.deinit();
    self.arena.deinit();
    self.parent_allocator.destroy(self.arena);
    self.parent_allocator.destroy(self);
}

pub fn load(self: *Self) !void {
    try self.layout.load();
    try self.textures.load();
    try self.shop.load();
    try self.current_player.load();
    for (self.opponents) |p| {
        try p.load();
    }
}

fn get_default_camera() rl.Camera {
    return rl.Camera3D{
        .position = rl.Vector3{
            .x = 0,
            .y = 0,
            .z = 200,
        },
        .target = rl.Vector3{
            .x = 0,
            .y = 0,
            .z = 0,
        },
        .up = rl.Vector3{
            .x = 0,
            .y = 1,
            .z = 0,
        },
        .fovy = 90,
        .projection = rl.CameraProjection.perspective,
    };
}

pub fn update(self: *Self) !void {
    try self.add_debug("Cull Distance Near {d} / Far {d}", .{ rl.gl.rl_cull_distance_near, rl.gl.rl_cull_distance_far });
    try self.debug_view.update();
    try self.layout.update();
    // try self.current_player.update();
}

pub fn add_debug(self: *Self, comptime format: []const u8, args: anytype) !void {
    try self.debug_view.debug(format, args);
}

pub fn draw(self: *Self) !void {
    self.camera.begin();
    try self.layout.draw();
    // self.current_player.draw();

    if (self.debug) {
        try self.debug_view.draw();
    }
    self.camera.end();
}

pub fn updateDimensions(self: *Self, height: i32, width: i32) void {
    self.current_screen_height = height;
    self.current_screen_width = width;
}

pub fn itof(i: i32) f32 {
    return @floatFromInt(i);
}

pub fn getScale(self: *Self) f32 {
    return @max(itof(self.current_screen_width) / itof(defaultScreenWidth), itof(self.current_screen_height) / itof(defaultScreenHeight));
}
