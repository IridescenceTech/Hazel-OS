/// Read a single byte from a port
pub inline fn readByte(port: u16) u8 {
    return asm volatile ("inb %[port], %[result]"
        : [result] "={al}" (-> u8)
        : [port] "N{dx}" (port)
    );
}

/// Send a single byte to a port
pub inline fn writeByte(port: u16, val: u8) void {
    asm volatile ("outb %[val], %[port]"
        :
        : [val] "{al}" (val),
          [port] "N{dx}" (port)
    );
}

/// Read a u16 from a port
pub inline fn readWord(port: u16) u16 {
    return asm volatile ("inw %[port], %[result]"
        : [result] "={ax}" (-> u16)
        : [port] "N{dx}" (port)
    );
}

/// Send a u16 to a port
pub inline fn writeWord(port: u16, val: u16) void {
    asm volatile ("outw %[val], %[port]"
        :
        : [val] "{ax}" (val),
          [port] "N{dx}" (port)
    );
}

/// Read a u32 from a port
pub inline fn readLong(port: u16) u32 {
    return asm volatile ("inl %[port], %[result]"
        : [result] "={eax}" (-> u32)
        : [port] "N{dx}" (port)
    );
}

/// Send a u32 to a port
pub inline fn writeLong(port: u16, val: u32) void {
    asm volatile ("outl %[val], %[port]"
        :
        : [val] "{eax}" (val),
          [port] "N{dx}" (port)
    );
}

/// Clear Interrupts
pub inline fn cli() void {
    asm volatile ("cli");
}

/// Start Interrupts
pub inline fn sti() void {
    asm volatile ("sti");
}

/// Hang the computer
pub inline fn hang() noreturn {
    asm volatile (
        \\cli
        \\hlt
    );
    while(true){}
}
