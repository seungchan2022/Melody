import DesignSystem
import MusicKit
import SwiftUI

// MARK: - AlbumDetailPage.RelatedAlbumComponent

extension AlbumDetailPage {
  struct RelatedAlbumComponent {
    let viewState: ViewState
    let tapAction: (Album) -> Void

  }
}

extension AlbumDetailPage.RelatedAlbumComponent { }

// MARK: - AlbumDetailPage.RelatedAlbumComponent + View

extension AlbumDetailPage.RelatedAlbumComponent: View {
  var body: some View {
    Button(action: { tapAction(viewState.item) }) {
      VStack {
        Spacer()

        HStack {
          if let existingArtwork = viewState.item.artwork {
            VStack {
              Spacer()
              ArtworkImage(existingArtwork, width: 56)
                .cornerRadius(6)
              Spacer()
            }
          }
          VStack(alignment: .leading) {
            Text(viewState.item.title)
              .lineLimit(1)
              .foregroundColor(.primary)

            Text(viewState.item.artistName)
              .lineLimit(1)
              .foregroundColor(.secondary)
              .padding(.top, -4.0)
          }

          Spacer()

          Image(systemName: "chevron.right")
            .fontWeight(.bold)
            .foregroundStyle(DesignSystemColor.palette(.gray(.lv400)).color)
        }
        .padding(.horizontal, 16)

        Spacer()

        Divider()
          .padding(.leading, 76)

        Spacer()
      }
    }
  }
}

// MARK: - AlbumDetailPage.RelatedAlbumComponent.ViewState

extension AlbumDetailPage.RelatedAlbumComponent {
  struct ViewState: Equatable {
    let item: Album
  }
}
