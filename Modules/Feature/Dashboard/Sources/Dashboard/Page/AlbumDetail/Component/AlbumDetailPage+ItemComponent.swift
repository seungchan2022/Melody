import MusicKit
import SwiftUI
import DesignSystem

// MARK: - AlbumDetailPage.ItemComponent

extension AlbumDetailPage {
  struct ItemComponent {
    let viewState: ViewState
    let tapAction: () -> Void
  }
}

extension AlbumDetailPage.ItemComponent { 
  private var songDuration: String {
    TimeFormatter.format(viewState.item.duration ?? .zero)
  }
}

// MARK: - AlbumDetailPage.ItemComponent + View

extension AlbumDetailPage.ItemComponent: View {
  var body: some View {
    Button(action: { tapAction() }) {
      VStack {
        HStack {
          Text(viewState.item.title)
            .lineLimit(1)

          Spacer()

          Text(songDuration)
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
