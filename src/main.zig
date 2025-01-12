const std = @import("std");
const process = std.process;
const zinc = @import("zinc");
const File = zinc.File;
const Util = zinc.Util;
const InputFile = zinc.IntputFile;

var GeneralPurposeAllocator = std.heap.GeneralPurposeAllocator(.{}){};

pub fn main() !u8 {
    const gpa = if (@import("builtin").link_libc)
        std.heap.raw_c_allocator
    else
        GeneralPurposeAllocator.allocator();
    defer if (!@import("builtin").link_libc) {
        _ = GeneralPurposeAllocator.deinit();
    };

    var arenaInstance = std.heap.ArenaAllocator.init(gpa);
    defer arenaInstance.deinit();

    const arena = arenaInstance.allocator();

    const fastExit = @import("builtin").mode != .Debug;
    const args = process.argsAlloc(arena) catch {
        std.debug.print("out of memory\n", .{});
        if (fastExit) process.exit(1);
        return 1;
    };

    if (args.len < 2) {
        Util.fatal("wrong args");
        return error.InvalidArguments;
    }

    const file = File.mustNewFile(gpa, args[1]) catch |err| {
        Util.fatal(@errorName(err));
        return 1;
    };
    defer file.deinit(gpa);

    _ = InputFile.new(&file, gpa) catch |err| {
        Util.fatal(@errorName(err));
        return 1;
    };

    std.debug.print("{s}:{s}\n", .{ file.name, file.contents });

    std.debug.print("{s}\n", .{args});

    return 0;
}
