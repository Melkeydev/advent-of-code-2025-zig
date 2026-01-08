const std = @import("std");
const day_four = @import("day_four");

//create the writer interface
var stdout_buffer: [1024]u8 = undefined;
var stdout_writer = std.fs.File.stdout().writer(&stdout_buffer);
const stdout = &stdout_writer.interface;
const fs = std.fs;

pub fn main() !void {
    var counter: u64 = undefined;
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    const allocator = gpa.allocator();

    var file = try open_file();
    defer file.close();

    try read_file(file, counter, allocator);
}

fn open_file() !fs.File {
    const file = try std.fs.cwd().openFile("inputs.txt", .{});
    return file;
}

fn read_file(file: fs.File, counter: *u64, allocator: std.mem.Allocator) !void {
    // load the file into memory
    const contents = try file.readToEndAlloc(allocator, std.math.maxInt(usize));
    defer allocator.free(contents);

    var lines = std.mem.splitScalar(u8, contents, '\n');
    var grid_buf: [150][]const u8 = undefined;
    var grid_len: usize = 0;

    while (lines.next()) |line| {
        if (line.len > 0) {
            grid_buf[grid_len] = line;
            grid_len += 1;
        }
    }

    const grid = grid_buf[0..grid_len];
}
