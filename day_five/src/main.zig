const std = @import("std");
const day_five = @import("day_five");
var stdout_buffer: [1024]u8 = undefined;
var stdout_writer = std.fs.File.stdout().writer(&stdout_buffer);
const stdout = &stdout_writer.interface;
const fs = std.fs;

const Range = struct {
    start: u64,
    end: u64,
};

const ParseResult = struct {
    ranges: []Range,
    values: []u64,
};

pub fn main() !void {
    var counter: u64 = 0;
    const file = try open_file();

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const parsed_results = try read_file_and_get_ranges_and_values(file, allocator);
    defer allocator.free(parsed_results.ranges);
    defer allocator.free(parsed_results.values);

    // Part 1
    check_results(parsed_results, &counter);
    try stdout.print("Part 1 counter: {d}\n", .{counter});

    // Part 2
    const fresh_count = count_fresh_ids(parsed_results.ranges);
    try stdout.print("Part 2 fresh IDs: {d}\n", .{fresh_count});
    try stdout.flush();
}

fn check_results(parsed_results: ParseResult, counter: *u64) void {
    for (parsed_results.values) |value| {
        for (parsed_results.ranges) |range| {
            if (value >= range.start and value <= range.end) {
                counter.* += 1;
                break;
            }
        }
    }
}

fn count_fresh_ids(ranges: []Range) u64 {
    if (ranges.len == 0) return 0;

    std.mem.sort(Range, ranges, {}, struct {
        fn lessThan(_: void, a: Range, b: Range) bool {
            return a.start < b.start;
        }
    }.lessThan);

    var total: u64 = 0;
    var current_start = ranges[0].start;
    var current_end = ranges[0].end;

    for (ranges[1..]) |range| {
        if (range.start <= current_end + 1) {
            current_end = @max(current_end, range.end);
        } else {
            total += current_end - current_start + 1;
            current_start = range.start;
            current_end = range.end;
        }
    }
    total += current_end - current_start + 1;

    return total;
}

// this will need to return the array with the ranges
fn read_file_and_get_ranges_and_values(file: fs.File, allocator: std.mem.Allocator) !ParseResult {
    var buffer: [1024]u8 = undefined;
    var file_reader = file.reader(&buffer);
    const reader = &file_reader.interface;

    // lets create the buffer to store everything
    // this will exist just on the heap
    var range_buffer: [1000]Range = undefined;
    var range_len: usize = 0;

    var value_buffer: [1000]u64 = undefined;
    var value_len: usize = 0;

    var collecting_ranges: bool = true;
    while (reader.takeDelimiterExclusive('\n')) |line| {
        if (line.len == 0) {
            collecting_ranges = false;
            continue;
        }

        if (collecting_ranges) {
            var parts = std.mem.splitScalar(u8, line, '-');
            const start_str = parts.next().?;
            const end_str = parts.next().?;

            const start = try std.fmt.parseInt(u64, start_str, 10);
            const end = try std.fmt.parseInt(u64, end_str, 10);

            const new_range = Range{ .start = start, .end = end };

            range_buffer[range_len] = new_range;
            range_len += 1;
        } else {
            const value = try std.fmt.parseInt(u64, line, 10);

            value_buffer[value_len] = value;
            value_len += 1;
        }
    } else |err| {
        if (err != error.EndOfStream) return err;
    }

    const ranges = try allocator.dupe(Range, range_buffer[0..range_len]);
    const values = try allocator.dupe(u64, value_buffer[0..value_len]);
    return .{ .ranges = ranges, .values = values };
}

fn open_file() !fs.File {
    const file = try std.fs.cwd().openFile("input.txt", .{});
    return file;
}
