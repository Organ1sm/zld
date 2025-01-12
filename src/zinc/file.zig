const std = @import("std");
const Allocator = std.mem.Allocator;

const File = @This();

name: []const u8,
contents: []u8,

pub fn mustNewFile(allocator: Allocator, filename: []const u8) !File {
    const contents = try std.fs.cwd().readFileAlloc(allocator, filename, std.math.maxInt(u32));

    return .{
        .name = filename,
        .contents = contents,
    };
}

pub fn deinit(self: File, allocator: Allocator) void {
    allocator.free(self.contents);
}
