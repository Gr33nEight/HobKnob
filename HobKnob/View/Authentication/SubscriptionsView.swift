//
//  SubscriptionsView.swift
//  HobKnob
//
//  Created by Natanael Jop on 21/12/2022.
//

import SwiftUI
import StoreKit

struct SubscriptionModel: Identifiable {
    var id = UUID()
    var description: [String]
    var productName: String
}

class SubscriptionVieModel: ObservableObject {
    var sub: SubscriptionModel
    @ObservedObject var purchaseManager: PurchaseManager
    
    init(sub: SubscriptionModel, purchaseManager: PurchaseManager) {
        self.sub = sub
        self.purchaseManager = purchaseManager
    }
    
    var description: [String] {
        sub.description
    }
    
    var product: Product? {
        self.purchaseManager.products.first(where: {$0.displayName == sub.productName})
    }
    
    var productPrice: String {
        if let product = product {
            return product.displayPrice
        }else{
            return "Free"
        }
    }
    
    
    func purchase(completion: @escaping () -> Void) async {
        guard let product = product else {
            return
        }
        do {
            try await purchaseManager.purchase(product, completion: completion)
        } catch {
            purchaseManager.errorService = .error(message: error.localizedDescription)
        }
    }
    
}

struct SubscriptionsView: View {
    @EnvironmentObject var purchaseManager: PurchaseManager
    @ObservedObject var userVM: UserViewModel
    @State var seleceted = 0
    @State var pickedOption = ""
    
    var subscriptions = [
        SubscriptionModel(description: ["The match will only allow you to send pre-selected messages to the match until they add you as a friend.", "You will see only 5 matches in a 12 hour time frame.", "Ads"], productName: ""),
        SubscriptionModel(description: ["You will see 10 matches in 12 hours.", "The match will only allow you to send pre-selected messages to the match until they add you as a friend.", "Have hearts to connect with silver and gold members.", "Ads"], productName: "Silver"),
        SubscriptionModel(description: ["You will be able to see all matches.", "You will able to send one custom message before being added as a friend.", "Have hearts to connect with silver and gold members.", "No Ads."], productName: "Gold")
    ]
    var body: some View {
        CustomAuthView(title: "More ways to find new peoples", destination: {
            InterestsView(userVM: userVM)
        }, content: {
            CustomPicker(items: ["STANDARD", "SILVER", "GOLD"], selection: $seleceted)
                .padding()
            SubscriptionCard(subVM: SubscriptionVieModel(sub: subscriptions[seleceted], purchaseManager: purchaseManager), picked: $pickedOption)
            Button(action: {
                Task {
                    do {
                        try await AppStore.sync()
                    } catch {
                        print(error)
                    }
                }
            }) {
                Text("Restore Purchases")
            }
        })
    }
}

struct SubscriptionCard: View {
    @ObservedObject var subVM: SubscriptionVieModel
    @Binding var picked: String
    var body: some View {
        VStack {
            customList(subVM.description)
            Spacer()
            if picked == subVM.productPrice {
                ZStack {
                    Capsule()
                        .fill(Color(.systemGray5))
                    Text("Bought")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.accentColor)
                }.frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .padding(.horizontal, 10)
            }else{
                HStack {
                    Spacer()
                    Button(action: {
                        withAnimation(.spring()) {
                            if subVM.product != nil {
                                Task {
                                    await subVM.purchase {
                                        picked = subVM.productPrice
                                    }
                                }
                            }else{
                                picked = subVM.productPrice
                            }
                        }
                    }) {
                        Text("BUY NOW")
                            .foregroundColor(.white)
                            .font(.system(size: 20, weight: .semibold))
                            .padding(10)
                            .padding(.horizontal, 7)
                            .background(Capsule().fill(Color.accentColor).shadow(radius: 3, y: 3))
                    }.customButtonStyle()
                    Spacer()
                    Text(subVM.productPrice)
                        .foregroundColor(.label)
                        .font(.system(size: 35, weight: .semibold))
                    Spacer()
                }
            }
        }.padding(10)
            .padding(.vertical)
            .background(RoundedRectangle(cornerRadius: 15).fill(Color.reversedLabel))
            .padding(.horizontal, 30)
            .padding(.bottom, 10)
    }
    private func customList(_ points: [String]) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            ForEach(points, id: \.self) { point in
                HStack(alignment: .top, spacing: 15) {
                    Circle()
                        .fill(Color.accentColor)
                        .frame(width: 12, height: 12)
                        .padding(.top, 5)
                    Text(point)
                        .multilineTextAlignment(.leading)
                    Spacer(minLength: 0)
                }.padding(.horizontal, 10)
            }
        }
    }
}

struct SubscriptionsView_Previews: PreviewProvider {
    static var previews: some View {
        SubscriptionsView(userVM: UserViewModel()).environmentObject(PurchaseManager())
    }
}
