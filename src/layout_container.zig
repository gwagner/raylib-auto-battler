const std = @import("std");
const rl = @import("raylib");
pub const types = @import("layout_container_types.zig").types;
pub const GetType = @import("layout_container_types.zig").GetType;

pub fn NewContainer(comptime T: type) type {
    return struct {
        allocator: std.mem.Allocator = undefined,
        parent: T = undefined,

        debug: bool = true,

        heightPerc: f32 = 1,
        widthPerc: f32 = 1,

        offsetX: i32 = 0,
        offsetY: i32 = 0,

        visibile: bool = true,

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

        pub fn draw(self: *Self) !void {
            if (!self.visibile) {
                return;
            }

            if (self.debug) {
                rl.drawRectangleLines(self.offsetX, self.offsetY, self.getWidthPx(), self.getHeightPx(), rl.Color.black);
            }
        }

        pub fn getHeightPx(self: *Self) i32 {
            return @intFromFloat(@as(f32, @floatFromInt(self.parent.height.*)) * self.heightPerc);
        }

        pub fn getWidthPx(self: *Self) i32 {
            return @intFromFloat(@as(f32, @floatFromInt(self.parent.width.*)) * self.widthPerc);
        }
    };
}

pub fn new_container(parent: anytype) NewContainer(parent) {
    return .{};
}
