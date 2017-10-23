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
    
    let isActive: Variable<Bool> = Variable(false)
    private let disposeBag = DisposeBag()
    
    var matches: Int // temp
    init(matches: Int, bracketRoundDelgate: BracketRoundSrollDelegate) {
        self.matches = matches
        self.bracketRoundDelgate = bracketRoundDelgate
        super.init(node: self.mainNode)
        self.mainNode.collectionNode.dataSource = self
        self.mainNode.collectionNode.delegate = self
        self.setupIsActiveObservable()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: -- Rx
    
    private func setupIsActiveObservable() {
        self.isActive.asObservable()
            .subscribe(onNext: {
                [weak self] active in
                if let weakSelf = self {
                    weakSelf.mainNode.collectionNode.isUserInteractionEnabled = active
                    weakSelf.mainNode.collectionNode.relayoutItems()
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
            
            DispatchQueue.main.async {
                displayNode.borderWidth = 2
                displayNode.layer.borderColor = UIColor.random().cgColor
                
            }
            node.addSubnode(displayNode)
            node.layoutSpecBlock = {
                node, constrainedSize in
                displayNode.style.preferredSize = CGSize(width: constrainedSize.max.width, height: 200)
                let inset: UIEdgeInsets
                if self.isActive.value {
                    inset = .zero
                } else {
                    inset = UIEdgeInsetsMake(0, 0, 200, 0)
                }
                let insetSpec = ASInsetLayoutSpec(insets: inset, child: displayNode)
                return insetSpec
            }
            return node
        }
        
    }
    
}

extension BracketRoundViewController: ASCollectionDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if self.isActive.value {
            self.bracketRoundDelgate.roundDidScroll(self, scrollView: scrollView)
        }
    }
}

