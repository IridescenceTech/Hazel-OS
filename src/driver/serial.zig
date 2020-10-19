//Used for port I/O
const x86 = @import("x86.zig");

//This is the serial port
const port: u16 = 0x3F8;

/// This function initializes the serial port connection and sets up the port for I/O
pub fn init() void {
    x86.writeByte(port + 1, 0x00);
    x86.writeByte(port + 3, 0x80);
    x86.writeByte(port + 0, 0x03);
    x86.writeByte(port + 1, 0x00);
    x86.writeByte(port + 3, 0x03);
    x86.writeByte(port + 2, 0xC7);
    x86.writeByte(port + 4, 0x0B);
}

/// This function is used to determine whether or not data is ready to be received
/// over the port itself.
pub fn serialReceived() bool {
    return (x86.readByte(port + 5) & 1) != 0;
}

/// This is a blocking call to read the serial port. If there is no data for the port,
/// the program will wait for there to be data before reading.
pub fn getChar() u8 {
    while(!serialReceived()){}

    return x86.readByte(port);
}

/// This function is used to determine whether or not the port has transmitted 
/// and is ready to receive new data to transmit.
pub fn transmitEmpty() bool {
    return (x86.readByte(port + 5) & 0x20) != 0;
}

/// This is a blocking call to write data to the serial port. If there is still data 
/// not yet transmitted, the program will wait for there to be open space.
pub fn putChar(char: u8) void {
    while(!transmitEmpty()){}
    x86.writeByte(port, char);
}

/// The print function will print a string out to the serial port.
pub fn print(string: []const u8) void {
    var i: usize = 0;
    while(i < string.len) : (i += 1) {
        putChar(string[i]);
    }
}

/// The print line function appends a newline to the end of the string.
pub inline fn println(string: []const u8) void{
    print(string);
    print("\n");
}