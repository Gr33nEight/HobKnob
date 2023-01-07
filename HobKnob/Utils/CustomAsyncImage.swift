//
//  CustomAsyncImage.swift
//  HobKnob
//
//  Created by Natanael Jop on 17/11/2022.
//

import SwiftUI

struct CacheAsyncImage<Content>: View where Content: View{
    private let url: URL
    private let scale: CGFloat
    private let transaction: Transaction
    private let content: (AsyncImagePhase) -> Content
    init(
        url: URL,
        scale: CGFloat = 1.0,
        transaction: Transaction = Transaction(),
        @ViewBuilder content: @escaping (AsyncImagePhase) -> Content
    ){
        self.url = url
        self.scale = scale
        self.transaction = transaction
        self.content = content
    }
    
    var body: some View{
        if let cached = ImageCache[url]{
            content(.success(cached))
        }else{
            AsyncImage(
                url: url,
                scale: scale,
                transaction: transaction
            ){ phase in
                cacheAndRender(phase: phase)
            }
        }
    }
    func cacheAndRender(phase: AsyncImagePhase) -> some View{
        if case .success (let image) = phase {
            ImageCache[url] = image
        }
        return content(phase)
    }
}
fileprivate class ImageCache{
    static private var cache: [URL: Image] = [:]
    static subscript(url: URL) -> Image?{
        get{
            ImageCache.cache[url]
        }
        set{
            ImageCache.cache[url] = newValue
        }
    }
}


struct CustomAsyncImage: View {
    var url: String
    var size: CGSize
    var body: some View {
        VStack {
            
            if let url = URL(string: url) {
                CacheAsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        ZStack {
                            Color(.systemGray6)
                            ProgressView()
                        }.frame(width: size.width, height: size.height)
                    case .success(let image):
                        image.resizable()
                            .scaledToFill()
                             .frame(width: size.width, height: size.height)
                             .clipped()
                    case .failure:
                        AsyncImage(url: url) { phase in
                            if let image = phase.image {
                                image
                                    .scaledToFill()
                                     .frame(width: size.width, height: size.height)
                                     .clipped()
                            } else{
                                ZStack{
                                    Color(.systemGray6)
                                    ProgressView()
                                }.frame(width: size.width, height: size.height)
                            }
                        }
                    @unknown default:
                        ZStack{
                            Color(.systemGray6)
                            ProgressView()
                        }.frame(width: size.width, height: size.height)
                    }
                }
            }else{
                ZStack{
                    Color(.systemGray6)
                    ProgressView()
                }.frame(width: size.width, height: size.height)
            }
        }
    }
}
