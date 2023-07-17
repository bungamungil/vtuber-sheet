import Vapor


extension Application {

    struct GoogleAPI {

        final class Storage {
            let key: String

            init(key: String) {
                self.key = key
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
            self.application.storage[Key.self] = .init(key: "")
        }

        func use(key: String) {
            self.application.storage[Key.self] = .init(key: key)
        }

        var key: String {
            self.storage.key
        }

    }

    var googleAPI: GoogleAPI {
        .init(application: self)
    }

}
