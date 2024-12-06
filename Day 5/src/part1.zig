const std = @import("std");

const data = @embedFile("input.txt");

const ParseResult = struct {
    rules: []const []const u8,
    updates: []const []const u8,
};

fn arrayToSlice(list: std.ArrayList([]const u8)) []const []const u8 {
    return list.items;
}

fn parseInput(data1: []const u8) !ParseResult {
    var lines = std.mem.split(u8, data1, "\n");
    var rules = std.ArrayList([]const u8).init(std.heap.page_allocator);
    var updates = std.ArrayList([]const u8).init(std.heap.page_allocator);
    var isUpdateSection = false;

    while (lines.next()) |line| {
        if (std.mem.eql(u8, line, "")) {
            isUpdateSection = true;
            continue;
        }
        if (isUpdateSection) {
            try updates.append(line);
        } else {
            try rules.append(line);
        }
    }

    return ParseResult{ .rules = arrayToSlice(rules), .updates = arrayToSlice(updates) };
}

fn arrayToSliceArrayList(splitIter: *std.mem.SplitIterator(u8, .sequence)) !std.ArrayList([]const u8) {
    var parts = std.ArrayList([]const u8).init(std.heap.page_allocator);
    while (splitIter.next()) |part| {
        try parts.append(part);
    }
    return parts;
}

fn isUpdateValid(update: []const u8, rules: []const []const u8) bool {
    var pages = std.mem.split(u8, update, ",");
    var pageMap = std.StringHashMap(u8).init(std.heap.page_allocator);

    var index: u8 = 0;
    while (pages.next()) |page| {
        pageMap.put(page, index) catch {};
        index += 1;
    }

    for (rules) |rule| {
        var ruleParts = std.mem.split(u8, rule, "|");
        const parsedRuleList = arrayToSliceArrayList(&ruleParts) catch {
            std.debug.print("Error parsing rule: {any}\n", .{rule});
            return false;
        };
        const parsedRule = arrayToSlice(parsedRuleList);
        if (parsedRule.len < 2) {
            std.debug.print("Invalid rule: {any}\n", .{rule});
            return false;
        }
        const x = parsedRule[0];
        const y = parsedRule[1];

        if (pageMap.get(x) != null and pageMap.get(y) != null) {
            if (pageMap.get(x).? >= pageMap.get(y).?) {
                return false;
            }
        }
    }

    return true;
}

fn getMiddlePage(update: []const u8) u8 {
    var pages = std.mem.split(u8, update, ",");
    var pageList = std.ArrayList([]const u8).init(std.heap.page_allocator);

    while (pages.next()) |page| {
        pageList.append(page) catch {};
    }

    if (pageList.items.len == 0) {
        std.debug.print("Empty update: {any}\n", .{update});
        return 0;
    }

    const middlePageStr = pageList.items[pageList.items.len / 2];
    std.debug.print("Middle page string: {any}\n", .{middlePageStr});
    return std.fmt.parseInt(u8, middlePageStr, 10) catch {
        std.debug.print("Error parsing middle page: {any}\n", .{middlePageStr});
        return 0;
    };
}

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();

    const input = data;
    const results = try parseInput(input);

    var sum: u32 = 0;

    for (results.updates) |update| {
        std.debug.print("Processing update: {any}\n", .{update});
        if (isUpdateValid(update, results.rules)) {
            sum += getMiddlePage(update);
        }
    }

    try stdout.print("Sum of middle pages: {any}\n", .{sum});
}
