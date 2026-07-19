//
//  AIInsulinAdjustmentService.swift
//  ACTIVE
//
//  Created by Emma Bian on 2026-07-16.
//

import Foundation
import Combine

struct AIAdjustmentResponse: Decodable {
    let suggestedReductionPercent: Int
    let reasoning: String
}

class AIInsulinAdjustmentService: ObservableObject {

    private let apiKey: String
    private let session: URLSession
    private let iso8601Formatter = ISO8601DateFormatter()

    init(apiKey: String, session: URLSession = .shared) {
        self.apiKey = apiKey
        self.session = session
    }

    func computeAdjustedInsulin(exercise: Exercise, healthKitManager: HealthKitManager) async throws -> Int {

        let baseline = exercise.calculateInsulin()
        let payload = buildPayload(exercise: exercise, healthKitManager: healthKitManager, baseline: baseline)
        let aiResponse = try await requestAISuggestion(payload: payload)
        let finalValue = clamp(aiResponse.suggestedReductionPercent, around: baseline)

        return finalValue
    }

    private func buildPayload(exercise: Exercise, healthKitManager: HealthKitManager, baseline: Int ) -> [String: Any] {
        [
            "exercise": [
                "type": exercise.type.name,
                "duration_minutes": exercise.duration,
                "intensity": exercise.intensity,
                "date": iso8601Formatter.string(from: exercise.date)
            ],
            "current_state": [
                "glucose_mgdl": healthKitManager.latestGlucose != nil ? (healthKitManager.latestGlucose!.value as Any): NSNull(),
                "glucose_trend": healthKitManager.glucoseTrend.rawValue,
                "heart_rate_bpm": healthKitManager.latestHeartRate != nil ? (healthKitManager.latestHeartRate!.value as Any) : NSNull(),
                "oxygen_saturation_pct": healthKitManager.latestOxygenSaturation != nil ? (healthKitManager.latestOxygenSaturation!.value as Any) : NSNull()
            ],
            "deterministic_baseline_reduction_pct": baseline
        ]
    }


    private func requestAISuggestion(payload: [String: Any]) async throws -> AIAdjustmentResponse {
        var request = URLRequest(url: URL(string: "https://api.anthropic.com/v1/messages")!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
        request.setValue("2023-06-01", forHTTPHeaderField: "anthropic-version")

        let payloadData = try JSONSerialization.data(withJSONObject: payload)
        let payloadString = String(data: payloadData, encoding: .utf8) ?? "{}"

        let prompt = """
        You are personalizing an insulin dose reduction percentage for exercise, \
        given a deterministic baseline that has already been safely computed.

        Respond with ONLY a JSON object, no other text, in exactly this shape:
        {"suggested_reduction_percent": <integer>, "reasoning": "<one short sentence>"}

        Context:
        \(payloadString)
        """

        let body: [String: Any] = [
            "model": "claude-sonnet-4-6",
            "max_tokens": 300,
            "messages": [["role": "user", "content": prompt]]
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }

        struct APIResponse: Decodable {
            struct ContentBlock: Decodable { let text: String }
            let content: [ContentBlock]
        }

        let apiResponse = try JSONDecoder().decode(APIResponse.self, from: data)
        guard let text = apiResponse.content.first?.text,
              let jsonData = text.data(using: .utf8) else {
            throw URLError(.cannotParseResponse)
        }

        return try JSONDecoder().decode(AIAdjustmentResponse.self, from: jsonData)
    }


    private func clamp(_ aiValue: Int, around baseline: Int) -> Int {
        let tolerance = 10
        let minAllowed = max(0, baseline - tolerance)
        let maxAllowed = min(75, baseline + tolerance)
        return min(max(aiValue, minAllowed), maxAllowed)
    }
}
