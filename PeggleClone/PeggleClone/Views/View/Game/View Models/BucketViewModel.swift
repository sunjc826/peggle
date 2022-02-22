import Foundation
import CoreGraphics
import Combine

protocol BucketViewModelDelegate: AnyObject, CoordinateMappable {}

class BucketViewModel {
    weak var delegate: BucketViewModelDelegate?
    var bucket: Bucket
    var displayFrame: CGRect {
        guard let delegate = delegate else {
            fatalError("should not be nil")
        }

        return CGRect(
            x: 0,
            y: 0,
            width: delegate.getDisplayLength(of: bucket.boundingBox.width),
            height: delegate.getDisplayLength(of: bucket.boundingBox.height)
        )
    }
    var displayCoordsPublisher: AnyPublisher<CGPoint, Never> {
        bucket.$position.map { [weak self] logicalCoords in
            guard let self = self, let delegate = self.delegate else {
                fatalError("should not be nil")
            }

            return delegate.getDisplayCoords(of: logicalCoords)
        }.eraseToAnyPublisher()
    }

    init(bucket: Bucket) {
        self.bucket = bucket
    }
}
