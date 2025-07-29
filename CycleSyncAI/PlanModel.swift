//
//  PlanModel.swift
//  CycleSyncAI
//
//  Created by Medhini Sridharr on 14/06/25.
//


import Foundation

struct PlanModel: Codable {
    let type: String
    let dateLabel: String
    let content: String
    let dates: [String]
}
