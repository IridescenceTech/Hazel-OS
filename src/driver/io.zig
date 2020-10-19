//General Purpose IO Driver

/// Includes the VGA Module
pub const vga = @import("vga.zig");

/// Includes the Serial I/O Module
pub const sio = @import("serial.zig");

/// Initializes Serial I/O and sets up defaults for the VGA driver
pub inline fn init() void {
    vga.init();
    vga.setFGColor(vga.Color.Yellow);
    sio.init();
}

/// Puts a char to output
pub inline fn putChar(char: u8) void {
    vga.print(&[_]u8{char});
    sio.putChar(char);
}

/// Prints a string to both I/O interfaces
pub inline fn print(string: []const u8) void {
    vga.print(string);
    sio.print(string);
}

/// Prints a string with a newline to both I/O interfaces
pub inline fn println(string: []const u8) void {
    vga.println(string);
    sio.println(string);
}

/// Get a character from serial I/O
pub inline fn getChar() u8 {
    return sio.getChar();
}