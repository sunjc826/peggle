import Foundation
import CoreGraphics
import Combine

protocol BucketViewModelDelegate: AnyObject, CoordinateMappable {}

class BucketViewModel {
    weak var delegate: BucketViewModelDelegate? {
        didSet {
            setupBindings()
        }
    }
    private var subscriptions: Set<AnyCancellable> = []
    var bucketPublisher: AnyPublisher<Bucket?, Never>
    var displayFramePublisher: AnyPublisher<CGRect, Never> {
        displayFrame.compactMap { $0 }.eraseToAnyPublisher()
    }

    private var displayFrame: CurrentValueSubject<CGRect?, Never> = CurrentValueSubject(nil)
    var displayCoordsPublisher: AnyPublisher<CGPoint, Never> {
        displayCoords.eraseToAnyPublisher()
    }
    private var displayCoords: PassthroughSubject<CGPoint, Never> = PassthroughSubject()

    init(bucketPublisher: AnyPublisher<Bucket?, Never>) {
        self.bucketPublisher = bucketPublisher

    }
    func setupBindings() {
        bucketPublisher
            .compactMap { $0 }
            .sink { [weak self] bucket in
                guard let self = self else {
                    return
                }

                guard let delegate = self.delegate else {
                    fatalError("should not be nil")
                }

                self.displayFrame.send(CGRect(
                    x: 0,
                    y: 0,
                    width: delegate.getDisplayLength(of: bucket.boundingBox.width),
                    height: delegate.getDisplayLength(of: bucket.boundingBox.height)
                ))
                self.setupBindingsWithBucket(bucket)
            }
            .store(in: &subscriptions)
    }

    func setupBindingsWithBucket(_ bucket: Bucket) {
        bucket.$position.sink { [weak self] logicalCoords in
            guard let self = self else {
                return
            }
            guard let delegate = self.delegate else {
                fatalError("should not be nil")
            }
            self.displayCoords.send(delegate.getDisplayCoords(of: logicalCoords))
        }
        .store(in: &subscriptions)
    }
}
