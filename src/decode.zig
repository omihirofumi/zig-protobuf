const std = @import("std");

const ProtoError = error{ UnexpectedEof, VariantTooLong };

const Reader = struct {
    buf: []const u8,
    pos: usize = 0,

    fn readByte(self: *Reader) !u64 {
        if (self.pos >= self.buf.len) return ProtoError.UnexpectedEof;
        const b = self.buf[self.pos];
        self.pos += 1;
        return b;
    }

    pub fn readVarintU64(self: *Reader) !u64 {
        var shift: u6 = 0;
        var result: u64 = 0;

        var i: u8 = 0;
        while (i < 10) : (i += 1) {
            const b = try self.readByte();
            const payload: u64 = @as(u64, b & 0x7F);
            result |= payload << shift;

            if ((b & 0x80) == 0) return result;

            shift += 7;
        }
        return ProtoError.VariantTooLong;
    }
};

test "varint decoding" {
    var r1 = Reader{ .buf = &.{0x01} };
    try std.testing.expectEqual(@as(u64, 1), try r1.readVarintU64());

    // 0x96 -> 10010110
    var r2 = Reader{ .buf = &.{ 0x96, 0x01 } };
    try std.testing.expectEqual(@as(u64, 150), try r2.readVarintU64());

    // 0xAC -> 10101100
    var r3 = Reader{ .buf = &.{ 0xAC, 0x02 } };
    try std.testing.expectEqual(@as(u64, 300), try r3.readVarintU64());
}
