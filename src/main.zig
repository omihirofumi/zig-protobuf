const std = @import("std");
const decode = @import("decode.zig");
pub fn main() !void {
    // var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    // const alloc = try gpa.allocator();

    var buf: [1024]u8 = undefined;
    var stdin_reader = std.fs.File.stdin().reader(&buf);
    const stdin = &stdin_reader.interface;

    var line_buf: [1024]u8 = undefined;
    var writer: std.io.Writer = .fixed(&line_buf);

    const n = try stdin.streamDelimiterEnding(&writer, '\n');
    const line = line_buf[0..n];

    var decode_reader = decode.Reader.init(line);

    const msg = try decode.decodeMsg(&decode_reader);
    std.debug.print("{d}, {s}", .{ msg.a, msg.s });

    // while (!decode_reader.eof()) {
    //     const key = try decode_reader.readKey();
    //     std.debug.print("field_number={d}\n", .{key.field_number});
    //
    //     switch (key.wire) {
    //         .varint => {
    //             const v = try decode_reader.readVarint();
    //             std.debug.print("value={d}", .{v});
    //         },
    //         .fixed32 => {
    //             const v = try decode_reader.readFixed32();
    //             std.debug.print("value={d}", .{v});
    //         },
    //         .fixed64 => {
    //             const v = try decode_reader.readFixed64();
    //             std.debug.print("value={d}", .{v});
    //         },
    //         .len => {
    //             _ = try decode_reader.readBytes();
    //         },
    //     }
    // }
}

test "simple test" {
    const gpa = std.testing.allocator;
    var list: std.ArrayList(i32) = .empty;
    defer list.deinit(gpa); // Try commenting this out and see if zig detects the memory leak!
    try list.append(gpa, 42);
    try std.testing.expectEqual(@as(i32, 42), list.pop());
}

test "fuzz example" {
    const Context = struct {
        fn testOne(context: @This(), input: []const u8) anyerror!void {
            _ = context;
            // Try passing `--fuzz` to `zig build test` and see if it manages to fail this test case!
            try std.testing.expect(!std.mem.eql(u8, "canyoufindme", input));
        }
    };
    try std.testing.fuzz(Context{}, Context.testOne, .{});
}
