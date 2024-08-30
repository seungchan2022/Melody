import ComposableArchitecture
import DesignSystem
import Functor
import MusicKit
import SwiftUI

// MARK: - HomePage

struct HomePage {
  @Bindable var store: StoreOf<HomeReducer>

  @State private var musicAuthorizationStatus: MusicAuthorization.Status = .notDetermined
  @State private var isWelcomeViewPresented = false
  @State var throttleEvent: ThrottleEvent = .init(value: "", delaySeconds: 1.5)

  @Environment(\.openURL) private var openURL
}

extension HomePage {
  /// 버튼에 표시될 텍스트를 반환
  private var buttonText: String {
    switch musicAuthorizationStatus {
    case .notDetermined:
      return "계속"
    case .denied:
      return "설정 열기"
    default:
      return ""
    }
  }

  private var permissionDescription: String? {
    switch musicAuthorizationStatus {
    case .denied:
      return "설정에서 해당 앱에 대한 접근 권한을 부여하세요."

    default:
      return ""
    }
  }

  /// 현재 권한 상태 확인
  private func checkMusicAuthorizationStatus() {
    Task {
      let status = MusicAuthorization.currentStatus
      musicAuthorizationStatus = status

      /// 권한이 부여되지 않은 경우, WelcomePage를 표시합니다.
      if status != .authorized {
        isWelcomeViewPresented = true
      }
    }
  }

  /// 권한 요청 또는 설정 열기 처리
  private func handleButtonPressed() {
    switch musicAuthorizationStatus {
    case .notDetermined:
      Task {
        /// 권한 요청
        let status = await MusicAuthorization.request()
        musicAuthorizationStatus = status

        if status == .authorized {
          /// 권한이 허용되면 시트를 닫고 앱을 정상적으로 실행합니다.
          isWelcomeViewPresented = false
        }
      }

    case .denied:
      if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
        openURL(settingsURL)
      }

    default:
      /// 이 경우에는 버튼이 표시되지 않아야 하므로, 이 부분이 호출되면 문제가 발생한 것임
      fatalError("현재 권한 상태에 대해 버튼이 표시되지 않아야 합니다: \(musicAuthorizationStatus).")
    }
  }

}

// MARK: View

extension HomePage: View {
  var body: some View {
    ScrollView {
      LazyVStack {
        if store.query.isEmpty {
          VStack(spacing: 32) {
            Image(systemName: "magnifyingglass.circle")
              .resizable()
              .fontWeight(.thin)
              .frame(width: 150, height: 150)

            Text("찾고 싶은 앨범을 검색해주세요.")
              .font(.body)
          }
          .padding(.top, 120)
        }

        ForEach(store.itemList, id: \.id) { item in

          ItemComponent(
            viewState: .init(item: item),
            tapAction: { store.send(.routeToDetail($0)) })
        }
      }
    }
    .sheet(isPresented: $isWelcomeViewPresented) {
      /// 권한 설정 View
      VStack {
        Text("Welcome Page")
          .font(.largeTitle)
          .padding()

        Text("이 앱은 Apple Music 데이터를 사용합니다. 계속하려면 권한을 허용하세요.")
          .multilineTextAlignment(.center)
          .padding()

        if let permissionDescription = self.permissionDescription {
          Text(permissionDescription)
        }

        Button(action: handleButtonPressed) {
          Text(buttonText)
            .font(.callout)
            .padding(4)
        }
        .buttonStyle(.borderedProminent)
      }
      .interactiveDismissDisabled()
    }
    .scrollDismissesKeyboard(.immediately)
    .searchable(
      text: $store.query,
      placement: .navigationBarDrawer(displayMode: .always),
      prompt: "Albums")
    .navigationTitle("Home")
    .navigationBarTitleDisplayMode(.large)
    .onChange(of: store.query) { _, new in
      throttleEvent.update(value: new)
    }
    .onAppear {
      /// checkMusicAuthorizationStatus()를 호출하여 현재 Apple Music 권한 상태를 확인합니다.
      checkMusicAuthorizationStatus()
      throttleEvent.apply { _ in
        store.send(.search(store.query))
      }
    }
    .onDisappear {
      throttleEvent.reset()
      store.send(.teardown)
    }
  }
}
