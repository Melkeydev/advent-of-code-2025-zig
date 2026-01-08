const std = @import("std");
const day_four = @import("day_four");
var stdout_buffer: [1024]u8 = undefined;
var stdout_writer = std.fs.File.stdout().writer(&stdout_buffer);
const stdout = &stdout_writer.interface;
const fs = std.fs;

// This is a BFS or DFS problem (similar to islands problem)
// Right now i am reading line by line but i just need to read the whole thing at once
//

const Position = struct {
    x: usize,
    y: usize,
};

pub fn main() !void {
    var counter: u64 = 0;
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var file = try open_file();
    defer file.close();

    try read_file(file, &counter, allocator);

    try stdout.print("this is the final counter - {d}\n", .{counter});
    try stdout.flush();
}

fn open_file() !fs.File {
    const file = try std.fs.cwd().openFile("inputs.txt", .{});
    return file;
}

fn read_file(file: fs.File, counter: *u64, allocator: std.mem.Allocator) !void {
    // load the contents into memory
    const contents = try file.readToEndAlloc(allocator, std.math.maxInt(usize));
    defer allocator.free(contents);

    // create an iterator
    var lines = std.mem.splitScalar(u8, contents, '\n');
    var grid_buf: [150][]u8 = undefined;
    var grid_len: usize = 0;

    while (lines.next()) |line| {
        if (line.len > 0) {
            grid_buf[grid_len] = @constCast(line);
            grid_len += 1;
        }
    }
    const grid = grid_buf[0..grid_len];

    while (true) {
        const to_remove = find_rolls(grid);
        counter.* += to_remove.len;

        remove_rolls(grid, to_remove);

        if (to_remove.len == 0) {
            break;
        }
    }
}

fn find_rolls(grid: [][]u8) []Position {
    var positions: [5000]Position = undefined;
    var count: usize = 0;
    for (grid, 0..) |row, y| {
        for (row, 0..) |cell, x| {
            if (cell == '@') {
                var inner_counter: u8 = 0;

                // top-left
                if (x > 0 and y > 0) {
                    if (grid[y - 1][x - 1] == '@') inner_counter += 1;
                }
                // top
                if (y > 0) {
                    if (grid[y - 1][x] == '@') inner_counter += 1;
                }
                // top-right
                if (x + 1 < row.len and y > 0) {
                    if (grid[y - 1][x + 1] == '@') inner_counter += 1;
                }
                // left
                if (x > 0) {
                    if (grid[y][x - 1] == '@') inner_counter += 1;
                }
                // right
                if (x + 1 < row.len) {
                    if (grid[y][x + 1] == '@') inner_counter += 1;
                }
                // bottom-left
                if (x > 0 and y + 1 < grid.len) {
                    if (grid[y + 1][x - 1] == '@') inner_counter += 1;
                }
                // bottom
                if (y + 1 < grid.len) {
                    if (grid[y + 1][x] == '@') inner_counter += 1;
                }
                // bottom-right
                if (x + 1 < row.len and y + 1 < grid.len) {
                    if (grid[y + 1][x + 1] == '@') inner_counter += 1;
                }

                if (inner_counter < 4) {
                    positions[count] = .{ .x = x, .y = y };
                    count += 1;
                }
            }
        }
    }
    return positions[0..count];
}

fn remove_rolls(grid: [][]u8, positions: []Position) void {
    // we change '@' to '.'

    // positoins is a list of positions
    for (positions) |pos| {
        grid[pos.y][pos.x] = '.';
    }
}
