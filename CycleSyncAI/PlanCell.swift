//
//  PlanCell.swift
//  CycleSyncAI
//
//  Created by Medhini Sridharr on 14/06/25.
//

import Foundation
import UIKit

class PlanCell: UITableViewCell {
    let titleLabel = UILabel()
    let downloadButton = UIButton(type: .system)
    let deleteButton = UIButton(type: .system)

    var onDownloadTapped: (() -> Void)?
    var deleteAction: (() -> Void)?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        titleLabel.font = UIFont(name: "Avenir", size: 16)
        titleLabel.textColor = UIColor.darkGray
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(titleLabel)

        downloadButton.setTitle("⬇️", for: .normal)
        downloadButton.titleLabel?.font = UIFont.systemFont(ofSize: 22)
        downloadButton.addTarget(self, action: #selector(handleDownload), for: .touchUpInside)
        downloadButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(downloadButton)
        
        deleteButton.setTitle("🗑️", for: .normal)
        deleteButton.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        deleteButton.addTarget(self, action: #selector(deleteTapped), for: .touchUpInside)
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(deleteButton)

        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),

            deleteButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            deleteButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            deleteButton.widthAnchor.constraint(equalToConstant: 30),
            deleteButton.heightAnchor.constraint(equalToConstant: 30),

            downloadButton.trailingAnchor.constraint(equalTo: deleteButton.leadingAnchor, constant: -10),
            downloadButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            downloadButton.widthAnchor.constraint(equalToConstant: 30),
            downloadButton.heightAnchor.constraint(equalToConstant: 30)
        ])
    }
    
    

    @objc func handleDownload() {
        print("📥 Download button tapped in cell")
        onDownloadTapped?()
    }
    
    @objc func deleteTapped() {
        deleteAction?()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
