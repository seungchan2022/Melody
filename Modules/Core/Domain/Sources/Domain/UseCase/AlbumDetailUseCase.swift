import Combine

public protocol AlbumDetailUseCase {
  var track: (MusicEntity.AlbumDetail.Track.Request) -> AnyPublisher<
    MusicEntity.AlbumDetail.Track.Response,
    CompositeErrorRepository
  > { get }

  var relatedAlbum: (MusicEntity.AlbumDetail.RelatedAlbum.Request) -> AnyPublisher<
    MusicEntity.AlbumDetail.RelatedAlbum.Response,
    CompositeErrorRepository
  > { get }
}
