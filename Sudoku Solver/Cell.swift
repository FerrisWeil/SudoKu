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
	
	func getText() -> String {if box > 0 {return "\(box)"}; return ""}
	func getRow() -> String {return "\(row)"}
	func getCol() -> String {return "\(col)"}
	func getBox() -> Int {return box}
	func getColor() -> Color {return color}
	func getDefaultColor() -> Color {return defaultColor}
	
	func setBox(box: Int) {self.box = box}
	func setColor(color: Color) {self.color = color}
	func removeColor() {self.color = defaultColor}
	
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
	
	
}



class Solver {
	
	static func solve(oldCells: [Cell]) -> [Cell] {
		var newCells = [Cell]()
		for row in 0 ..< 9 {
			for col in 0 ..< 9 {
				let cell = oldCells[row*9+col]
				cell.setBox(box: cell.box + 1)
				newCells.append(cell)
			}
		}
		return newCells
	}
	
	/*
	Decides if the new move is valid based on Rows Cols and Boxes
	*/
	static func checkMove(cells: [Cell], changedCell: Int, changedValue: Int) -> Bool {
		let cell = cells[changedCell]
		for c in cells {
			if c.getCol() == cell.getCol() || c.getRow() == cell.getRow() || c.getBox() == cell.getBox() {
				if Int(c.getText()) == changedValue {return false}
			}
		}
		return true
	}
}
