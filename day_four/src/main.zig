const std = @import("std");
const day_four = @import("day_four");
var stdout_buffer: [1024]u8 = undefined;
var stdout_writer = std.fs.File.stdout().writer(&stdout_buffer);
const stdout = &stdout_writer.interface;
const fs = std.fs;

pub fn main() !void {
    var counter: u64 = 0;

    var file = try open_file();
    defer file.close();

    try read_file(file, &counter);

    try stdout.print("this is the final counter - {d}\n", .{counter});
}

fn open_file() !fs.File {
    const file = try std.fs.cwd().openFile("inputs.txt", .{});
    return file;
}

fn read_file(file: fs.File, counter: *u64) !void {
    var buffer: [1024]u8 = undefined;
    var file_reader = file.reader(&buffer);
    const reader = &file_reader.interface;

    while (reader.takeDelimiterExclusive('\n')) |line| {
        const trimmed_line = std.mem.trimRight(u8, line, "\r\n");

        try stdout.print("this is the trimmed_line - {s} and counter - {d}\n", .{ trimmed_line, counter.* });
    } else |err| {
        if (err != error.EndOfStream) return err;
    }
}
