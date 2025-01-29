const layout = @import("layout.zig");
const container = @import("layout_container.zig");
const player = @import("player.zig");

pub const types = enum {
    BASE,
    CONTAINER_PLAYER,
};

pub fn GetType(T: types) type {
    return switch (T) {
        types.BASE => *container.NewContainer(*layout),
        types.CONTAINER_PLAYER => *container.NewContainer(*layout, *player),
    };
}
