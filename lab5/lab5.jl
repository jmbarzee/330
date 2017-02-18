abstract Shape

type Position
  x::Real
  y::Real
end

type Circ <: Shape
  center::Position
  radius::Real
end

type Square <: Shape
  upper_left::Position
  length::Real
end

type Rect <: Shape
  upper_left::Position
  width::Real
  height::Real
end

function area(shape::Circ)
  return pi * shape.radius * shape.radius
end

function area(shape::Square)
  return shape.length * shape.length
end

function area(shape::Rect)
  return shape.width * shape.height
end

function in_shape(shape::Circ, position::Position)
  disX = position.x - shape.center.x
  disY = position.y - shape.center.y
  dis = (disX ^ 2 + disY ^ 2) ^ (1/2)
  if shape.radius < dis
    return false
  end
  return true
end

function in_shape(shape::Square, position::Position)
  left = shape.upper_left.x
  right = left + shape.length
  top = shape.upper_left.y
  bottom = top - shape.length
  if position.x < left
    return false
  elseif position.x > right
    return false
  elseif position.y < bottom
    return false
  elseif position.y > top
    return false
  end
  return true
end

function in_shape(shape::Rect, position::Position)
  left = shape.upper_left.x
  right = left + shape.width
  top = shape.upper_left.y
  bottom = top - shape.height
  if position.x < left
    return false
  elseif position.x > right
    return false
  elseif position.y < bottom
    return false
  elseif position.y > top
    return false
  end
  return true
end

type Pixel
  r::Real
  g::Real
  b::Real
end

function greyscale(picture::Array{Pixel,2})
  map!(greyscale, picture)
end
function greyscale(pixel::Pixel)
  total = pixel.r + pixel.g + pixel.b
  pixel.g = pixel.b = pixel.r = round(total/3)
  return pixel
end

function invert(picture::Array{Pixel,2})
  map!(invert, picture)
end
function invert(pixel::Pixel)
  pixel.r = 255 - pixel.r
  pixel.b = 255 - pixel.b
  pixel.g = 255 - pixel.g
  return pixel
end

function eqp(p1::Pixel, p2::Pixel)
  if p1.r != p2.r
    return false
  elseif p1.g != p2.g
    return false
  elseif p1.b != p2.b
    return false
  end
  return true
end

function eq(p1::Array{Pixel,2}, p2::Array{Pixel,2})
  rowSize = size(p1, 1)
  colSize = size(p1, 2)
  for pixel = 1:rowSize * colSize
    if !eqp(p1[pixel], p2[pixel])
      return false
    end
  end
  return true
end


abstract TreeItem

type Person <: TreeItem
  name::AbstractString
  birthyear::Integer
  eyecolor::Symbol
  father::TreeItem
  mother::TreeItem
end

type Unknown <: TreeItem
end

function count_persons(tree::Unknown)
  return 0
end
function count_persons(tree::Person)
  paternal = count_persons(tree.father)
  maternal = count_persons(tree.mother)
  return paternal + maternal + 1
end

function average_age(tree::TreeItem)
  totalAge, persons = total_age(tree)
  if (persons < 1)
    return 0
  end
  return totalAge / persons
end
function total_age(tree::Person)
  agePat, personsPat = total_age(tree.father)
  ageMat, personsMat = total_age(tree.mother)
  age = 2017 - tree.birthyear
  return agePat + ageMat + age, personsPat + personsMat + 1
end
function total_age(tree::Unknown)
  return 0, 0
end

function tree_map(f, tree::Person)
  newTree = f(tree)
  newTree.father = tree_map(f, newTree.father)
  newTree.mother = tree_map(f, newTree.mother)
  return newTree
end
function tree_map(f, tree::Unknown)
  return tree
end

function add_last_name(name::AbstractString, tree::TreeItem)
  f = function (node::TreeItem)
    if (isa(node, Person))
      node.name = node.name * name
    end
    return node
  end
  return tree_map(f, tree)
end

function eye_colors(tree::Person)
  child = tree.eyecolor
  paternal = eye_colors(tree.father)
  maternal = eye_colors(tree.mother)
  return [child; paternal; maternal]
end
function eye_colors(tree::Unknown)
  return []
end
