import UIKit
import Combine

protocol PeggleMasterCellViewModelDelegate: AnyObject {}

class PeggleMasterCellViewModel {
    weak var delegate: PeggleMasterCellViewModelDelegate?
    
    @Published private(set) var name: String?
    @Published private(set) var portrait: UIImage?
    
    init(name: String) {
        self.name = name
        DispatchQueue.global().async {
            let image = UIImage(named: "\(name)_ougon")
            DispatchQueue.main.async {
                self.portrait = image
            }
        }
    }
}
