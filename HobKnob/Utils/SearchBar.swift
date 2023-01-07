//
//  SearchBar.swift
//  HobKnob
//
//  Created by Natanael Jop on 17/11/2022.
//

import SwiftUI
 
struct CustomSearchBar: View {
    
    let placeholder: String
    @Binding var text: String
    
    var body: some View {
        HStack{
            Image(systemName: "magnifyingglass")
                .foregroundColor(Color(.systemGray3))
            ZStack(alignment: .leading){
                if text.isEmpty{
                    Text(placeholder)
                        .lineLimit(1)
                        .foregroundColor(Color(.systemGray4))
                }
                TextField("", text: $text)
                    .disableAutocorrection(true)
                    .autocapitalization(.none)
                
            }
            Spacer()
        }.padding()
            .background(
                ZStack{
                    Color(.systemGray6)
                        .cornerRadius(20)
                        .frame(height: 50)
                }
            )
    }
}

struct Preview: PreviewProvider {
    static var previews: some View {
        CustomSearchBar(placeholder: "Search...", text: .constant(""))
    }
}
