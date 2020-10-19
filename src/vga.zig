/// This enumeration describes the 16 possible VGA Text Colors
/// Each Color is represented by 4 bits, such that the text color
/// including foreground and background can be made into 1 byte
/// This means that a character displayed to the screen is in the 
/// format |fg|bg|char| within a 16 bit integer (1 byte color, 1 char)
pub const VGAColor = enum(u4) {
    Black = 0, Blue = 1, Green = 2, Cyan = 3, Red = 4, Magenta = 5, Brown = 6, LightGray = 7, DarkGray = 8, LightBlue = 9, LightGreen = 10, LightCyan = 11, LightRed = 12, Pink = 13, Yellow = 14, White = 15
};

/// The VGA Text buffer specification says that there are 80 columns
pub const ScrWidth: u8 = 80;

/// The VGA Text buffer specification says that there are 25 rows
pub const ScrHeight: u8 = 25;

/// These are the internal terminal X & Y and keep track of print position.
var tx: u8 = 0;
var ty: u8 = 0;

/// These are the internal terminal foreground and background colors
/// and they specify the color of a print command.
var ifg: VGAColor = VGAColor.White;
var ibg: VGAColor = VGAColor.Black;

/// The VGA text buffer is a pointer to memory address 0xb8000
/// The text buffer is consisted of 80 x 25 columns and rows of 16-bit
/// Integers which hold the data as described by the VGA text colors.
var text_buffer: [*]u16 = @intToPtr([*]u16, 0xb8000);

/// This function sets the internal foreground color to a new VGA color.
pub fn setFGColor(nfg: VGAColor) void {
    ifg = nfg;
}

/// This function sets the internal background color to a new VGA color.
pub fn setBGColor(nbg: VGAColor) void {
    ibg = nbg;
}

/// This function creates a VGA text buffer entry with the correct color
/// and character. The two VGA colors become a single byte with |fg|bg|
/// which prefixes the character in the Least Significant Byte.
fn makeVGACode(fg: VGAColor, bg: VGAColor, char: u8) u16 {
    return @intCast(u16, @enumToInt(bg)) << 4 | @intCast(u16, @enumToInt(fg)) << 8 | char;
}

/// The clear function starts at 0 and iterates through all 80x25 columns
/// and rows to set every value to 0. This clears the screen to black and
/// the screen is filled with null characters.
pub fn clear() void {
    var x: usize = 0;
    while (x < ScrWidth) : (x += 1) {
        var y: usize = 0;
        while (y < ScrHeight) : (y += 1) {
            text_buffer[y * ScrWidth + x] = 0;
        }
    }
}

/// The putChar method replaces a single entry at X, Y with a new entry
/// with FG and BG colors and the character specified.
pub fn putChar(x: u8, y: u8, fg: VGAColor, bg: VGAColor, char: u8) void {
    text_buffer[y * ScrWidth + x] = makeVGACode(fg, bg, char);
}

/// The puts method is a simple method which renders a string onto the
/// screen with a given FG and BG color. The string may span onto a new
/// line. If said newline is equivalent to the end of the text buffer, then
/// the buffer is cleared and the text starts again at the top left.
pub fn puts(cx: u8, cy: u8, cfg: VGAColor, cbg: VGAColor, string: []const u8) void {
    var ix = cx;
    var iy = cy;

    var i: usize = 0;
    while (i < string.len) : (i += 1) {
        putChar(ix, iy, cfg, cbg, string[i]);

        if (ix == ScrWidth) {
            ix = 0;
            iy += 1;
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

/// The print command is nearly identical to the puts command but uses
/// the internal values for X and Y, alongside the internal color set.
/// The print command also handles newlines, tabs, and other special
/// characters in addition. The print command behaves identically otherwise.
pub fn print(string: []const u8) void {
    var i: usize = 0;
    while(i < string.len) : (i += 1) {

        //Look for special characters.

        //Is a new line
        if(string[i] == '\n'){
            tx = 0;
            ty += 1;
            //We must also check that we hit the end of the buffer
            if(ty == ScrHeight) {
                clear();
                tx = 0;
                ty = 0;
            }

            continue;
        }

        //Is a tab
        if(string[i] == '\t'){
            //Add spaces until it evenly divides by 4.
            var currentAlign = tx / 4;
            while(tx / 4 == currentAlign) : (tx += 1){}

            if(tx == ScrWidth){
                tx = 0;
                ty += 1;
            }

            if(ty == ScrHeight) {
                clear();
                tx = 0;
                ty = 0;
            }

            continue;
        }

        //Print the character
        putChar(tx, ty, ifg, ibg, string[i]);

        //Checks if we hit the end of the columns
        if(tx == ScrWidth){
            tx = 0;
            ty += 1;
        }

        //Checks if we hit the end of the buffer
        if(ty == ScrHeight) {
            clear();
            tx = 0;
            ty = 0;
            continue;
        }

        //Increment by one.
        tx += 1;
    }
}

/// The print line function appends a newline to the string and passes
/// the end result to the main print function. This function is  purely for
/// syntactic sugar.
pub fn println(comptime string: []const u8) void {
    print(string ++ "\n");
}
