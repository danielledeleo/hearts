import Textdeck
setscreen ("nocursor,offscreenonly")

var deck : array 1 .. 52 of int
var player : array 1 .. 4 of array 1 .. 13 of int
var played : array 1 .. 4 of int := init (0, 0, 0, 0)
var selected : array 1 .. 13 of boolean := init (false, false, false, false, false, false, false, false, false, false, false, false, false)
var chosen, maximum, count, leader : int
var deck_picture_ids : array 1 .. 52 of int
var turn : int := 1
var match : int := 0
var winner : int := 1

var playable : array 1 .. 13 of boolean := init (false, false, false, false, false, false, false, false, false, false, false, false, false)

var sidecard, upcard, tabsPicture : int % card images for EAST, NORTH, and WEST players as well as key correlation tabs

proc loadpictures (var a : array 1 .. * of int, path, extension : string)
    for i : 1 .. upper (a)
	a (i) := Pic.FileNew (path + intstr (i) + extension) % assumes 1.jpg, 2.jpg, 3.jpg... Does not support or check for leading zeros.
    end for
end loadpictures

upcard := Pic.FileNew ("cards/jpg/blankup.jpg")
sidecard := Pic.FileNew ("cards/jpg/blanksideways.jpg")
tabsPicture := Pic.FileNew ("cards/tabs.jpg")
loadpictures (deck_picture_ids, "cards/jpg/", ".jpg")        % loads 1..52 card pictures


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

proc sort (var a : array 1 .. * of int)  % bubble sorts any array of integers
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


proc displayhand (selected : array 1 .. 13 of boolean)    % old text-based display version
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


	if player (1) (i) not= 0 then % checks for filler card
	    Pic.Draw (deck_picture_ids (player (1) (i)), 142 + ((i - 1) * 26), 32 + shift, picCopy)         % displays player hand
	    shift := 0
	end if

	if player (2) (i) not= 0 then
	    Pic.Draw (sidecard, -32, 100 + ((i - 1) * 16), picCopy)                                         % displays west's hand
	    shift := 0
	end if

	if player (3) (i) not= 0 then
	    Pic.Draw (upcard, 142 + ((i - 1) * 26), 370, picCopy)                                           % displays north's hand
	    shift := 0
	end if

	if player (4) (i) not= 0 then
	    Pic.Draw (sidecard, 607, 100 + ((i - 1) * 16), picCopy)                                         % displays east's hand
	    shift := 0
	end if
    end for

    Pic.Draw (tabsPicture, 142, 0, picCopy)

end displayhandpic

proc flip (var x : boolean)  % flips any boolean
    if x = true then
	x := false
    elsif x = false then
	x := true
    end if
end flip

proc swap (var a, b : int) % swaps two integers in an array
    var temp : int

    temp := b
    b := a
    a := temp
end swap

proc playcard (card_position, player_id : int, var a : array 1 .. 4 of int) % puts a player's card in its respective
    a (player_id) := player (player_id) (card_position)                     % spot in the 'played' array. this  is later
    player (player_id) (card_position) := 0                                 % displayed in the middle of the display.

    for i : card_position .. 12                  % slides cards to left of hand after a card has played
	if player (player_id) (i) = 0 then
	    swap (player (player_id) (i), player (player_id) (i + 1))
	end if
    end for
end playcard

proc checkcount (maximum : int, var count : int)
    if chosen not= 0 and player (1) (chosen) not= 0 then
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
end checkcount

proc displayboard (a : array 1 .. 4 of int)
    if a (1) not= 0 then
	Pic.Draw (deck_picture_ids (a (1)), 298, 140, picCopy)
    end if

    if a (2) not= 0 then
	Pic.Draw (deck_picture_ids (a (2)), 208, 204, picCopy)
    end if

    if a (3) not= 0 then
	Pic.Draw (deck_picture_ids (a (3)), 298, 268, picCopy)
    end if

    if a (4) not= 0 then
	Pic.Draw (deck_picture_ids (a (4)), 388, 204, picCopy)
    end if
end displayboard

proc render
    displayhandpic (selected)
    displayboard (played)
    View.Update
end render

proc ai(a_player : int)
    var high, low : int
    var hasplayable : boolean := false

    for i : 1 .. 14 - match
	if Textdeck.suitnum (player (a_player) (i)) = Textdeck.suitnum(played(leader)) then
	    playable (i) := true
	    hasplayable := true
	end if
    end for

    if hasplayable then
	for i : 1 .. 14 - match
	    if playable (i) = true then
		low := i
		exit
	    end if
	end for
	for i : low .. 14 - match
	    if playable (i) = false then
		high := i - 1
		exit
	    else
		high := i
	    end if
	end for
	playcard (Rand.Int (low, high), a_player, played)
    else
	playcard (Rand.Int (1, 14 - match), a_player, played)
    end if
    
    for i : 1 .. 13
	playable (i) := false
    end for
end ai

function locatecard (cardnumber : int) : int %returns what player has a specific card, such as the 2 of clubs
    var depth_of_search : int
    
    if cardnumber < 13 then % nice little trick to optimize looking for clubs
	depth_of_search := cardnumber
    else
	depth_of_search := 13
    end if
    
    for i : 1 .. 4
	for j : 1 .. depth_of_search
	    if player(i)(j) = cardnumber then
		result i
	    end if
	end for
    end for
end locatecard

function determine_winner(lead : int) : int
    var leadingsuit : int := Textdeck.suitnum(lead)
    var winningcard : int := lead
    var newwinner : int
    
    for i : 1 .. 4 
	if Textdeck.suitnum(played(i)) = leadingsuit and played(i) >= winningcard then
	    winningcard := played(i)
	    newwinner := i
	end if
    end for
    
    result newwinner
end determine_winner

function isfull(a : array 1 .. * of int, highrange : int) : boolean % takes in an array of ints and returns true if 1 to highrange aren't zero
    var haszero : boolean := false
    for i : 1 .. highrange
	if a(i) = 0 then
	    haszero := true
	end if
    end for
    flip(haszero)
    result haszero
end isfull

function isempty(a : array 1 .. * of int, highrange : int) : boolean
    var hasnozero : boolean := false
    for i : 1 .. highrange
	if a(i) not = 0 then
	    hasnozero := true
	end if
    end for
    flip(hasnozero)
    result hasnozero    
end isempty

function initialized_elements (a : array 1 .. * of int, highrange : int) : int  % like isfull and isempty, but returns number of 
    
end initialized_elements

proc advance(var turn : int)
    if turn = 4 then
	turn := 1
    else
	turn := turn + 1
    end if
end advance
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

var cardsplayed : int := 0

shuffle (deck)
deal

for i : 1 .. 4          %sorts each player's hand by suit
    sort (player (i))
end for

maximum := 1
count := 0
leader := locatecard(1)

turn := leader

displayhandpic (selected)

match += 1

render
loop

    if turn = 1 then
	loop
	    Input.Pause
	    chosen := choose
	    cls
	    checkcount (1, count)


	    if count = 1 and chosen = 0 then   %
		turn += 1
		for i : 1 .. 13
		    if selected (i) = true then
			playcard (i, 1, played)
			cardsplayed += 1
		    end if
		    selected (i) := false
		end for
		count := 0
		exit
	    elsif count = 3 and chosen = 0 then

	    end if
	    render
	end loop
	
	if match not = 13 then
	    match += 1
	end if
    elsif turn = 3 then
	cls
	put "wtf"
	exit
    else
	delay (600)
	ai(turn)  % not very smart
	cls
	render
    end if
    cls
    render
    advance(turn)
    
    if isfull(played,4) = true then
	leader := determine_winner(played(leader))
	turn := leader
	for i : 1 .. 4
	    played(i) := 0
	end for
    end if

    if isempty(player(1),1) and isempty(player(2),1) and isempty(player(3),1) and isempty(player(4),1) then
	    exit
    end if
end loop




