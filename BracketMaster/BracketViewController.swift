//
//  ViewController.swift
//  BracketMaster
//
//  Created by Brandon Jenniges on 10/19/17.
//  Copyright © 2017 BrandonJenniges. All rights reserved.
//

import AsyncDisplayKit
import RxSwift

class BracketViewController: ASViewController<ASDisplayNode> {
    
    let mainNode = BracketViewNode()
    lazy var pageSize: CGFloat = {
        CGFloat(self.view.bounds.size.width * self.mainNode.OFFSET_PERCENT)
    }()
    
    let currentPage: Variable<Int> = Variable(0)
    private let disposeBag = DisposeBag()
    
    let roundSize = [64, 32, 16, 8,4,2,1]
    lazy var rounds: [BracketRoundViewController] = {
        [BracketRoundViewController(matches: 64, bracketRoundDelgate: self), BracketRoundViewController(matches: 32, bracketRoundDelgate: self),BracketRoundViewController(matches: 16, bracketRoundDelgate: self),BracketRoundViewController(matches: 8, bracketRoundDelgate: self),  BracketRoundViewController(matches: 4, bracketRoundDelgate: self), BracketRoundViewController(matches: 2, bracketRoundDelgate: self), BracketRoundViewController(matches: 1, bracketRoundDelgate: self)]
    }()
    
    var translationX:CGFloat = 0
    var gest:UIPanGestureRecognizer?
    
    enum ScrollingDirection {
        case left, right
    }
    
    init() {
        super.init(node: self.mainNode)
        self.mainNode.pagerNode.dataSource = self
        self.mainNode.pagerNode.delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addPanGesture()
        self.setupCurrentPageObservable()
        
        DispatchQueue.main.async {
            let newActive = self.rounds[self.currentPage.value]
            self.roundDidChange(newActive, scrollView: newActive.mainNode.collectionNode.view)
        }
    }
    
    // MARK: -- Rx
    
    private func setupCurrentPageObservable() {
        self.currentPage.asObservable()
            .subscribe(onNext: {
                [weak self] currentPage in
                if let weakSelf = self {
                    weakSelf.updateActiveRound(with: currentPage)
                }
            })
            .addDisposableTo(disposeBag)
    }
    
    private func updateActiveRound(with currentPage: Int) {
        for (index, round) in self.rounds.enumerated() {
            if index == currentPage {
                round.viewingStatus.value = .current
            } else if index < currentPage {
                round.viewingStatus.value = .trailing
            } else {
                round.viewingStatus.value = .leading
            }
        }
    }
    
    // MARK: -- Gesture
    
    func addPanGesture(){
        gest = UIPanGestureRecognizer(target: self, action: #selector(self.panGestureHandler(panGesture:)))
        gest?.minimumNumberOfTouches = 1
        self.mainNode.pagerNode.view.addGestureRecognizer(gest!)
        
    }
    
    func panGestureHandler(panGesture recognizer: UIPanGestureRecognizer) {
        
        let translation = recognizer.translation(in: self.view)
        
        if  recognizer.state == .began {
            
            // Don't do anything if x is 0
            if translation.x == 0 {
                return
            }
            
            let newValue: Int
            if translation.x > 0 {
                if self.currentPage.value == 0 {
                    return
                }
                newValue = self.currentPage.value - 1
            } else {
                if self.currentPage.value == self.rounds.count - 1 {
                    return
                }
                newValue = self.currentPage.value + 1
            }
            
            self.currentPage.value = newValue
            let newActive = self.rounds[self.currentPage.value]
            
            UIView.animate(withDuration: 0.3, animations: {
                self.roundDidChange(newActive, scrollView: newActive.mainNode.collectionNode.view)
                self.mainNode.pagerNode.scrollToItem(at: IndexPath(row: newValue, section: 0), at: .left, animated: true)
            }, completion: { (finished) in
            })
        }
        
    }
}

extension BracketViewController: BracketRoundSrollDelegate {
    
    func roundDidScroll(_ controller: BracketRoundViewController, scrollView: UIScrollView) {
        for (index, round) in self.rounds.enumerated() {
            
            // Skip older or not yet visible rounds
            if index < self.currentPage.value || index > self.currentPage.value + 1 {
                continue
            }
            
            // Ignore updating the round that scrolled, this would cause looping
            if round == controller {
                continue
            }
            
            // Update round that is upcoming so that the offset matches the current round's scrolling
            let additionalOffset: CGFloat = round.viewingStatus.value == .trailing ? 0 : -(BracketRoundMatchNode.height / 2)
            let newOffset = CGPoint(x: scrollView.contentOffset.x, y: scrollView.contentOffset.y + additionalOffset)
            round.mainNode.collectionNode.setContentOffset(newOffset, animated: false)
            
        }
    }
    
    func roundDidChange(_ controller: BracketRoundViewController, scrollView: UIScrollView) {
        for (index, round) in self.rounds.enumerated() {
    
            // Skip older or not yet visible rounds
            if index < self.currentPage.value || index > self.currentPage.value + 1 {
                continue
            }
            
            // Update the new current round to have the correct normal layout
            if round == controller {
                round.mainNode.collectionNode.view.setCollectionViewLayout(round.mainNode.collectionLayout, animated: true)
                continue
            }
            
            // Handle upcoming round coming into focus, correct it's content offset and update the collection layout to the spaced layout
            let additionalOffset: CGFloat = round.viewingStatus.value == .trailing ? 0 : -(BracketRoundMatchNode.height / 2)
            let newOffset = CGPoint(x: scrollView.contentOffset.x, y: scrollView.contentOffset.y + additionalOffset)
        
            UIView.animate(withDuration: 0.3, animations: {
                round.mainNode.collectionNode.view.setCollectionViewLayout(round.mainNode.spacedLayout, animated: false)
                round.mainNode.collectionNode.contentOffset = newOffset
            }, completion: { (finished) in
                // clean up to make sure offset is correct after animation finishes
                if finished {
                    round.mainNode.collectionNode.contentOffset = newOffset
                }
            })
        }
    }
}

extension BracketViewController: ASCollectionDataSource, ASCollectionDelegate {
    func collectionNode(_ collectionNode: ASCollectionNode, numberOfItemsInSection section: Int) -> Int {
        return self.rounds.count
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, nodeBlockForItemAt indexPath: IndexPath) -> ASCellNodeBlock {
        return {
            return ASCellNode(viewControllerBlock: { () -> UIViewController in
                return self.rounds[indexPath.item]
            }, didLoad: nil)
        }
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, constrainedSizeForItemAt indexPath: IndexPath) -> ASSizeRange {
        if indexPath.item == self.rounds.count - 1 {
            return ASSizeRange(min: self.view.bounds.size, max: self.view.bounds.size)
        }
        let offsetSize = CGSize(width: self.view.bounds.size.width * self.mainNode.OFFSET_PERCENT, height: self.view.bounds.size.height)
        return ASSizeRange(min: offsetSize, max: offsetSize)
    }
}

extension CGFloat {
    static func random() -> CGFloat {
        return CGFloat(arc4random()) / CGFloat(UInt32.max)
    }
}

extension UIColor {
    static func random() -> UIColor {
        return UIColor(red:   .random(),
                       green: .random(),
                       blue:  .random(),
                       alpha: 1.0)
    }
}

