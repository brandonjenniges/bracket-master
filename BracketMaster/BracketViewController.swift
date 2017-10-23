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
    
    let roundSize = [8,4,2,1]
    lazy var rounds: [BracketRoundViewController] = {
        [BracketRoundViewController(matches: 8, bracketRoundDelgate: self), BracketRoundViewController(matches: 4, bracketRoundDelgate: self), BracketRoundViewController(matches: 2, bracketRoundDelgate: self), BracketRoundViewController(matches: 1, bracketRoundDelgate: self)]
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
        // Set first controller as active
        self.rounds.first?.isActive.value = true
        self.setupCurrentPageObservable()
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
            round.isActive.value = index == currentPage
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
            
            if translation.x > 0 {
                print("left")
                if self.currentPage.value == 0 {
                    // Tried to swipe left on first page
                    return
                }
                self.currentPage.value = self.currentPage.value - 1
                self.mainNode.pagerNode.scrollToItem(at: IndexPath(row: self.currentPage.value, section: 0), at: .left, animated: true)
            } else {
                print("right")
                if self.currentPage.value == self.rounds.count - 1 {
                    // Tried to swipe right on last page
                    return
                }
                self.currentPage.value = self.currentPage.value + 1
                self.mainNode.pagerNode.scrollToItem(at: IndexPath(row: self.currentPage.value, section: 0), at: .left, animated: true)
            }
            let newActive = self.rounds[self.currentPage.value]
            self.roundDidScroll(newActive, scrollView: newActive.mainNode.collectionNode.view)
        }
        
    }
}

extension BracketViewController: BracketRoundSrollDelegate {
    
    func roundDidScroll(_ controller: BracketRoundViewController, scrollView: UIScrollView) {
        for round in self.rounds {
            if round == controller {
                continue
            }
            let newOffset = CGPoint(x: scrollView.contentOffset.x, y: scrollView.contentOffset.y - 100)
            round.mainNode.collectionNode.setContentOffset(newOffset, animated: false)
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

