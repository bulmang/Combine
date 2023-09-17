//
//  TestView.swift
//  Test_Combine
//
//  Created by 하명관 on 2023/09/15.
//

import SwiftUI

struct IncreaseNumberView: View {
    @ObservedObject var viewModel = CounterViewModel1()
    
    var body: some View {
        VStack {
            Text("Count: \(viewModel.count)")
            
            Button(action: {
                self.viewModel.count += 1
            }) {
                Text("Increment")
            }
        }
    }
}

struct TestView_Previews: PreviewProvider {
    static var previews: some View {
        IncreaseNumberView()
    }
}
class CounterViewModel1: ObservableObject {
    @Published var count: Int = 0
}



