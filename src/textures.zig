const std = @import("std");
const rl = @import("raylib");
const archie_bytes = @embedFile("assets/archie.jpg");
const PURPLE_CARD_FRONT_bytes = @embedFile("assets/tcg/PNG/Cards_color3/Civilian_card_version1/Civilian_card_version1.png");

const Self = @This();

texture_registry: *TextureRegistry,

pub const Textures = enum {
    // Assets
    ARCHIE,
    PURPLE_CARD_FRONT,

    // Cards
    Archie_Card,
};

pub fn init(alloc: std.mem.Allocator) !*Self {
    const self = try alloc.create(Self);
    self.* = Self{
        .texture_registry = try TextureRegistry.init(alloc),
    };

    return self;
}

pub fn deinit(self: *Self) !void {
    for (self.texture_registry.registry.items) |i| {
        rl.unloadTexture(i.texture);
    }
}

pub fn load(self: *Self) !void {
    try self.texture_registry.load(Textures.ARCHIE, ".jpg", archie_bytes);
    try self.texture_registry.load(Textures.PURPLE_CARD_FRONT, ".png", PURPLE_CARD_FRONT_bytes);

    try self.texture_registry.compose(Textures.Archie_Card, ComposedTexture{
        .dimensions = rl.Vector2{ .x = 195, .y = 284 },
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
}

pub fn get_texture_by_id(self: *Self, id: Textures) !rl.Texture {
    return try self.texture_registry.get_texture_by_id(id);
}

const TextureRegistry = struct {
    registry: std.ArrayList(Texture),

    pub fn init(alloc: std.mem.Allocator) !*TextureRegistry {
        const self = try alloc.create(TextureRegistry);
        self.* = TextureRegistry{ .registry = std.ArrayList(Texture).init(alloc) };

        return self;
    }

    pub fn load(self: *TextureRegistry, id: Textures, image_type: [:0]const u8, image_bytes: []const u8) !void {
        const image = try rl.loadImageFromMemory(image_type, image_bytes);
        errdefer rl.unloadImage(image);

        const texture = try rl.Texture.fromImage(image);
        errdefer rl.unloadTexture(texture);

        rl.setTextureFilter(texture, rl.TextureFilter.bilinear);

        try self.registry.append(.{
            .id = id,
            .image = image,
            .texture = texture,
        });
    }

    pub fn compose(self: *TextureRegistry, id: Textures, composition: ComposedTexture) !void {
        var base_image: rl.Image = rl.genImageColor(
            @intFromFloat(composition.dimensions.x),
            @intFromFloat(composition.dimensions.y),
            rl.Color.white.alpha(0),
        );

        for (0..composition.textures.len, composition.textures) |i, t| {
            var image = try self.get_image_by_id(t);
            rl.imageCrop(&image, composition.crop[i]);

            rl.imageDraw(
                &base_image,
                image,
                rl.Rectangle{
                    .x = 0,
                    .y = 0,
                    .width = @floatFromInt(image.width),
                    .height = @floatFromInt(image.height),
                },
                composition.position[i],
                rl.Color.white,
            );
        }

        const texture = try rl.Texture.fromImage(base_image);
        errdefer rl.unloadTexture(texture);

        rl.setTextureFilter(texture, rl.TextureFilter.bilinear);

        try self.registry.append(.{
            .id = id,
            .image = base_image,
            .texture = texture,
        });
    }

    fn get_texture_by_id(self: *TextureRegistry, id: Textures) !rl.Texture {
        return for (self.registry.items) |t| {
            if (t.id == id) {
                break t.texture;
            }
        } else error.InvalidIdProvided;
    }

    fn get_image_by_id(self: *TextureRegistry, id: Textures) !rl.Image {
        return for (self.registry.items) |t| {
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

const ComposedTexture = struct {
    dimensions: rl.Vector2,
    textures: []const Textures,
    crop: []const rl.Rectangle,
    position: []const rl.Rectangle,
};
