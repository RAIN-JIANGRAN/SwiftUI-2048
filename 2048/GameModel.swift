//
//  GameModel.swift
//  2048
//
//  Created by 姜冉 on 2020/6/8.
//  Copyright © 2020 rain. All rights reserved.
//

import Foundation
import SwiftUI

struct GameModel {
    private(set) var tiles: Array<Array<Tile>>
    private(set) var gridSize:Int
    
    
    
    init(gridSize:Int){
        self.gridSize = gridSize
        tiles = Array<Array<Tile>>()
        for i in 0..<gridSize{
            var row = Array<Tile>()
            for j in 0..<gridSize{
                row.append(Tile(x: j, y: i))
            }
            tiles.append(row)
        }
        generateTile()
        generateTile()
    }
    
    private mutating func generateTile(){
        var emptyPositionArr:Array<(x:Int,y:Int)> = []
        for rowIndex in 0..<gridSize{
            for colIndex in 0..<gridSize{
                if(tiles[rowIndex][colIndex].value == 0){
                    emptyPositionArr.append((x:colIndex,y:rowIndex))
                }
            }
        }
        if let randomPos = emptyPositionArr.randomElement() {
            let randomValue = Bool.random() ? 2 : 4
            tiles[randomPos.y][randomPos.x].value = randomValue
        }else{
            print("No remaining spaces!")
        }
    }
    
    mutating func prepareTiles(){
        for y in 0..<gridSize{
            for x in 0..<gridSize{
                if(tiles[y][x].value != 0){
                    tiles[y][x].mergedFrom = nil
//                    tiles[y][x].savePosition()
                }
            }
        }
    }
    
    
    mutating func move(by direction:Direction){
        let vector:(x:Int,y:Int) = getVector(by: direction)
        var moved = false
        prepareTiles()
        
        var col:Array<Int> = []
        var row:Array<Int> = []
        for i in 0...3{
            col.append(i)
            row.append(i)
        }
        if(vector.x == 1){
            col = col.reversed()
        }
        if(vector.y == 1){
            row = row.reversed()
        }
        for y in row{
            for x in col{
                let cell = Cell(x: x, y: y)
                var newCell:Cell
                let tile = tiles[y][x]
                if(tile.value != 0){
                    let positions = findFarthestPosition(cell: cell, vector: vector)
        
                    if let next = cellCotent(at: positions.next), next.value == tile.value, next.mergedFrom == nil{
                        let merged = Tile(x: next.x, y: next.y, value: tile.value * 2, mergedFrom: [tile,next])
                        insertTile(tile: merged)
                        removeTile(tile: tile)
                        newCell = Cell(x: next.x, y: next.y)
                    }else{
                        removeTile(tile: tile)
                        insertTile(tile: Tile(x: positions.farthest.x, y: positions.farthest.y, value: tile.value,previousPosition: cell))
                    
                        newCell = Cell(x: positions.farthest.x, y: positions.farthest.y)
                    }
                    
                    if(newCell.x != cell.x  || newCell.y != cell.y){
                        moved = true
                    }
                    
                }
            }
        }
        
        if(moved){
            generateTile()
        }
        
    }
    
    func findFarthestPosition(cell: Cell,vector:(x:Int,y:Int)) -> (farthest:Cell,next:Cell){
        var previous:Cell
        var currentcell = cell
        repeat{
            previous = currentcell
            currentcell = Cell(x: previous.x + vector.x, y: previous.y + vector.y)
        }while(withinBounds(cell: currentcell) && cellAvailable(cell: currentcell) )
        return (previous,currentcell)
    }
    
    func getVector(by direction:Direction) -> (x:Int,y:Int){
        var x = 0;
        var y = 0;
        switch direction {
        case .down:
            y =  1
        case .up:
            y = -1
        case .left:
            x = -1
        case .right:
            x = 1
        }
        return (x:x,y:y)
    }
    
    //MARK: - Cell
    
    struct Cell {
        var x:Int
        var y:Int
    }
    
    func cellCotent(at cell:Cell) -> Tile? {
        if(withinBounds(cell: cell)){
            return tiles[cell.y][cell.x]
        }else{
            return nil
        }
    }
    
    func cellAvailable (cell:Cell) -> Bool {
        if(withinBounds(cell: cell)){
            return tiles[cell.y][cell.x].value == 0
        }else{
            return false
        }
    }
    
    func withinBounds(cell:Cell) -> Bool {
        return cell.x >= 0 && cell.x < self.gridSize && cell.y >= 0 && cell.y < gridSize
    }
    
    mutating func insertTile(tile:Tile){
        tiles[tile.y][tile.x] = tile
    }
    
    mutating func removeTile(tile:Tile){
        tiles[tile.y][tile.x].value = 0
        tiles[tile.y][tile.x].mergedFrom = nil
        tiles[tile.y][tile.x].previousPosition = nil
    }
    
    mutating func moveTile(tile:Tile,cell:Cell){
        tiles[tile.y][tile.x].value = 0
        tiles[tile.y][tile.x].mergedFrom = nil
        tiles[cell.y][cell.x] = tile
       
    }
    
    //MARK: - Tile
    
    struct Tile: Identifiable{
        var x:Int
        var y:Int
        var value:Int = 0
        var mergedFrom:Array<Tile>?
        var previousPosition:Cell?
        var bgColor:Color{
            get{
                if(value > 2048){
                    return Color(.black)
                }else{
                    return  GameModel.ColorMap[value]!}
            }
        }
        var fontColor:Color{
            get{
                if(value <= 4){
                    return Color(.black)
                }else{
                    return Color(.white)
                }
            }
        }
        
        var id: Int{
            get{
                (y*10) + x
            }
        }
        
        mutating func savePosition(){
            self.previousPosition = Cell(x: x, y: y)
        }
        
    }
    
    static let ColorMap =  [
        0:Color(#colorLiteral(red: 0.8036968112, green: 0.7560353875, blue: 0.7039339542, alpha: 1)),
        2: Color(#colorLiteral(red: 0.9316522479, green: 0.8934505582, blue: 0.8544340134, alpha: 1)),
        4: Color(#colorLiteral(red: 0.9296537042, green: 0.8780228496, blue: 0.7861451507, alpha: 1)),
        8: Color(#colorLiteral(red: 0.9504186511, green: 0.6943461895, blue: 0.4723204374, alpha: 1)),
        16: Color(#colorLiteral(red: 0.9621869922, green: 0.6018956304, blue: 0.3936881721, alpha: 1)),
        32:Color(#colorLiteral(red: 0.9640850425, green: 0.49890697, blue: 0.3777080476, alpha: 1)),
        64: Color(#colorLiteral(red: 0.9669782519, green: 0.406899184, blue: 0.2450104952, alpha: 1)),
        128: Color(#colorLiteral(red: 0.9315031767, green: 0.8115276694, blue: 0.4460085034, alpha: 1)),
        256: Color(#colorLiteral(red: 0.9288312197, green: 0.7997121811, blue: 0.3823960423, alpha: 1)),
        512: Color(#colorLiteral(red: 0.9315162301, green: 0.783490479, blue: 0.3152971864, alpha: 1)),
        1024: Color(#colorLiteral(red: 0.9308142066, green: 0.7592952847, blue: 0.179728806, alpha: 1)),
        2048: Color(#colorLiteral(red: 0.9308142066, green: 0.7592952847, blue: 0.179728806, alpha: 1)),
    ]
    
    enum Direction {
        case up
        case down
        case left
        case right
    }
    
}
