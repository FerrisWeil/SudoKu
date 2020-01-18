//
//  ContentView.swift
//  Sudoku Solver
//
//  Created by Taylor Weil on 1/16/20.
//  Copyright © 2020 Taylor Weil. All rights reserved.
//

import SwiftUI
import Combine

struct ContentView: View {
	//	@State private var num1 = ""
	
	@State var cells = fillCells()
	@State var num = 0
	@State var selectedNumber = 0
	@State var activeCell = -1
//	@State private var message = false
	
	
	var body: some View {
		ZStack{
			Color(red: 70/255, green: 70/255, blue: 70/255)
				.edgesIgnoringSafeArea(.all)
			VStack(spacing: 0){
				//Heading
				VStack {
					Spacer().frame(height: 20)
					Text("Sukoku Solver")
						.foregroundColor(Color(red: 22/255, green: 188/255, blue: 188/255))
					Spacer().frame(height: 20)
					
				}
				//Board
				VStack(alignment: .center, spacing: 10){
					ForEach(0 ..< 9) {row in
						HStack(){
							ForEach (0 ..< 9) {col in
								Button(action: {
									self.setActive(row: row, col: col)
								}){
									Text(self.getCellText(row: row, col: col))
										.frame(width: 30, height: 30)
										.foregroundColor(Color.black)
										.cornerRadius(5)
										.background(self.getColor(row: row, col: col))
								}
							}
						}
					}
					Spacer().frame(height: 20)
					Picker("Numbers",selection: $selectedNumber){
						ForEach(1 ..< 10) {
							Text("\($0)").tag($0)
						}
					}.pickerStyle(SegmentedPickerStyle()).padding(20)
					Spacer()
					Button(action: {
						self.runSolver()
					}){
						Text("\(activeCell)")
					}
				}
			}
		}
//		.alert(isPresented: $message) {
//			Alert(
//				title: Text("Invalid Move"),
//				dismissButton: .cancel()
//			)
//		}
	}
	
	func runSolver() {
		cells[activeCell].removeColor()
		activeCell = -1
		cells = Solver.solve(oldCells: cells)
	}
	
	func setActive(row: Int, col: Int) {
		if activeCell != -1 {
			cells[activeCell].removeColor()
		}
		activeCell = (row*9+col)
		cells[activeCell].setColor(color: Color(red: 22/255, green: 188/255, blue: 188/255))
		selectedNumber = (Int(cells[activeCell].getText()) ?? 1)-1
	}
	
	func getColor(row: Int, col: Int) -> Color {return cells[row*9+col].getColor()}
	
	func getCellText(row: Int, col: Int) -> String{
		if activeCell != -1 {
			//if the numnber if diffrent and it is valid, update it
			if Int(cells[activeCell].getText()) != selectedNumber+1 {
				if Solver.checkMove(cells: cells, changedCell: activeCell, changedValue: selectedNumber+1) {
					cells[activeCell].setBox(box: selectedNumber+1)
				}
				else {
//					message = true;
					selectedNumber = ((Int(cells[activeCell].getText()) ?? 1)-1)
					return cells[activeCell].getText()
				}
			}
		}
		if (row*9+col) != activeCell {return String(cells[row*9+col].getText())}
		return String(1+selectedNumber)
	}
}

func fillCells() -> [Cell] {
	var cells = [Cell]()
	for row in 0 ..< 9 {
		for col in 0 ..< 9 {
			cells.append(Cell(row: row, col: col))
		}
	}
	return cells
}

struct ContentView_Previews: PreviewProvider {
	static var previews: some View {
		ContentView()
	}
}
