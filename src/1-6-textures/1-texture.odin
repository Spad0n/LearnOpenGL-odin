/* -*- compile-command: "odin build 1-texture.odin -file -debug" -*- */
package main

import    "vendor:glfw"
import gl "vendor:OpenGL"
import    "core:fmt"
import    "core:os"
import    "core:mem"
import    "core:image/png"
import    "core:bytes"

GL_MAJOR_VERSION :: 3
GL_MINOR_VERSION :: 3

vert_src    :: string(#load("textures.vert"))
frag_src    :: string(#load("textures.frag"))
wall_assets :: "wall.png"
face_assets :: "awesomeface.png"

flip_vertical :: proc(data: []u8, width, height, channels: int) {
    tmp : [4]u8
    px1 : ^u8
    px2 : ^u8
    for x in 0..<width {
        for y in 0..< height/2 {
            px1 = &data[(x + y * width) * channels]
            px2 = &data[(x + (height - 1 - y) * width) * channels]

            mem.copy(&tmp, px1, channels)
            mem.copy(px1, px2, channels)
            mem.copy(px2, &tmp, channels)
        }
    }
}

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
        // positions     // colors       // texture coord
         0.5,  0.5, 0.0,  1.0, 0.0, 0.0,  1.0, 1.0, // top right
         0.5, -0.5, 0.0,  0.0, 1.0, 0.0,  1.0, 0.0, // bottom right
        -0.5, -0.5, 0.0,  0.0, 0.0, 1.0,  0.0, 0.0, // bottom left
        -0.5,  0.5, 0.0,  1.0, 1.0, 0.0,  0.0, 1.0, // top left
    }

    indices := [?]u32{
        0, 1, 3, // first triangle
        1, 2, 3, // second triangle
    }

    program, ok := gl.load_shaders_source(vert_src, frag_src)
    if !ok {
        msg, shader_type := gl.get_last_error_message()
        fmt.eprintf("Shader program creation error! %s %v", msg, shader_type)
        os.exit(1)
    }
    defer gl.DeleteProgram(program)

    vao, vbo, ebo: u32
    gl.GenVertexArrays(1, &vao)
    gl.GenBuffers(1, &vbo)
    gl.GenBuffers(1, &ebo)
    defer {
        gl.DeleteVertexArrays(1, &vao)
        gl.DeleteBuffers(1, &vbo)
        gl.DeleteBuffers(1, &ebo)
    }

    // 1. Bind vertex array object
    gl.BindVertexArray(vao)

    // 2. copy our vertices array in a buffer for OpenGL to use
    gl.BindBuffer(gl.ARRAY_BUFFER, vbo)
    gl.BufferData(gl.ARRAY_BUFFER, size_of(vertices), &vertices, gl.STATIC_DRAW)

    gl.BindBuffer(gl.ELEMENT_ARRAY_BUFFER, ebo)
    gl.BufferData(gl.ELEMENT_ARRAY_BUFFER, size_of(indices), &indices, gl.STATIC_DRAW)

    // 3. then set our vertex attributes pointers
    gl.VertexAttribPointer(0, 3, gl.FLOAT, false, 8 * size_of(f32), 0)
    gl.EnableVertexAttribArray(0)

    gl.VertexAttribPointer(1, 3, gl.FLOAT, false, 8 * size_of(f32), 3 * size_of(f32))
    gl.EnableVertexAttribArray(1)

    gl.VertexAttribPointer(2, 2, gl.FLOAT, false, 8 * size_of(f32), 6 * size_of(f32))
    gl.EnableVertexAttribArray(2)

    gl_texture1, gl_texture2: u32

    // texture 1
    // -----------
    gl.GenTextures(1, &gl_texture1)
    defer gl.DeleteTextures(1, &gl_texture1)
    gl.BindTexture(gl.TEXTURE_2D, gl_texture1)
    // set the texture wrapping parameters
    gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.REPEAT)
    gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.REPEAT)
    // set the texture filtering parameters
    gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.NEAREST)
    gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.NEAREST)

    png_wall, err_wall := png.load_from_file(wall_assets)
    if err_wall != nil {
        fmt.eprintf("Could not load the assets %s: %v\n", wall_assets, err_wall)
        os.exit(1)
    }
    img_bytes := bytes.buffer_to_bytes(&png_wall.pixels)
    gl.TexImage2D(gl.TEXTURE_2D, 0, gl.RGB, i32(png_wall.width), i32(png_wall.height), 0, gl.RGB, gl.UNSIGNED_BYTE, &img_bytes[0])
    gl.GenerateMipmap(gl.TEXTURE_2D)
    png.destroy(png_wall)

    // texture 2
    // ----------
    gl.GenTextures(1, &gl_texture2)
    defer gl.DeleteTextures(1, &gl_texture2)
    gl.BindTexture(gl.TEXTURE_2D, gl_texture2)
    // set the texture wrapping parameters
    gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.REPEAT)
    gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.REPEAT)
    // set the texture filtering parameters
    gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.NEAREST)
    gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.NEAREST)

    png_face, err_face := png.load_from_file(face_assets)
    if err_face != nil {
        fmt.eprintf("Could not load the assets %s: %v\n", face_assets, err_face)
        return
    }
    img_bytes = bytes.buffer_to_bytes(&png_face.pixels)
    // flip the image vertically
    flip_vertical(img_bytes, png_face.width, png_face.height, png_face.channels)
    gl.TexImage2D(gl.TEXTURE_2D, 0, gl.RGBA, i32(png_face.width), i32(png_face.height), 0, gl.RGBA, gl.UNSIGNED_BYTE, &img_bytes[0])
    gl.GenerateMipmap(gl.TEXTURE_2D)
    png.destroy(png_face)

    gl.UseProgram(program)
    gl.Uniform1i(gl.GetUniformLocation(program, "texture1"), 0)
    gl.Uniform1i(gl.GetUniformLocation(program, "texture2"), 1)

    for !glfw.WindowShouldClose(window) {
        gl.ClearColor(0.2, 0.3, 0.3, 1.0)
        gl.Clear(gl.COLOR_BUFFER_BIT)

        // bind texture on corresponding texture units
        gl.ActiveTexture(gl.TEXTURE0)
        gl.BindTexture(gl.TEXTURE_2D, gl_texture1)
        gl.ActiveTexture(gl.TEXTURE1)
        gl.BindTexture(gl.TEXTURE_2D, gl_texture2)

        // render container
        gl.UseProgram(program)
        gl.BindVertexArray(vao)
        gl.DrawElements(gl.TRIANGLES, 6, gl.UNSIGNED_INT, nil)

        glfw.PollEvents()
        glfw.SwapBuffers(window)
    }
}

size_callback :: proc "c" (window: glfw.WindowHandle, width, height: i32) {
    gl.Viewport(0, 0, width, height)
}
