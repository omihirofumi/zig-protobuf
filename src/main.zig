const std = @import("std");
const decode = @import("decode.zig");
pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const alloc = gpa.allocator();

    // https://williamw520.github.io/2025/09/23/back-to-basic-reading-file-in-zig.html
    const cwd = std.fs.cwd();
    const file = try cwd.openFile(".jj/working_copy/checkout", .{ .mode = .read_only });
    defer file.close();

    var f_buf: [1024]u8 = undefined;
    var f_reader = file.reader(&f_buf);
    const reader = &f_reader.interface;

    const content = try reader.allocRemaining(alloc, .unlimited);
    var decode_reader = decode.Reader.init(content);
    const checkout = try decode.decodeCheckout(&decode_reader);

    std.debug.print("workspace = {s}\n", .{checkout.workspace_name});

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
