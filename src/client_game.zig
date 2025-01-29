const std = @import("std");
const rl = @import("raylib");
const lo = @import("layout.zig");
const sh = @import("shop.zig");
const tex = @import("textures.zig");
pub const Textures = @import("textures.zig").Textures;
const player = @import("player.zig");

const Self = @This();
pub const defaultScreenHeight: i32 = 1080;
pub const defaultScreenWidth: i32 = 1920;
pub var windowTitle: *const [12:0]u8 = "Auto Battler";
pub const targetFPS: i32 = 60;

// Meta
parent_allocator: std.mem.Allocator,
allocator: std.mem.Allocator,
arena: *std.heap.ArenaAllocator,

// GUI vars
current_screen_height: i32 = 0,
current_screen_width: i32 = 0,

// Textures
textures: *tex,

// layout
layout: *lo,

shop: *sh,

// Game Play
state: game_state = game_state.GAME_STARTED,

current_player: *player,
current_opponent: *player = undefined,
opponents: [7]*player,

debug: bool = false,

const game_state = enum {
    GAME_STARTED,
    SHOP,
};

pub fn init(alloc: std.mem.Allocator) !*Self {
    rl.setTargetFPS(targetFPS);

    // Create the game arena and allocator off the stack
    var arena = try alloc.create(std.heap.ArenaAllocator);
    errdefer alloc.destroy(arena);

    arena.* = std.heap.ArenaAllocator.init(alloc);

    const self: *Self = try alloc.create(Self);
    self.* = Self{
        .parent_allocator = alloc,
        .allocator = arena.allocator(),
        .arena = arena,
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

    self.layout.width = &self.current_screen_width;
    self.layout.height = &self.current_screen_height;
    self.current_opponent = self.opponents[0];
    return self;
}

pub fn allocator(self: *Self) std.mem.Allocator {
    return self.allocator;
}

pub fn deinit(self: *Self) void {
    try self.textures.deinit();
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

pub fn update(self: *Self) !void {
    try self.layout.update();
    try self.current_player.update();
}

pub fn draw(self: *Self) void {
    try self.layout.draw();
    self.current_player.draw();
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
