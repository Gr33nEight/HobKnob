//
//  NavigationBarViewModel.swift
//  HobKnob
//
//  Created by Natanael Jop on 17/11/2022.
//

import SwiftUI

class NavigationBarViewModel: ObservableObject {
    @Published var pickedView: NavigationOption = .home
    @Published var showBar = true
}
