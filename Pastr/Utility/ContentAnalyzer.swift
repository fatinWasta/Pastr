//
//  ContentAnalyzer.swift
//  Pastr
//
//  Created by Fatin on 17/03/26.
//

import SwiftUI

/// A utility for analyzing a string to determine its content type and generate a subtitle.
struct ContentAnalyzer {
    /// Analyzes a string and returns a best-guess content type and subtitle.
    static func analyze(string: String) -> (type: ContentType, subtitle: String) {
        let trimmed = string.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Rule-based analysis chain. The first rule to match wins.
        if let urlTuple = analyzeURL(trimmed) { return urlTuple }
        if let tokenTuple = analyzeToken(trimmed) { return tokenTuple }
        if let codeTuple = analyzeCode(trimmed) { return codeTuple }
        
        // Default fallback
        return (.text, "Text Snippet")
    }
    
    private static func analyzeURL(_ string: String) -> (ContentType, String)? {
        guard let url = URL(string: string),
              let scheme = url.scheme, ["http", "https"].contains(scheme),
              string.contains("."), !string.contains(" ")
        else { return nil }
        
        return (.url, url.host ?? "Web Link")
    }
    
    private static func analyzeToken(_ string: String) -> (ContentType, String)? {
        //JWT (JSON Web Token) Check - Very specific pattern: three parts separated by dots, first part is Base64Url-encoded JSON.
        let jwtParts = string.split(separator: ".")
        if jwtParts.count == 3 && jwtParts[0].starts(with: "ey") {
            return (.token, "JWT Token")
        }
        
        //UUID Check - Standard 8-4-4-4-12 format.
        if UUID(uuidString: string) != nil {
            return (.token, "UUID")
        }
        
        //Common API Key Prefix Check
        let knownPrefixes: [String: String] = [
            "ghp_": "GitHub Token", "gho_": "GitHub Token", "ghu_": "GitHub Token",
            "ghs_": "GitHub Token", "ghr_": "GitHub Token",
            "sk_": "Stripe API Key", "pk_": "Stripe API Key", "rk_": "Stripe API Key"
        ]
        
        for (prefix, description) in knownPrefixes where string.starts(with: prefix) {
            return (.token, description)
        }
        
        //Generic Heuristic Checks for other tokens - A common characteristic is no whitespace and a minimum length.
        guard !string.contains(where: \.isWhitespace) && string.count >= 20 else { return nil }
        
        //Check for long Hexadecimal strings
        if string.allSatisfy(\.isHexDigit) {
            return (.token, "Hex Token")
        }
        
        //Check for strings that appear to be Base64-encoded.
        //This is a heuristic: a valid Base64 string can be decoded into data.
        if string.count % 4 == 0, let data = Data(base64Encoded: string), !data.isEmpty {
            return (.token, "API Token")
        }
        
        //Fallback: check for a high density of alphanumeric characters.
        //This catches many other miscellaneous tokens that don't fit the patterns above.
        let alphanumericCount = string.filter(\.isLetter).count + string.filter(\.isNumber).count
        if Double(alphanumericCount) / Double(string.count) > 0.8 {
            return (.token, "Access Token")
        }
        
        return nil
    }
    
    private static let codeStrategies: [CodeAnalysisStrategy] = [
        JavaCodeStrategy(),
        PythonCodeStrategy(),
        JavaScriptCodeStrategy(),
        SQLCodeStrategy(),
        ShellCodeStrategy(),
        SwiftCodeStrategy(),
        JSONCodeStrategy()
    ]
    
    private static func analyzeCode(_ string: String) -> (ContentType, String)? {
        for strategy in codeStrategies {
            if let result = strategy.analyze(string) {
                return result
            }
        }
        return nil
    }
}


// MARK: - Code Analysis Strategies

private protocol CodeAnalysisStrategy {
    func analyze(_ string: String) -> (ContentType, String)?
}

private struct JavaCodeStrategy: CodeAnalysisStrategy {
    private let indicators = ["public class", "System.out.println", "import java.util", "public static void main"]
    
    func analyze(_ string: String) -> (ContentType, String)? {
        guard indicators.contains(where: string.contains) else { return nil }
        return (.codeSnippet, "Java Snippet")
    }
}

private struct PythonCodeStrategy: CodeAnalysisStrategy {
    private let secondaryIndicators = ["import numpy", "import pandas", "elif"]
    
    func analyze(_ string: String) -> (ContentType, String)? {
        let hasDefWithColon = string.contains("def ") && string.contains(":")
        let hasOtherIndicator = secondaryIndicators.contains(where: string.contains)
        
        guard hasDefWithColon || hasOtherIndicator else { return nil }
        return (.codeSnippet, "Python Snippet")
    }
}

private struct JavaScriptCodeStrategy: CodeAnalysisStrategy {
    private let indicators = ["console.log", "document.getElementById", "window.addEventListener"]
    
    func analyze(_ string: String) -> (ContentType, String)? {
        let hasIndicator = indicators.contains(where: string.contains)
        let hasFunctionKeyword = string.contains("function ") && !string.contains("func ")
        
        guard hasIndicator || hasFunctionKeyword else { return nil }
        return (.codeSnippet, "JavaScript Snippet")
    }
}

private struct SQLCodeStrategy: CodeAnalysisStrategy {
    private let keywords = ["SELECT ", "INSERT ", "UPDATE ", "DELETE ", "CREATE ", "DROP "]
    
    func analyze(_ string: String) -> (ContentType, String)? {
        let uppercased = string.uppercased()
        guard keywords.contains(where: uppercased.starts(with:)) else { return nil }
        return (.codeSnippet, "SQL Query")
    }
}

private struct ShellCodeStrategy: CodeAnalysisStrategy {
    func analyze(_ string: String) -> (ContentType, String)? {
        guard string.starts(with: "curl ") else { return nil }
        return (.codeSnippet, "Shell Command")
    }
}

private struct SwiftCodeStrategy: CodeAnalysisStrategy {
    private let indicators = ["import SwiftUI", "import Foundation", "struct ", "enum ", "@State", "func ", "private var", "private let", "guard let", "?."]
    
    func analyze(_ string: String) -> (ContentType, String)? {
        guard indicators.contains(where: string.contains) else { return nil }
        return (.codeSnippet, "Swift Snippet")
    }
}

private struct JSONCodeStrategy: CodeAnalysisStrategy {
    func analyze(_ string: String) -> (ContentType, String)? {
        let isJsonObject = string.starts(with: "{") && string.hasSuffix("}")
        let isJsonArray = string.starts(with: "[") && string.hasSuffix("]")
        
        guard isJsonObject || isJsonArray else { return nil }
        return (.codeSnippet, "JSON Object")
    }
}
