const std = @import("std");
var stdout_buffer: [1024]u8 = undefined;
var stdout_writer = std.fs.File.stdout().writer(&stdout_buffer);
const stdout = &stdout_writer.interface;
const fs = std.fs;

// Day 2
// Read input.txt
// Separate each range of values by their comma
// all duplicates need to be invalided. 11 is invalid. 1212 is invalid. 123123 is invalid. *this part is kind of confusing
// separate the two values from the '-'
// loop (inclusive) from the first to the last value
// combine all the invalid numbers in each comma range

pub fn main() !void {
    var counter: u64 = 0;

    var file = try open_file();
    defer file.close();

    try read_file(file, &counter);

    try stdout.print("the counter is - {d}\n", .{counter});
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

    while (reader.takeDelimiterExclusive(',')) |line| {
        const trimmed_line = std.mem.trimRight(u8, line, "\r\n");

        var parts = std.mem.splitScalar(u8, trimmed_line, '-');
        const first_num = try std.fmt.parseInt(u64, parts.next().?, 10);
        const second_num = try std.fmt.parseInt(u64, parts.next().?, 10);

        var value = first_num;

        while (value <= second_num) : (value += 1) {
            var num_buf: [20]u8 = undefined;
            const num_str = std.fmt.bufPrint(&num_buf, "{d}", .{value}) catch unreachable;

            if (num_str.len % 2 == 0) {
                const half = num_str.len / 2;
                const first_half = num_str[0..half];
                const second_half = num_str[half..];

                if (std.mem.eql(u8, first_half, second_half)) {
                    try stdout.print("invalid: {s}\n", .{num_str});
                    const num_int = try std.fmt.parseInt(u64, num_str, 10);
                    counter.* = counter.* + num_int;
                }
            }
        }
    } else |err| {
        if (err != error.EndOfStream) return err;
    }
}

fn process_code() !void {}
