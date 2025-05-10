import UIKit

class PagedFlowLayout: UICollectionViewFlowLayout {
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint,
                                      withScrollingVelocity velocity: CGPoint) -> CGPoint {
        guard let collectionView = collectionView else {
            return super.targetContentOffset(forProposedContentOffset: proposedContentOffset,
                                             withScrollingVelocity: velocity)
        }

        let pageWidth = itemSize.width * 7 // 7 days per week
        let currentOffset = collectionView.contentOffset.x
        let targetOffset: CGFloat

        if velocity.x > 0 {
            targetOffset = ceil(currentOffset / pageWidth) * pageWidth
        } else if velocity.x < 0 {
            targetOffset = floor(currentOffset / pageWidth) * pageWidth
        } else {
            targetOffset = round(currentOffset / pageWidth) * pageWidth
        }

        return CGPoint(x: targetOffset, y: proposedContentOffset.y)
    }
}
