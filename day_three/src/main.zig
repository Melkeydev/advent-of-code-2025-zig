const std = @import("std");
const day_three = @import("day_three");
var stdout_buffer: [1024]u8 = undefined;
var stdout_writer = std.fs.File.stdout().writer(&stdout_buffer);
const stdout = &stdout_writer.interface;
const fs = std.fs;

// Read inputs.txt file
// read each individual battery bank
// iterate through each individual bank and create biggest combo

pub fn main() !void {
    var counter: u64 = 0;

    var file = try open_file();
    defer file.close();

    try read_file(file, &counter);

    try stdout.print("this is the counter - {any}", .{counter});
    try stdout.flush();
}

fn open_file() !fs.File {
    const file = try std.fs.cwd().openFile("inputs.txt", .{});
    return file;
}

fn read_file(file: fs.File, counter: *u64) !void {
    var buffer: [1024]u8 = undefined;
    var file_reader = file.reader(&buffer);
    const reader = &file_reader.interface;

    // this was my previous mistake
    while (reader.takeDelimiterExclusive('\n')) |line| {
        var max_joltage: u8 = 0;
        const trimmed_line = std.mem.trimRight(u8, line, "\r\n");

        for (trimmed_line, 0..) |_, x| {
            for (trimmed_line[x + 1 ..], x + 1..) |_, y| {
                const tens = trimmed_line[x] - '0';
                const ones = trimmed_line[y] - '0';
                const joltage = tens * 10 + ones;

                if (joltage > max_joltage) {
                    max_joltage = joltage;
                }
            }
        }
        counter.* = counter.* + max_joltage;
    } else |err| {
        if (err != error.EndOfStream) return err;
    }
}
