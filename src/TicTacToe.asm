asm TicTacToe


import StandardLibrary

signature:
	enum domain Position = {TOP_LEFT | TOP_MID | TOP_RIGHT | MID_LEFT | MID_MID | MID_RIGHT | BTM_LEFT | BTM_MID | BTM_RIGHT}
	enum domain Player = {PLAYER_X | PLAYER_O | NONE}
	
	controlled turn: Player
	controlled winner: Player
	controlled player: Position -> Player
	
	monitored choice: Position
	controlled lastComputerChoice: Position

definitions:
	rule r_updateBoard($pos in Position, $p in Player) =
		player($pos) := $p
	
	rule r_updateBoardUser($pos in Position) =
		r_updateBoard[$pos, PLAYER_X]
	
	rule r_updateBoardComputer =
		choose $p in Position with player($p) = NONE do
			par
				lastComputerChoice := $p
				r_updateBoard[$p, PLAYER_O]
			endpar
	
	rule r_turnUser($pos in Position) =
		if player($pos) = NONE then
			par
				r_updateBoardUser[$pos]
				turn := PLAYER_O
			endpar
		endif

	rule r_turnComputer =
		par
			r_updateBoardComputer[]
			turn := PLAYER_X
		endpar
		
	rule r_turn =
		skip
	
	rule r_checkForWinnerIn($a in Position, $b in Position, $c in Position) =
		if player($a) = player($b) and player($b) = player($c) then
			winner := player($a)
		endif
		
	rule r_checkWinner =
		par
			r_checkForWinnerIn[TOP_LEFT, TOP_MID, TOP_RIGHT]
			r_checkForWinnerIn[MID_LEFT, MID_MID, MID_RIGHT]
			r_checkForWinnerIn[BTM_LEFT, BTM_MID, BTM_RIGHT]
			
			r_checkForWinnerIn[TOP_LEFT,  MID_LEFT,  BTM_LEFT]
			r_checkForWinnerIn[TOP_MID,   MID_MID,   BTM_MID]
			r_checkForWinnerIn[TOP_RIGHT, MID_RIGHT, BTM_RIGHT]
			
			r_checkForWinnerIn[TOP_LEFT,  MID_MID, BTM_RIGHT]
			r_checkForWinnerIn[TOP_RIGHT, MID_MID, BTM_LEFT]
		endpar

	main rule r_Main =
		if winner = NONE then
			seq
				if turn = PLAYER_X then
					r_turnUser[choice]
				else
					r_turnComputer[]
				endif
				r_checkWinner[]
			endseq
		endif

default init s0:
	function turn = PLAYER_X
	function winner = NONE
	function player($p in Position) = NONE