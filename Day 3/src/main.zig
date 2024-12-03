const std = @import("std");

const data = @embedFile("input.txt");
const split = std.mem.split;

const MulResult = struct {
    rest: []const u8,
    x: u64,
    y: u64,
};

fn parseMulInstruction(input: []const u8) ?MulResult {
    const openParen = std.mem.indexOfScalar(u8, input, '(') orelse return null;
    const closeParen = std.mem.indexOfScalar(u8, input, ')') orelse return null;

    if (closeParen <= openParen) return null;

    const args = input[openParen + 1 .. closeParen];
    const comma = std.mem.indexOfScalar(u8, args, ',') orelse return null;

    const x = std.fmt.parseInt(u64, args[0..comma], 10) catch return null;
    const y = std.fmt.parseInt(u64, args[comma + 1 ..], 10) catch return null;

    return MulResult{ .rest = input[closeParen + 1 ..], .x = x, .y = y };
}

pub fn main() void {
    var splits = split(u8, data, "\n");

    var part1_sum: u64 = 0;
    var enabled = true;
    var part2_sum: u64 = 0;

    const instructionEnable = "do()";
    const instructionDisable = "don't()";
    const mulPrefix = "mul(";

    while (splits.next()) |line| {
        const trimmedLine = std.mem.trimRight(u8, line, " \r");
        if (trimmedLine.len == 0) continue;

        var input = trimmedLine;
        while (input.len > 0) {
            var temp_input = input; // Store the current input in a temporary variable

            if (std.mem.startsWith(u8, temp_input, instructionEnable)) {
                enabled = true;
                std.debug.print("Enabled: {s}\n", .{"do()"});
                input = temp_input[instructionEnable.len..]; // Update input after processing
            } else if (std.mem.startsWith(u8, temp_input, instructionDisable)) {
                enabled = false;
                std.debug.print("Disabled: {s}\n", .{"don't()"});
                input = temp_input[instructionDisable.len..]; // Update input after processing
            } else if (std.mem.startsWith(u8, temp_input, mulPrefix)) {
                const match = parseMulInstruction(temp_input);
                if (match) |result| {
                    const product = result.x * result.y;
                    part1_sum += product;
                    if (enabled) {
                        part2_sum += product;
                    }
                    std.debug.print("Mul Instruction: {d} * {d} = {d}, Enabled: {s}, Part2 Sum: {d}\n", .{ result.x, result.y, product, if (enabled) "Yes" else "No", part2_sum });
                    input = result.rest; // Update input to the remaining part after the multiplication instruction
                } else {
                    const next_pos = std.mem.indexOfScalar(u8, temp_input[1..], 'm') orelse temp_input.len;
                    input = temp_input[next_pos..]; // Update input after failed parsing attempt
                }
            } else {
                input = temp_input[1..]; // Move to the next character if no match is found
            }
        }
    }

    std.debug.print("Part 1 Sum: {d}\n", .{part1_sum});
    std.debug.print("Part 2 Sum: {d}\n", .{part2_sum});
}
