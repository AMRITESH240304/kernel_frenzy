import Foundation

actor CacheManager {
    static let shared = CacheManager()
    private let cache = NSCache<NSString, NSArray>()
    private let userDefaults = UserDefaults.standard
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    private init() {}

    func cacheFiles(_ files: [FileItem], forKey key: String) async {
        cache.setObject(files as NSArray, forKey: key as NSString)

        if let encoded = try? encoder.encode(files) {
            userDefaults.set(encoded, forKey: key)
            userDefaults.set(Date(), forKey: "\(key)_timestamp")
        }
    }

    func getCachedFiles(forKey key: String) async -> [FileItem]? {
        let timestampKey = "\(key)_timestamp"
        let maxCacheAge: TimeInterval = 300 // 5 minutes

        if let timestamp = userDefaults.object(forKey: timestampKey) as? Date,
           Date().timeIntervalSince(timestamp) < maxCacheAge,
           let cachedFiles = cache.object(forKey: key as NSString) as? [FileItem] {
            return cachedFiles
        }

        if let data = userDefaults.data(forKey: key),
           let files = try? decoder.decode([FileItem].self, from: data) {
            cache.setObject(files as NSArray, forKey: key as NSString)
            return files
        }

        return nil
    }

    func clearCache(forKey key: String) async {
        cache.removeObject(forKey: key as NSString)
        userDefaults.removeObject(forKey: key)
        userDefaults.removeObject(forKey: "\(key)_timestamp")
    }
}
