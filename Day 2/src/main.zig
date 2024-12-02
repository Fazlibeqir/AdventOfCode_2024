const std = @import("std");
const data = @embedFile("input.txt");
const split = std.mem.split;

fn isSafe(report: []const i32) bool {
    if (report.len <= 1) return true;

    const increasing = report[1] > report[0];
    for (0..report.len - 1) |i| {
        const diff = report[i + 1] - report[i];
        if (diff < -3 or diff > 3) return false;
        if ((increasing and diff <= 0) or (!increasing and diff >= 0)) return false;
    }
    return true;
}
fn isSafeWithDampener(report: []const i32) bool {
    if (isSafe(report)) return true;

    for (0..report.len) |i| {
        var tempReport = std.ArrayList(i32).init(std.heap.page_allocator);
        defer tempReport.deinit();

        for (0..report.len) |j| {
            if (i == j) continue;
            _ = tempReport.append(report[j]) catch return false;
        }
        if (isSafe(tempReport.items)) return true;
    }
    return false;
}

pub fn main() void {
    const allocator = std.heap.page_allocator;
    var splits = split(u8, data, "\n");

    var safe_count: usize = 0;
    var safe_count_with_dampener: usize = 0;
    while (splits.next()) |line| {
        const trimmedLine = std.mem.trimRight(u8, line, " \r");
        if (trimmedLine.len == 0) continue;

        var report = std.ArrayList(i32).init(allocator);
        defer report.deinit();

        var numbers = split(u8, trimmedLine, " ");
        while (numbers.next()) |number| {
            const parsed = std.fmt.parseInt(i32, number, 10) catch {
                std.debug.print("Failed to parse number: {s}\n", .{number});
                continue;
            };
            _ = report.append(parsed) catch {};
        }

        if (isSafe(report.items)) {
            safe_count += 1;
        }
        if (isSafeWithDampener(report.items)) {
            safe_count_with_dampener += 1;
        }
    }

    std.debug.print("Safe Reports: {}\n", .{safe_count});
    std.debug.print("Safe Reports with Dampener: {}\n", .{safe_count_with_dampener});
}
