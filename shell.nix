let pkgs = import <nixpkgs> { };
in pkgs.mkShell {
  buildInputs = with pkgs; [
    glfw
    libGL
  ];

  LD_LIBRARY_PATH="$LD_LIBRARY_PATH:${
    with pkgs;
    pkgs.lib.makeLibraryPath [ glfw libGL ]
  }";
}
