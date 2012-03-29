import Textdeck

setscreen ("nocursor")

var deck : array 1 .. 52 of int
var player : array 1 .. 4 of array 1 .. 13 of int
var played : array 1 .. 4 of int
var selected : array 1 .. 13 of boolean := init (false, false, false, false, false, false, false, false, false, false, false, false, false)
var chosen, maximum, count, tabsPicture : int
var deck_picture_ids : array 1 .. 52 of int
var turn : int := 1

proc loadpictures (var a : array 1 .. * of int, path, extension : string)
    for i : 1 .. upper (a)
	a (i) := Pic.FileNew (path + intstr (i) + extension) % assumes 1.jpg, 2.jpg, 3.jpg... Does not support or check for leading zeros.
    end for
end loadpictures

loadpictures (deck_picture_ids, "cards/jpg/", ".jpg")        % loads card pictures


for i : 1 .. 52         % init deck
    deck (i) := i
end for


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

function choose : int
    var ch : array char of boolean
    loop
	Input.KeyDown (ch)
	if ch ('`') then
	    result 1
	elsif ch ('1') then
	    result 2
	elsif ch ('2') then
	    result 3
	elsif ch ('3') then
	    result 4
	elsif ch ('4') then
	    result 5
	elsif ch ('5') then
	    result 6
	elsif ch ('6') then
	    result 7
	elsif ch ('7') then
	    result 8
	elsif ch ('8') then
	    result 9
	elsif ch ('9') then
	    result 10
	elsif ch ('0') then
	    result 11
	elsif ch ('-') then
	    result 12
	elsif ch ('=') then
	    result 13
	elsif ch (' ') then
	    result 0
	end if
    end loop
end choose



proc displayhand (selected : array 1 .. 13 of boolean)
    var info_row, selection_row : string := ""

    for j : 1 .. upper (player (1))
	info_row := info_row + "| " + Textdeck.whatcard (player (1) (j))
    end for
    info_row := info_row + "|"

    for k : 1 .. 13
	if selected (k) = true then
	    selection_row := selection_row + " _V_"
	else
	    selection_row := selection_row + " _ _"
	end if
    end for

    locate (18, 13)
    put selection_row
    locate (19, 13)
    put info_row
    locate (20, 13)
    put "|   |   |   |   |   |   |   |   |   |   |   |   |   |"
    locate (21, 13)
    put "  `   1   2   3   4   5   6   7   8   9   0   -   = "
end displayhand

proc displayhandpic (selected : array 1 .. 13 of boolean)
    var shift : int := 0
    for i : 1 .. 13
	if selected (i) = true then
	    shift := 24
	end if
	
	if player (1) (i) not = 0 then
	    Pic.Draw (deck_picture_ids (player (1) (i)), 142 + ((i - 1) * 26), 32 + shift, picCopy)
	    shift := 0
	end if
    end for
end displayhandpic

proc flip (var x : boolean)
    if x = true then
	x := false
    elsif x = false then
	x := true
    end if
end flip

proc swap(var a, b: int)
    var temp : int
    
    temp := b
    b := a
    a := temp
end swap

proc playcard(card_position, player_id : int, var a : array 1 .. 4 of int)
    a(player_id) := player(player_id)(card_position)
    player(player_id)(card_position) := 0
    
    for i : card_position .. 12
	if player(player_id)(i) = 0 then
	    swap(player(player_id)(i),player(player_id)(i+1))
	end if
    end for
end playcard

%------------------------------------ TESTS -----------------------------------
%randomize
/*
 for i : 1 .. 52
 put rank (deck (i)) ..
 put suit (deck (i)) ..
 put " " ..
 end for


for f : 1 .. 4
    sort (player (f))
    for i : 1 .. 13
	put Textdeck.whatcard (player (f) (i)), " " ..
    end for
    put "\n"
end for
 */
 
%---------------------------------- THE GAME ---------------------------------
shuffle (deck)
deal

for i : 1 .. 4          %sorts each player's hand by suit
    sort (player (i))
end for

maximum := 1
count := 0

displayhandpic (selected)

tabsPicture := Pic.FileNew ("cards/tabs.jpg")
loop
    Input.Pause
    chosen := choose
    

    if chosen not = 0 and player(1)(chosen) not = 0 then
	if maximum = 1 then                          % when maximum = 1, which is normal play (without swapping 3 cards)
	    if count = 1 then                        % if a card is already selected, it swaps the selected card to that position.
		for i : 1 .. 13
		    if selected (i) = true then
			flip (selected (i))
			flip (selected (chosen))
			exit
		    end if
		end for
	    else                                     % if not, raise a card.
		flip (selected (chosen))
		count := count + 1
	    end if
	else                                         % when picking three cards to swap, it allows you to pick three cards
	    if selected (chosen) = true then         % and drop or raise any card you want.
		flip (selected (chosen))
		count := count - 1
	    elsif selected (chosen) = false and count < maximum then
		flip (selected (chosen))
		count := count + 1
	    end if
	end if
    end if
    cls

    if count = 1 and chosen = 0 then           %
	turn += 1
	for i : 1 .. 13
	    if selected(i) = true then
		playcard(i, 1, played)
	    end if
	    selected (i) := false
	end for
	count := 0
    elsif count = 3 and chosen = 0 then
	 
	
    end if

    displayhandpic (selected)
    
    
    Pic.Draw (tabsPicture, 142, 0, picCopy)
end loop




