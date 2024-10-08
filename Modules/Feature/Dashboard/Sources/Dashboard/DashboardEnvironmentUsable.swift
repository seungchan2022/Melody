import Architecture
import Domain

public protocol DashboardEnvironmentUsable {
  var toastViewModel: ToastViewActionType { get }
  var searchUseCase: SearchUseCase { get }
  var albumDetailUseCase: AlbumDetailUseCase { get }
  var subscriptionUseCase: SubscriptionUseCase { get }
}
