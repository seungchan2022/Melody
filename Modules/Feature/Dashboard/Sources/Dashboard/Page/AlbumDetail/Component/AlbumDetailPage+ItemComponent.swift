import MusicKit
import SwiftUI

// MARK: - AlbumDetailPage.ItemComponent

extension AlbumDetailPage {
  struct ItemComponent {
    let viewState: ViewState
    let tapAction: () -> Void
  }
}

extension AlbumDetailPage.ItemComponent { }

// MARK: - AlbumDetailPage.ItemComponent + View

extension AlbumDetailPage.ItemComponent: View {
  var body: some View {
    Button(action: { tapAction() }) {
      VStack {
        HStack {
          Text(viewState.item.title)
            .lineLimit(1)

          Spacer()

          Text("\(viewState.item.duration?.asString ?? "")")
        }
        .foregroundColor(.primary)
        .font(.body)
        .padding(.horizontal, 16)
        .padding(.vertical, 4)

        Divider()
      }
    }
  }
}

// MARK: - AlbumDetailPage.ItemComponent.ViewState

extension AlbumDetailPage.ItemComponent {
  struct ViewState: Equatable {
    let item: Track
  }
}

extension TimeInterval {
  /// `TimeInterval`을 "mm:ss" 형식의 문자열로 변환
  fileprivate var asString: String {
    let minutes = Int(self) / 60
    let seconds = Int(self) % 60
    return String(format: "%d:%02d", minutes, seconds)
  }
}
