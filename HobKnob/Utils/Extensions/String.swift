//
//  String.swift
//  HobKnob
//
//  Created by Natanael Jop on 30/11/2022.
//

import SwiftUI

extension String: Identifiable {
    public typealias ID = Int
    public var id: Int {
        return hash
    }
}
