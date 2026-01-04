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

    try stdout.print("this is the counter - {any}\n", .{counter});
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
        const trimmed_line = std.mem.trimRight(u8, line, "\r\n");

        var result: [12]u8 = undefined;
        var start: usize = 0;
        const k: usize = 12;

        for (0..k) |i| {
            const end = trimmed_line.len - (k - i);
            var max_digit: u8 = 0;
            var max_pos: usize = start;

            var pos = start;

            while (pos <= end) : (pos += 1) {
                if (trimmed_line[pos] > max_digit) {
                    max_digit = trimmed_line[pos];
                    max_pos = pos;
                }
            }

            result[i] = max_digit;
            start = max_pos + 1;
        }

        const joltage = try std.fmt.parseInt(u64, &result, 10);
        counter.* = counter.* + joltage;
    } else |err| {
        if (err != error.EndOfStream) return err;
    }
}
