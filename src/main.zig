const std = @import("std");
const data = @embedFile("input.txt");
const split = std.mem.split;

fn abs(value: i32) i32 {
    if (value < 0) {
        return -value;
    }
    return value;
}
fn sort(array: []i32) void {
    const len = array.len;
    if (len <= 1) return;

    for (0..len - 1) |i| {
        for (0..len - 1 - i) |j| {
            if (array[j] > array[j + 1]) {
                const temp = array[j];
                array[j] = array[j + 1];
                array[j + 1] = temp;
            }
        }
    }
}
// Part 1
fn totalDistance(leftList: []i32, rightList: []i32) i32 {
    var sortedLeft = std.ArrayList(i32).init(std.heap.page_allocator);
    var sortedRight = std.ArrayList(i32).init(std.heap.page_allocator);

    for (leftList) |item| _ = sortedLeft.append(item) catch {};
    for (rightList) |item| _ = sortedRight.append(item) catch {};

    sort(sortedLeft.items);
    sort(sortedRight.items);

    var totalDist: i32 = 0;
    const minLen = @min(sortedLeft.items.len, sortedRight.items.len);
    for (0..minLen) |i| {
        totalDist += abs(sortedLeft.items[i] - sortedRight.items[i]);
    }

    return totalDist;
}
//Part 2
fn totalSimilarityScore(leftList: []i32, rightList: []i32) i32 {
    var countMap = std.AutoHashMap(i32, i32).init(std.heap.page_allocator);

    for (rightList) |right| {
        const currentCount = countMap.get(right) orelse 0;
        countMap.put(right, currentCount + 1) catch {};
    }

    var similarityScore: i32 = 0;
    for (leftList) |left| {
        const count = countMap.get(left) orelse 0;
        similarityScore += left * count;
    }

    return similarityScore;
}

pub fn main() void {
    const mutable_data = data;
    var splits = split(u8, mutable_data, "\n");

    var leftList = std.ArrayList(i32).init(std.heap.page_allocator);
    var rightList = std.ArrayList(i32).init(std.heap.page_allocator);

    while (splits.next()) |line| {
        const trimmedLine = std.mem.trim(u8, line, " ");
        std.debug.print("Processing line: {s}\n", .{trimmedLine});

        if (trimmedLine.len == 0) continue;

        var parts = std.mem.tokenize(u8, trimmedLine, " \t");
        var numbers: [2]?i32 = .{ null, null };
        var i: usize = 0;

        while (parts.next()) |part| {
            if (i >= 2) break;
            std.debug.print("Parsing part: {s}\n", .{part});
            numbers[i] = std.fmt.parseInt(i32, part, 10) catch null;
            i += 1;
        }

        if (numbers[0] != null and numbers[1] != null) {
            _ = leftList.append(numbers[0].?) catch {};
            _ = rightList.append(numbers[1].?) catch {};
        } else {
            std.debug.print("Invalid data in line: {s}\n", .{trimmedLine});
        }
    }

    if (leftList.items.len == 0 or rightList.items.len == 0) {
        std.debug.print("Error: One or both lists are empty.\n", .{});
        return;
    }

    const distanceResult = totalDistance(leftList.items, rightList.items);
    std.debug.print("Total distance: {}\n", .{distanceResult});

    const similarityResult = totalSimilarityScore(leftList.items, rightList.items);
    std.debug.print("Total similarity score: {}\n", .{similarityResult});
}
