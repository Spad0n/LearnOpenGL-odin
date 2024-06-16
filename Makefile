SRC := src
WINDOW := $(SRC)/1-3-hello-window
TRIANGLE := $(SRC)/1-4-hello-triangle
ATTRIBUTES := $(SRC)/1-5-shaders
TEXTURES := $(SRC)/1-6-textures
TRANSFORMATION := $(SRC)/1-7-transformations
COORDINATE := $(SRC)/1-8-coordinates
CAMERA := $(SRC)/1-9-camera

all: part1 part2 part3 part4 part5 part6 part7

part1: hello-window hello-triangle

part2: quad quad-vertices quad-2-vertices quad-2-programs

part3: in-out uniforms attributes

part4: textures multiple-textures

part5: transformations

part6: plane cube more-cube

part7: lookat walk

# Part 1
hello-window: $(WINDOW)/1-rendering.odin
	odin build "$(WINDOW)/1-rendering.odin" -out:"build/1-rendering" -file -debug

hello-triangle: $(TRIANGLE)/1-triangle.odin
	odin build "$(TRIANGLE)/1-triangle.odin" -out:"build/1-triangle" -file -debug

# Part 2
quad: $(TRIANGLE)/2-quad.odin
	odin build "$(TRIANGLE)/2-quad.odin" -out:"build/2-quad" -file -debug

quad-vertices: $(TRIANGLE)/3-quad-vertices.odin
	odin build "$(TRIANGLE)/3-quad-vertices.odin" -out:"build/3-quad-vertices" -file -debug

quad-2-vertices: $(TRIANGLE)/4-quad-2-vertices.odin
	odin build "$(TRIANGLE)/4-quad-2-vertices.odin" -out:"build/4-quad-2-vertices" -file -debug

quad-2-programs: $(TRIANGLE)/5-quad-2-programs.odin
	odin build "$(TRIANGLE)/5-quad-2-programs.odin" -out:"build/5-quad-2-programs" -file -debug

# Part 3
in-out: $(ATTRIBUTES)/1-in-out.odin
	odin build "$(ATTRIBUTES)/1-in-out.odin" -out:"build/1-in-out" -file -debug

uniforms: $(ATTRIBUTES)/2-uniforms.odin
	odin build "$(ATTRIBUTES)/2-uniforms.odin" -out:"build/2-uniforms" -file -debug

attributes: $(ATTRIBUTES)/3-attributes.odin
	odin build "$(ATTRIBUTES)/3-attributes.odin" -out:"build/3-attributes" -file -debug

# Part 4
textures: $(TEXTURES)/1-texture.odin
	odin build "$(TEXTURES)/1-texture.odin" -out:"build/1-texture" -file -debug

multiple-textures: $(TEXTURES)/2-multiple-textures.odin
	odin build "$(TEXTURES)/2-multiple-textures.odin" -out:"build/2-multiple-textures" -file -debug

# Part 5
transformations: $(TRANSFORMATION)/1-scale-rotate.odin
	odin build "$(TRANSFORMATION)/1-scale-rotate.odin" -out:"build/1-scale-rotate" -file -debug

# Part 6
plane: $(COORDINATE)/1-plane.odin
	odin build "$(COORDINATE)/1-plane.odin" -out:"build/1-plane" -file -debug

cube: $(COORDINATE)/2-cube.odin
	odin build "$(COORDINATE)/2-cube.odin" -out:"build/2-cube" -file -debug

more-cube: $(COORDINATE)/3-more-cubes.odin
	odin build "$(COORDINATE)/3-more-cubes.odin" -out:"build/3-more-cubes" -file -debug

# Part 7
lookat: $(CAMERA)/1-lookat.odin
	odin build "$(CAMERA)/1-lookat.odin" -out:"build/1-lookat" -file -debug

walk: $(CAMERA)/2-walk.odin
	odin build "$(CAMERA)/2-walk.odin" -out:"build/2-walk" -file -debug

clean:
	@rm -fv build/1-*
	@rm -fv build/2-*
	@rm -fv build/3-*
	@rm -fv build/4-*
	@rm -fv build/5-*
