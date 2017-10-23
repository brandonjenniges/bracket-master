//
//  BracketRoundMatchNode.swift
//  BracketMaster
//
//  Created by Brandon Jenniges on 10/23/17.
//  Copyright © 2017 BrandonJenniges. All rights reserved.
//

import Foundation
import AsyncDisplayKit

final class BracketRoundMatchNode: ASCellNode {
    
    static let height: CGFloat = 80
    private let contentNode = ASDisplayNode()
    
    override init() {
        super.init()
        self.automaticallyManagesSubnodes = true
        self.selectionStyle = .none
        self.contentNode.backgroundColor = UIColor.random()
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        contentNode.style.preferredSize = CGSize(width: constrainedSize.max.width, height: BracketRoundMatchNode.height)
        let insetSpec = ASInsetLayoutSpec(insets: .zero, child: contentNode)
        return insetSpec
    }
}
