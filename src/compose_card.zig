const std = @import("std");
const rl = @import("raylib");
const util = @import("util.zig");
pub const PURPLE_CARD_FRONT_bytes = @embedFile("assets/tcg/PNG/Cards_color3/Civilian_card_version1/Civilian_card_version1.png");

pub const ComposedTexture = struct {
    dimensions: rl.Vector2,
    images: []const rl.Image,
    crop: ?[]const rl.Rectangle = undefined,
    position: ?[]const rl.Vector2 = undefined,
};

pub fn compose(composition: ComposedTexture) !rl.Texture {

    // Pure white image that all images will be composed on top of
    var base_image: rl.Image = rl.genImageColor(
        @intFromFloat(composition.dimensions.x),
        @intFromFloat(composition.dimensions.y),
        rl.Color.white.alpha(0),
    );

    for (0..composition.images.len) |i| {
        var tmp = composition.images[i];

        if (composition.crop != null) {
            if (composition.crop.?.len > i) rl.imageCrop(&tmp, composition.crop.?[i]);
        }

        var dest = rl.Rectangle{
            .x = 0,
            .y = 0,
            .width = @min(try util.i_to_f32(tmp.width), composition.dimensions.x),
            .height = @min(try util.i_to_f32(tmp.height), composition.dimensions.y),
        };
        if (composition.position != null) {
            if (composition.position.?.len > i) {
                dest.x = composition.position.?[i].x;
                dest.y = composition.position.?[i].y;
            }
        }

        rl.imageDraw(
            &base_image,
            tmp,
            rl.Rectangle{
                .x = 0,
                .y = 0,
                .width = @floatFromInt(tmp.width),
                .height = @floatFromInt(tmp.height),
            },
            dest,
            rl.Color.white,
        );

        rl.unloadImage(tmp);
    }

    rl.imageRotate(&base_image, 180);

    const texture = try rl.Texture.fromImage(base_image);
    errdefer rl.unloadTexture(texture);

    rl.setTextureFilter(texture, rl.TextureFilter.bilinear);
    return texture;
}
