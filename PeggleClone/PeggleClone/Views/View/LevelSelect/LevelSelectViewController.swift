import UIKit
import Combine

private let reuseIdentifier = "LevelSelectCell"
private let unwindIdentifier = "segueUnwind"
private let numOfSections = 1
private let itemsPerRow = 3
private let sectionInsets = UIEdgeInsets(
  top: 50.0,
  left: 20.0,
  bottom: 50.0,
  right: 20.0
)

/// Controls the level select screen.
class LevelSelectViewController: UICollectionViewController, Storyboardable {
    var viewModel: LevelSelectViewModel?
    private var subscriptions: Set<AnyCancellable> = []

    var didLoadLevel: ((URL) -> Void)?
    var didStartLevel: ((URL) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()

        setupBindings()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        //  self.collectionView!.register(LevelSelectCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        // Do any additional setup after loading the view.
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        numOfSections
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let viewModel = viewModel else {
            fatalError("should not be nil")
        }

        return viewModel.count
    }

    override func collectionView(_ collectionView: UICollectionView,
                                 cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: reuseIdentifier,
            for: indexPath) as? LevelSelectCell else {
            fatalError("Expect cast to succeed")
        }

        guard let viewModel = viewModel else {
            fatalError("should not be nil")
        }

        let index = indexPath.row
        cell.viewModel = viewModel.getChildViewModel(for: index)
        cell.setup()
        cell.delegate = self
        return cell
    }

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(
     _ collectionView: UICollectionView,
     shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu
    // should be displayed for the specified item,
    // and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView,
     shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView,
     canPerformAction action: Selector, forItemAt indexPath: IndexPath,
     withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView,
     performAction action: Selector, forItemAt indexPath: IndexPath,
     withSender sender: Any?) {
    
    }
    */

}

// Reference: https://www.raywenderlich.com/18895088-uicollectionview-tutorial-getting-started

// MARK: - Collection View Flow Layout Delegate
extension LevelSelectViewController: UICollectionViewDelegateFlowLayout {
  func collectionView(
    _ collectionView: UICollectionView,
    layout collectionViewLayout: UICollectionViewLayout,
    sizeForItemAt indexPath: IndexPath
  ) -> CGSize {
    let paddingSpace = sectionInsets.left * Double(itemsPerRow + 1)
    let availableWidth = view.frame.width - paddingSpace
    let widthPerItem = availableWidth / Double(itemsPerRow)

    return CGSize(width: widthPerItem, height: widthPerItem)
  }

  func collectionView(
    _ collectionView: UICollectionView,
    layout collectionViewLayout: UICollectionViewLayout,
    insetForSectionAt section: Int
  ) -> UIEdgeInsets {
    sectionInsets
  }

  func collectionView(
    _ collectionView: UICollectionView,
    layout collectionViewLayout: UICollectionViewLayout,
    minimumLineSpacingForSectionAt section: Int
  ) -> CGFloat {
    sectionInsets.left
  }
}

extension LevelSelectViewController: LevelSelectCellDelegate {
    func onLoadLevel(levelURL: URL) {
        didLoadLevel?(levelURL)
    }

    func onStartLevel(levelURL: URL) {
        didStartLevel?(levelURL)
    }
}

// MARK: Setup
extension LevelSelectViewController {
    func setupBindings() {
        viewModel?.$shouldReload
            .sink { [weak self] shouldReload in
                guard let self = self, shouldReload else {
                    return
                }

                self.collectionView.reloadData()
            }
            .store(in: &subscriptions)
    }
}
