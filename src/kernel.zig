pub const vga = @import("vga.zig");

const MBMAGIC = 0x36d76289;

extern fn kCrash() void;

export fn kInit(mboot_mag: u32, mboot_hdr: ?*c_void) void {
    //Fill this out
    vga.init();
    vga.puts(0, 0, vga.VGAColor.Yellow, vga.VGAColor.Black, "Loaded into kernel boiler-plate...");

    if (mboot_mag != MBMAGIC) {
        vga.puts(0, 1, vga.VGAColor.LightRed, vga.VGAColor.Black, "ERROR: Kernel must be loaded with MultiBoot2.");
        vga.puts(0, 2, vga.VGAColor.LightRed, vga.VGAColor.Black, "Failed to boot.");
        kCrash();
    } else {
        vga.puts(0, 1, vga.VGAColor.LightGreen, vga.VGAColor.Black, "Found Valid MultiBoot2 Header!");
    }

    //Otherwise initialize the rest of the system
}
