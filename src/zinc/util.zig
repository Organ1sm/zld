const std = @import("std");

pub fn fatal(msg: []const u8) void {
    var m = defaultMsgWriter(detectConfig(std.io.getStdErr()));
    defer m.deinit();

    m.start(.@"fatal error");
    m.print("{s}", .{msg});
    m.end();

    std.process.exit(1);
}

pub fn read(comptime T: type, data: []const u8) !T {
    if (data.len < @sizeOf(T)) return error.InsufficientSize;

    const value = std.mem.bytesToValue(T, data[0..@sizeOf(T)]);
    return std.mem.littleToNative(T, value);
}

pub fn detectConfig(file: std.fs.File) std.io.tty.Config {
    if (file.supportsAnsiEscapeCodes()) return .escape_codes;
    if (@import("builtin").os.tag == .windows and file.isTty()) {
        var info: std.os.windows.CONSOLE_SCREEN_BUFFER_INFO = undefined;
        if (std.os.windows.kernel32.GetConsoleScreenBufferInfo(file.handle, &info) != std.os.windows.TRUE) {
            return .no_color;
        }

        return .{
            .windows_api = .{
                .handle = file.handle,
                .reset_attributes = info.wAttributes,
            },
        };
    }

    return .no_color;
}

fn defaultMsgWriter(config: std.io.tty.Config) MsgWriter {
    return MsgWriter.init(config);
}

pub const Kind = enum { @"fatal error", @"error", note, warning, off, default };

const MsgWriter = struct {
    w: std.io.BufferedWriter(4096, std.fs.File.Writer),
    config: std.io.tty.Config,

    fn init(config: std.io.tty.Config) MsgWriter {
        std.debug.lockStdErr();
        return .{
            .w = std.io.bufferedWriter(std.io.getStdErr().writer()),
            .config = config,
        };
    }

    pub fn deinit(m: *MsgWriter) void {
        m.w.flush() catch {};
        std.debug.unlockStdErr();
    }

    pub fn print(m: *MsgWriter, comptime fmt: []const u8, args: anytype) void {
        m.w.writer().print(fmt, args) catch {};
    }

    fn write(m: *MsgWriter, msg: []const u8) void {
        m.w.writer().writeAll(msg) catch {};
    }

    fn setColor(m: *MsgWriter, color: std.io.tty.Color) void {
        m.config.setColor(m.w.writer(), color) catch {};
    }

    fn start(m: *MsgWriter, kind: Kind) void {
        switch (kind) {
            .@"fatal error", .@"error" => m.setColor(.bright_red),
            .note => m.setColor(.bright_cyan),
            .warning => m.setColor(.bright_magenta),
            .off, .default => unreachable,
        }
        m.write(switch (kind) {
            .@"fatal error" => "fatal error: ",
            .@"error" => "error: ",
            .note => "note: ",
            .warning => "warning: ",
            .off, .default => unreachable,
        });
        m.setColor(.white);
    }

    fn end(m: *MsgWriter) void {
        m.write("\n");
        m.setColor(.reset);
        return;
    }
};
