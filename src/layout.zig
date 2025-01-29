const std = @import("std");
const container = @import("layout_container.zig");
const player = @import("player.zig");
const client_game = @import("client_game.zig");
const Self = @This();
const ContainerType = *container.NewContainer(*Self);

alloc: std.mem.Allocator,
game: *client_game,

containers: std.ArrayList(ContainerType),

shop: ContainerType = undefined,
shop_keeper: ContainerType = undefined,
opponent: ContainerType = undefined,
opponent_board: ContainerType = undefined,
current_player_board: ContainerType = undefined,
current_player: ContainerType = undefined,

height: *i32 = undefined,
width: *i32 = undefined,

pub fn init(alloc: std.mem.Allocator, game: *client_game) !*Self {
    const self = try alloc.create(Self);
    self.* = Self{
        .alloc = alloc,
        .game = game,
        .containers = std.ArrayList(ContainerType).init(alloc),
    };

    self.shop_keeper = try container.new_container(*Self).init(alloc, self);
    self.shop_keeper.heightPerc = 0.20;
    self.shop_keeper.widthPerc = 1;
    try self.containers.append(self.shop_keeper);

    self.opponent = try container.new_container(*Self).init(alloc, self);
    self.opponent.visibile = false;
    self.opponent.heightPerc = 0.20;
    self.opponent.widthPerc = 1;
    try self.containers.append(self.opponent);

    self.shop = try container.new_container(*Self).init(alloc, self);
    self.shop.heightPerc = 0.30;
    self.shop.widthPerc = 1;
    try self.containers.append(self.shop);

    self.opponent_board = try container.new_container(*Self).init(alloc, self);
    self.opponent_board.visibile = false;
    self.opponent_board.heightPerc = 0.30;
    self.opponent_board.widthPerc = 1;
    try self.containers.append(self.opponent_board);

    self.current_player_board = try container.new_container(*Self).init(alloc, self);
    self.current_player_board.heightPerc = 0.30;
    self.current_player_board.widthPerc = 1;
    try self.containers.append(self.current_player_board);

    self.current_player = try container.new_container(*Self).init(alloc, self);
    self.current_player.heightPerc = 0.20;
    self.current_player.widthPerc = 1;
    try self.containers.append(self.current_player);

    return self;
}

pub fn load(self: *Self) !void {
    self.game.current_player.container = self.current_player;
}

// Updates all of the elements on the screen
pub fn update(self: *Self) !void {
    // Reset all calculated offsets
    for (self.containers.items) |c| {
        c.offsetY = 0;
        c.offsetX = 0;
    }

    // Calculate new offsets because the screen size could have changed
    for (1..self.containers.items.len, self.containers.items[1..]) |i, c| {
        if (!c.visibile) {
            continue;
        }

        const previous = try self.getPreviousVisibleSibling(i - 1);

        // if we can append to the end, append to the end
        if (previous.offsetX + previous.getWidthPx() + c.getWidthPx() < self.width.*) {
            c.offsetX += previous.getWidthPx();

            // perform child update

            continue;
        }

        // otherwise we need a new line
        c.offsetX = 0;
        c.offsetY += previous.offsetY + previous.getHeightPx();
    }
}

fn getPreviousVisibleSibling(self: Self, idx: usize) !ContainerType {
    var i = idx;
    return while (i > -1) : (i -= 1) {
        if (self.containers.items[i].visibile) {
            break self.containers.items[i];
        }
    } else error.NoVisibileSibling;
}

pub fn deinit(self: *Self) void {
    self.containers.deinit();
    self.alloc.destroy(self);
}

pub fn add_container(self: *Self, c: *container) !void {
    try self.containers.append(c);
}

pub fn draw(self: *Self) !void {
    for (self.containers.items) |c| {
        try c.draw();
    }
}
