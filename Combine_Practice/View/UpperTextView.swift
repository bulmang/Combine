import SwiftUI
import Combine

class UserViewModel: ObservableObject {
    @Published var userInput: String = ""
    @Published private(set) var formattedInput: String = ""
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // 사용자 입력이 변경될 때마다 대문자로 변환하여 formattedInput에 할당
        $userInput
            .map { $0.uppercased() }
            .assign(to: \.formattedInput, on: self)
            .store(in: &cancellables)
    }
}

struct UpperTextView: View {
    @ObservedObject private var viewModel = UserViewModel()
    
    var body: some View {
        VStack {
            TextField("Enter your name", text: $viewModel.userInput)
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            Text("Hello, \(viewModel.formattedInput)")
                .padding()
        }
        .padding()
    }
}

struct UpperTextView_Previews: PreviewProvider {
    static var previews: some View {
        UpperTextView()
    }
}
