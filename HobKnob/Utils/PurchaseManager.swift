//
//  PurchaseManager.swift
//  HobKnob
//
//  Created by Natanael Jop on 21/12/2022.
//

import SwiftUI
import Foundation
import StoreKit

@MainActor
class PurchaseManager: ObservableObject {

    static let shared = PurchaseManager()
    
    @State var isWaiting = false
    @State var errorService: ErrorService = .nul
    
    private let productIds = ["silver_id", "gold_id"]

    @Published private(set) var products: [Product] = []
    private var productsLoaded = false
    
    @Published private(set) var purchasedProdcutIDs = Set<String>()
    
    var hasFree: Bool {
        return self.purchasedProdcutIDs.isEmpty
    }
    
    var hasGold: Bool {
        return self.purchasedProdcutIDs.contains(productIds[1])
    }
    
    var hasSilver: Bool {
        return self.purchasedProdcutIDs.contains(productIds[0])
    }
    
    private var updates: Task<Void, Never>? = nil
    
    init() {
        updates = observeTransactionUpdates()
    }
    
    deinit {
        updates?.cancel()
    }
    
    private func observeTransactionUpdates() -> Task<Void, Never> {
        Task(priority: .background) { [unowned self] in
            for await _ in Transaction.updates {
                await self.updatePurchaseProducts()
            }
        }
    }
    
    func updatePurchaseProducts() async {
        for await result in Transaction.currentEntitlements {
            guard case .verified(let transaction) = result else {
                continue
            }
            
            if transaction.revocationDate == nil {
                self.purchasedProdcutIDs.insert(transaction.productID)
            } else {
                self.purchasedProdcutIDs.remove(transaction.productID)
            }
        }
    }

    func loadProducts() async throws {
        guard !self.productsLoaded else { return }
        self.products = try await Product.products(for: productIds)
        self.productsLoaded = true
    }

    func purchase(_ product: Product, completion: @escaping () -> Void) async throws {
        let result = try await product.purchase()

        switch result {
        case let .success(.verified(transaction)):
            await transaction.finish()
            await self.updatePurchaseProducts()
            completion()
        case let .success(.unverified(_, error)):
            self.errorService = .error(message: error.localizedDescription)
            break
        case .pending:
            self.isWaiting = true
            break
        case .userCancelled:
            self.errorService = .error(message: "Transaction Cancelled")
            break
        @unknown default:
            break
        }
    }
}


//struct Testing: View {
//    @EnvironmentObject var purchaseManager: PurchaseManager
//    var body: some View {
//        VStack(spacing: 20) {
//            Text("Products")
//            ForEach(purchaseManager.products) { product in
//                Button {
//                    Task {
//                        do {
//                            try await purchaseManager.purchase(product)
//                        } catch {
//                            print(error)
//                        }
//                    }
//                } label: {
//                    Text("\(product.displayPrice) - \(product.displayName)")
//                        .foregroundColor(.white)
//                        .padding()
//                        .background(.blue)
//                        .clipShape(Capsule())
//                }
//            }
//            Button {
//                Task {
//                    do {
//                        try await AppStore.sync()
//                    } catch {
//                        print(error)
//                    }
//                }
//            } label: {
//                Text("Resore Purchases")
//            }
//
//        }.task {
//            Task {
//                do {
//                    try await purchaseManager.loadProducts()
//                } catch {
//                    print(error)
//                }
//            }
//        }
//    }
//    
//}
