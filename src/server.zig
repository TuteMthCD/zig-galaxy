const std = @import("std");

const main = @import("main.zig");

const posix = std.posix;

const Sphere = main.Sphere;

pub fn createServer(array: *std.ArrayList(Sphere)) !void {
    const addr = try std.net.Address.parseIp("127.0.0.1", 2000);

    const listener = try posix.socket(addr.any.family, posix.SOCK.STREAM, posix.IPPROTO.TCP);
    defer posix.close(listener);

    const timeout = posix.timeval{ .sec = 0, .usec = 0 };

    try posix.setsockopt(listener, posix.SOL.SOCKET, posix.SO.REUSEADDR, &std.mem.toBytes(timeout));
    try posix.setsockopt(listener, posix.SOL.SOCKET, posix.SO.SNDTIMEO, &std.mem.toBytes(timeout));

    try posix.bind(listener, &addr.any, addr.getOsSockLen()); //redirecciona el puerto a nuestro FD , posix btw
    try posix.listen(listener, 128);

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    var readBuff = try gpa.allocator().alloc(u8, 512);
    defer gpa.allocator().free(readBuff);

    var clientAddr: std.net.Address = undefined;
    var clientAddrLen: posix.socklen_t = @sizeOf(std.net.Address);

    while (true) {
        const sck = posix.accept(listener, &clientAddr.any, &clientAddrLen, 0) catch |err| {
            std.debug.print("error accept {}\n", .{err});
            continue;
        };
        defer posix.close(sck);

        const stream = std.net.Stream{ .handle = sck };

        const read = stream.read(readBuff) catch |err| {
            posix.close(sck);
            std.debug.print("error {}\n", .{err});

            continue;
        };

        const json = try std.json.parseFromSlice([]Sphere, gpa.allocator(), readBuff[0..read], .{ .allocate = .alloc_if_needed });
        defer json.deinit();

        array.clearAndFree();

        for (json.value) |value| {
            std.debug.print("{}\n", .{value});

            try array.append(value);
        }
    }
}

test "server" {
    const allocator = std.testing.allocator;

    var array = std.ArrayList(Sphere).init(allocator);
    defer array.deinit();

    try createServer(&array);
}
