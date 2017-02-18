workspace()

include("lab5.jl")

using Base.Test

@testset "lab5" begin
  @testset "shapes" begin
    @testset "area" begin
      P0_0 = Position(0, 0)
      P10_10 = Position(10, 10)
      PN10_N10 = Position(-10, -10)
      posi = [P0_0, P10_10, PN10_N10]
      for pos = 1:3
        @testset "circ" begin
          radi = [0, 1, 10]
          for rad = 1:3
            circ = Circ(posi[pos], radi[rad])
            @test abs(area(circ)-radi[rad]^2*pi) < 0.0001
          end
        end
        @testset "square" begin
          lens = [0, 1, 10]
          for len = 1:3
            square = Square(posi[pos], lens[len])
            @test area(square) == lens[len]^2
          end
        end
        @testset "rect" begin
          lens1 = [0, 0, 0, 1, 1, 1, 10, 10, 10]
          lens2 = [0, 1, 10, 0, 1, 10, 0, 1, 10]
          for len = 1:9
            rect = Rect(posi[pos], lens1[len], lens2[len])
            @test area(rect) == lens1[len] * lens2[len]
          end
        end
      end
    end
    @testset "in_shape" begin
      @testset "circ" begin
        vals = [
          (1, Position(0, 0), Position(0, 0), true),
          (1, Position(0, 0), Position(0, 1), true),
          (1, Position(0, 0), Position(0, -1), true),
          (1, Position(0, 0), Position(1, 0), true),
          (1, Position(0, 0), Position(1, 1), false),
          (1, Position(0, 0), Position(1, -1), false),
          (1, Position(0, 0), Position(-1, 0), true),
          (1, Position(0, 0), Position(-1, 1), false),
          (1, Position(0, 0), Position(-1, -1), false),

          (1, Position(0, 1), Position(0, 0), true),
          (1, Position(0, 1), Position(0, 1), true),
          (1, Position(0, 1), Position(0, -1), false),
          (1, Position(0, 1), Position(1, 0), false),
          (1, Position(0, 1), Position(1, 1), true),
          (1, Position(0, 1), Position(1, -1), false),
          (1, Position(0, 1), Position(-1, 0), false),
          (1, Position(0, 1), Position(-1, 1), true),
          (1, Position(0, 1), Position(-1, -1), false),

          (1, Position(1, 0), Position(0, 0), true),
          (1, Position(1, 0), Position(0, 1), false),
          (1, Position(1, 0), Position(0, -1), false),
          (1, Position(1, 0), Position(1, 0), true),
          (1, Position(1, 0), Position(1, 1), true),
          (1, Position(1, 0), Position(1, -1), true),
          (1, Position(1, 0), Position(-1, 0), false),
          (1, Position(1, 0), Position(-1, 1), false),
          (1, Position(1, 0), Position(-1, -1), false)
        ]
        for val = 1:27
          circ = Circ(vals[val][2], vals[val][1])
          @test in_shape(circ, vals[val][3]) == vals[val][4]
        end
      end
      @testset "Square" begin
        vals = [
          (2, Position(0, 0), Position(0, 0), true),
          (2, Position(0, 0), Position(0, 1), false),
          (2, Position(0, 0), Position(0, -1), true),
          (2, Position(0, 0), Position(1, 0), true),
          (2, Position(0, 0), Position(1, 1), false),
          (2, Position(0, 0), Position(1, -1), true),
          (2, Position(0, 0), Position(-1, 0), false),
          (2, Position(0, 0), Position(-1, 1), false),
          (2, Position(0, 0), Position(-1, -1), false),

          (2, Position(0, 1), Position(0, 0), true),
          (2, Position(0, 1), Position(0, 1), true),
          (2, Position(0, 1), Position(0, -1), true),
          (2, Position(0, 1), Position(1, 0), true),
          (2, Position(0, 1), Position(1, 1), true),
          (2, Position(0, 1), Position(1, -1), true),
          (2, Position(0, 1), Position(-1, 0), false),
          (2, Position(0, 1), Position(-1, 1), false),
          (2, Position(0, 1), Position(-1, -1), false),

          (2, Position(-2, 0), Position(0, 0), true),
          (2, Position(-2, 0), Position(0, 1), false),
          (2, Position(-2, 0), Position(0, -1), true),
          (2, Position(-2, 0), Position(1, 0), false),
          (2, Position(-2, 0), Position(1, 1), false),
          (2, Position(-2, 0), Position(1, -1), false),
          (2, Position(-2, 0), Position(-1, 0), true),
          (2, Position(-2, 0), Position(-1, 1), false),
          (2, Position(-2, 0), Position(-1, -1), true)
        ]
        for val = 1:27
          square = Square(vals[val][2], vals[val][1])
          @test in_shape(square, vals[val][3]) == vals[val][4]
        end
      end
    end
  end
  @testset "picture" begin
    @testset "pixel" begin
      @testset "invert" begin
        pixels = [
          Pixel(0, 0, 0),
          Pixel(1, 1, 1),
          Pixel(127, 127, 127),
          Pixel(0, 127, 255),
          Pixel(255, 0, 0),
          Pixel(0, 255, 0),
          Pixel(0, 0, 255),
          Pixel(254, 254, 254),
          Pixel(255, 255, 255)
        ]
        ipixels = [
          Pixel(255, 255, 255),
          Pixel(254, 254, 254),
          Pixel(128, 128, 128),
          Pixel(255, 128, 0),
          Pixel(0, 255, 255),
          Pixel(255, 0, 255),
          Pixel(255, 255, 0),
          Pixel(1, 1, 1),
          Pixel(0, 0, 0)
        ]
        for p = 1:8
          @test eqp(invert(pixels[p]), ipixels[p]) == true
        end
      end
      @testset "greyscale" begin
        pixels = [
          Pixel(0, 0, 0),
          Pixel(1, 1, 1),
          Pixel(127, 127, 127),
          Pixel(0, 127, 255),
          Pixel(255, 0, 0),
          Pixel(0, 255, 0),
          Pixel(0, 0, 255),
          Pixel(254, 254, 254),
          Pixel(255, 255, 255)
        ]
        gpixels = [
          Pixel(0, 0, 0),
          Pixel(1, 1, 1),
          Pixel(127, 127, 127),
          Pixel(127, 127, 127),
          Pixel(85, 85, 85),
          Pixel(85, 85, 85),
          Pixel(85, 85, 85),
          Pixel(254, 254, 254),
          Pixel(255, 255, 255),
        ]
        for p = 1:8
          @test eqp(greyscale(pixels[p]), gpixels[p]) == true
        end
      end
    end
    @testset "invert" begin
      pics = [
        [Pixel(0, 0, 0) Pixel(0, 0, 0) Pixel(0, 0, 0);
        Pixel(1, 1, 1) Pixel(1, 1, 1) Pixel(1, 1, 1);
        Pixel(2, 2, 2) Pixel(2, 2, 2) Pixel(2, 2, 2)],

        [Pixel(127, 127, 127) Pixel(127, 127, 127) Pixel(127, 127, 127);
        Pixel(128, 128, 128) Pixel(128, 128, 128) Pixel(128, 128, 128);
        Pixel(129, 129, 129) Pixel(129, 129, 129) Pixel(129, 129, 129)],

        [Pixel(253, 253, 253) Pixel(253, 253, 253) Pixel(253, 253, 253);
        Pixel(254, 254, 254) Pixel(254, 254, 254) Pixel(254, 254, 254);
        Pixel(255, 255, 255) Pixel(255, 255, 255) Pixel(255, 255, 255)],

        [Pixel(0, 1, 2) Pixel(3, 4, 5) Pixel(6, 7, 8)],

        [Pixel(255, 254, 253) Pixel(252, 251, 250) Pixel(249, 248, 247)]',

        Array{Pixel}(0,0)
      ]
      ipics = [
        [Pixel(255, 255, 255) Pixel(255, 255, 255) Pixel(255, 255, 255);
        Pixel(254, 254, 254) Pixel(254, 254, 254) Pixel(254, 254, 254);
        Pixel(253, 253, 253) Pixel(253, 253, 253) Pixel(253, 253, 253)],

        [Pixel(128, 128, 128) Pixel(128, 128, 128) Pixel(128, 128, 128);
        Pixel(127, 127, 127) Pixel(127, 127, 127) Pixel(127, 127, 127);
        Pixel(126, 126, 126) Pixel(126, 126, 126) Pixel(126, 126, 126)],

        [Pixel(2, 2, 2) Pixel(2, 2, 2) Pixel(2, 2, 2);
        Pixel(1, 1, 1) Pixel(1, 1, 1) Pixel(1, 1, 1);
        Pixel(0, 0, 0) Pixel(0, 0, 0) Pixel(0, 0, 0)],

        [Pixel(255, 254, 253) Pixel(252, 251, 250) Pixel(249, 248, 247)],

        [Pixel(0, 1, 2) Pixel(3, 4, 5) Pixel(6, 7, 8)]',

        Array{Pixel}(0,0)
      ]
      for p = 1:6
        @test eq(invert(pics[p]), ipics[p]) == true
      end
    end
    @testset "greyscale" begin
      pics = [
        [Pixel(0, 0, 0) Pixel(0, 0, 0) Pixel(0, 0, 0);
        Pixel(1, 1, 1) Pixel(1, 1, 1) Pixel(1, 1, 1);
        Pixel(2, 2, 2) Pixel(2, 2, 2) Pixel(2, 2, 2)],

        [Pixel(127, 127, 127) Pixel(127, 127, 127) Pixel(127, 127, 127);
        Pixel(128, 128, 128) Pixel(128, 128, 128) Pixel(128, 128, 128);
        Pixel(129, 129, 129) Pixel(129, 129, 129) Pixel(129, 129, 129)],

        [Pixel(253, 253, 253) Pixel(253, 253, 253) Pixel(253, 253, 253);
        Pixel(254, 254, 254) Pixel(254, 254, 254) Pixel(254, 254, 254);
        Pixel(255, 255, 255) Pixel(255, 255, 255) Pixel(255, 255, 255)],

        [Pixel(0, 1, 2) Pixel(3, 4, 5) Pixel(6, 7, 8)],

        [Pixel(255, 254, 253) Pixel(252, 251, 250) Pixel(249, 248, 247)]',

        Array{Pixel}(0,0)
      ]
      gpics = [
        [Pixel(0, 0, 0) Pixel(0, 0, 0) Pixel(0, 0, 0);
        Pixel(1, 1, 1) Pixel(1, 1, 1) Pixel(1, 1, 1);
        Pixel(2, 2, 2) Pixel(2, 2, 2) Pixel(2, 2, 2)],

        [Pixel(127, 127, 127) Pixel(127, 127, 127) Pixel(127, 127, 127);
        Pixel(128, 128, 128) Pixel(128, 128, 128) Pixel(128, 128, 128);
        Pixel(129, 129, 129) Pixel(129, 129, 129) Pixel(129, 129, 129)],

        [Pixel(253, 253, 253) Pixel(253, 253, 253) Pixel(253, 253, 253);
        Pixel(254, 254, 254) Pixel(254, 254, 254) Pixel(254, 254, 254);
        Pixel(255, 255, 255) Pixel(255, 255, 255) Pixel(255, 255, 255)],

        [Pixel(1, 1, 1) Pixel(4, 4, 4) Pixel(7, 7, 7)],

        [Pixel(254, 254, 254) Pixel(251, 251, 251) Pixel(248, 248, 248)]',

        Array{Pixel}(0,0)
      ]
      for p = 1:6
        @test eq(greyscale(pics[p]), gpics[p]) == true
      end
    end
  end
  @testset "tree" begin
    @testset "count_persons" begin
      trees = [
        Unknown(),

        Person("a", 2000, "A",
          Unknown(),
          Unknown()),

      ]
      for t = 1:5
        println(trees[t])
        println(count_persons(trees[t]))
        println(average_age(trees[t]))
        println(add_last_name("z", trees[t]))
      end
    end
  end
end

0
