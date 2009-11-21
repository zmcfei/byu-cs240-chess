#ifndef _PAWN_H_
#define _PAWN_H_

#include "Piece.h"

class Pawn : public Piece{
public:
	Pawn(PieceColor);
	~Pawn();
private:
	bool firstMove;
};

#endif
