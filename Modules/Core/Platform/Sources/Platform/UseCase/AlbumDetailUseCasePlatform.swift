import Combine
import Domain
import MusicKit

// MARK: - AlbumDetailUseCasePlatform

public struct AlbumDetailUseCasePlatform {
  public init() { }
}

// MARK: AlbumDetailUseCase

extension AlbumDetailUseCasePlatform: AlbumDetailUseCase {
  public var track: (MusicEntity.AlbumDetail.Track.Request) -> AnyPublisher<
    MusicEntity.AlbumDetail.Track.Response,
    CompositeErrorRepository
  > {
    { req in
      Future<MusicEntity.AlbumDetail.Track.Response, CompositeErrorRepository> { promise in

        Task {
          do {
            let request = MusicCatalogResourceRequest<Album>(
              matching: \.id,
              equalTo: MusicItemID(rawValue: req.album.id.rawValue))

            let response = try await request.response()

            guard let playList = response.items.first else { return }

            let detailedPlayList = try await playList.with([.tracks])
            let tracks = detailedPlayList.tracks ?? []

            let result = MusicEntity.AlbumDetail.Track.Response(tracks: tracks)

            return promise(.success(result))

          } catch {
            return promise(.failure(.other(error)))
          }
        }
      }
      .eraseToAnyPublisher()
    }
  }
}
