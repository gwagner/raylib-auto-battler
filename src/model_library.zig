const std = @import("std");
const rl = @import("raylib");
const archie = @import("card_archie.zig");
const Self = @This();

alloc: std.mem.Allocator,
arena: *std.heap.ArenaAllocator,
models: std.StringArrayHashMap(rl.Model),

pub fn init(alloc: std.mem.Allocator) !*Self {
    const arena = try alloc.create(std.heap.ArenaAllocator);
    arena.* = std.heap.ArenaAllocator.init(alloc);

    const self = try alloc.create(Self);
    self.* = Self{
        .alloc = arena.allocator(),
        .arena = arena,
        .models = std.StringArrayHashMap(rl.Model).init(alloc),
    };

    return self;
}

pub fn deinit(self: *Self) void {
    self.arena.deinit();
    self.alloc.destroy(self);
}

pub fn load(self: *Self) !void {
    const a = try archie.init(self.alloc);
    try self.add_model(a.id, a.texture);
}

pub fn add_model(self: *Self, name: []const u8, t: rl.Texture) !void {
    const mesh = rl.genMeshCube(150, 200, 2);
    const model = try rl.loadModelFromMesh(mesh);
    model.materials[0].maps[0].texture = t;

    try self.models.put(name, model);
}

pub fn get_model(self: *Self, name: []const u8) !rl.Model {
    const model = self.models.get(name);
    if (model == null) {
        return error.ModelDoesNotExist;
    }
    return model orelse unreachable;
}
