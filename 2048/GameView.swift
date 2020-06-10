//
//  GameView.swift
//  2048
//
//  Created by 姜冉 on 2020/6/8.
//  Copyright © 2020 rain. All rights reserved.
//

import SwiftUI

struct GameView: View {
    @ObservedObject var viewModel:GameViewModel
    
    var body: some View {
        let tap = DragGesture().onEnded({value in self.move(by: value)})
        
        return GeometryReader{geo in
            ZStack{
                RoundedRectangle(cornerRadius: 10.0).fill(Color(#colorLiteral(red: 0.719702065, green: 0.6819230318, blue: 0.6252140403, alpha: 1)))
                VStack{
                    ForEach(0..<self.viewModel.gridSize){rowIndex in
                        HStack {
                            ForEach(self.viewModel.tiles[rowIndex]){tile in
                                ZStack{
                                    RoundedRectangle(cornerRadius: 10.0).fill(Color(#colorLiteral(red: 0.794301331, green: 0.7563138604, blue: 0.7084676027, alpha: 1))).transition(.identity).zIndex(0)
                                    TileView(tile:tile)
                                }
                                
                            }
                        }
                    }
                }
                .padding()
            }
            .gesture(tap)
            .frame(width: geo.size.width, height: geo.size.width, alignment: .center)
            
        }
        
        
        
    }
    
    func move(by value:DragGesture.Value){
        
        withAnimation(Animation.easeInOut.speed(2)){
            if abs(value.translation.height) > abs(value.translation.width){
                if value.translation.height > 30 {
                    self.viewModel.move(by:GameModel.Direction.down)
                }else if value.translation.height < -30{
                    self.viewModel.move(by:GameModel.Direction.up)
                }
            }else{
                if value.translation.width > 30 {
                    self.viewModel.move(by:GameModel.Direction.right)
                }else if value.translation.width < -30{
                    self.viewModel.move(by:GameModel.Direction.left)
                }
            }
        }
        
    }
    
}


struct TileView: View {
    var tile:GameModel.Tile
    
    var body: some View {
        GeometryReader { geometry in
            self.body(for: geometry.size)
        }
    }
    
    @ViewBuilder
    private func body(for size:CGSize) -> some View {
        if(tile.value != 0){
            ZStack{
                RoundedRectangle(cornerRadius: 10.0).fill(tile.bgColor)
                Text(String(tile.value)).font(Font.system(size: fontSize(for: size,in: tile.value))).foregroundColor(tile.fontColor)
            }
            .transition(transition(for: size))
        
        }
        
    }
    
    
    private let cornerRadius:CGFloat = 10.0
    private let edgeLineWidth:CGFloat = 3
    
    private func fontSize(for size: CGSize, in value:Int) -> CGFloat{
        size.width * 0.7 / CGFloat(String(value).count)
    }
    
    private func transition(for size:CGSize) -> AnyTransition{
        var transition:AnyTransition
        if let mergedFrom = tile.mergedFrom{
            let perviousTile = mergedFrom[0]
            let offset = CGSize(width: CGFloat(perviousTile.x - tile.x )*size.width, height: CGFloat(perviousTile.y - tile.y )*size.height)
            transition = AnyTransition.offset(offset).combined(with: .scale)
        }else{
            if let previousPosition = tile.previousPosition {
                let offset = CGSize(width: CGFloat(previousPosition.x - tile.x )*size.width, height: CGFloat(previousPosition.y - tile.y )*size.height)
                transition = AnyTransition.offset(offset)
            }else{
                transition = AnyTransition.scale
            }
        }
        return AnyTransition.asymmetric(insertion: transition.animation(.easeInOut), removal: .identity)
    }
    
}





struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        GameView(viewModel: GameViewModel())
    }
}
