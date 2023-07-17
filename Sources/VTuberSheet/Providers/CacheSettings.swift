import Vapor


extension Application {

    struct CacheSettings {

        final class Storage {

            let expirationInSeconds: Int

            init(expirationInSeconds: Int) {
                self.expirationInSeconds = expirationInSeconds
            }

        }

        struct Key: StorageKey {
            typealias Value = Storage
        }

        fileprivate let application: Application

        fileprivate var storage: Storage {
            if self.application.storage[Key.self] == nil {
                self.initialize()
            }
            return self.application.storage[Key.self]!
        }

        fileprivate func initialize() {
            self.application.storage[Key.self] = .init(expirationInSeconds: 60 * 60 * 24) // default: 1 day
        }

        func set(expirationInSeconds: Int) {
            self.application.storage[Key.self] = .init(expirationInSeconds: expirationInSeconds)
        }

        var expirationInSeconds: Int {
            self.storage.expirationInSeconds
        }

    }

    var cacheSettings: CacheSettings {
        .init(application: self)
    }

}