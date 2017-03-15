% A Sudoku solver.  The basic idea is for each position,
% check that it is a digit with `digit`.  Then verify that the digit
% chosen doesn't violate any constraints (row, column, and cube).
% If no constraints were violated, proceed further.  If a constraint
% was violated, then backtrack to the last digit choice and move from
% there (the Prolog engine should handle this for you automatically).
% If we reach the end of the board with this scheme, it means that
% the whole thing is solved.
 
% YOU SHOULD FILL IN THE SOLVE PROCEDURE, DOWN BELOW.

:- use_module(library(lists)).
 
digit(1).
digit(2).
digit(3).
digit(4).
digit(5).
digit(6).
digit(7).
digit(8).
digit(9).
 
numBetween(Num, Lower, Upper) :-
	Num >= Lower,
	Num =< Upper.
 
% cubeBounds: (RowLow, RowHigh, ColLow, ColHigh, CubeNumber)
cubeBounds(0, 2, 0, 2, 0).
cubeBounds(0, 2, 3, 5, 1).
cubeBounds(0, 2, 6, 8, 2).
cubeBounds(3, 5, 0, 2, 3).
cubeBounds(3, 5, 3, 5, 4).
cubeBounds(3, 5, 6, 8, 5).
cubeBounds(6, 8, 0, 2, 6).
cubeBounds(6, 8, 3, 5, 7).
cubeBounds(6, 8, 6, 8, 8).
 
% Given a board and the index of a column of interest (0-indexed),
% returns the contents of the column as a list.
% posCol: (Board, ColumnNumber, AsRow)
posCol([], _, []).
posCol([Head|Tail], ColumnNum, [Item|Rest]) :-
	nth0(ColumnNum, Head, Item),
	posCol(Tail, ColumnNum, Rest).
 
% given which row and column we are in, gets which cube
% is relevant.  A helper ultimately for `posCube`.
% cubeNum: (RowNum, ColNum, WhichCube)
cubeNum(RowNum, ColNum, WhichCube) :-
	cubeBounds(RowLow, RowHigh, ColLow, ColHigh, WhichCube),
	numBetween(RowNum, RowLow, RowHigh),
	numBetween(ColNum, ColLow, ColHigh).
 
% Drops the first N elements from a list.  A helper ultimately
% for `posCube`.
% drop: (InputList, NumToDrop, ResultList)
drop([], _, []):-!.
drop(List, 0, List):-!.
drop([_|Tail], Num, Rest) :-
	Num > 0,
	NewNum is Num - 1,
	drop(Tail, NewNum, Rest).
 
% Takes the first N elements from a list.  A helper ultimately
% for `posCube`.
% take: (InputList, NumToTake, ResultList)
take([], _, []):-!.
take(_, 0, []):-!.
take([Head|Tail], Num, [Head|Rest]) :-
	Num > 0,
	NewNum is Num - 1,
	take(Tail, NewNum, Rest).
 
% Gets a sublist of a list in the same order, inclusive.
% A helper for `posCube`.
% sublist: (List, Start, End, NewList)
sublist(List, Start, End, NewList) :-
	drop(List, Start, TempList),
	NewEnd is End - Start + 1,
	take(TempList, NewEnd, NewList).
 
% Given a board and cube number, gets the corresponding cube as a list.
% Cubes are 3x3 portions, numbered from the top left to the bottom right,
% starting from 0.  For example, they would be numbered like so:
%
% 0  1  2
% 3  4  5
% 6  7  8
%
% posCube: (Board, CubeNumber, ContentsOfCube)
posCube(Board, Number, AsList) :-
	cubeBounds(RowLow, RowHigh, ColLow, ColHigh, Number),
	sublist(Board, RowLow, RowHigh, [Row1, Row2, Row3]),
	sublist(Row1, ColLow, ColHigh, Row1Nums),
	sublist(Row2, ColLow, ColHigh, Row2Nums),
	sublist(Row3, ColLow, ColHigh, Row3Nums),
	append(Row1Nums, Row2Nums, TempRow),
	append(TempRow, Row3Nums, AsList).

posRow(Board, Number, Row) :-
	nth0(Number, Board, Row).
 
% Given a board, solve it in-place.
% After calling `solve` on a board, the board should be fully
% instantiated with a satisfying Sudoku solution.
 
% ---- PUT CODE HERE ---
% ---- PUT CODE HERE ---
 
solve(Board) :- 
    posCube(Board, 0, Cube0),
    posCube(Board, 1, Cube1),
    posCube(Board, 2, Cube2),
    posCube(Board, 3, Cube3),
    posCube(Board, 4, Cube4),
    posCube(Board, 5, Cube5),
    posCube(Board, 6, Cube6),
    posCube(Board, 7, Cube7),
    posCube(Board, 8, Cube8),
	Cubes = [Cube0, Cube1, Cube2, Cube3, Cube4, Cube5, Cube6, Cube7, Cube8],

    posCol(Board, 0, Col0),
    posCol(Board, 1, Col1),
    posCol(Board, 2, Col2),
    posCol(Board, 3, Col3),
    posCol(Board, 4, Col4),
    posCol(Board, 5, Col5),
    posCol(Board, 6, Col6),
    posCol(Board, 7, Col7),
    posCol(Board, 8, Col8),
    Cols = [Col0, Col1, Col2, Col3, Col4, Col5, Col6, Col7, Col8],

    Rows = Board,

    defineRow(Cubes, Cols, Rows, 0),
    defineRow(Cubes, Cols, Rows, 1),
    defineRow(Cubes, Cols, Rows, 2),
    defineRow(Cubes, Cols, Rows, 3),
    defineRow(Cubes, Cols, Rows, 4),
    defineRow(Cubes, Cols, Rows, 5),
    defineRow(Cubes, Cols, Rows, 6),
    defineRow(Cubes, Cols, Rows, 7),
    defineRow(Cubes, Cols, Rows, 8).

defineRow(Cubes, Cols, Rows, RowNum) :-
	defineCell(Cubes, Cols, Rows, RowNum, 0),
	defineCell(Cubes, Cols, Rows, RowNum, 1),
	defineCell(Cubes, Cols, Rows, RowNum, 2),
	defineCell(Cubes, Cols, Rows, RowNum, 3),
	defineCell(Cubes, Cols, Rows, RowNum, 4),
	defineCell(Cubes, Cols, Rows, RowNum, 5),
	defineCell(Cubes, Cols, Rows, RowNum, 6),
	defineCell(Cubes, Cols, Rows, RowNum, 7),
	defineCell(Cubes, Cols, Rows, RowNum, 8).

defineCell(Cubes, Cols, Rows, RowNum, ColNum) :-
	nth0(RowNum, Rows, Row),
	nth0(ColNum, Cols, Col),
	nth0(ColNum, Row, Cell),
	nth0(RowNum, Col, Cell),
	cubeNum(RowNum, ColNum, CubeNum),
	nth0(CubeNum, Cubes, Cube),
	checkCell(Cell, Row, Col, Cube).

checkCell(Cell, Row, Col, Cube) :-
	(nonvar(Cell); var(Cell), digit(Cell), is_set(Row), is_set(Col), is_set(Cube)).
 
% Prints out the given board.
printBoard([]).
printBoard([Head|Tail]) :-
	write(Head), nl,
	printBoard(Tail).
 
test1() :-
	Board =
		[[2, _, _, _, 8, 7, _, 5, _],
		 [_, _, _, _, 3, 4, 9, _, 2],
		 [_, _, 5, _, _, _, _, _, 8],
		 [_, 6, 4, 2, 1, _, _, 7, _],
		 [7, _, 2, _, 6, _, 1, _, 9],
		 [_, 8, _, _, 7, 3, 2, 4, _],
		 [8, _, _, _, _, _, 4, _, _],
		 [3, _, 9, 7, 4, _, _, _, _],
		 [_, 1, _, 8, 2, _, _, _, 5]],
	solve(Board),
	printBoard(Board), nl,
	Board =
		[[2, 9, 3, 1, 8, 7, 6, 5, 4],
		 [6, 7, 8, 5, 3, 4, 9, 1, 2],
		 [1, 4, 5, 6, 9, 2, 7, 3, 8],
		 [9, 6, 4, 2, 1, 8, 5, 7, 3],
		 [7, 3, 2, 4, 6, 5, 1, 8, 9],
		 [5, 8, 1, 9, 7, 3, 2, 4, 6],
		 [8, 2, 6, 3, 5, 1, 4, 9, 7],
		 [3, 5, 9, 7, 4, 6, 8, 2, 1],
		 [4, 1, 7, 8, 2, 9, 3, 6, 5]],
	printBoard(Board), nl, nl.
 
test2() :-
	Board = 
		[[_, _, _, 7, 9, _, 8, _, _],
		 [_, _, _, _, _, 4, 3, _, 7],
		 [_, _, _, 3, _, _, _, 2, 9],
		 [7, _, _, _, 2, _, _, _, _],
		 [5, 1, _, _, _, _, _, 4, 8],
		 [_, _, _, _, 5, _, _, _, 1],
		 [1, 2, _, _, _, 8, _, _, _],
		 [6, _, 4, 1, _, _, _, _, _],
		 [_, _, 3, _, 6, 2, _, _, _]],
	solve(Board),
	printBoard(Board), nl,
	Board = 
		[[2, 3, 1, 7, 9, 6, 8, 5, 4],
		 [9, 8, 5, 2, 1, 4, 3, 6, 7],
		 [4, 6, 7, 3, 8, 5, 1, 2, 9],
		 [7, 9, 8, 4, 2, 1, 5, 3, 6],
		 [5, 1, 2, 6, 3, 9, 7, 4, 8],
		 [3, 4, 6, 8, 5, 7, 2, 9, 1],
		 [1, 2, 9, 5, 4, 8, 6, 7, 3],
		 [6, 5, 4, 1, 7, 3, 9, 8, 2],
		 [8, 7, 3, 9, 6, 2, 4, 1, 5]],
	printBoard(Board), nl, nl.

test3() :-
	Board = 
		[[_, 2, _, _, _, _, _, _, _],
		 [_, _, _, 6, _, _, _, _, 3],
		 [_, 7, 4, _, 8, _, _, _, _],
		 [_, _, _, _, _, 3, _, _, 2],
		 [_, 8, _, _, 4, _, _, 1, _],
		 [6, _, _, 5, _, _, _, _, _],
		 [_, _, _, _, 1, _, 7, 8, _],
		 [5, _, _, _, _, 9, _, _, _],
		 [_, _, _, _, _, _, _, 4, _]],
	solve(Board),
	printBoard(Board), nl,
	Board = 
		[[1, 2, 6, 4, 3, 7, 9, 5, 8],
		 [8, 9, 5, 6, 2, 1, 4, 7, 3],
		 [3, 7, 4, 9, 8, 5, 1, 2, 6],
		 [4, 5, 7, 1, 9, 3, 8, 6, 2],
		 [9, 8, 3, 2, 4, 6, 5, 1, 7],
		 [6, 1, 2, 5, 7, 8, 3, 9, 4],
		 [2, 6, 9, 3, 1, 4, 7, 8, 5],
		 [5, 4, 8, 7, 6, 9, 2, 3, 1],
		 [7, 3, 1, 8, 5, 2, 6, 4, 9]],
	printBoard(Board), nl, nl.

test4() :-
	Board = 
		[[8, _, _, _, _, _, _, _, _],
		 [_, _, 3, 6, _, _, _, _, _],
		 [_, 7, _, _, 9, _, 2, _, _],
		 [_, 5, _, _, _, 7, _, _, _],
		 [_, _, _, _, 4, 5, 7, _, _],
		 [_, _, _, 1, _, _, _, 3, _],
		 [_, _, 1, _, _, _, _, 6, 8],
		 [_, _, 8, 5, _, _, _, 1, _],
		 [_, 9, _, _, _, _, 4, _, _]],
	solve(Board),
	printBoard(Board), nl,
	Board = 
		[[8, 1, 2, 7, 5, 3, 6, 4, 9],
		 [9, 4, 3, 6, 8, 2, 1, 7, 5],
		 [6, 7, 5, 4, 9, 1, 2, 8, 3],
		 [1, 5, 4, 2, 3, 7, 8, 9, 6],
		 [3, 6, 9, 8, 4, 5, 7, 2, 1],
		 [2, 8, 7, 1, 6, 9, 5, 3, 4],
		 [5, 2, 1, 9, 7, 4, 3, 6, 8],
		 [4, 3, 8, 5, 2, 6, 9, 1, 7],
		 [7, 9, 6, 3, 1, 8, 4, 5, 2]],
	printBoard(Board), nl, nl.

tests() :-
	test1(),
	test2(),
	test3(),
	test4().

:- initialization(main).
main :- tests(), halt.