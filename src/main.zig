const std = @import("std");
const rl = @import("raylib");
const client = @import("client_game.zig");
const util = @import("util.zig");
const expect = std.testing.expect;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer {
        const deinit_status = gpa.deinit();
        //fail test; can't try in defer as defer is executed after we return
        if (deinit_status == .leak) expect(false) catch @panic("TEST FAIL");
    }

    rl.setConfigFlags(
        rl.ConfigFlags{
            .window_resizable = true,
            .msaa_4x_hint = true,
        },
    );
    rl.initWindow(client.defaultScreenWidth, client.defaultScreenHeight, client.windowTitle);
    defer rl.closeWindow(); // Close window and OpenGL context

    //--------------------------------------------------------------------------------------
    const c = try client.init(allocator);
    c.updateDimensions(rl.getScreenHeight(), rl.getScreenWidth());
    rl.beginDrawing();

    // Loading Screen
    try c.load();

    rl.endDrawing();

    // Main game loop
    while (!rl.windowShouldClose()) { // Detect window close button or ESC key
        // Update
        //----------------------------------------------------------------------------------
        // TODO: Update your variables here
        //----------------------------------------------------------------------------------
        c.updateDimensions(rl.getScreenHeight(), rl.getScreenWidth());
        if (rl.isKeyPressed(rl.KeyboardKey.d)) {
            switch (c.debug) {
                true => c.debug = false,
                false => c.debug = true,
            }
        }
        try c.update();

        // Draw
        //----------------------------------------------------------------------------------
        rl.beginDrawing();
        defer rl.endDrawing();

        rl.clearBackground(rl.Color.white);

        try c.draw();
    }

    c.deinit();
}

fn ftoi(f: f32) i32 {
    return @intFromFloat(f);
}
