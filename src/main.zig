const std = @import("std");
const advent_of_code = @import("advent_of_code");
var stdout_buffer: [1024]u8 = undefined;
var stdout_writer = std.fs.File.stdout().writer(&stdout_buffer);
const stdout = &stdout_writer.interface;
const fs = std.fs;

// Day 1
//
// first step read an input file
// if/else statement keeping track of first character for either L or R
// edge cases
// starts at 50
pub fn main() !void {
    var dial_position: i32 = 50;

    try stdout.print("this is the dial - {any}\n", .{dial_position});

    var file = try open_file();
    defer file.close();

    try read_file(file, &dial_position);

    try stdout.print("final position value - {d}\n", .{dial_position});
    try stdout.flush();
}

fn open_file() !fs.File {
    const file = try std.fs.cwd().openFile("src/inputs.txt", .{});
    return file;
}

fn read_file(file: fs.File, dial_position: *i32) !void {
    var buffer: [1024]u8 = undefined;
    var file_reader = file.reader(&buffer);
    const reader = &file_reader.interface;

    while (reader.takeDelimiterExclusive('\n')) |line| {
        const trimmed_line = std.mem.trimRight(u8, line, "\r");
        // try stdout.print("this is the line {s}\n", .{trimmed_line});
        try process_code(trimmed_line, dial_position);
    } else |err| {
        if (err != error.EndOfStream) return err;
    }
}

fn process_code(code: []const u8, dial_position: *i32) !void {
    const direction = code[0];
    const value = try std.fmt.parseInt(i32, code[1..], 10);

    if (direction == 'R') {
        // we can increment
        dial_position.* = dial_position.* + value;

        try stdout.print("this is the value {d}, this is direction {c}\n", .{ value, direction });
    } else {
        // we can subsctract
        try stdout.print("this is the value {any}\n", .{value});
    }
}
