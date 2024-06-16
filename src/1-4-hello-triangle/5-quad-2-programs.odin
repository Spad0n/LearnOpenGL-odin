/* -*- compile-command: "odin build 4-quad-2-programs.odin -file -debug" -*- */
package main

import    "vendor:glfw"
import gl "vendor:OpenGL"
import    "core:fmt"
import    "core:os"

SCREEN_WIDTH     :: 800
SCREEN_HEIGHT    :: 600
GL_MAJOR_VERSION :: 3
GL_MINOR_VERSION :: 3

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

    vertice_1 := [?]f32{
       -0.9, -0.5, 0.0, // top right
        0.0, -0.5, 0.0, // bottom right
       -0.45, 0.5, 0.0, // top left
    }

    vertice_2 := [?]f32{
       -0.0, -0.5, 0.0, // bottom right
        0.9, -0.5, 0.0, // bottom left
        0.45, 0.5, 0.0, // top left
    }

    program_1, ok_1 := gl.load_shaders_source(vertex_shader_source, fragment_shader1_source)
    if !ok_1 {
        msg, shader_type := gl.get_last_error_message()
        fmt.eprintf("Shader program_1 creation error! %s %v", msg, shader_type)
        os.exit(1)
    }
    defer gl.DeleteProgram(program_1)

    program_2, ok_2 := gl.load_shaders_source(vertex_shader_source, fragment_shader2_source)
    if !ok_2 {
        msg, shader_type := gl.get_last_error_message()
        fmt.eprintf("Shader program_2 creation error! %s %v", msg, shader_type)
        os.exit(1)
    }
    defer gl.DeleteProgram(program_2)

    vao, vbo: [2]u32
    gl.GenVertexArrays(2, raw_data(vao[:]))
    gl.GenBuffers(2, raw_data(vbo[:]))
    defer {
        gl.DeleteVertexArrays(2, raw_data(vao[:]))
        gl.DeleteBuffers(2, raw_data(vbo[:]))
    }

    gl.BindVertexArray(vao[0])
    gl.BindBuffer(gl.ARRAY_BUFFER, vbo[0])
    gl.BufferData(gl.ARRAY_BUFFER, size_of(vertice_1), &vertice_1, gl.STATIC_DRAW)
    gl.VertexAttribPointer(0, 3, gl.FLOAT, false, 3 * size_of(f32), cast(uintptr)0)
    gl.EnableVertexAttribArray(0)

    gl.BindVertexArray(vao[1])
    gl.BindBuffer(gl.ARRAY_BUFFER, vbo[1])
    gl.BufferData(gl.ARRAY_BUFFER, size_of(vertice_2), &vertice_2, gl.STATIC_DRAW)
    gl.VertexAttribPointer(0, 3, gl.FLOAT, false, 0, cast(uintptr)0)
    gl.EnableVertexAttribArray(0)

    for !glfw.WindowShouldClose(window) {

	//render(program, vao)
        gl.ClearColor(0.2, 0.3, 0.3, 1.0)
        gl.Clear(gl.COLOR_BUFFER_BIT)

        gl.UseProgram(program_1)
        gl.BindVertexArray(vao[0])
        gl.DrawArrays(gl.TRIANGLES, 0, 3)

        gl.UseProgram(program_2)
        gl.BindVertexArray(vao[1])
        gl.DrawArrays(gl.TRIANGLES, 0, 3)

	glfw.SwapBuffers(window)
	glfw.PollEvents()
    }

}

size_callback :: proc "c" (window: glfw.WindowHandle, width, height: i32) {
    gl.Viewport(0, 0, width, height)
}

vertex_shader_source :: `
#version 330 core
layout (location = 0) in vec3 aPos;
void main() {
    gl_Position = vec4(aPos.x, aPos.y, aPos.z, 1.0);
}`

fragment_shader1_source :: `
#version 330 core
out vec4 FragColor;
void main() {
    FragColor = vec4(1.0f, 0.5f, 0.2f, 1.0f);
}`

fragment_shader2_source :: `
#version 330 core
out vec4 FragColor;
void main() {
    FragColor = vec4(1.0f, 1.0f, 0.0f, 1.0f);
}`
