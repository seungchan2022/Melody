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

            guard let album = response.items.first else { return }

            let albumTrack = try await album.with([.tracks])
            let trackItemList = albumTrack.tracks ?? []

            let result = MusicEntity.AlbumDetail.Track.Response(tracks: trackItemList)

            return promise(.success(result))

          } catch {
            return promise(.failure(.other(error)))
          }
        }
      }
      .eraseToAnyPublisher()
    }
  }

  public var relatedAlbum: (MusicEntity.AlbumDetail.RelatedAlbum.Request) -> AnyPublisher<
    MusicEntity.AlbumDetail.RelatedAlbum.Response,
    CompositeErrorRepository
  > {
    { req in
      Future<MusicEntity.AlbumDetail.RelatedAlbum.Response, CompositeErrorRepository> { promise in
        Task {
          do {
            let request = MusicCatalogResourceRequest<Album>(
              matching: \.id,
              equalTo: MusicItemID(rawValue: req.album.id.rawValue))

            let response = try await request.response()

            guard let detailedAlbum = try await response.items.first?.with([.artists]) else { return }

            let relatedArtist = try await detailedAlbum.artists?.first?.with([.albums])

            let albumList = relatedArtist?.albums ?? []

            let result = MusicEntity.AlbumDetail.RelatedAlbum.Response(albums: albumList)

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
