const io = @import("driver/io.zig");

/// This is the multiboot magic number to verify
//TODO: Make a multiboot.zig
const MBMAGIC = 0x36d76289;

/// Checks if the magic number is a valid multiboot magic number
/// If it is not, the kernel crashes.
pub fn validateMultiboot(magic: u32) void {
    if (magic != MBMAGIC) {
        io.vga.setFGColor(io.vga.Color.Red);
        @panic("Could not find a MultiBoot2 Header! Boot failed.");
    } else {
        io.println("Found Valid MultiBoot2 Header!");
    }
}