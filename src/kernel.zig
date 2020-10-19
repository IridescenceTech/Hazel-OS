//Validate the kernel with refAllDecls
test "" {
    @import("std").testing.refAllDecls(@This());
}

//The VGA Driver
pub const io = @import("driver/io.zig");
pub const x86 = @import("driver/x86.zig");

/// A simple method that simply hangs the CPU
fn kCrash() noreturn {
    io.println("KERNEL HAS CRASHED!");
    x86.hang();
    while (true) {}
}


/// This is the multiboot magic number to verify
//TODO: Make a multiboot.zig
const MBMAGIC = 0x36d76289;

/// Checks if the magic number is a valid multiboot magic number
/// If it is not, the kernel crashes.
fn validateMultiboot(magic: u32) void {
    if (magic != MBMAGIC) {
        io.vga.setFGColor(io.vga.Color.Red);
        io.println("ERROR: Kernel must be loaded with MultiBoot2.");
        io.println("Failed to boot.");
        kCrash();
    } else {
        io.println("Found Valid MultiBoot2 Header!");
    }
}

/// This is the main boilerplate for kernel execution
/// Here, we are in charge of setting up the system for our needs.
/// Errors here will result in direct crashes with error messages.
export fn kInit(magic: u32, mboot_hdr: ?*c_void) void {
    io.init();

    io.putChar('q');
    //Print a very basic message
    io.println("Loaded into kernel boiler-plate...");

    //Validate the Multiboot header
    validateMultiboot(magic);
}
