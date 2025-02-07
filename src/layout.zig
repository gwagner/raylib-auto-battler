const std = @import("std");
const rl = @import("raylib");
const container = @import("layout_container.zig");
const client_game = @import("client_game.zig");
const cube = @import("tween_cube.zig");
const player = @import("player.zig");
const Self = @This();
const ContainerType = *container.NewContainer(*Self);
const ContainerSize = 2;

alloc: std.mem.Allocator,
game: *client_game,

containers: containers = undefined,

shop: ContainerType = undefined,
shop_keeper: ContainerType = undefined,
opponent: ContainerType = undefined,
opponent_board: ContainerType = undefined,
current_player_board: ContainerType = undefined,
current_player: ContainerType = undefined,

background_dims: *cube,
play_area_dims: *cube,
shop_keeper_dims: *cube,
shop_dims: *cube,
board_dims: *cube,
player_dims: *cube,

shop_keeper_cube: rl.Model,
shop_cube: rl.Model,
board_cube: rl.Model,
player_cube: rl.Model,

const containers = struct {
    items: [ContainerSize]ContainerType,

    fn init(self: *containers) void {
        for (0..self.items.len) |i| {
            self.items[i].index = i;
        }
    }
};

pub fn init(alloc: std.mem.Allocator, game: *client_game) !*Self {
    const self = try alloc.create(Self);

    const background_square: f32 = 5000;
    const play_area_width: f32 = 1600;
    const play_area_height: f32 = 1200;
    const inner_width: f32 = play_area_width * 0.9;
    const shop_keeper_height: f32 = play_area_height * 0.2;
    const shop_height: f32 = play_area_height * 0.3;

    const shop_keeper_mesh = rl.genMeshCube(inner_width, shop_keeper_height, 6);
    const shop_mesh = rl.genMeshCube(inner_width, shop_height, 6);
    const board_mesh = rl.genMeshCube(inner_width, shop_height, 6);
    const player_mesh = rl.genMeshCube(inner_width, shop_keeper_height, 6);

    self.* = Self{
        .alloc = alloc,
        .game = game,
        .background_dims = try cube.init(alloc, 0, 0, -500, background_square, background_square, -2, 0, 0, 0),
        .play_area_dims = try cube.init(alloc, 0, 0, -450, play_area_height, play_area_width, -10, 0, 0, 0),
        .shop_keeper_dims = try cube.init(
            alloc,
            0,
            (play_area_height / 2) - (shop_keeper_height / 2),
            -442,
            shop_keeper_height,
            inner_width,
            -6,
            0,
            0,
            0,
        ),
        .shop_dims = try cube.init(
            alloc,
            0,
            (play_area_height / 2) - shop_keeper_height - (shop_height / 2),
            -442,
            shop_height,
            inner_width,
            -6,
            0,
            0,
            0,
        ),
        .board_dims = try cube.init(
            alloc,
            0,
            (play_area_height / 2) - shop_keeper_height - shop_height - (shop_height / 2),
            -442,
            shop_height,
            inner_width,
            -6,
            0,
            0,
            0,
        ),
        .player_dims = try cube.init(
            alloc,
            0,
            (play_area_height / 2) - shop_keeper_height - (shop_height * 2) - (shop_keeper_height / 2),
            -442,
            shop_keeper_height,
            inner_width,
            -6,
            0,
            0,
            0,
        ),
        .shop_keeper_cube = try rl.loadModelFromMesh(shop_keeper_mesh),
        .shop_cube = try rl.loadModelFromMesh(shop_mesh),
        .board_cube = try rl.loadModelFromMesh(board_mesh),
        .player_cube = try rl.loadModelFromMesh(player_mesh),
    };

    return self;
}

pub fn load(self: *Self) !void {
    self.game.current_player.container = self.current_player;
}

// Updates all of the elements on the screen
pub fn update(self: *Self) !void {
    if (rl.isKeyPressed(rl.KeyboardKey.j)) {
        try self.panel_flip(self.board_dims);
    }

    try self.background_dims.tween();
    try self.play_area_dims.tween();
    try self.shop_keeper_dims.tween();
    try self.shop_dims.tween();
    try self.board_dims.tween();
    try self.player_dims.tween();
}

pub fn panel_flip(_: *Self, panel: *cube) !void {
    if (panel.tweening) return;
    try panel.positions.append(cube.Position{ .z = panel.get_z() + 20, .duration = 0.1 });
    try panel.positions.append(cube.Position{ .rotation_x = @abs(panel.get_rotation_x() - 180), .duration = 0.2 });
    try panel.positions.append(cube.Position{ .z = panel.get_z(), .duration = 0.1 });
}

pub fn deinit(self: *Self) void {
    self.containers.deinit();
    self.alloc.destroy(self);
}

pub fn draw(self: *Self) !void {
    self.draw_background_cube();
    self.draw_play_area_cube();
    self.draw_shop_keeper_cube();
    self.draw_shop_cube();
    self.draw_board_cube();
    self.draw_player_cube();
}

pub fn draw_background_cube(self: *Self) void {
    rl.drawCubeV(
        self.background_dims.get_raylib_position_vec3(),
        self.background_dims.get_raylib_size_vec3(),
        rl.Color.black,
    );
}

pub fn draw_play_area_cube(self: *Self) void {
    rl.drawCubeV(
        self.play_area_dims.get_raylib_position_vec3(),
        self.play_area_dims.get_raylib_size_vec3(),
        rl.Color.white,
    );
}

pub fn draw_shop_keeper_cube(self: *Self) void {
    self.shop_keeper_cube.drawEx(
        self.shop_keeper_dims.get_raylib_position_vec3(),
        rl.Vector3{
            .x = 1,
            .y = 0,
            .z = 0,
        },
        self.shop_keeper_dims.get_rotation_x(),
        rl.Vector3{
            .x = 1,
            .y = 1,
            .z = 1,
        },
        rl.Color.red,
    );
}

pub fn draw_shop_cube(self: *Self) void {
    self.shop_cube.drawEx(
        self.shop_dims.get_raylib_position_vec3(),
        rl.Vector3{
            .x = 1,
            .y = 0,
            .z = 0,
        },
        self.shop_dims.get_rotation_x(),
        rl.Vector3{
            .x = 1,
            .y = 1,
            .z = 1,
        },
        rl.Color.green,
    );
}

pub fn draw_board_cube(self: *Self) void {
    self.board_cube.drawEx(
        self.board_dims.get_raylib_position_vec3(),
        rl.Vector3{
            .x = 1,
            .y = 0,
            .z = 0,
        },
        self.board_dims.get_rotation_x(),
        rl.Vector3{
            .x = 1,
            .y = 1,
            .z = 1,
        },
        rl.Color.blue,
    );
}

pub fn draw_player_cube(self: *Self) void {
    self.player_cube.drawEx(
        self.player_dims.get_raylib_position_vec3(),
        rl.Vector3{
            .x = 1,
            .y = 0,
            .z = 0,
        },
        self.player_dims.get_rotation_x(),
        rl.Vector3{
            .x = 1,
            .y = 1,
            .z = 1,
        },
        rl.Color.yellow,
    );
}
