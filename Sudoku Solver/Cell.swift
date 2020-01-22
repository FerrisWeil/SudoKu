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
	var color: Color
	var box = -1
	var defaultColor = Color.gray
	var result = 0
	var possibleResults = [Int]()
	
	init(row: Int, col: Int){
		self.row = row
		self.col = col
		self.color = defaultColor
		self.box = findBox()
	}
	
	func getText() -> String {if result > 0 {return "\(result)"}; return ""}
	func getRow() -> String {return "\(row)"}
	func getCol() -> String {return "\(col)"}
	func getBox() -> Int {return box}
	func getResult() -> Int {return result}
	func getPossibleResults() -> [Int] {return self.possibleResults}
	func getColor() -> Color {return color}
	func getDefaultColor() -> Color {return defaultColor}
	
	func setBox(box: Int) {self.box = box}
	func setResult(result: Int) {self.result = result}
	func setColor(color: Color) {self.color = color}
	func removePossibleResult(result: Int) {
		for i in 0 ..< self.possibleResults.count {
			if result == self.possibleResults[i]  {self.possibleResults.remove(at: i); return}
		}}
	func removeColor() {self.color = defaultColor}
	func addPossibleResult(result: Int) {self.possibleResults.append(result)}
	func addPossibleResult(result: [Int]) {self.possibleResults.removeAll(); self.possibleResults.append(contentsOf: result)}
	
	func findBox() -> Int {
		var count = 1;
		for row in [3,6,9] {
			for col in [3,6,9] {
				if self.row < row && self.col < col {return count}
				else {count += 1}
			}
		}
		return 0
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
	
	var cells = [Cell]()
	
	init() {
		var tempString = ""
		for _ in 0 ..< 81 {tempString.append("0,")}
		_ = getCellsFromString(cellString: tempString)
	}
	
	func getCells() -> [Cell] { return cells }
	
	func setCells(cells: [Cell]) { self.cells = cells }
	
	func updateCell(cell: Int, result: Int) {
		cells[cell].setResult(result: result)
		cells[cell].addPossibleResult(result: result)
	}
	
	func getCellsFromString(cellString: String) -> Bool{
		let cellArr = cellString.split(separator: ",")
		//if cellArr.count != 81 { return false }
		//Creates a new array of new cells
		cells = [Cell]()
		for row in 0 ..< 9 {
			for col in 0 ..< 9 {
				cells.append(Cell(row: row, col: col))
			}
		}
		//Fills the new list of cells with possible values from the string
		for i in 0 ..< 81{
			for res in cellArr[i] {
				cells[i].addPossibleResult(result: Int(String(res)) ?? 0)
			}
			_ = cells[i].checkForSolved()
		}
		return true
	}
	
	func getStringFromArr() -> String{
		var str = ""
		for cell in cells {
//			for result in cell.getPossibleResults() {
//				str.append("\(result)")
//			}
			str.append("\(cell.getResult()),")
		}
		return str
	}
	
	func solve() -> Bool {
		return Solver.solve(cells: &self.cells)
	}
	
	func getSolvedBoard() {
		_ = getCellsFromString(cellString: "8,2,4,9,5,3,6,7,1,6,3,5,8,1,7,9,2,4,7,1,9,6,2,4,8,5,3,5,8,7,2,9,1,3,4,6,1,4,2,7,3,6,5,8,9,3,9,6,4,8,5,2,1,7,2,6,1,5,4,9,7,3,8,4,7,8,3,6,2,1,9,5,9,5,3,1,7,8,4,6,2")
	}
	
}


class Solver {
	
	/*
	What happens when the player presses the solve button
	*/
	static func solve(cells: inout [Cell]) -> Bool {
		Solver.fillPossibleValues(cells: &cells)
		var complete = true
		while(!complete) {
			complete = true
			var changed = false
			for cell in cells {
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
			if !changed {return false}
		}
		return true
	}
	
	/*
	Decides if the new move is valid based on Rows Cols and Boxes
	*/
	static func checkMove(cells: [Cell], cell: Cell, changedValue: Int) -> Bool {
		for c in cells {
			if c.getCol() == cell.getCol() || c.getRow() == cell.getRow() || c.getBox() == cell.getBox() {
				if Int(c.getText()) == changedValue {return false}
			}
		}
		return true
	}
	
	/*
	Fill the cells with each of their possible values
	*/
	static func fillPossibleValues( cells: inout [Cell]) {
		for cell in cells {
			cell.removePossibleResult(result: 0)
			if cell.checkForSolved() == -1 {
				cell.addPossibleResult(result: [Int]())
				for i in 1 ..< 10 {
					if Solver.checkMove(cells: cells, cell: cell, changedValue: i) {
						cell.addPossibleResult(result: i)
					}
				}
			}
		}
	}
}
