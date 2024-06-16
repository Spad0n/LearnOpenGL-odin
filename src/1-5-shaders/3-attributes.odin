/* -*- compile-command: "odin build 3-attributes.odin -file -debug" -*- */
package main

import    "vendor:glfw"
import gl "vendor:OpenGL"
import    "core:fmt"
import    "core:os"
import    "core:math"

GL_MAJOR_VERSION :: 3
GL_MINOR_VERSION :: 3

vert_src :: string(#load("3-attributes.vert"))
frag_src :: string(#load("3-attributes.frag"))

main :: proc() {
    if !glfw.Init() {
        description, code := glfw.GetError()
        fmt.eprintln(#location(), description, code)
        os.exit(1)
    }
    defer glfw.Terminate()

    glfw.WindowHint(glfw.RESIZABLE, 1)
    glfw.WindowHint(glfw.CONTEXT_VERSION_MAJOR, GL_MAJOR_VERSION)
    glfw.WindowHint(glfw.CONTEXT_VERSION_MINOR, GL_MINOR_VERSION)
    glfw.WindowHint(glfw.OPENGL_PROFILE, glfw.OPENGL_CORE_PROFILE)

    window := glfw.CreateWindow(800, 600, "Open Window", nil, nil)
    if window == nil {
        description, code := glfw.GetError()
        fmt.eprintln(#location(window), description, code)
        os.exit(1)
    }
    defer glfw.DestroyWindow(window)

    // opengl is a state machine. An OpenGL context holds that state. The state contains information such as wich textures are bound
    // to which texture units, which attachments the current FBO has, and things like that
    // when you set the current context, you are switching all the state from the old context to the new context.
    glfw.MakeContextCurrent(window)

    // Enable VSync
    glfw.SwapInterval(1)

    glfw.SetFramebufferSizeCallback(window, size_callback)

    gl.load_up_to(GL_MAJOR_VERSION, GL_MINOR_VERSION, glfw.gl_set_proc_address)

    vertices := [?]f32{
        // positions     // colors
       -0.5, -0.5, 0.0,  1.0, 0.0, 0.0, // bottom right
	0.5, -0.5, 0.0,  0.0, 1.0, 0.0, // bottom left
	0.0,  0.5, 0.0,  0.0, 0.0, 1.0, // top
    }

    program, ok := gl.load_shaders_source(vert_src, frag_src)
    if !ok {
        msg, shader_type := gl.get_last_error_message()
        fmt.eprintf("Shader program creation error! %s %v", msg, shader_type)
        os.exit(1)
    }
    defer gl.DeleteProgram(program)

    vao, vbo: u32
    gl.GenVertexArrays(1, &vao)
    gl.GenBuffers(1, &vbo)
    defer {
        gl.DeleteBuffers(1, &vbo)
        gl.DeleteVertexArrays(1, &vao)
    }

    // 1. Bind vertex array object
    gl.BindVertexArray(vao)

    // 2. copy our vertices array in a buffer for OpenGL to use
    gl.BindBuffer(gl.ARRAY_BUFFER, vbo)
    gl.BufferData(gl.ARRAY_BUFFER, size_of(vertices), &vertices, gl.STATIC_DRAW)

    // 3. then set our vertex attributes pointers
    gl.VertexAttribPointer(0, 3, gl.FLOAT, false, 6 * size_of(f32), 0)
    gl.EnableVertexAttribArray(0)

    gl.VertexAttribPointer(1, 3, gl.FLOAT, false, 6 * size_of(f32), 3 * size_of(f32))
    gl.EnableVertexAttribArray(1)

    for !glfw.WindowShouldClose(window) {
        gl.ClearColor(0.2, 0.3, 0.3, 1.0)
        gl.Clear(gl.COLOR_BUFFER_BIT)

        gl.UseProgram(program)
        gl.BindVertexArray(vao)
        gl.DrawArrays(gl.TRIANGLES, 0, 3)

        glfw.PollEvents()
        glfw.SwapBuffers(window)
    }
}

size_callback :: proc "c" (window: glfw.WindowHandle, width, height: i32) {
    gl.Viewport(0, 0, width, height)
}
