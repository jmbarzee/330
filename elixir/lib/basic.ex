defmodule Elixir_Intro do
	def fib(n) do
		case n do
			0 ->
				0
			1 ->
				1
			_ ->
				fibPart(1, 1, n-2)
		end
	end

	def fibPart(a, b, n) do
		case n do
			0 ->
				b
			_ ->
				fibPart(b, a+b, n-1)
		end
	end

	def area(shape, shape_info) do
	end

	def sqrList(nums) do
	end

	def calcTotals(inventory) do
	end

	def map(function, vals) do
	end

	def quickSortServer() do
	end
end