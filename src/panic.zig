const io = @import("driver/io.zig");
const x86 = @import("driver/x86.zig");

const builtin = @import("builtin");

/// Kernel Panic!
/// A kernel panic results in the output of the panic itself, and an address.
/// The address can be used in addr2line -e kernel.bin to find the exact line
/// at which the kernel has panicked.
pub fn panic(message: []const u8, stack_trace: ?*builtin.StackTrace) noreturn {
    @setCold(true);
    @setRuntimeSafety(false);

    //Tell the user that the kernel has panicked
    io.vga.setFGColor(io.vga.Color.Red);
    io.println("KERNEL HAS PANICKED!");

    //Give the panic message
    io.println(message);

    const std = @import("std");
    var it = std.debug.StackIterator.init(@returnAddress(), @frameAddress());
    while (it.next()) |return_address| {
        if (return_address == 0) break;
        var buf : [64]u8 = undefined;
        std.mem.set(u8, buf[0..], 0);

        var str = std.fmt.bufPrint(buf[0..], "ADDR: 0x{x}\n", .{return_address-4}) catch unreachable;
        io.print(str);
    }
    x86.hang();
}