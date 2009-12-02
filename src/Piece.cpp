/*
 * Piece.cpp
 *
 *  Created on: Mar 29, 2009
 *      Author: coolaj86
 */

#include "Piece.h"

#include <iostream>

  Piece::Piece(PieceColor _color) :
    type(PAWN)
  {
    assert (WHITE == _color || BLACK == _color);
    color = _color;
  }
  Piece * Piece::Clone()
  {
    throw new exception();
    return NULL;
  }

  Piece::~Piece() {
    return;
  }

  PieceName Piece::Name() const {
    return (PieceName) (type + color);
  }

  PieceType Piece::Type() const {
    return type;
  }

  PieceColor Piece::Color() const {
    return color;
  }

  void Piece::UpdateLocation(int _row, int _col)
  {
    row = _row;
    col = _col;
  }
  void Piece::UpdateLocation(Cell const& other)
  {
    row = other.row;
    col = other.col;
  }

  Cell Piece::Location()
  {
    return Cell(row, col);
  }

  bool Piece::CouldTake(Cell cell)
  {
    std::vector<Cell> moves = Moves();
    for (int i = 0; i < moves.size(); i++)
    {
      if (moves[i] == cell) { return true; }
    }
    return false;
  }

  std::vector<Cell> Piece::Moves()
  {
    return std::vector<Cell>();
  }

  void Piece::_cells_advancing(std::vector<Cell>& cells, int _row, int _col)
  {
    Cell cell(row + _row, col + _col);
    //std::cout << "cells advance (" << cell.row << "," << cell.col << ")" << std::endl;
    while (board->ValidCell(cell) && NULL == board->PieceAt(cell))
    {
      //std::cout << "valid (" << cell.row << "," << cell.col << ")" << std::endl;
      cells.push_back(cell);
      cell.row += _row;
      cell.col += _col;
      //std::cout << "????? (" << cell.row << "," << cell.col << ")" << std::endl;
    }
    if (board->ValidCell(cell) && board->PieceAt(cell)->Color() != this->color)
    {
      //std::cout << "attackable (" << cell.row << "," << cell.col << ")" << std::endl;
      cells.push_back(cell);
    }
  }

  void Piece::_cell_advancing(std::vector<Cell>& cells, int _row, int _col)
  {
    Cell cell(row + _row, col + _col);
    if (board->ValidCell(cell) && (NULL == board->PieceAt(cell) || board->PieceAt(cell)->Color() != this->color))
    {
      cells.push_back(cell);
    }
  }

/*
  static bool Piece::UnitTest() {
    TEST(Piece * piece = new Piece(BLACK));
    TEST(delete piece && piece = new Piece(WHITE));
    TEST(piece->Name());
  }
*/
