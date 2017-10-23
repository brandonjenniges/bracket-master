//
//  BracketRoundViewController.swift
//  BracketMaster
//
//  Created by Brandon Jenniges on 10/20/17.
//  Copyright © 2017 BrandonJenniges. All rights reserved.
//

import Foundation
import AsyncDisplayKit
import RxSwift

final class BracketRoundViewController: ASViewController<ASDisplayNode> {
    
    let mainNode = BracketRoundViewNode()
    let bracketRoundDelgate: BracketRoundSrollDelegate
    
    enum ViewingStatus {
        case trailing
        case current
        case leading
    }
    
    let viewingStatus: Variable<ViewingStatus> = Variable(.trailing)
    private let disposeBag = DisposeBag()
    
    var matches: Int // temp
    init(matches: Int, bracketRoundDelgate: BracketRoundSrollDelegate) {
        self.matches = matches
        self.bracketRoundDelgate = bracketRoundDelgate
        super.init(node: self.mainNode)
        self.mainNode.collectionNode.dataSource = self
        self.mainNode.collectionNode.delegate = self
        self.setupViewingStatusObservable()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.mainNode.collectionNode.contentOffset = CGPoint(x: 0, y: -100)
    }
    
    // MARK: -- Rx
    
    private func setupViewingStatusObservable() {
        self.viewingStatus.asObservable()
            .subscribe(onNext: {
                [weak self] viewingStatus in
                if let weakSelf = self {
                    switch viewingStatus {
                    case .leading:
                        weakSelf.mainNode.collectionNode.view.setCollectionViewLayout(weakSelf.mainNode.spacedLayout, animated: true)
                        break
                    case .trailing:
                        weakSelf.mainNode.collectionNode.view.setCollectionViewLayout(weakSelf.mainNode.collectionLayout, animated: true)
                        break
                    case .current:
                        weakSelf.mainNode.collectionNode.view.setCollectionViewLayout(weakSelf.mainNode.collectionLayout, animated: true)
                        break
                    }
                    weakSelf.mainNode.collectionNode.isUserInteractionEnabled = viewingStatus == .current
                }
            })
            .addDisposableTo(disposeBag)
    }
}

extension BracketRoundViewController: ASCollectionDataSource {
    func collectionNode(_ collectionNode: ASCollectionNode, numberOfItemsInSection section: Int) -> Int {
        return self.matches
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, nodeBlockForItemAt indexPath: IndexPath) -> ASCellNodeBlock {
        return { () -> ASCellNode in
            let node = ASCellNode()
            
            node.selectionStyle = .none
            let displayNode = ASDisplayNode()
            displayNode.backgroundColor = UIColor.random()
            //
            //            DispatchQueue.main.async {
            //                displayNode.borderWidth = 2
            //                displayNode.layer.borderColor = UIColor.random().cgColor
            //
            //            }
            node.addSubnode(displayNode)
            node.layoutSpecBlock = {
                node, constrainedSize in
                displayNode.style.preferredSize = CGSize(width: constrainedSize.max.width, height: 200)
                let insetSpec = ASInsetLayoutSpec(insets: .zero, child: displayNode)
                return insetSpec
            }
            return node
        }
        
    }
    
}

extension BracketRoundViewController: ASCollectionDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if self.viewingStatus.value == .current {
            self.bracketRoundDelgate.roundDidScroll(self, scrollView: scrollView)
        }
    }
}

