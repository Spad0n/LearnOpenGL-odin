/* -*- compile-command: "odin build 1-rendering.odin -file -debug" -*- */
package main

import    "vendor:glfw"
import gl "vendor:OpenGL"
import    "core:fmt"
import    "core:os"

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

    glfw.MakeContextCurrent(window)

    // Enable VSync
    glfw.SwapInterval(1)

    // opengl is a state machine. An OpenGL context holds that state. The state contains information such as wich textures are bound
    // to which texture units, which attachments the current FBO has, and things like that
    // when you set the current context, you are switching all the state from the old context to the new context.
    glfw.SetFramebufferSizeCallback(window, size_callback)

    gl.load_up_to(GL_MAJOR_VERSION, GL_MINOR_VERSION, glfw.gl_set_proc_address)

    for !glfw.WindowShouldClose(window) {
        gl.ClearColor(0.2, 0.3, 0.3, 1.0)
        gl.Clear(gl.COLOR_BUFFER_BIT)

        glfw.PollEvents()
        glfw.SwapBuffers(window)
    }
}

size_callback :: proc "c" (window: glfw.WindowHandle, width, height: i32) {
    gl.Viewport(0, 0, width, height)
}
