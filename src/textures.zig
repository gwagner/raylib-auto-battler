const std = @import("std");
const rl = @import("raylib");
const archie_bytes = @embedFile("assets/archie.jpg");
const jasper_bytes = @embedFile("assets/jasper.jpg");
const mccormick_bytes = @embedFile("assets/mccormick.jpg");
const PURPLE_CARD_FRONT_bytes = @embedFile("assets/tcg/PNG/Cards_color3/Civilian_card_version1/Civilian_card_version1.png");

const Self = @This();

texture_registry: *Registry,

pub const Textures = enum {
    // Assets
    ARCHIE,
    JASPER,
    MCCORMICK,
    PURPLE_CARD_FRONT,
};

pub const Cards = enum {
    // Cards
    Archie_Card,
    Jasper_Card,
    McCormick_Card,
};

pub fn init(alloc: std.mem.Allocator) !*Self {
    const self = try alloc.create(Self);
    self.* = Self{
        .texture_registry = try Registry.init(alloc),
    };

    return self;
}

pub fn deinit(self: *Self) !void {
    for (self.texture_registry.texture_registry.items) |i| {
        rl.unloadTexture(i.texture);
    }

    for (self.texture_registry.card_registry.items) |i| {
        rl.unloadTexture(i.texture);
    }
}

pub fn load(self: *Self) !void {
    try self.texture_registry.load_texture(Textures.ARCHIE, ".jpg", archie_bytes);
    try self.texture_registry.load_texture(Textures.JASPER, ".jpg", jasper_bytes);
    try self.texture_registry.load_texture(Textures.MCCORMICK, ".jpg", mccormick_bytes);
    try self.texture_registry.load_texture(Textures.PURPLE_CARD_FRONT, ".png", PURPLE_CARD_FRONT_bytes);

    try self.texture_registry.compose_card(Cards.Archie_Card, ComposedTexture{
        .dimensions = rl.Vector2{ .x = 195, .y = 284 },
        .images = ([_]rl.Image{
            try rl.loadImageFromMemory(".jpg", archie_bytes),
            try rl.loadImageFromMemory(".png", PURPLE_CARD_FRONT_bytes),
        })[0..],
        .textures = ([_]Textures{
            Textures.ARCHIE,
            Textures.PURPLE_CARD_FRONT,
        })[0..],
        .crop = ([_]rl.Rectangle{
            .{
                .x = 0,
                .y = 0,
                .width = @floatFromInt((try self.get_texture_by_id(Textures.ARCHIE)).width),
                .height = @floatFromInt((try self.get_texture_by_id(Textures.ARCHIE)).height),
            },
            .{
                .x = 0,
                .y = 0,
                .width = @floatFromInt((try self.get_texture_by_id(Textures.PURPLE_CARD_FRONT)).width),
                .height = @floatFromInt((try self.get_texture_by_id(Textures.PURPLE_CARD_FRONT)).height),
            },
        })[0..],
        .position = ([_]rl.Rectangle{
            .{
                .x = 20,
                .y = 10,
                .width = @floatFromInt((try self.get_texture_by_id(Textures.ARCHIE)).width),
                .height = @floatFromInt((try self.get_texture_by_id(Textures.ARCHIE)).height),
            },
            .{
                .x = 0,
                .y = 0,
                .width = @floatFromInt((try self.get_texture_by_id(Textures.PURPLE_CARD_FRONT)).width),
                .height = @floatFromInt((try self.get_texture_by_id(Textures.PURPLE_CARD_FRONT)).height),
            },
        })[0..],
    });

    try self.texture_registry.compose_card(Cards.Jasper_Card, ComposedTexture{
        .dimensions = rl.Vector2{ .x = 195, .y = 284 },
        .images = ([_]rl.Image{
            try rl.loadImageFromMemory(".jpg", jasper_bytes),
            try rl.loadImageFromMemory(".png", PURPLE_CARD_FRONT_bytes),
        })[0..],
        .textures = ([_]Textures{
            Textures.JASPER,
            Textures.PURPLE_CARD_FRONT,
        })[0..],
        .crop = ([_]rl.Rectangle{
            .{
                .x = 0,
                .y = 0,
                .width = @floatFromInt((try self.get_texture_by_id(Textures.JASPER)).width),
                .height = @floatFromInt((try self.get_texture_by_id(Textures.JASPER)).height),
            },
            .{
                .x = 0,
                .y = 0,
                .width = @floatFromInt((try self.get_texture_by_id(Textures.PURPLE_CARD_FRONT)).width),
                .height = @floatFromInt((try self.get_texture_by_id(Textures.PURPLE_CARD_FRONT)).height),
            },
        })[0..],
        .position = ([_]rl.Rectangle{
            .{
                .x = 20,
                .y = 0,
                .width = @floatFromInt((try self.get_texture_by_id(Textures.JASPER)).width),
                .height = @floatFromInt((try self.get_texture_by_id(Textures.JASPER)).height),
            },
            .{
                .x = 0,
                .y = 0,
                .width = @floatFromInt((try self.get_texture_by_id(Textures.PURPLE_CARD_FRONT)).width),
                .height = @floatFromInt((try self.get_texture_by_id(Textures.PURPLE_CARD_FRONT)).height),
            },
        })[0..],
    });

    try self.texture_registry.compose_card(Cards.McCormick_Card, ComposedTexture{
        .dimensions = rl.Vector2{ .x = 195, .y = 284 },
        .images = ([_]rl.Image{
            try rl.loadImageFromMemory(".jpg", mccormick_bytes),
            try rl.loadImageFromMemory(".png", PURPLE_CARD_FRONT_bytes),
        })[0..],
        .textures = ([_]Textures{
            Textures.MCCORMICK,
            Textures.PURPLE_CARD_FRONT,
        })[0..],
        .crop = ([_]rl.Rectangle{
            .{
                .x = 0,
                .y = 0,
                .width = @floatFromInt((try self.get_texture_by_id(Textures.MCCORMICK)).width),
                .height = @floatFromInt((try self.get_texture_by_id(Textures.MCCORMICK)).height),
            },
            .{
                .x = 0,
                .y = 0,
                .width = @floatFromInt((try self.get_texture_by_id(Textures.PURPLE_CARD_FRONT)).width),
                .height = @floatFromInt((try self.get_texture_by_id(Textures.PURPLE_CARD_FRONT)).height),
            },
        })[0..],
        .position = ([_]rl.Rectangle{
            .{
                .x = 20,
                .y = 0,
                .width = @floatFromInt((try self.get_texture_by_id(Textures.MCCORMICK)).width),
                .height = @floatFromInt((try self.get_texture_by_id(Textures.MCCORMICK)).height),
            },
            .{
                .x = 0,
                .y = 0,
                .width = @floatFromInt((try self.get_texture_by_id(Textures.PURPLE_CARD_FRONT)).width),
                .height = @floatFromInt((try self.get_texture_by_id(Textures.PURPLE_CARD_FRONT)).height),
            },
        })[0..],
    });
}

pub fn get_texture_by_id(self: *Self, id: Textures) !rl.Texture {
    return try self.texture_registry.get_texture_by_id(id);
}

pub fn get_card_by_id(self: *Self, id: Cards) !rl.Texture {
    return try self.texture_registry.get_card_by_id(id);
}

const Registry = struct {
    texture_registry: std.ArrayList(Texture),
    card_registry: std.ArrayList(Card),

    pub fn init(alloc: std.mem.Allocator) !*Registry {
        const self = try alloc.create(Registry);
        self.* = Registry{
            .texture_registry = std.ArrayList(Texture).init(alloc),
            .card_registry = std.ArrayList(Card).init(alloc),
        };

        return self;
    }

    pub fn load_texture(self: *Registry, id: Textures, image_type: [:0]const u8, image_bytes: []const u8) !void {
        const image = try rl.loadImageFromMemory(image_type, image_bytes);
        errdefer rl.unloadImage(image);

        const texture = try rl.Texture.fromImage(image);
        errdefer rl.unloadTexture(texture);

        rl.setTextureFilter(texture, rl.TextureFilter.bilinear);

        try self.texture_registry.append(.{
            .id = id,
            .image = image,
            .texture = texture,
        });
    }

    pub fn compose_card(self: *Registry, id: Cards, composition: ComposedTexture) !void {
        var base_image: rl.Image = rl.genImageColor(
            @intFromFloat(composition.dimensions.x),
            @intFromFloat(composition.dimensions.y),
            rl.Color.white.alpha(0),
        );

        for (0..composition.images.len) |i| {
            var tmp = composition.images[i];
            rl.imageCrop(&tmp, composition.crop[i]);

            rl.imageDraw(
                &base_image,
                tmp,
                rl.Rectangle{
                    .x = 0,
                    .y = 0,
                    .width = @floatFromInt(tmp.width),
                    .height = @floatFromInt(tmp.height),
                },
                composition.position[i],
                rl.Color.white,
            );

            rl.unloadImage(tmp);
        }

        const texture = try rl.Texture.fromImage(base_image);
        errdefer rl.unloadTexture(texture);

        rl.setTextureFilter(texture, rl.TextureFilter.bilinear);

        try self.card_registry.append(.{
            .id = id,
            .image = base_image,
            .texture = texture,
        });
    }

    fn get_texture_by_id(self: *Registry, id: Textures) !rl.Texture {
        return for (self.texture_registry.items) |t| {
            if (t.id == id) {
                break t.texture;
            }
        } else error.InvalidIdProvided;
    }

    fn get_card_by_id(self: *Registry, id: Cards) !rl.Texture {
        return for (self.card_registry.items) |t| {
            if (t.id == id) {
                break t.texture;
            }
        } else error.InvalidIdProvided;
    }

    fn get_image_by_id(self: *Registry, id: Textures) !rl.Image {
        return for (self.texture_registry.items) |t| {
            if (t.id == id) {
                break t.image;
            }
        } else error.InvalidIdProvided;
    }
};

pub const Texture = struct {
    id: Textures,
    image: rl.Image,
    texture: rl.Texture,
};

pub const Card = struct {
    id: Cards,
    image: rl.Image,
    texture: rl.Texture,
};

const ComposedTexture = struct {
    dimensions: rl.Vector2,
    images: []const rl.Image,
    textures: []const Textures,
    crop: []const rl.Rectangle,
    position: []const rl.Rectangle,
};
