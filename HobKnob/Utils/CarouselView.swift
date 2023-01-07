//
//  CarouselView.swift
//  HobKnob
//
//  Created by Natanael Jop on 15/12/2022.
//

import SwiftUI

struct Card: Identifiable {
    var id = UUID()
    var image: String
    var offset = 0.0
    var zIndex = 0.0
}

enum SwipeStatus {
    case left, right, center
}

let screenW = UIScreen.main.bounds.width
let screenH = UIScreen.main.bounds.height

struct CarouselView: View {
    @State var cardArray: [Card]
    @State var centeredIndex = 0
    @State var swipedCards = 0
    @State var status: SwipeStatus = .center
    var body: some View {
        ZStack{
            ForEach(cardArray.indices.reversed(), id: \.self) { index in
                VStack{
                    CustomAsyncImage(url: cardArray[index].image, size: CGSize(width: screenW/1.2, height: screenW))
                        .cornerRadius(15)
                        .offset(x: getOffset(index: index) + 20)
                }.frame(height: screenW + 30)
                    .contentShape(Rectangle())
                    .rotationEffect(.degrees((cardArray[index].offset)*0.05))
                    .rotationEffect(.degrees(getRotation(index: index)))
                    .scaleEffect(1-(abs(cardArray[index].offset)/800))
                    .scaleEffect(getScale(index: index))
                .gesture(
                    DragGesture()
                        .onChanged({ value in
                            if index == centeredIndex {
                                onChange(value: value, index: index)
                            }
                        })
                        .onEnded({ value in
                            withAnimation {
                                if index == centeredIndex {
                                    onEnd(value: value, index: index)
                                }
                            }
                        })
                )
                .zIndex(getzIndex(index: index))
            }
        }
    }
    func onChange(value: DragGesture.Value, index: Int){
        
        if centeredIndex == 0 {
            if value.translation.width < 0 {
                centeredIndex = index
                cardArray[index].offset = value.translation.width * 1.5
            }
        }else if centeredIndex >= cardArray.count-1 {
            if value.translation.width > 0 {
                centeredIndex = index
                cardArray[index].offset = value.translation.width * 1.5
            }
        }
        else{
            centeredIndex = index
            cardArray[index].offset = value.translation.width
        }
        
        if cardArray[index].offset < -1 {
            status = .left
        }
        
        if cardArray[index].offset > 1 {
            status = .right
        }
    }
    
    func onEnd(value: DragGesture.Value, index: Int){
        
        
        
       if value.translation.width < 0 && centeredIndex == 0 {
            cardArray[index].offset = value.translation.width
        }

        if cardArray[index].offset < -screenW / 4.5 {
            withAnimation {
                cardArray[index].offset = -screenW / 2
            }
            
            withAnimation(.linear) {
                cardArray[index].zIndex -= Double(cardArray.count - swipedCards)*2
                centeredIndex = index + 1
                swipedCards += 1
            }
            
        }else if cardArray[index].offset > screenW / 4.5 {
            withAnimation {
                cardArray[index].offset = screenW / 2
            }
            
            withAnimation(.linear){
                centeredIndex = index - 1
                swipedCards -= 1
                cardArray[index - 1].zIndex = 1
            }
        }
        else{
            withAnimation {
                cardArray[index].offset = 0
            }
        }
        cardArray[index].offset = 0
    }
    
    func getOffset(index: Int) -> Double {
        
        if centeredIndex == index {
            return cardArray[index].offset
        }else if centeredIndex > index {
            return Double((index - swipedCards) * 50)
        }else if centeredIndex < index {
            return Double((index - swipedCards) * 50)
        }else{
            return 0
        }
    }
    
    func getzIndex(index: Int) -> Double {
        if status == .right {
            return 1 - (0.08 * Double(abs(centeredIndex - index)))
        }else {
            return cardArray[index].zIndex
        }
    }
    
    func getScale(index: Int) -> CGFloat {
        return 1 - (0.1 * Double(abs(centeredIndex - index)))
    }
    
    func getRotation(index: Int) -> CGFloat {
        return 0 - (7.0 * Double(centeredIndex-index))
    }
}
