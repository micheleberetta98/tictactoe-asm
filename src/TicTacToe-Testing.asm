asm TicTacToe


import StandardLibrary

signature:
	enum domain Position = {TOP_LEFT | TOP_MID | TOP_RIGHT | MID_LEFT | MID_MID | MID_RIGHT | BTM_LEFT | BTM_MID | BTM_RIGHT}
	enum domain Player = {PLAYER_X | PLAYER_O | NONE}
	
	// turn rappresenta il giocatore che deve fare la mossa
	controlled turn: Player
	controlled winner: Player
	
	// Rappresenta quale giocatore ha occupato quale posizione
	controlled player: Position -> Player
	// Contatore delle mosse
	controlled moves: Integer
	
	monitored choice: Position
	monitored computerChoice: Position

definitions:
	// Questa regola deve anche aumentare il numero di mosse
	rule r_updateBoard($pos in Position, $p in Player) =
		par
			player($pos) := $p
			moves := moves + 1
		endpar
	
	rule r_updateBoardUser($pos in Position) =
		r_updateBoard[$pos, PLAYER_X]
	
	// Il computer sceglie a caso una posizione libera
	rule r_updateBoardComputer($pos in Position) =
    r_updateBoard[$pos, PLAYER_O]
	
	rule r_turnUser($pos in Position) =
		if player($pos) = NONE then
			par
				r_updateBoardUser[$pos]
				turn := PLAYER_O
			endpar
		endif

	rule r_turnComputer($pos in Position) =
    if player($pos) = NONE then
      par
        r_updateBoardComputer[$pos]
        turn := PLAYER_X
      endpar
    end if
	
	rule r_checkForWinnerIn($a in Position, $b in Position, $c in Position) =
		if player($a) = player($b) and player($b) = player($c) then
			winner := player($a)
		endif

	// Questa regola deve avere seq e non par, perché
	// r_checkForWinner cambia il contenuto di winner
	macro rule r_checkWinner =
		seq
			r_checkForWinnerIn[TOP_LEFT, TOP_MID, TOP_RIGHT]
			r_checkForWinnerIn[MID_LEFT, MID_MID, MID_RIGHT]
			r_checkForWinnerIn[BTM_LEFT, BTM_MID, BTM_RIGHT]
			
			r_checkForWinnerIn[TOP_LEFT,  MID_LEFT,  BTM_LEFT]
			r_checkForWinnerIn[TOP_MID,   MID_MID,   BTM_MID]
			r_checkForWinnerIn[TOP_RIGHT, MID_RIGHT, BTM_RIGHT]
			
			r_checkForWinnerIn[TOP_LEFT,  MID_MID, BTM_RIGHT]
			r_checkForWinnerIn[TOP_RIGHT, MID_MID, BTM_LEFT]
		endseq

	main rule r_Main =
		// Il gioco si ferma se c'è un vincitore o se tutte le posizioni sono occupate
		if winner = NONE and moves < 9 then
			seq
				if turn = PLAYER_X then
					r_turnUser[choice]
				else
					r_turnComputer[computerChoice]
				endif
				r_checkWinner[]
			endseq
		endif

default init s0:
	function turn = PLAYER_X
	function winner = NONE
	function moves = 0
	function player($p in Position) = NONE