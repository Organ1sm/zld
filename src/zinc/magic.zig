const std = @import("std");

pub fn checkMagic(contents: []const u8) bool {
    return std.mem.startsWith(u8, contents, "\x7FELF");
}
