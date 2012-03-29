unit
module Textdeck
    export rank, whatcard, suitnum, ranknum    

    const suits : array 1 .. 4 of string := init ("C", "D", "S", "H") % clubs, diamonds, spades, hearts
    const ranks : array 1 .. 13 of int := init (1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13) % 2, 3, 4, 5, 6, 7, 8, 9, 10, Jack, Queen, King, Ace

    function suit (x : int) : string % determines suit based on card number (1 to 52) example:  card 40 (2 of hearts)
	var suitno : int                                                                    % = floor([40 - 1] / 13) + 1
	suitno := (x - 1) div 13 + 1                                                        % = 3 + 1
	result suits (suitno)                                                               % suit 4 is hearts, according to constant array, "suits"
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
end Textdeck

