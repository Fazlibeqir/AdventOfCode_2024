const std = @import("std");

const data = @embedFile("input.txt");
const kernels_data = @embedFile("search_kernels.txt");

fn is_valid(x: i32, y: i32, row_count: i32, col_count: i32) bool {
    return x >= 0 and y >= 0 and x < row_count and y < col_count;
}

fn check_direction(grid: [][]u8, x: i32, y: i32, dx: i32, dy: i32, word: []const u8) bool {
    const word_length = word.len;
    for (0..word_length) |k| {
        const i: i32 = @intCast(k);
        const nx = x + (i * dx);
        const ny = y + (i * dy);

        if (nx < 0 or ny < 0) {
            return false;
        }

        const nxu: usize = @intCast(nx);
        const nyu: usize = @intCast(ny);

        const row_count: i32 = @intCast(grid.len);
        const col_count: i32 = @intCast(grid[0].len);

        if (!is_valid(nx, ny, row_count, col_count) or grid[nxu][nyu] != word[k]) {
            return false;
        }
    }
    return true;
}

pub fn count_xmas_occurrences(grid: [][]u8) i32 {
    const directions = [_][2]i32{
        .{ 0, 1 }, // Right
        .{ 1, 0 }, // Down
        .{ 1, 1 }, // Diagonal down-right
        .{ 1, -1 }, // Diagonal down-left
        .{ 0, -1 }, // Left
        .{ -1, 0 }, // Up
        .{ -1, -1 }, // Diagonal up-left
        .{ -1, 1 }, // Diagonal up-right
    };

    const word = "XMAS";
    const row_count: i32 = @intCast(grid.len);
    const col_count: i32 = @intCast(grid[0].len);
    var count: i32 = 0;

    var i: i32 = 0;
    while (i < row_count) {
        var j: i32 = 0;
        while (j < col_count) {
            for (directions) |dir| {
                if (check_direction(grid, i, j, dir[0], dir[1], word)) {
                    count += 1;
                }
            }
            j += 1;
        }
        i += 1;
    }

    return count;
}
pub fn count_xmas_patterns(lines: [][]const u8, search_kernels: [][][]const u8) i32 {
    var count: i32 = 0;
    const max_y = lines.len;
    const max_x = lines[0].len;

    for (0..max_y) |start_y| {
        for (0..max_x) |start_x| {
            for (search_kernels) |search_kernel| {
                var flag = true;

                if (start_y + search_kernel.len > max_y or start_x + search_kernel[0].len > max_x) {
                    continue;
                }
                for (0..search_kernel.len) |dy| {
                    for (0..search_kernel[dy].len) |dx| {
                        const char = lines[start_y + dy][start_x + dx];
                        const target = search_kernel[dy][dx];
                        if (target == '.') {
                            continue;
                        }
                        if (target != char) {
                            flag = false;
                            break;
                        }
                    }
                    if (!flag) {
                        break;
                    }
                }
                if (flag) {
                    count += 1;
                }
            }
        }
    }

    return count;
}

pub fn main() !void {
    const grid = try parse_grid(data);
    const search_kernels = try parse_kernels(kernels_data);

    // debugg
    std.debug.print("Grid size: {} x {}\n", .{ grid.len, grid[0].len });
    for (search_kernels) |kernel| {
        std.debug.print("Kernel size: {} x {}\n", .{ kernel.len, kernel[0].len });
        for (kernel) |line| {
            std.debug.print("{any}\n", .{line});
        }
        std.debug.print("\n", .{});
    }

    const result = count_xmas_occurrences(grid);
    try std.io.getStdOut().writer().print("Total occurrences of XMAS: {}\n", .{result});

    const result_part2 = count_xmas_patterns(grid, search_kernels);
    try std.io.getStdOut().writer().print("Total patterns of XMAS: {}\n", .{result_part2});
}

fn parse_grid(data1: []const u8) ![][]u8 {
    const allocator = std.heap.page_allocator;
    var grid = std.ArrayList([]u8).init(allocator);
    var current_row = std.ArrayList(u8).init(allocator);

    for (data1) |c| {
        if (c == '\n') {
            if (current_row.items.len > 0) {
                try grid.append(array_list_to_slice_u8(current_row));
                current_row = std.ArrayList(u8).init(allocator);
            }
        } else {
            try current_row.append(c);
        }
    }

    if (current_row.items.len > 0) {
        try grid.append(array_list_to_slice_u8(current_row));
    }

    return grid.items;
}

fn parse_kernels(data1: []const u8) ![][][]const u8 {
    const allocator = std.heap.page_allocator;
    var kernels = std.ArrayList([][]const u8).init(allocator);
    var current_kernel = std.ArrayList([]const u8).init(allocator);

    var line_start: usize = 0;
    var i: usize = 0;

    while (i < data1.len) {
        const c = data1[i];
        if (c == '\n' or i == data1.len - 1) {
            const line = if (i == data1.len - 1) data1[line_start..] else data1[line_start..i];
            try current_kernel.append(line);
            line_start = i + 1;

            if (c == '\n' and current_kernel.items.len > 0) {
                try kernels.append(array_list_to_slice_kernel(current_kernel));
                current_kernel = std.ArrayList([]const u8).init(allocator);
            }
        }
        i += 1;
    }

    if (current_kernel.items.len > 0) {
        try kernels.append(array_list_to_slice_kernel(current_kernel));
    }

    return kernels.items;
}

fn array_list_to_slice_u8(list: std.ArrayList(u8)) []u8 {
    return list.items[0..list.items.len];
}

fn array_list_to_slice_kernel(list: std.ArrayList([]const u8)) [][]const u8 {
    return list.items;
}
