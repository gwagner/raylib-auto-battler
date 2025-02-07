const std = @import("std");
const rl = @import("raylib");
const game = @import("client_game.zig");
const util = @import("util.zig");
pub const types = @import("layout_container_types.zig").types;
pub const GetType = @import("layout_container_types.zig").GetType;

pub fn NewContainer(comptime T: type) type {
    return struct {
        allocator: std.mem.Allocator = undefined,
        parent: T = undefined,

        debug: bool = true,
        debugColor: rl.Color = undefined,

        index: usize = 0,
        heightPerc: f32 = 1,
        widthPerc: f32 = 1,

        offsetX: i32 = 0,
        offsetY: i32 = 0,
        width: f32 = 0,
        height: f32 = 0,
        z: f32 = 0,

        visible: bool = true,

        const Self = @This();

        pub fn init(_: Self, alloc: std.mem.Allocator, parent: T) !*Self {
            const self = try alloc.create(Self);
            self.* = Self{
                .allocator = alloc,
                .parent = parent,
            };

            return self;
        }

        pub fn deinit(self: *Self) void {
            self.children.deinit();
            self.allocator.destroy(self);
        }

        pub fn update(self: *Self) !void {
            _ = self;
            // if (!self.visible) {
            //     return;
            // }
            //
            // if (self.index == 0) {
            //     self.offsetX = @divFloor(self.getWidthPx(), 2);
            //     self.offsetY = @divFloor(self.getHeightPx(), 2);
            //     self.width = self.getWidthPx_f32();
            //     self.height = self.getHeightPx_f32();
            //     return;
            // }
            //
            // const prev = try self.parent.getPreviousVisibleSibling(self.index);
            // self.offsetX = @divFloor(self.getWidthPx(), 2);
            // self.offsetY = prev.offsetY + @as(i32, @intFromFloat(prev.height));
            // self.width = self.getWidthPx_f32();
            // self.height = self.getHeightPx_f32();
        }

        pub fn draw(self: *Self) !void {
            _ = self;
            // if (!self.visible) {
            //     return;
            // }
            //
            // try self.parent.game.add_debug("Container World Detail: {d},{d},{d} {d} x {d} x {d}", .{
            //     self.offsetX,
            //     self.offsetY,
            //     0,
            //     self.width,
            //     self.height,
            //     2,
            // });
            //
            // var dest = rl.Vector3{
            //     .x = @floatFromInt(self.offsetX),
            //     .y = @floatFromInt(self.offsetY),
            //     .z = -200,
            // };
            //
            // const world = rl.getWorldToScreen(dest, self.parent.game.camera);
            //
            // try self.parent.game.add_debug("Container Screen Detail: {d},{d}", .{
            //     world.x,
            //     world.y,
            // });
            // dest.x = world.x;
            // dest.y = world.y;
            // rl.drawCube(
            //     dest,
            //     self.width,
            //     self.height,
            //     2,
            //     self.debugColor,
            // );
            // rl.drawCubeWires(
            //     dest,
            //     self.width,
            //     self.height,
            //     2,
            //     rl.Color.black,
            // );
        }

        pub fn getCenterOffsetX_f32(self: *Self) f32 {
            return @as(f32, @floatFromInt(self.offsetX)) - try util.i_to_f32(self.parent.width.*) / 2;
        }

        pub fn getCenterOffsetY_f32(self: *Self) f32 {
            return @as(f32, @floatFromInt(self.offsetY)) + try util.i_to_f32(self.parent.height.*) / 2;
        }

        pub fn getCenteredWindowHeightPx_i32(self: *Self) i32 {
            return @intFromFloat(self.getWindowHeightPx_f32());
        }
        pub fn getCenteredWindowHeightPx_f32(_: *Self) f32 {
            return 1920 / 2.0;
        }

        pub fn getHeightPx(self: *Self) i32 {
            return @intFromFloat(self.getHeightPx_f32());
        }

        pub fn getWidthPx(self: *Self) i32 {
            return @intFromFloat(self.getWidthPx_f32());
        }

        pub fn getHeightPx_f32(self: *Self) f32 {
            return (1920 * game.screenRatio) * self.heightPerc;
        }

        pub fn getWidthPx_f32(self: *Self) f32 {
            return @as(f32, @floatFromInt(1920)) * self.widthPerc;
        }
    };
}

pub fn new_container(parent: anytype) NewContainer(parent) {
    return .{};
}
