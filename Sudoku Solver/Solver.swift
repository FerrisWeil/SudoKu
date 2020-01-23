//
//  Solver.swift
//  Sudoku Solver
//
//  Created by Taylor Weil on 1/23/20.
//  Copyright © 2020 Taylor Weil. All rights reserved.
//

import Foundation

class Solver {
	
	/*
	DESCRIPTION: What happens when the player presses the solve button
	INPUTS: cells- The 2D array of cells that make up the puzlle (inout)
	DETAILS: This method will atempt to solve the given cells until the puzzle is complete or there are no more possible changes to be made. Inside of the loop is a variety of solving methods that increase in complexity as they go down.
	RETURNS: Whether or not the puzzle was solved after there are no more possible moves
	*/
	static func solve(cells: inout [[Cell]]) -> Bool {
		Solver.fillPossibleValues(cells: &cells)
		var complete = false
		while(!complete) {
			var changed = false
			complete = Solver.solveByElimination(cells: &cells, changed: &changed)
			if !changed {Solver.solveRowColBox(cells: &cells, changed: &changed)
			if !changed {return false}}
		}
		return true
	}
	
	/*
	DESCRIPTION: The first and most simple method for solving the puzzle.
	INPUTS: cells- The 2D array of cells that make up the puzlle (inout)
			changed- If the puzzle was ever changed by this method (inout)
	DETAILS: Here we will iterate through each of the cells and conform that each cell's possible values are still possible. If not, the values will be removed.  Once an unsolved cell has one and only one possible value, that cell will have its result set
	RETURNS: When ever an unsolved cell is found, the complete Bool gets set to false.  By the end of the loop, we will reuturn this Bool stating whether or not the puzzle is complete.
	*/
	static func solveByElimination(cells: inout [[Cell]], changed: inout Bool) -> Bool {
		var complete = true
		for cellRow in cells {
			for cell in cellRow {
				let solvedStatus = cell.checkForSolved()
				if solvedStatus == 2 { changed = true }
				else if solvedStatus == -1 {
					complete = false
					for possibleResult in cell.getPossibleResults(){
						if !checkMove(cells: cells, cell: cell, changedValue: possibleResult) {cell.removePossibleResult(result: possibleResult)
							changed = true
						}
					}
				}
			}
		}
		return complete
	}
	
	/*
	DESCRIPTION: This is second method to solving the sudoku puzzle
	INPUTS: cells- The 2D array of cells that make up the puzlle (inout)
			changed- If the puzzle was ever changed by this method (inout)
	DETAILS: This method will preform 3 seperate checks to see if a row, column, or box can have its value decided.  This is done by comparing the possible values for each of the respective cells, and if one cell is unique in a possible result, it will be set.
	*/
	static func solveRowColBox(cells: inout [[Cell]], changed: inout Bool) {
		//Checks each row for uniqued possible results
		for row in 0 ..< 9 {
			for num in 1 ..< 10 {
				var foundAt = -1
				for col in 0 ..< 9 {
					if cells[row][col].getPossibleResults().contains(num) && cells[row][col].getResult() == 0 {
						if foundAt > -1 {foundAt = -1; break}
						foundAt = row*9+col
					}
				}
				if foundAt > -1 {
					cells[foundAt/9][foundAt%9].setResult(result: num)
					changed = true
				}
			}
		}
		//Checks each column for uniqued possible results
		for col in 0 ..< 9 {
			for num in 1 ..< 10 {
				var foundAt = -1
				for row in 0 ..< 9 {
					if cells[row][col].getPossibleResults().contains(num) && cells[row][col].getResult() == 0 {
						if foundAt > -1 {foundAt = -1;break}
						foundAt = row*9+col
					}
				}
				if foundAt > -1 {
					cells[foundAt/9][foundAt%9].setResult(result: num)
					changed = true
				}
			}
		}
		//Checks each box for uniqued possible results
		for box in 0 ..< 9 {
			for num in 1 ..< 10 {
				var foundAt = -1
				for row in 0 ..< 3 {
					for col in 0 ..< 3 {
						if cells[(box/3)*3+row][(box%3)*3+col].getPossibleResults().contains(num) && cells[(box/3)*3+row][(box%3)*3+col].getResult() == 0 {
							if foundAt > -1 {foundAt = -2}
							if foundAt == -1 {foundAt = (((box/3)*3+row))*9+((box%3)*3+col)}
						}
					}
				}
				if foundAt > -1 {
					cells[foundAt/9][foundAt%9].setResult(result: num)
					changed = true
				}
			}
		}
	}
	
	/*
	DESCRIPTION: Decides if the new move is valid based on Rows Cols and Boxes
	INPUTS: cells- The 2D array of cells that make up the puzzle
			cell- The Cell that is having its move checked
			changedValues- The value that we will be testing
	DETAILS: This method will iterate through the array and compare the results of cells in the targer's row, col, and box to validate changing a value
	RETURNS: Wether or not the new value is valid to be changed to
	*/
	static func checkMove(cells: [[Cell]], cell: Cell, changedValue: Int) -> Bool {
		if changedValue == 0 {return true}
		for i in 0 ..< 9 { //Checks cell's rows and cols
			if cells[i][cell.getCol()].getResult() == changedValue && i != cell.getRow() || cells[cell.getRow()][i].getResult() == changedValue && i != cell.getCol() {return false}
		}
		let box = cell.getBox()
		for row in 0 ..< 3 { //Checks cell's box
			for col in 0 ..< 3 {
				let checkCell = cells[((box/3)*3+row)][((box%3)*3+col)]
				if checkCell.getResult() == changedValue && checkCell.getRow() != cell.getRow() && checkCell.getCol() != cell.getCol() {return false}
			}
		}
		return true
	}
	
	/*
	DESCRIPTION: Fill the cells with each of their possible values
	INPUTS: cells- The 2D array of cells that make up the puzzle
	DETAILS: Iterates through each cell, if the cell is not already solved, it will check to see if each number 1 through 9 is valid, if so, the number will be added to the possible results array.  If the cell is already solved, the result will get added to the possible values
	*/
	static func fillPossibleValues( cells: inout [[Cell]]) {
		for row in 0 ..< 9 {
			for col in 0 ..< 9 {
				cells[row][col].clearPossibleResults()
				if cells[row][col].getResult() == 0 {
					cells[row][col].addPossibleResult(result: [Int]())
					for i in 1 ..< 10 {
						if Solver.checkMove(cells: cells, cell: cells[row][col], changedValue: i) && !cells[row][col].getPossibleResults().contains(i) {
							cells[row][col].addPossibleResult(result: i)
						}
					}
				}
				else {cells[row][col].addPossibleResult(result: cells[row][col].getResult())}
			}
		}
	}
}
