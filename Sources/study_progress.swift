import Foundation
import PDFKit

struct BookProgress: Codable {
    let title: String
    let path: String
    let displayPath: String
    let currentPage: Int?
    let totalPages: Int?
    let percent: Double?
    let source: String
    let updatedAt: String
    let note: String?
}

struct Output: Codable {
    let generatedAt: String
    let booksDir: String
    let books: [BookProgress]
}

let args = CommandLine.arguments
let booksDir = args.count > 1 ? args[1] : "/Users/xianliticn/Desktop/考研/基础期"
let outputPath = args.count > 2 ? args[2] : "/Users/xianliticn/Library/Application Support/UbersichtStudyProgress/progress.json"
let viewStatePath = args.count > 3 ? args[3] : "/Users/xianliticn/Library/Containers/com.apple.Preview/Data/Library/Preferences/com.apple.Preview.ViewState.plist"

let isoFormatter = ISO8601DateFormatter()
let generatedAt = isoFormatter.string(from: Date())

func loadPreviewStates() -> [String: [String: Any]] {
    let url = URL(fileURLWithPath: viewStatePath)
    guard let data = try? Data(contentsOf: url),
          let plist = try? PropertyListSerialization.propertyList(from: data, options: [], format: nil),
          let root = plist as? [String: Any] else {
        return [:]
    }

    var states: [String: [String: Any]] = [:]
    for (key, value) in root {
        guard let entry = value as? [String: Any],
              let nestedData = entry["Data"] as? Data,
              let nested = try? PropertyListSerialization.propertyList(from: nestedData, options: [], format: nil),
              let nestedDict = nested as? [String: Any] else {
            continue
        }
        states[key] = nestedDict
    }
    return states
}

func resolvedURL(for fileURL: URL) -> URL? {
    if let resolved = try? URL(resolvingAliasFileAt: fileURL, options: []) {
        return resolved
    }
    return fileURL.pathExtension.lowercased() == "pdf" ? fileURL : nil
}

func fileStateKey(for url: URL) -> String? {
    guard let values = try? url.resourceValues(forKeys: [.volumeUUIDStringKey]),
          let volumeUUID = values.volumeUUIDString else {
        return nil
    }

    var statInfo = stat()
    guard stat(url.path, &statInfo) == 0 else {
        return nil
    }
    return "\(volumeUUID).\(statInfo.st_ino)"
}

func currentPage(from state: [String: Any]?) -> Int? {
    guard let props = state?["UI_Additions_Windowed_Properties"] as? [String: Any],
          let index = props["elementIndex"] as? Int else {
        return nil
    }
    return max(index + 1, 1)
}

func displayTitle(for url: URL) -> String {
    var name = url.deletingPathExtension().lastPathComponent
    name = name.replacingOccurrences(of: " (z-library.sk, 1lib.sk, z-lib.sk)", with: "")
    name = name.replacingOccurrences(of: "高清带书签", with: "")
    return name.trimmingCharacters(in: .whitespacesAndNewlines)
}

let previewStates = loadPreviewStates()
let dirURL = URL(fileURLWithPath: booksDir, isDirectory: true)
let entries = (try? FileManager.default.contentsOfDirectory(at: dirURL, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles])) ?? []

var seenPaths = Set<String>()
var books: [BookProgress] = []

for entry in entries.sorted(by: { $0.lastPathComponent.localizedStandardCompare($1.lastPathComponent) == .orderedAscending }) {
    guard let pdfURL = resolvedURL(for: entry), pdfURL.pathExtension.lowercased() == "pdf" else {
        continue
    }
    guard !seenPaths.contains(pdfURL.path) else {
        continue
    }
    seenPaths.insert(pdfURL.path)

    let totalPages = PDFDocument(url: pdfURL)?.pageCount
    let stateKey = fileStateKey(for: pdfURL)
    let page = currentPage(from: stateKey.flatMap { previewStates[$0] })
    let percent: Double?
    if let page, let totalPages, totalPages > 0 {
        percent = min(100, max(0, (Double(page) / Double(totalPages)) * 100))
    } else {
        percent = nil
    }

    let note: String?
    if totalPages == nil {
        note = "无法读取页数"
    } else if page == nil {
        note = "Preview 尚未记录页码"
    } else {
        note = nil
    }

    books.append(BookProgress(
        title: displayTitle(for: pdfURL),
        path: pdfURL.path,
        displayPath: entry.path,
        currentPage: page,
        totalPages: totalPages,
        percent: percent,
        source: stateKey == nil ? "pdf" : "preview-view-state",
        updatedAt: generatedAt,
        note: note
    ))
}

let output = Output(generatedAt: generatedAt, booksDir: booksDir, books: books)
let encoder = JSONEncoder()
encoder.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
let json = try encoder.encode(output)
let outputURL = URL(fileURLWithPath: outputPath)
try FileManager.default.createDirectory(at: outputURL.deletingLastPathComponent(), withIntermediateDirectories: true)
try json.write(to: outputURL, options: .atomic)
