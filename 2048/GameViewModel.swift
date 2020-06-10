//
//  GameViewModel.swift
//  2048
//
//  Created by 姜冉 on 2020/6/8.
//  Copyright © 2020 rain. All rights reserved.
//

import Foundation

class GameViewModel: ObservableObject {
    @Published private(set) var model: GameModel =  GameViewModel.createGame()
    
    private static func createGame () -> GameModel {
        return GameModel(gridSize: 4)
    }
    
    //MARK: - Access to the model
    var tiles:Array<Array<GameModel.Tile>> {
        model.tiles
    }
    
    var gridSize:Int {
        model.gridSize
    }
    
    //MARK: - Intent(s)
    
    func move(by direction:GameModel.Direction){
        model.move(by: direction)
    }
    
}
