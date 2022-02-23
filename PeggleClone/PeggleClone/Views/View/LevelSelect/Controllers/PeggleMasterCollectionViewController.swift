import UIKit

private let reuseIdentifier = "PeggleMasterCell"
private let numOfSections = 1
private let itemsPerRow = 2
private let sectionInsets = UIEdgeInsets(
  top: 50.0,
  left: 20.0,
  bottom: 50.0,
  right: 20.0
)

class PeggleMasterCollectionViewController: UICollectionViewController, Storyboardable {
    var viewModel: PeggleMasterViewModel?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        // self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        // Do any additional setup after loading the view.
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        viewModel?.numberOfSections ?? 0
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel?.countForSection(section: section) ?? 0
    }

    override func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let cell = collectionView
                .dequeueReusableCell(
                    withReuseIdentifier: reuseIdentifier,
                    for: indexPath
                ) as? PeggleMasterCell else {
            fatalError("cast should succeed")
        }

        guard let viewModel = viewModel else {
            fatalError("should not be nil")
        }

        cell.viewModel = viewModel.getChildViewModel(for: indexPath.row)
        cell.setup()
        cell.delegate = self

        return cell
    }

}

// Reference: https://www.raywenderlich.com/18895088-uicollectionview-tutorial-getting-started

// MARK: - Collection View Flow Layout Delegate
extension PeggleMasterCollectionViewController: UICollectionViewDelegateFlowLayout {
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

extension PeggleMasterCollectionViewController: PeggleMasterCellDelegate {}
