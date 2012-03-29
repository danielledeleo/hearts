setscreen("nocursor")
var deck : array 1 .. 52 of int
var player : array 1 .. 4 of array 1 .. 13 of int
var played : array 1 .. 4 of int
var selected : array 1 .. 13 of boolean := init(false,false,false,false,false,false,false,false,false,false,false,false,false)
var chosen, maximum, count : int
var deck_picture_ids : array 1 .. 52 of int

proc loadpictures(var a : array 1 .. * of int, path, extension : string)
    for i : 1 .. upper(a)
	a(i) := Pic.FileNew(path + intstr(i) + extension)   % assumes 1.jpg, 2.jpg, 3.jpg... Does not support or check for leading zeros.
    end for
end loadpictures

loadpictures(deck_picture_ids, "cards/jpg/", ".jpg")         % loads card pictures

const suits : array 1 .. 4 of string := init ("C", "D", "S", "H") % clubs, diamonds, spades, hearts
const ranks : array 1 .. 13 of int := init (1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13) % 2, 3, 4, 5, 6, 7, 8, 9, 10, Jack, Queen, King, Ace

for i : 1 .. 52         % init deck
    deck (i) := i
end for

function suit (x : int) : string     % determines suit based on card number (1 to 52) example:  card 40 (2 of hearts) 
    var suitno : int                                                                        % = floor([40 - 1] / 13) + 1
    suitno := (x - 1) div 13 + 1                                                            % = 3 + 1
    result suits (suitno)                                                                   % suit 4 is hearts, according to constant array, "suits"
end suit

function rank (x : int) : string
    var rankno : int
    rankno := (x - 1) mod 13 + 1
    for i : 1 .. 8
	if rankno = i then
	    result intstr (rankno + 1)
	end if
    end for
    if rankno = 9 then
	result "T"
    elsif rankno = 10 then
	result "J"
    elsif rankno = 11 then
	result "Q"
    elsif rankno = 12 then
	result "K"
    elsif rankno = 13 then
	result "A"
    end if
end rank

function whatcard (x : int) : string
    result rank (x) + suit (x)
end whatcard

function suitnum (x : int) : int
    result (x - 1) div 13 + 1
end suitnum

function ranknum (x : int) : int
    result (x - 1) mod 13 + 1
end ranknum

proc shuffle (var a : array 1 .. * of int)
    var selected, temp : int

    for n : 1 .. upper (a)
	selected := Rand.Int (lower (a), upper (a))
	temp := a (n)
	a (n) := a (selected) 
	a (selected) := temp
    end for
end shuffle

proc deal
    var count : int := 0
    for y : 1 .. 13
	for x : 1 .. 4
	    count += 1
	    player (x) (y) := deck (count)
	end for
    end for
end deal

proc sort (var a : array 1 .. * of int)
    var tf : boolean
    var temp : int
    loop
	tf := false
	for i : 1 .. upper (a) - 1
	    if a (i) > a (i + 1) then
		temp := a (i)
		a (i) := a (i + 1)
		a (i + 1) := temp
		tf := true
	    end if
	end for
	exit when tf = false
    end loop
end sort

function choosecard : int
    var ch : array char of boolean
    loop
	Input.KeyDown (ch)
	if ch('`') then
	    result 1           
	elsif ch('1') then
	    result 2
	elsif ch('2') then
	    result 3
	elsif ch('3') then
	    result 4
	elsif ch('4') then
	    result 5
	elsif ch('5') then
	    result 6
	elsif ch('6') then
	    result 7
	elsif ch('7') then
	    result 8
	elsif ch('8') then
	    result 9
	elsif ch('9') then
	    result 10
	elsif ch('0') then
	    result 11
	elsif ch('-') then
	    result 12
	elsif ch('=') then
	    result 13
	end if
    end loop
end choosecard



proc displayhand(selected : array 1 .. 13 of boolean)
    var info_row, selection_row : string := ""

    for j : 1 .. upper(player(1))
	info_row := info_row + "| " + whatcard(player(1)(j))
    end for
    info_row := info_row + "|"
    
    for k : 1 .. 13
	if selected(k) = true then
	    selection_row := selection_row + " _V_"
	else
	    selection_row := selection_row + " _ _"            
	end if
    end for

    locate(18,13)
    put selection_row
    locate(19,13)
    put info_row
    locate(20,13)
    put "|   |   |   |   |   |   |   |   |   |   |   |   |   |"
    locate(21,13)
    put "  `   1   2   3   4   5   6   7   8   9   0   -   = "
end displayhand

proc displayhandpic(selected : array 1 .. 13 of boolean)
    var shift : int := 0
    for i : 1 .. 13
	if selected(i) = true then
	    shift := 24
	end if
	Pic.Draw(deck_picture_ids(player(1)(i)),0 + ((i-1) * 26),0 + shift,picCopy)
	shift := 0
    end for
end displayhandpic

proc flip(var x : boolean)
    if x = true then
	x := false
    elsif x = false then
	x := true
    end if
end flip


%------------------------------------ TESTS -----------------------------------
randomize

shuffle (deck)
/*
for i : 1 .. 52
    put rank (deck (i)) ..
    put suit (deck (i)) ..
    put " " ..
end for
*/
deal
for f : 1 .. 4
    sort (player (f))
    for i : 1 .. 13
	put whatcard (player (f) (i)), " " ..
    end for
    put "\n"
end for

%---------------------------------- THE GAME ---------------------------------

maximum := 13
count := 0

displayhandpic(selected)
loop
    Input.Pause
    chosen := choosecard
    
    if selected(chosen) = true then
	flip(selected(chosen))
	count := count - 1
    elsif selected(chosen) = false and count < maximum then
	flip(selected(chosen))
	count := count + 1
    end if
    cls
    displayhandpic(selected)
end loop


