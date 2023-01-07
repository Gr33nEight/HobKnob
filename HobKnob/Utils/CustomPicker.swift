//
//  CustomPicker.swift
//  HobKnob
//
//  Created by Natanael Jop on 21/12/2022.
//

import SwiftUI

struct SizeAwareViewModifier: ViewModifier {
    
    @Binding private var viewSize: CGSize
    
    init(viewSize: Binding<CGSize>) {
        self._viewSize = viewSize
    }
    
    func body(content: Content) -> some View {
        content
            .background(BackgroundGeometryReader())
            .onPreferenceChange(SizePreferenceKey.self, perform: { if self.viewSize != $0 { self.viewSize = $0 }})
    }
}

// MARK: - SizePreferenceKey

struct SizePreferenceKey: PreferenceKey {
    typealias Value = CGSize
    static var defaultValue: CGSize = .zero
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = nextValue()
    }
}

// MARK: - BackgroundGeometryReader

struct BackgroundGeometryReader: View {
    var body: some View {
        GeometryReader { geometry in
            return Color
                .clear
                .preference(key: SizePreferenceKey.self, value: geometry.size)
        }
    }
}


struct CustomPicker: View {
    
    // MARK: - Variables
    
    private static let BackgroundColor: Color = Color(.systemGray6)
    private static let ShadowColor: Color = Color.black.opacity(0.2)
    private static let TextColor: Color = .accentColor
    private static let SelectedTextColor: Color = Color(.white)
    
    private static let TextFont: Font = .system(size: 14, weight: .semibold)
    
    private static let SegmentCornerRadius: CGFloat = 12
    private static let ShadowRadius: CGFloat = 4
    private static let SegmentXPadding: CGFloat = 16
    private static let SegmentYPadding: CGFloat = 8
    private static let PickerPadding: CGFloat = 4
    
    private static let AnimationDuration: Double = 0.25
    
    @State private var segmentSize: CGSize = .zero
    private var activeSegmentView: AnyView {
        let isInitialized: Bool = segmentSize != .zero
        if !isInitialized { return EmptyView().eraseToAnyView() }
        return RoundedRectangle(cornerRadius: CustomPicker.SegmentCornerRadius)
            .foregroundColor(
                .accentColor
            )
            .shadow(color: CustomPicker.ShadowColor, radius: CustomPicker.ShadowRadius)
            .frame(width: self.segmentSize.width, height: self.segmentSize.height)
            .offset(x: self.computeActiveSegmentHorizontalOffset(), y: 0)
            .animation(Animation.linear(duration: CustomPicker.AnimationDuration))
            .eraseToAnyView()
    }
    
    @Binding private var selection: Int
    private let items: [String]
    
    // MARK: - Init
    
    init(items: [String], selection: Binding<Int>) {
        self._selection = selection
        self.items = items
    }
    
    // MARK: - Body
    
    var body: some View {
        ZStack(alignment: .leading) {
            self.activeSegmentView
            HStack {
                ForEach(0..<self.items.count, id: \.self) { index in
                    self.getSegmentView(for: index)
                }
            }
        }
        .padding(CustomPicker.PickerPadding)
        .background(CustomPicker.BackgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: CustomPicker.SegmentCornerRadius))
    }
    
    // MARK: - Helper Functions
    
    private func computeActiveSegmentHorizontalOffset() -> CGFloat {
        CGFloat(self.selection) * (self.segmentSize.width + CustomPicker.SegmentXPadding / 2)
    }
    
    private func getSegmentView(for index: Int) -> some View {
        guard index < self.items.count else {
            return EmptyView().eraseToAnyView()
        }
        let isSelected = self.selection == index
        return Text(self.items[index])
            .font(CustomPicker.TextFont)
            .foregroundColor(isSelected ? CustomPicker.SelectedTextColor: CustomPicker.TextColor)
            .lineLimit(1)
            .padding(.vertical, CustomPicker.SegmentYPadding)
            .padding(.horizontal, CustomPicker.SegmentXPadding)
            .frame(minWidth: 0, maxWidth: .infinity)
            .modifier(SizeAwareViewModifier(viewSize: self.$segmentSize))
            .onTapGesture { self.onItemTap(index: index) }
            .eraseToAnyView()
    }
    
    private func onItemTap(index: Int) {
        guard index < self.items.count else {
            return
        }
        self.selection = index
    }
    
}
