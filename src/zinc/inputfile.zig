const std = @import("std");
const Allocator = std.mem.Allocator;
const Elf = @import("elf.zig");
const Ehdr = Elf.Ehdr;
const Shdr = Elf.Shdr;
const File = @import("file.zig");
const Util = @import("util.zig");
const Magic = @import("magic.zig");

const InputFile = @This();

file: *const File,
elfSections: ?[]Shdr = null,

pub fn new(file: *const File, allocator: Allocator) !InputFile {
    var f: InputFile = .{ .file = file };
    if (file.contents.len < Elf.EhdrSize) Util.fatal("file too small");
    if (!Magic.checkMagic(file.contents)) Util.fatal("not an elf file");

    const ehdr = try Util.read(Ehdr, file.contents);
    var contents = file.contents[ehdr.sh_off..];
    const shdr = try Util.read(Shdr, contents);

    var numSections: i64 = @intCast(ehdr.sh_num);
    if (numSections == 0) numSections = @intCast(shdr.size);

    var shdrList = std.ArrayList(Shdr).init(allocator);
    defer shdrList.deinit();

    try shdrList.append(shdr);
    f.elfSections = shdrList.items;

    while (numSections > 1) {
        contents = contents[Elf.ShdrSize..];

        try shdrList.ensureUnusedCapacity(1);
        try shdrList.append(try Util.read(Shdr, contents));

        f.elfSections = shdrList.items;

        numSections -= 1;
    }

    return f;
}
