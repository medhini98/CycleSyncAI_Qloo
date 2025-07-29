//
//  ChatCell.swift
//  CycleSyncAI
//
//  Created by Medhini Sridharr on 18/06/25.
//

import Foundation
import UIKit

class ChatCell: UITableViewCell {
    let bubbleLabel = UILabel()
    let bubbleBackground = UIView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        bubbleLabel.numberOfLines = 0
        bubbleLabel.font = UIFont(name: "Avenir", size: 16)
        bubbleLabel.translatesAutoresizingMaskIntoConstraints = false

        bubbleBackground.layer.cornerRadius = 16
        bubbleBackground.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(bubbleBackground)
        contentView.addSubview(bubbleLabel)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with message: ChatMessage) {
        bubbleLabel.text = message.text
        bubbleLabel.textColor = message.isFromUser ? .white : .black
        bubbleBackground.backgroundColor = message.isFromUser ? UIColor.systemPurple : UIColor.systemGray5

        // NSLayoutConstraint.deactivate(bubbleBackground.constraints)
        // NSLayoutConstraint.deactivate(bubbleLabel.constraints)
        
        bubbleLabel.translatesAutoresizingMaskIntoConstraints = false
        bubbleBackground.translatesAutoresizingMaskIntoConstraints = false
        bubbleLabel.removeFromSuperview()
        bubbleBackground.removeFromSuperview()
        contentView.addSubview(bubbleBackground)
        contentView.addSubview(bubbleLabel)

        let horizontalPadding: CGFloat = 20
        NSLayoutConstraint.activate([
            bubbleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            bubbleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
            bubbleLabel.widthAnchor.constraint(lessThanOrEqualToConstant: 250),

            bubbleBackground.topAnchor.constraint(equalTo: bubbleLabel.topAnchor, constant: -10),
            bubbleBackground.leadingAnchor.constraint(equalTo: bubbleLabel.leadingAnchor, constant: -10),
            bubbleBackground.bottomAnchor.constraint(equalTo: bubbleLabel.bottomAnchor, constant: 10),
            bubbleBackground.trailingAnchor.constraint(equalTo: bubbleLabel.trailingAnchor, constant: 10),
        ])

        if message.isFromUser {
            bubbleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -horizontalPadding).isActive = true
        } else {
            bubbleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: horizontalPadding).isActive = true
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        bubbleLabel.text = nil
    }
}
