import DesignSystem
import Domain
import MusicKit
import SwiftUI

// MARK: - HomePage.ItemComponent

extension HomePage {
  struct ItemComponent {
    let viewState: ViewState
    let tapAction: (Album) -> Void
  }
}

extension HomePage.ItemComponent { }

// MARK: - HomePage.ItemComponent + View

extension HomePage.ItemComponent: View {
  var body: some View {
    Button(action: { tapAction(viewState.item) }) {
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
    }
  }
}

// MARK: - HomePage.ItemComponent.ViewState

extension HomePage.ItemComponent {
  struct ViewState: Equatable {
    let item: Album
  }
}
