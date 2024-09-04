import DesignSystem
import MusicKit
import SwiftUI

// MARK: - AlbumDetailPage.TrackComponent

extension AlbumDetailPage {
  struct TrackComponent {
    let viewState: ViewState
    let tapAction: () -> Void
  }
}

extension AlbumDetailPage.TrackComponent {
  private var songDuration: String {
    TimeFormatter.format(viewState.item.duration ?? .zero)
  }
}

// MARK: - AlbumDetailPage.TrackComponent + View

extension AlbumDetailPage.TrackComponent: View {
  var body: some View {
    Button(action: { tapAction() }) {
      VStack {
        Spacer()

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

        Spacer()

        Divider()
      }
    }
  }
}

// MARK: - AlbumDetailPage.TrackComponent.ViewState

extension AlbumDetailPage.TrackComponent {
  struct ViewState: Equatable {
    let item: Track
  }
}
