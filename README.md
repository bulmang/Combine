# Combine
- [**Combine Framework**](#combine-framework)
- [Publisher의 Subscriber 종류](#publisher의-subscriber-종류)
  * [Convenience Publisher](#convenience-publisher)
    + [Just](#just)
    + [Promise](#promise)
    + [Fail](#fail)
    + [Empty](#empty)
    + [Sequence](#sequence)
  * [Framework 내장제공](#framework-내장제공)
- [Combine Code](#combine-code)
  + [예시 1 - 버튼을 눌러서 숫자 증가](#예시-1---버튼을-눌러서-숫자-증가)
    + [설명](#설명-1)
  + [예시 2 - Text를 입력받아 대문자로 변환하여 표시](#예시-2---text를-입력받아-대문자로-변환하여-표시)
    + [설명](#설명-2)
- [Combine을 쓰면 좋은 이유](#combine을-쓰면-좋은-이유)
  * [다른 비동기 처리 방식과의 차이점](#다른-비동기-처리-방식과의-차이점)
  * [Publisher를 이용한 코드 예시](#publisher를-이용한-코드-예시)
    + [설명](#설명-3)
    + [설명](#설명-4)
# **Combine Framework**

- 시간에 따라 값들을 처리하기 위한 선언적인 Swift API
- 시간에 따라 변할 수 있는 값으로 노출하기위해 `publisher`를 선언합니다
- `publisher`로부터 받아오기 위한 `subscriber`를 선언합니다.
- `publisher`는 시간에 따라 일련의 값을 전달할 수 있는 타입을 선언하며, 연산자를 사용하여 상위 발행자로부터 받은 값을 처리하고 다시 발행할 수 있습니다.
- `subscriber`는 `publisher`로부터 이벤트를 얼마나 빨리 받을지 제어 할 수 있습니다.
- 텍스트 필드의 업데이트와 URL 요청, 응 답 처리 등을 조율할 수 있습니다.
- 코드를 더 읽기 쉽고 유지 보수하기 쉽게 만들 수 있습니다.
- 이벤트 처리 코드를 중앙 집중화하여 중첩된 클로저 및 규약 기반 콜백과 같은 번거로운 기술을 제거할 수 있습니다.

`data`가 발행될때마다 `receiveValue`가 호출되고 데이터 스크림이 끝나게 되면 `receiveCompletion`이 호출

# Publisher의 Subscriber 종류

## Convenience Publisher

- 간단한 데이터 스트림을 생성하고 조작하는 데 사용.
- 예를 들어, 배열의 요소를 데이터 스트림으로 변환하거나 특정 시간 간격으로 이벤트를 생성하는데 유용

### Just

- 오직 하나의 값만 출력하고 끝나게 되는 가장 단순한 형태
- Combine Freamework에서 (Built-in) 형태로 제공하는 Publisher

### Promise

- Just와 비슷하지만 Filter Type을 정의 가능

### Fail

- 정의된 실패타입을 내보냄

### Empty

- 어떤 데이터도 발행하지 않는 퍼블리셔로 `error`, `optional` 값을 처리함

### Sequence

- 데이터를 순차적으로 발행하는 `Publisher`로 `(1…10).publisher`처럼 쓰임

## Framework 내장제공

- Foundation Farmework, Notification Center 처럼 프레임워크에서 직접적으로 제공하는 Provider는 개발자가 Subscribe만 구현하여 손쉽게 사용할 수 있음
- **`ObservableObject`**은 Combine 프레임워크의 기능을 활용하여 데이터의 변경을 처리하고 SwiftUI 뷰에 반영하는 역할을 함

# Combine Code

### 예시 1 - 버튼을 눌러서 숫자 증가

```swift
import SwiftUI
import Combine

class CounterViewModel: ObservableObject {
    @Published var count: Int = 0
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // Combine을 사용하여 count의 변경을 구독하고 처리
        $count
            .sink { newValue in
                print("Count changed to: \(newValue)")
            }
            .store(in: &cancellables)
    }
}

struct ContentView: View {
    @ObservedObject var viewModel = CounterViewModel()
    
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

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
```

### 설명

- `$count:`
    - Publisher로 생성된 count속성
    - **`@Published`** 속성 래퍼로 감싸져 있어서 데이터의 변경이 발생하면 Combine 프레임워크에서 Publisher로 변환
- `.sink:`
    - Combine에서 사용하는 구독(Subscription) 관련 연산자
- `.store:`
    - Combine에서 Subscription을 수동으로 해제하거나 취소하지 않고 Subscription을 수행하는 동안 유지하고 싶을 때 사용
    - Publisher 와 Subscriber간의 연결을 유지할때 사용
    - Subscription을 자동으로 해제하기 위해 .store사용 만약 해제하지않으면 메모리 누수 발생

### 예시 2 - Text를 입력받아 대문자로 변환하여 표시

```swift
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

struct ContentView: View {
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

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
```

### 설명

- **`.assign(to:on:)`**
    - Combine 프레임워크에서 사용되는 연산자로, Publisher에서 생성된 값을 특정 속성에 할당할 때 사용
    - 속성의 값이 변경될 때마다 값을 업데이트할 수 있도록 도우고 주로 뷰를 업데이트할때 사용
 # Combine을 쓰면 좋은 이유

- 아래 코드 예시는 로그인을 할때 userId와 userName을 가져올때 사용할 수 있는 코드이다.
- switch case를 사용하며 값이 두개 밖에 처리 할 것이 없을때는 사용 가능하겠지만 값이 점점 많아지고 복잡해지면 switch case를 이용해서 하기 어려워질 것이다.

```swift
func fetchUserId(_ completionHandler: @escaping (Result<Int, Error> ) -> Void){
    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
        let result = 24
        completionHandler(.success(result))
    }
}

func fetchName(for userId: Int,_ completionHandler: @escaping (Result<String, Error>) -> Void) {
    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
        let result = "Bulmang"
        completionHandler(.success((result)))
    }
}

func run() {
    fetchUserId { userIdResult in
        switch userIdResult {
        case .success(let userId):
            fetchName(for: userId) { nameResult in
                switch nameResult {
                case .success(let name):
                    print(name)
                case .failure(let failure):
                    // 실패 처리
                    break
                }
            }
        case .failure(let failure):
            // 실패 처리
            break
        }
    }
}
```

## 다른 비동기 처리 방식과의 차이점

| 특징 | "async/await" | "Combine" | RxSwift |
| --- | --- | --- | --- |
| 비동기 작업 처리 | 개별 비동기 함수 호출 | Publisher-Subscriber 모델 | Observable-Observer 모델 |
| 에러 처리 | 일반적인 try-catch 구문 사용 | sink 및 Operator에서 에러 처리 | onError 이벤트 핸들링 |
| 코드 구조 | 동기적인 코드와 유사함 | 비동기 스트림 및 데이터 흐름의 조작을 위한 연산자 활용 | 비동기 스트림 및 연산자 활용 |
| 간소화된 코드 작성 | 간결하고 직관적인 코드 작성 | 코드는 조금 더 길어질 수 있지만 강력한 연산자 활용 | 코드는 길어지지만 강력한 연산자 활용 |
| 복잡한 비동기 흐름 관리 | 일반적으로 한 번에 한 비동기 작업 처리 | 여러 비동기 작업의 조합, 복잡한 데이터 흐름 관리 | 여러 비동기 작업의 조합, 데이터 흐름 관리 |
| 적합한 사용 사례 | 간단한 비동기 작업 및 단일 비동기 호출 | 여러 비동기 작업의 관리, 데이터 스트림 처리 | 여러 비동기 작업의 관리, 데이터 스트림 처리 |
| 지원 범위 및 버전 | Swift 5.5 이상 | iOS 13 이상 | iOS 8 이상, macOS 10.10 이상 |

간단한 비동기 처리를 할때는 `**"async/await"**`가 좋다

하지만 여러 비동기 작업 관리와 데이터 스트림 처리를 하려면 `Combine`, `RxSwift` 이지만 SwiftUI에 더 효율성 있는 프레임워크는 `Combine` 이다.

## Publisher를 이용한 코드 예시

```swift
[1, 2, 3, 4, 5]
        .publisher
        .print()
        .filter { $0.isMultiple(of: 2) == false }
        .map { $0 * $0 }
        .sink { value in
            print(value)
        }
        .store(in: &cancel)
```

### 설명

- .print()를 사용하여 Debug를 쉽게 확인할 수 있다.
    
    ```swift
    출력 결과 : 
    receive value: (1)
    1
    receive value: (2)
    request max: (1) (synchronous)
    receive value: (3)
    9
    receive value: (4)
    request max: (1) (synchronous)
    receive value: (5)
    25
    receive finished
    ```
