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
    
    enum MatchPosition {
        case top
        case bottom
        case unknown
    }
    
    static let height: CGFloat = 100
    static let contentHeight: CGFloat = 75
    
    private let contentNode = ASDisplayNode()
    private let matchNode = ASDisplayNode()
    
    private let matchPosition: MatchPosition
    
    init(matchPosition: MatchPosition) {
        self.matchPosition = matchPosition
        super.init()
        self.automaticallyManagesSubnodes = true
        self.selectionStyle = .none
        self.contentNode.backgroundColor = matchPosition == .top ? .red : .blue
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        contentNode.style.preferredSize = CGSize(width: constrainedSize.max.width - 25, height: BracketRoundMatchNode.contentHeight)
        let centerSpec = ASCenterLayoutSpec(centeringOptions: .Y, sizingOptions: .minimumY, child: self.contentNode)
        centerSpec.style.preferredSize = CGSize(width: constrainedSize.max.width, height: BracketRoundMatchNode.height)
        let insetSpec = ASInsetLayoutSpec(insets: .zero, child: centerSpec)
        return insetSpec
    }
}
