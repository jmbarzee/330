defmodule BasicTest do
	use ExUnit.Case
	alias Elixir_Intro, as: Tro
	doctest Elixir_Intro

	test "fib" do
		assert Tro.fib(0) == 0
		assert Tro.fib(1) == 1
		assert Tro.fib(2) == 1
		assert Tro.fib(3) == 2
		assert Tro.fib(4) == 3
		assert Tro.fib(5) == 5
		assert Tro.fib(6) == 8
		assert Tro.fib(7) == 13
		assert Tro.fib(8) == 21
	end

	test "area" do
		assert Tro.area(:triangle, {4, 2}) == 4
		assert Tro.area(:triangle, {3, 2}) == 3
		assert Tro.area(:triangle, {2, 2}) == 2
		assert Tro.area(:triangle, {1, 2}) == 1
		assert Tro.area(:triangle, {2, 1}) == 1
		assert Tro.area(:triangle, {2, 2}) == 2
		assert Tro.area(:triangle, {2, 3}) == 3
		assert Tro.area(:triangle, {2, 4}) == 4

		assert Tro.area(:rectangle, {4, 2}) == 8
		assert Tro.area(:rectangle, {3, 2}) == 6
		assert Tro.area(:rectangle, {2, 2}) == 4
		assert Tro.area(:rectangle, {1, 2}) == 2
		assert Tro.area(:rectangle, {2, 1}) == 2
		assert Tro.area(:rectangle, {2, 2}) == 4
		assert Tro.area(:rectangle, {2, 3}) == 6
		assert Tro.area(:rectangle, {2, 4}) == 8

		assert Tro.area(:square, 0) == 0
		assert Tro.area(:square, 1) == 1
		assert Tro.area(:square, 2) == 4
		assert Tro.area(:square, 3) == 9
		assert Tro.area(:square, 4) == 16
		assert Tro.area(:square, 5) == 25

		assert Tro.area(:circle, 0) == 0 * :math.pi
		assert Tro.area(:circle, 1) == 1 * :math.pi
		assert Tro.area(:circle, 2) == 4 * :math.pi
		assert Tro.area(:circle, 3) == 9 * :math.pi
		assert Tro.area(:circle, 4) == 16 * :math.pi
		assert Tro.area(:circle, 5) == 25 * :math.pi
	end

	test "sqrList" do
		assert Tro.sqrList([]) == []
		assert Tro.sqrList([1]) == [1]
		assert Tro.sqrList([1, 1]) == [1, 1]
		assert Tro.sqrList([2]) == [4]
		assert Tro.sqrList([2, 2]) == [4, 4]
		assert Tro.sqrList([1, 2, 3]) == [1, 4, 9]
		assert Tro.sqrList([0.5]) == [0.25]
	end


	test "calcTotals" do
		assert Tro.calcTotals([]) == []
		assert Tro.calcTotals([{:a, 1, 0.5}]) == [{:a, 0.5}]
		assert Tro.calcTotals([{:a, 0, 1}]) == [{:a, 0}]
		assert Tro.calcTotals([{:a, 1, 0}]) == [{:a, 0}]
		assert Tro.calcTotals([{:a, 1, 1}]) == [{:a, 1}]
		assert Tro.calcTotals([{:a, 2, 1}]) == [{:a, 2}]
		assert Tro.calcTotals([{:a, 1, 2}]) == [{:a, 2}]
		assert Tro.calcTotals([{:a, 2, 2}]) == [{:a, 4}]
		assert Tro.calcTotals([{:a, 1, 1}, {:b, 1, 1}]) == [{:a, 1}, {:b, 1}]
		assert Tro.calcTotals([{:a, 1, 2}, {:b, 1, 3}]) == [{:a, 2}, {:b, 3}]
		assert Tro.calcTotals([{:a, 2, 2}, {:b, 3, 3}]) == [{:a, 4}, {:b, 9}]
		assert Tro.calcTotals([{:a, 1, 1}, {:b, 1, 1}, {:c, 1, 1}]) == [{:a, 1}, {:b, 1}, {:c, 1}]
	end

	test "qsort" do
		assert Tro.qsort([]) == []
		assert Tro.qsort([1]) == [1]
		assert Tro.qsort([1, 2]) == [1, 2]
		assert Tro.qsort([2, 1]) == [1, 2]
		assert Tro.qsort([1, 1, 1]) == [1, 1, 1]
		assert Tro.qsort([1, 1, 2]) == [1, 1, 2]
		assert Tro.qsort([1, 1, 3]) == [1, 1, 3]
		assert Tro.qsort([1, 2, 1]) == [1, 1, 2]
		assert Tro.qsort([1, 2, 2]) == [1, 2, 2]
		assert Tro.qsort([1, 2, 3]) == [1, 2, 3]
		assert Tro.qsort([1, 3, 1]) == [1, 1, 3]
		assert Tro.qsort([1, 3, 2]) == [1, 2, 3]
		assert Tro.qsort([1, 3, 3]) == [1, 3, 3]
		assert Tro.qsort([2, 1, 1]) == [1, 1, 2]
		assert Tro.qsort([2, 1, 2]) == [1, 2, 2]
		assert Tro.qsort([2, 1, 3]) == [1, 2, 3]
		assert Tro.qsort([2, 2, 1]) == [1, 2, 2]
		assert Tro.qsort([2, 2, 2]) == [2, 2, 2]
		assert Tro.qsort([2, 2, 3]) == [2, 2, 3]
		assert Tro.qsort([2, 3, 1]) == [1, 2, 3]
		assert Tro.qsort([2, 3, 2]) == [2, 2, 3]
		assert Tro.qsort([1, 3, 3]) == [1, 3, 3]
		assert Tro.qsort([3, 1, 1]) == [1, 1, 3]
		assert Tro.qsort([3, 1, 2]) == [1, 2, 3]
		assert Tro.qsort([3, 1, 3]) == [1, 3, 3]
		assert Tro.qsort([3, 2, 1]) == [1, 2, 3]
		assert Tro.qsort([3, 2, 2]) == [2, 2, 3]
		assert Tro.qsort([3, 2, 3]) == [2, 3, 3]
		assert Tro.qsort([3, 3, 1]) == [1, 3, 3]
		assert Tro.qsort([3, 3, 2]) == [2, 3, 3]
		assert Tro.qsort([3, 3, 3]) == [3, 3, 3]
		assert Tro.qsort([1, 2, 3, 4]) == [1, 2, 3, 4]
		assert Tro.qsort([1, 2, 3, 4, 5]) == [1, 2, 3, 4, 5]
		assert Tro.qsort([1, 2, 3, 4, 5, 6]) == [1, 2, 3, 4, 5, 6]
		assert Tro.qsort([1, 6, 3, 4, 5, 2]) == [1, 2, 3, 4, 5, 6]
		assert Tro.qsort([1, 2, 5, 4, 3, 6]) == [1, 2, 3, 4, 5, 6]
		assert Tro.qsort([1, 2, 2, 2, 2, 6]) == [1, 2, 2, 2, 2, 6]
		assert Tro.qsort([1, 1, 1, 1, 1, 1]) == [1, 1, 1, 1, 1, 1]
	end

	test "server sort" do
		spid = spawn &Elixir_Intro.quickSortServer/0

		assert Tro.callServer(spid,[]) == []
		assert Tro.callServer(spid,[1]) == [1]
		assert Tro.callServer(spid,[1, 2]) == [1, 2]
		assert Tro.callServer(spid,[2, 1]) == [1, 2]
		assert Tro.callServer(spid,[1, 1, 1]) == [1, 1, 1]
		assert Tro.callServer(spid,[1, 1, 2]) == [1, 1, 2]
		assert Tro.callServer(spid,[1, 1, 3]) == [1, 1, 3]
		assert Tro.callServer(spid,[1, 2, 1]) == [1, 1, 2]
		assert Tro.callServer(spid,[1, 2, 2]) == [1, 2, 2]
		assert Tro.callServer(spid,[1, 2, 3]) == [1, 2, 3]
		assert Tro.callServer(spid,[1, 3, 1]) == [1, 1, 3]
		assert Tro.callServer(spid,[1, 3, 2]) == [1, 2, 3]
		assert Tro.callServer(spid,[1, 3, 3]) == [1, 3, 3]
		assert Tro.callServer(spid,[2, 1, 1]) == [1, 1, 2]
		assert Tro.callServer(spid,[2, 1, 2]) == [1, 2, 2]
		assert Tro.callServer(spid,[2, 1, 3]) == [1, 2, 3]
		assert Tro.callServer(spid,[2, 2, 1]) == [1, 2, 2]
		assert Tro.callServer(spid,[2, 2, 2]) == [2, 2, 2]
		assert Tro.callServer(spid,[2, 2, 3]) == [2, 2, 3]
		assert Tro.callServer(spid,[2, 3, 1]) == [1, 2, 3]
		assert Tro.callServer(spid,[2, 3, 2]) == [2, 2, 3]
		assert Tro.callServer(spid,[1, 3, 3]) == [1, 3, 3]
		assert Tro.callServer(spid,[3, 1, 1]) == [1, 1, 3]
		assert Tro.callServer(spid,[3, 1, 2]) == [1, 2, 3]
		assert Tro.callServer(spid,[3, 1, 3]) == [1, 3, 3]
		assert Tro.callServer(spid,[3, 2, 1]) == [1, 2, 3]
		assert Tro.callServer(spid,[3, 2, 2]) == [2, 2, 3]
		assert Tro.callServer(spid,[3, 2, 3]) == [2, 3, 3]
		assert Tro.callServer(spid,[3, 3, 1]) == [1, 3, 3]
		assert Tro.callServer(spid,[3, 3, 2]) == [2, 3, 3]
		assert Tro.callServer(spid,[3, 3, 3]) == [3, 3, 3]
		assert Tro.callServer(spid,[1, 2, 3, 4]) == [1, 2, 3, 4]
		assert Tro.callServer(spid,[1, 2, 3, 4, 5]) == [1, 2, 3, 4, 5]
		assert Tro.callServer(spid,[1, 2, 3, 4, 5, 6]) == [1, 2, 3, 4, 5, 6]
		assert Tro.callServer(spid,[1, 6, 3, 4, 5, 2]) == [1, 2, 3, 4, 5, 6]
		assert Tro.callServer(spid,[1, 2, 5, 4, 3, 6]) == [1, 2, 3, 4, 5, 6]
		assert Tro.callServer(spid,[1, 2, 2, 2, 2, 6]) == [1, 2, 2, 2, 2, 6]
		assert Tro.callServer(spid,[1, 1, 1, 1, 1, 1]) == [1, 1, 1, 1, 1, 1]
	end

end
