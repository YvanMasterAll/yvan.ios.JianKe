//
//  TabView.swift
//  TabPageViewController
//
//  Created by EndouMari on 2016/02/24.
//  Copyright © 2016年 EndouMari. All rights reserved.
//

import UIKit

public class TabView: UIView {
    
    var pageItemPressedBlock: ((_ index: Int, _ direction: UIPageViewControllerNavigationDirection) -> Void)?
    var pageTabItems: [String] = [] {
        didSet {
            pageTabItemsCount = pageTabItems.count
            beforeIndex = pageTabItems.count
        }
    }
    var layouted: Bool = false
    
    fileprivate var option: TabPageOption = TabPageOption()
    fileprivate var beforeIndex: Int = 0
    fileprivate var currentIndex: Int = 0
    fileprivate var pageTabItemsCount: Int = 0
    fileprivate var shouldScrollToItem: Bool = false
    fileprivate var shouldTabBarScroll: Bool = true
    fileprivate var pageTabItemsWidth: CGFloat = 0.0
    fileprivate var collectionViewContentOffsetX: CGFloat = 0.0
    fileprivate var currentBarViewWidth: CGFloat = 0.0
    fileprivate var cellForSize: TabCollectionCell!
    fileprivate var cachedCellSizes: [IndexPath: CGSize] = [:]
    fileprivate var currentBarViewLeftConstraint: NSLayoutConstraint?
    
    @IBOutlet var contentView: UIView!
    @IBOutlet fileprivate weak var collectionView: UICollectionView!
    @IBOutlet fileprivate weak var currentBarView: UIView!
    @IBOutlet fileprivate weak var currentBarViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet fileprivate weak var currentBarViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet fileprivate weak var bottomBarViewHeightConstraint: NSLayoutConstraint!
    
    init(option: TabPageOption) {
        super.init(frame: CGRect.zero)
        
        self.option = option
        Bundle(for: TabView.self).loadNibNamed("TabView", owner: self, options: nil)
        addSubview(contentView)
        contentView.backgroundColor = option.tabBackgroundColor.withAlphaComponent(option.tabBarAlpha)
        
        let top = NSLayoutConstraint(item: contentView,
                                     attribute: .top,
                                     relatedBy: .equal,
                                     toItem: self,
                                     attribute: .top,
                                     multiplier: 1.0,
                                     constant: 0.0)
        
        let left = NSLayoutConstraint(item: contentView,
                                      attribute: .leading,
                                      relatedBy: .equal,
                                      toItem: self,
                                      attribute: .leading,
                                      multiplier: 1.0,
                                      constant: 0.0)
        
        let bottom = NSLayoutConstraint (item: self,
                                         attribute: .bottom,
                                         relatedBy: .equal,
                                         toItem: contentView,
                                         attribute: .bottom,
                                         multiplier: 1.0,
                                         constant: 0.0)
        
        let right = NSLayoutConstraint(item: self,
                                       attribute: .trailing,
                                       relatedBy: .equal,
                                       toItem: contentView,
                                       attribute: .trailing,
                                       multiplier: 1.0,
                                       constant: 0.0)
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        self.addConstraints([top, left, bottom, right])
        
        let bundle = Bundle(for: TabView.self)
        let nib = UINib(nibName: TabCollectionCell.cellIdentifier(), bundle: bundle)
        collectionView.register(nib, forCellWithReuseIdentifier: TabCollectionCell.cellIdentifier())
        cellForSize = nib.instantiate(withOwner: nil, options: nil).first as! TabCollectionCell
        
        collectionView.scrollsToTop = false
        
        currentBarView.backgroundColor = option.currentColor
        currentBarViewHeightConstraint.constant = option.currentBarHeight
        currentBarView.removeFromSuperview()
        collectionView.addSubview(currentBarView)
        currentBarView.translatesAutoresizingMaskIntoConstraints = false
        let top2 = NSLayoutConstraint(item: currentBarView,
                                     attribute: .top,
                                     relatedBy: .equal,
                                     toItem: collectionView,
                                     attribute: .top,
                                     multiplier: 1.0,
                                     constant: option.tabHeight - currentBarViewHeightConstraint.constant)
        
        let left2 = NSLayoutConstraint(item: currentBarView,
                                      attribute: .leading,
                                      relatedBy: .equal,
                                      toItem: collectionView,
                                      attribute: .leading,
                                      multiplier: 1.0,
                                      constant: 0.0)
        currentBarViewLeftConstraint = left2
        collectionView.addConstraints([top2, left2])
        
        bottomBarViewHeightConstraint.constant = 1.0 / UIScreen.main.scale
    }
    
    open func initOption(option: TabPageOption) {
        self.option = option
        Bundle(for: TabView.self).loadNibNamed("TabView", owner: self, options: nil)
        addSubview(contentView)
        contentView.backgroundColor = option.tabBackgroundColor.withAlphaComponent(option.tabBarAlpha)
        
        let top = NSLayoutConstraint(item: contentView,
                                     attribute: .top,
                                     relatedBy: .equal,
                                     toItem: self,
                                     attribute: .top,
                                     multiplier: 1.0,
                                     constant: 0.0)
        
        let left = NSLayoutConstraint(item: contentView,
                                      attribute: .leading,
                                      relatedBy: .equal,
                                      toItem: self,
                                      attribute: .leading,
                                      multiplier: 1.0,
                                      constant: 0.0)
        
        let bottom = NSLayoutConstraint (item: self,
                                         attribute: .bottom,
                                         relatedBy: .equal,
                                         toItem: contentView,
                                         attribute: .bottom,
                                         multiplier: 1.0,
                                         constant: 0.0)
        
        let right = NSLayoutConstraint(item: self,
                                       attribute: .trailing,
                                       relatedBy: .equal,
                                       toItem: contentView,
                                       attribute: .trailing,
                                       multiplier: 1.0,
                                       constant: 0.0)
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        self.addConstraints([top, left, bottom, right])
        
        let bundle = Bundle(for: TabView.self)
        let nib = UINib(nibName: TabCollectionCell.cellIdentifier(), bundle: bundle)
        collectionView.register(nib, forCellWithReuseIdentifier: TabCollectionCell.cellIdentifier())
        cellForSize = nib.instantiate(withOwner: nil, options: nil).first as! TabCollectionCell
        
        collectionView.scrollsToTop = false
        
        currentBarView.backgroundColor = option.currentColor
        currentBarViewHeightConstraint.constant = option.currentBarHeight
        currentBarView.removeFromSuperview()
        collectionView.addSubview(currentBarView)
        currentBarView.translatesAutoresizingMaskIntoConstraints = false
        let top2 = NSLayoutConstraint(item: currentBarView,
                                     attribute: .top,
                                     relatedBy: .equal,
                                     toItem: collectionView,
                                     attribute: .top,
                                     multiplier: 1.0,
                                     constant: option.tabHeight - currentBarViewHeightConstraint.constant)
        
        let left2 = NSLayoutConstraint(item: currentBarView,
                                      attribute: .leading,
                                      relatedBy: .equal,
                                      toItem: collectionView,
                                      attribute: .leading,
                                      multiplier: 1.0,
                                      constant: 0.0)
        currentBarViewLeftConstraint = left2
        collectionView.addConstraints([top2, left2])
        
        bottomBarViewHeightConstraint.constant = 1.0 / UIScreen.main.scale
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}


// MARK: - View

extension TabView {
    
    /**
     Called when you swipe in isInfinityTabPageViewController, moves the contentOffset of collectionView
     
     - parameter index: Next Index
     - parameter contentOffsetX: contentOffset.x of scrollView of isInfinityTabPageViewController
     */
    func scrollCurrentBarView(contentOffsetX: CGFloat) {
        guard self.shouldTabBarScroll else { return }
        
        let currentIndexPath = IndexPath(item: currentIndex, section: 0)
        let currentCell = collectionView.cellForItem(at: currentIndexPath) as? TabCollectionCell
        currentBarViewLeftConstraint?.constant = contentOffsetX * (currentCell?.frame.width)!
    }
    func scrollCurrentBarView(_ index: Int, contentOffsetX: CGFloat) {
        let nextIndex = index

        if collectionViewContentOffsetX == 0.0 {
            collectionViewContentOffsetX = collectionView.contentOffset.x
        }

        let currentIndexPath = IndexPath(item: currentIndex, section: 0)
        let nextIndexPath = IndexPath(item: nextIndex, section: 0)
        if let currentCell = collectionView.cellForItem(at: currentIndexPath) as? TabCollectionCell, let nextCell = collectionView.cellForItem(at: nextIndexPath) as? TabCollectionCell {
            nextCell.hideCurrentBarView()
            currentCell.hideCurrentBarView()
            currentBarView.isHidden = false

            if currentBarViewWidth == 0.0 {
                currentBarViewWidth = currentCell.frame.width
            }

            let scrollRate = contentOffsetX / frame.width

            if fabs(scrollRate) > 0.6 {
                nextCell.highlightTitle()
                currentCell.unHighlightTitle()
            } else {
                nextCell.unHighlightTitle()
                currentCell.highlightTitle()
            }

            let width = fabs(scrollRate) * (nextCell.frame.width - currentCell.frame.width)
            if scrollRate > 0 {
                currentBarViewLeftConstraint?.constant = currentCell.frame.minX + scrollRate * currentCell.frame.width
            } else {
                currentBarViewLeftConstraint?.constant = currentCell.frame.minX + nextCell.frame.width * scrollRate
            }
            currentBarViewWidthConstraint.constant = currentBarViewWidth + width
        }
    }
    
    /**
     Center the current cell after page swipe
     */
    func scrollToHorizontalCenter() {
        let indexPath = IndexPath(item: currentIndex, section: 0)
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
        collectionViewContentOffsetX = collectionView.contentOffset.x
    }
    
    /**
     Called in after the transition is complete pages in isInfinityTabPageViewController in the process of updating the current
     
     - parameter index: Next Index
     */
    func updateCurrentIndex(_ index: Int, shouldScroll: Bool) {
        deselectVisibleCells()
        
        currentIndex = index
        
        let indexPath = IndexPath(item: currentIndex, section: 0)
        moveCurrentBarView(indexPath, animated: true, shouldScroll: shouldScroll)
    }
    /**
     Make the tapped cell the current if isInfinity is true
     
     - parameter index: Next IndexPath√
     */
    fileprivate func updateCurrentIndexForTap(_ index: Int) {
        deselectVisibleCells()
        
        currentIndex = index
        let indexPath = IndexPath(item: index, section: 0)
        moveCurrentBarView(indexPath, animated: true, shouldScroll: true)
    }
    
    /**
     Move the collectionView to IndexPath of Current
     
     - parameter indexPath: Next IndexPath
     - parameter animated: true when you tap to move the isInfinityTabCollectionCell
     - parameter shouldScroll:
     */
    fileprivate func moveCurrentBarView(_ indexPath: IndexPath, animated: Bool, shouldScroll: Bool) {
        if shouldScroll {
            collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: animated)
            layoutIfNeeded()
            collectionViewContentOffsetX = 0.0
            currentBarViewWidth = 0.0
        }
        if let cell = collectionView.cellForItem(at: indexPath) as? TabCollectionCell {
            currentBarView.isHidden = false
            if animated && shouldScroll {
                cell.isCurrent = true
            }
            cell.hideCurrentBarView()
            currentBarViewWidthConstraint.constant = cell.frame.width
            currentBarViewLeftConstraint?.constant = cell.frame.origin.x
            self.shouldTabBarScroll = false
            UIView.animate(withDuration: 0.2, animations: {
                self.layoutIfNeeded()
            }, completion: { [weak self] _ in
                self?.shouldTabBarScroll = true
                if !animated && shouldScroll {
                    cell.isCurrent = true
                }
                
                self?.updateCollectionViewUserInteractionEnabled(true)
            })
        }
        beforeIndex = currentIndex
    }
    
    /**
     Touch event control of collectionView
     
     - parameter userInteractionEnabled: collectionViewに渡すuserInteractionEnabled
     */
    func updateCollectionViewUserInteractionEnabled(_ userInteractionEnabled: Bool) {
        collectionView.isUserInteractionEnabled = userInteractionEnabled
    }
    
    /**
     Update all of the cells in the display to the unselected state
     */
    fileprivate func deselectVisibleCells() {
        collectionView
            .visibleCells
            .flatMap { $0 as? TabCollectionCell }
            .forEach { $0.isCurrent = false }
    }
}


// MARK: - UICollectionViewDataSource

extension TabView: UICollectionViewDataSource {
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pageTabItemsCount
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TabCollectionCell.cellIdentifier(), for: indexPath) as! TabCollectionCell
        configureCell(cell, indexPath: indexPath)
        return cell
    }
    
    fileprivate func configureCell(_ cell: TabCollectionCell, indexPath: IndexPath) {
        let fixedIndex = indexPath.item
        cell.item = pageTabItems[fixedIndex]
        cell.option = option
        cell.isCurrent = fixedIndex == (currentIndex % pageTabItemsCount)
        cell.tabItemButtonPressedBlock = { [weak self] () -> Void in
            var direction: UIPageViewControllerNavigationDirection = .forward
            if let _ = self?.pageTabItemsCount, let currentIndex = self?.currentIndex {
                if indexPath.item < currentIndex {
                    direction = .reverse
                }
            }
            self?.pageItemPressedBlock?(fixedIndex, direction)
            if cell.isCurrent == false {
                // Not accept touch events to scroll the animation is finished
                self?.updateCollectionViewUserInteractionEnabled(false)
            }
            self?.updateCurrentIndexForTap(indexPath.item)
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        // FIXME: Tabs are not displayed when processing is performed during introduction display
        if let cell = cell as? TabCollectionCell, layouted {
            let fixedIndex = indexPath.item
            cell.isCurrent = fixedIndex == (currentIndex % pageTabItemsCount)
        }
    }
}


// MARK: - UIScrollViewDelegate

extension TabView: UICollectionViewDelegate {
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.isDragging {
            currentBarView.isHidden = true
            let indexPath = IndexPath(item: currentIndex, section: 0)
            if let cell = collectionView.cellForItem(at: indexPath) as? TabCollectionCell {
                cell.showCurrentBarView()
            }
        }
        
    }
    
    public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        // Accept the touch event because animation is complete
        updateCollectionViewUserInteractionEnabled(true)

    }
}


// MARK: - UICollectionViewDelegateFlowLayout

extension TabView: UICollectionViewDelegateFlowLayout {
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if let size = cachedCellSizes[indexPath] {
            return size
        }
        
        configureCell(cellForSize, indexPath: indexPath)
        
        let size = cellForSize.sizeThatFits(CGSize(width: collectionView.bounds.width, height: option.tabHeight))
        cachedCellSizes[indexPath] = size
        
        return size
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
}

