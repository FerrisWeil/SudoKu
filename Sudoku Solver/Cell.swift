//
//  Cell.swift
//  Sudoku Solver
//
//  Created by Taylor Weil on 1/16/20.
//  Copyright © 2020 Taylor Weil. All rights reserved.
//

import Foundation
import SwiftUI

class Cell {
	
	var row: Int
	var col: Int
	var color = Color.gray
	var box = -1
	var defaultColor = Color.gray
	var result = 0
	var possibleResults = [Int]()
	
	init(row: Int, col: Int){
		self.row = row
		self.col = col
		self.box = findBox()
		findColor()
	}
	
	func getText() -> String {if result > 0 {return "\(result)"}; return ""}
	func getRow() -> Int {return row}
	func getCol() -> Int {return col}
	func getBox() -> Int {return box}
	func getResult() -> Int {return result}
	func getPossibleResults() -> [Int] {return self.possibleResults}
	func getColor() -> Color {return color}
	func getDefaultColor() -> Color {return defaultColor}
	
	func setBox(box: Int) {self.box = box}
	func setResult(result: Int) {self.result = result; self.possibleResults = [result]}
	func setColor(color: Color) {self.color = color}
	func removePossibleResult(result: Int) {
		for i in 0 ..< self.possibleResults.count {
			if result == self.possibleResults[i]  {self.possibleResults.remove(at: i); return}
		}}
	func clearPossibleResults() {self.possibleResults = [Int]()}
	func removeColor() {findColor()}
	func addPossibleResult(result: Int) {self.possibleResults.append(result)}
	func addPossibleResult(result: [Int]) {self.possibleResults.removeAll(); self.possibleResults.append(contentsOf: result)}
	
	func findBox() -> Int {
		var count = 0;
		for row in [3,6,9] {
			for col in [3,6,9] {
				if self.row < row && self.col < col {return count}
				else {count += 1}
			}
		}
		return -1
	}
	
	func findColor() {
		if box % 2 == 1 {self.color =  Color.gray}
		else {self.color = Color.purple}
	}
	
	/*
	Returns: -1 when not solved, 1 when already solved, and 2 if it was just solved
	*/
	func checkForSolved() -> Int{
		if self.result > 0 { return 1 }
		if possibleResults.count != 1 { return -1 }
		result = possibleResults[0]
		return 2
	}
}

class Game {
	
	var cells = [[Cell]]()
	
	init() {
		var tempString = ""
		for _ in 0 ..< 81 {tempString.append("0,")}
		_ = getCellsFromString(cellString: tempString)
	}
	
	func getCells() -> [[Cell]] { return cells }
	func getCell(cell: Int) -> Cell {return cells[cell/9][cell%9]}
	
	func setCells(cells: [[Cell]]) { self.cells = cells }
	
	func updateCell(row: Int, col: Int, result: Int) {
		cells[row][col].setResult(result: result)
		cells[row][col].addPossibleResult(result: result)
	}
	func updateCell(cell: Int, result: Int) { updateCell(row: cell/9, col: cell%9, result: result)}
	
	func getCellsFromString(cellString: String){
		let cellArr = cellString.split(separator: ",")
		//Creates a new array of new cells
		cells = [[Cell]]()
		for row in 0 ..< 9 {
			cells.append([Cell]())
			for col in 0 ..< 9 {
				cells[row].append(Cell(row: row, col: col))
			}
		}
		//Fills the new list of cells with possible values from the string
		for row in 0 ..< 9 {
			for col in 0 ..< 9 {
				cells[row][col].addPossibleResult(result: Int(String(cellArr[row*9+col])) ?? 0)
				_ = cells[row][col].checkForSolved()
			}
		}
	}
	
	func getStringFromArr() -> String{
		var str = ""
		for row in 0 ..< 9 {
			for col in 0 ..< 9 {
				str.append("\(cells[row][col].getResult()),")
			}
		}
		return str
	}
	
	func solve() -> Bool {
		return Solver.solve(cells: &self.cells)
	}
	
	func getSolvedBoard(val: Int) {
		if val == 1 {_ = getCellsFromString(cellString: "8,2,4,9,5,3,6,7,1,6,3,5,8,1,7,9,2,4,7,1,9,6,2,4,8,5,3,5,8,7,2,9,1,3,4,6,1,4,2,7,3,6,5,8,9,3,9,6,4,8,5,2,1,7,2,6,1,5,4,9,7,3,8,4,7,8,3,6,2,1,9,5,9,5,3,1,7,8,4,6,2")}
		else if val == 2 {_ = getCellsFromString(cellString: "0,0,0,2,6,0,7,0,1,6,8,0,0,7,0,0,9,0,1,9,0,0,0,4,5,0,0,8,2,0,1,0,0,0,4,0,0,0,4,6,0,2,9,0,0,0,5,0,0,0,3,0,2,8,0,0,9,3,0,0,0,7,4,0,4,0,0,5,0,0,3,6,7,0,3,0,1,8,0,0,0")}
		else if val == 3 {_ = getCellsFromString(cellString:  "0,0,0,6,0,0,4,0,0,7,0,0,0,0,3,6,0,0,0,0,0,0,9,1,0,8,0,0,0,0,0,0,0,0,0,0,0,5,0,1,8,0,0,0,3,0,0,0,3,0,6,0,4,5,0,4,0,2,0,0,0,6,0,9,0,3,0,0,0,0,0,0,0,2,0,0,0,0,1,0,0")}
		else if val == 4 {_ = getCellsFromString(cellString: "2,0,0,3,0,0,0,0,0,8,0,4,0,6,2,0,0,3,0,1,3,8,0,0,2,0,0,0,0,0,0,2,0,3,9,0,5,0,7,0,0,0,6,2,1,0,3,2,0,0,6,0,0,0,0,2,0,0,0,9,1,4,0,6,0,1,2,5,0,8,0,9,0,0,0,0,0,1,0,0,2")}
	}
}


class Solver {
	
	/*
	What happens when the player presses the solve button
	*/
	static func solve(cells: inout [[Cell]]) -> Bool {
		Solver.fillPossibleValues(cells: &cells)
		var complete = false
		while(!complete) {
			complete = true
			var changed = false
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
			if !changed {
				if !Solver.solveRowColBox(cells: &cells) {return false}}
		}
		return true
	}
	
	static func solveRowColBox(cells: inout [[Cell]]) -> Bool {
		var changed = false
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
		return changed
	}
	
	/*
	Decides if the new move is valid based on Rows Cols and Boxes
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
	Fill the cells with each of their possible values
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
