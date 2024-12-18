const std = @import("std");
const glfw = @cImport(@cInclude("GLFW/glfw3.h"));

const sv = @import("server.zig");

const screen_width = 1024;
const screen_height = 1024;

const resolution = 50;
const radial = 0.01;

pub extern "c" fn framebuffer_size_callback_c(window: ?*glfw.GLFWwindow, width: i32, height: i32) void;
pub extern "c" fn process_input_c(window: ?*glfw.GLFWwindow) void;
pub extern "c" fn drawCircle(radio: f64, posx: f64, posy: f64, vertexs: i32, pitch: f64) void;
pub extern "c" fn drawSphere(radio: f32, posx: f32, posy: f32, posz: f32, vertexs: i32) void;
pub extern "c" fn setCamera(cameraX: f64, cameraY: f64, cameraZ: f64, targetX: f64, targetY: f64, targetZ: f64) void;
pub extern "c" fn rotateCamera(angle: f32, camerax: f32, cameraY: f32, cameraZ: f32) void;

pub const Vec3 = struct { x: f32 = 0, y: f32 = 0, z: f32 = 0 };

pub const Sphere = struct {
    position: Vec3,
    color: i32,
    radio: f32 = 1,
    translation: f32 = 0,

    fn draw(self: *Sphere) void {
        drawSphere(self.radio, self.position.x, self.position.y, self.position.z, 5);
    }

    fn log(self: *Sphere) void {
        std.debug.print("{} {d:.2}\n", .{ self.position, self.radio });
    }
};

pub fn getRand(mul: f32) f32 {
    const rand = std.crypto.random;
    return (rand.float(f32) - 0.5) * mul;
}

fn cursorPosCallback(window: ?*glfw.GLFWwindow, x: f64, y: f64) callconv(.C) void {
    _ = window;
    _ = y;

    const angle: f64 = x / 1024.0;

    rotateCamera(@floatCast(angle), 0, 0, 0);
}

pub fn main() !void {
    //allocator
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    // Inicializar GLFW
    if (glfw.glfwInit() != glfw.GLFW_TRUE) {
        return error.InitializationFailed;
    }

    // Crear ventana
    const window = glfw.glfwCreateWindow(screen_width, screen_height, "Zig Galaxy Render", null, null);
    if (window == null) {
        glfw.glfwTerminate();
        return error.WindowCreationFailed;
    }

    glfw.glfwMakeContextCurrent(window);

    _ = glfw.glfwSetFramebufferSizeCallback(window, framebuffer_size_callback_c);
    _ = glfw.glfwSetCursorPosCallback(window, cursorPosCallback);

    // Ocultar el cursor y capturarlo dentro de la ventana
    // _ = glfw.glfwSetInputMode(window, glfw.GLFW_CURSOR, glfw.GLFW_CURSOR_DISABLED);

    // Configurar OpenGL
    glfw.glViewport(0, 0, screen_width, screen_height);

    var list = std.ArrayList(Sphere).init(allocator);
    defer list.deinit();

    try list.append(.{ .color = 0xFFFFFF, .radio = 0.03, .translation = 0, .position = .{ .y = 0, .x = 0, .z = 0 } });

    const th = try std.Thread.spawn(.{}, sv.createServer, .{&list});
    _ = th;

    setCamera(0.5, 0.1, 0.5, 0, 0, 0);
    // Bucle principal
    while (glfw.glfwWindowShouldClose(window) == glfw.GLFW_FALSE) {
        process_input_c(window);
        glfw.glClear(glfw.GL_COLOR_BUFFER_BIT);
        //render

        for (list.items) |*wordl| {
            wordl.draw();
        }

        //end render;
        glfw.glfwSwapBuffers(window);
        glfw.glfwPollEvents();
    }

    glfw.glfwTerminate();
}
