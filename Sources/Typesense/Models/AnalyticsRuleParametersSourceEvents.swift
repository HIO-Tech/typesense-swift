//
// AnalyticsRuleParametersSourceEvents.swift
//
// Generated by swagger-codegen
// https://github.com/swagger-api/swagger-codegen
//

import Foundation



public struct AnalyticsRuleParametersSourceEvents: Codable {

    public var type: String
    public var weight: Float
    public var name: String

    public init(type: String, weight: Float, name: String) {
        self.type = type
        self.weight = weight
        self.name = name
    }


}
