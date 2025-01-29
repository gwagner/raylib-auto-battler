const std = @import("std");
const rl = @import("raylib");
const client = @import("client_game.zig");
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

        c.draw();

        if (c.debug) {
            rl.drawFPS(10, 10);

            const mousePosition = rl.getMousePosition();

            const pos_text = try std.fmt.allocPrintZ(allocator, "Mouse Position: ({d}, {d})", .{ mousePosition.x, mousePosition.y });
            rl.drawText(@ptrCast(pos_text.ptr), 10, 40, 10, rl.Color.green);
            allocator.free(pos_text);

            rl.drawLine(ftoi(mousePosition.x), 0, ftoi(mousePosition.x), c.current_screen_height, rl.Color.green);
            rl.drawLine(0, ftoi(mousePosition.y), c.current_screen_width, ftoi(mousePosition.y), rl.Color.green);
        }
    }

    c.deinit();
}

fn ftoi(f: f32) i32 {
    return @intFromFloat(f);
}
