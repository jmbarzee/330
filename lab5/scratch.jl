workspace()

include("lab5.jl")

using Base.Test
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
