const io = @import("driver/io.zig");
const x86 = @import("driver/x86.zig");

const builtin = @import("builtin");

export fn errorCB(code: u32) void {
    x86.hang();
}

pub fn drawBSOD(panicMessage: []const u8, addrMessage: []const u8) void {
    io.vga.setBGColor(io.vga.Color.Blue);
    io.vga.setFGColor(io.vga.Color.White);
    io.vga.clear();

    //Tell the user that the kernel has panicked
    io.vga.setPosXY(0, 0);

    io.println("A problem has been detected and Hazel has been shut down to prevent damage\nto your computer.\n");
    io.println("If this is the first time you've seen this Stop error screen, restart your\ncomputer. If this screen appears again, follow these steps:\n");
    io.println("Check to be sure you have adequate disk space. If a driver is identified in the Stop message, disable the driver or check with the manufacturer for driver updates. Try changing video adapters.\n");
    io.println("Check with your hardware vendor for any BIOS updates. Disable BIOS memory\noptions such as caching or shadowing. If you need to use Safe Mode to remove or disable components, restart your computer, press F8 to select Advanced Startup\nOptions, and then select Safe Mode.\n\n");
    io.println("Technical information: \n");
    io.print("Kernel Panic: ");
    //Give the panic message
    io.println(panicMessage);
    io.println(addrMessage);

    io.println("Hanging computer...\n");
    io.print("Please Restart.");
}

/// Kernel Panic!
/// A kernel panic results in the output of the panic itself, and an address.
/// The address can be used in addr2line -e kernel.bin to find the exact line
/// at which the kernel has panicked.
pub fn panic(message: []const u8, stack_trace: ?*builtin.StackTrace) noreturn {
    @setCold(true);
    @setRuntimeSafety(false);
    
    const std = @import("std");
    var it = std.debug.StackIterator.init(@returnAddress(), @frameAddress());
    while (it.next()) |return_address| {
        if (return_address == 0) break;
        var buf : [64]u8 = undefined;
        std.mem.set(u8, buf[0..], 0);

        var str = std.fmt.bufPrint(buf[0..], "Found error at: 0x{x}\n\n", .{return_address-4}) catch unreachable;
        drawBSOD(message, str);
        break;
    }
    x86.hang();
}