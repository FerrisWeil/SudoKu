//
//  ContentView.swift
//  Sudoku Solver
//
//  Created by Taylor Weil on 1/16/20.
//  Copyright © 2020 Taylor Weil. All rights reserved.
//

import SwiftUI
import CoreData

struct ContentView: View {
	
	@FetchRequest(entity: GameData.entity(), sortDescriptors: []) var games: FetchedResults<GameData>
	@Environment(\.managedObjectContext) var moc
	
	
	@State var num = 0
	@State var selectedNumber = 0
	let pickerValues = ["-","1","2","3","4","5","6","7","8","9"]
	@State var activeCell = -1
	@State var game = Game()
	@State var currentGameId = UUID(uuidString: "0")
	@State var consoleText = ""
//	@State private var message = false
	
	let backgroundColor = Color(red: 70/255, green: 70/255, blue: 70/255)
	
	
	var body: some View {
		ZStack{
			backgroundColor.edgesIgnoringSafeArea(.all)
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
					//Buttons and UI
					Text(self.consoleText)
						.frame(height: 10)
						.padding(.top, 5)
					Picker("Numbers",selection: $selectedNumber){
						ForEach((0 ..< 10)) {
							Text(self.pickerValues[$0]).tag($0)
						}
					}.pickerStyle(SegmentedPickerStyle()).padding(.horizontal, 20)
					HStack {
						Button(action: {
							self.checkAction()
						}){
							Text("Check")
						}
						Button(action: {
							self.saveGame()
						}){
							Text("Save")
						}
						Button(action: {
							self.clearSaves()
						}){
							Text("Clear_Saves")
						}
						Button(action: {
							self.clearBoard()
						}){
							Text("Clear_Board")
						}
						Button(action: {
							self.game.getSolvedBoard()
							self.consoleText = "Solved Board Loaded"
						}){
							Text("Solved_Board")
						}
					}
					//Games
					ForEach(games, id: \.id) { game in
						HStack {
							Text("\(game.id!)")
								.background(self.getBackgroundColor(id: game.id!))
								.cornerRadius(5)
							Button(action: {
								self.loadGame(id: game.id!)
							}){
								
								Text("Load")
							}
						}
					}
					Spacer()
					Button(action: {
						self.runSolver()
					}){
						Text("Run Solver")
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
		if activeCell > -1 {game.getCells()[activeCell].removeColor()
			activeCell = -1 }
		if game.solve() { self.consoleText = "Game Successfully Solved" }
		else { self.consoleText = "Game Could Not Be Solved"}
	}
	
	func checkAction() {
		if activeCell != -1 {
			//if the numnber if diffrent and it is valid, update it
			if Int(game.getCells()[activeCell].getText()) != selectedNumber {
				if Solver.checkMove(cells: game.getCells(), cell: game.cells[activeCell], changedValue: selectedNumber) {
					game.updateCell(cell: activeCell, result: selectedNumber)
					self.consoleText = "Valid!"
				}
				else {
					self.consoleText = "That move is invalid"
					selectedNumber = ((Int(game.getCells()[activeCell].getText()) ?? 1))
				}
			}
		}
	}
	
	func setActive(row: Int, col: Int) {
		if activeCell != -1 {
			game.getCells()[activeCell].removeColor()
		}
		activeCell = (row*9+col)
		game.getCells()[activeCell].setColor(color: Color(red: 22/255, green: 188/255, blue: 188/255))
		selectedNumber = (Int(game.getCells()[activeCell].getText()) ?? 0)
	}
	
	func loadGame(id: UUID) {
		if activeCell != -1 {self.game.getCells()[activeCell].removeColor()}
		for game in self.games {
			if game.id == id {
				
				if self.game.getCellsFromString(cellString: game.cellString!) {
					self.currentGameId = game.id!
					self.activeCell = -1
					self.selectedNumber = -1
					self.consoleText = "Game Loaded"
					return
				}
				else {return} //TODO: Handle error
			}
		}
	}
	
	func saveGame() {
		self.moc.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
		let gameToSave = GameData(context: self.moc)
		if UUID(uuidString: "0") != self.currentGameId {gameToSave.id = self.currentGameId}
		else {gameToSave.id = UUID()}
		gameToSave.cellString = self.game.getStringFromArr()
		self.currentGameId = gameToSave.id!
		try? self.moc.save()
		self.consoleText = "Game Saved"
	}
	
	func clearSaves() {
		for game in games {
			self.moc.delete(game)
		}
		try? self.moc.save()
		self.consoleText = "Saves Cleared"
//		self.moc.reset()
	}
	
	func clearBoard() {
		self.game = Game()
		self.currentGameId = UUID(uuidString: "0")
		self.consoleText = "Board Cleared"
	}
	
	func getColor(row: Int, col: Int) -> Color {return game.getCells()[row*9+col].getColor()}
	
	func getBackgroundColor(id: UUID) -> Color {if id == self.currentGameId {return Color.blue}
		else {return backgroundColor}
	}
	
	func getCellText(row: Int, col: Int) -> String{
		if (row*9+col) != activeCell {return String(game.getCells()[row*9+col].getText())}
		if selectedNumber == 0 {return ""}
		return String(selectedNumber)
	}
}

struct ContentView_Previews: PreviewProvider {
	static var previews: some View {
		ContentView()
	}
}
