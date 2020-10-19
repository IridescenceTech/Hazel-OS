//Validate the kernel with refAllDecls
test "" {@import("std").testing.refAllDecls(@This());}

//The VGA Driver
pub const vga = @import("vga.zig");

/// This is the multiboot magic number to verify
//TODO: Make a multiboot.zig
const MBMAGIC = 0x36d76289;

/// kCrash() is a silent method that simply hangs the CPU
fn kCrash() noreturn {
    asm volatile(
        \\cli
        \\hlt
    );
    while(true){}
}

fn validateMultiboot(magic: u32) void {
    if (magic != MBMAGIC) {
        vga.setFGColor(vga.VGAColor.Red);
        vga.println("ERROR: Kernel must be loaded with MultiBoot2.");
        vga.println("Failed to boot.");
        kCrash();
    } else {
        vga.println("Found Valid MultiBoot2 Header!");
    }
}

/// This is the main boilerplate for kernel execution
/// Here, we are in charge of setting up the system for our needs.
/// Errors here will result in direct crashes with error messages.
export fn kInit(magic: u32, mboot_hdr: ?*c_void) void {
    
    //Print a very basic message
    vga.setFGColor(vga.VGAColor.Yellow);
    vga.println("Loaded into kernel boiler-plate...");

    //Validate the Multiboot header
    validateMultiboot(magic);
    
    
}
