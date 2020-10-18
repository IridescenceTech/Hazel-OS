pub const VGAColor = enum(u16) {
    Black = 0, Blue = 1, Green = 2, Cyan = 3, Red = 4, Magenta = 5, Brown = 6, LightGray = 7, DarkGray = 8, LightBlue = 9, LightGreen = 10, LightCyan = 11, LightRed = 12, Pink = 13, Yellow = 14, White = 15
};

pub const ScrWidth: u8 = 80;
pub const ScrHeight: u8 = 25;

var text_buffer: [*]u16 = @intToPtr([*]u16, 0xb8000);

pub fn init() void {
    clear();
}

pub fn clear() void {
    var x: usize = 0;
    while (x < ScrWidth) : (x += 1) {
        var y: usize = 0;
        while (y < ScrHeight) : (y += 1) {
            text_buffer[y * ScrWidth + x] = 0;
        }
    }
}

fn makeVGACode(fg: VGAColor, bg: VGAColor, char: u8) u16 {
    return @enumToInt(bg) << 4 | @enumToInt(fg) << 8 | char;
}

pub fn putChar(x: u8, y: u8, fg: VGAColor, bg: VGAColor, char: u8) void {
    text_buffer[y * ScrWidth + x] = makeVGACode(fg, bg, char);
}

pub fn puts(x: u8, y: u8, fg: VGAColor, bg: VGAColor, string: []const u8) void {
    var ix = x;
    var iy = y;

    var i: usize = 0;
    while (i < string.len) : (i += 1) {
        putChar(ix, iy, fg, bg, string[i]);

        if (ix == ScrWidth) {
            ix = 0;
            iy += 1;
            continue;
        }

        if (iy == ScrHeight) {
            clear();
            iy = 0;
            ix = 0;
            continue;
        }

        ix += 1;
    }
}
