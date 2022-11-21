![Y—Network](https://user-images.githubusercontent.com/1037520/202389911-bd44883e-aa11-4584-9f78-3934ef1b4bf2.jpeg)
_A networking layer for iOS and tvOS._

🤖 Looking for the Android version? Check it out [here](https://github.com/yml-org/ynetwork-android).

Documentation
----------

Documentation is automatically generated from source code comments and rendered as a static website hosted via GitHub Pages at:  https://yml-org.github.io/ynetwork-ios/

Usage
----------

### NetworkManager

You will need to instantiate a `NetworkManager` either in your AppDelegate, SceneDelegate or other top-level application coordinator. You should then use Dependency Injection to pass it to the various service layers or view models that need it.

`NetworkManager` can be extensively configured via a `NetworkManagerConfiguration` object and/or by subclassing, but for basic functionality neither is required.

```swift
// Declare an instance of the network manager, so that it can be injected where needed.
private let networkManager = NetworkManager()
```

### NetworkRequest

Each network request you issue will be its own object (class or struct) that conforms to the `NetworkRequest` protocol. This protocol allows you to configure many things about your request (path, method, query parameters, body, timeout, headers, etc.) but it has sensible defaults so that the only mandatory property is `path` (which endpoint to hit).

```swift
struct GetUsersRequest { }

extension GetUsersRequest: NetworkRequest {
    // which endpoint to hit
    var path: PathRepresentable { "https://myendpoint.com/api/v1/users" }
}
```

Then you would issue a request like so (where the request will either return an array of `User` objects or else throw an `Error`). The following example shows how to use the modern `async` / `await` approach, but there’s also a completion handler based override of `submit`.

```swift
func fetchUsers() async {
    let request = GetUsersRequest()

    do {
        let users = try await networkManager.submit(request)
        // handle success
    } catch {
        // handle failure
    }
}
```

### Using relative paths

`NetworkRequest` supports relative paths by having both `basePath` and `path` properties. `path` is treated as an absolute path when `basePath` is nil (the default), otherwise it is treated as a relative path when `basePath` has been specified. We recommend the use of `enum`'s to list your applications base paths and paths.

```swift
enum MyApiBasePath: String, PathRepresentable {
    case prod = "https://myendpoint.com/api/v1"

    // In a real app you'd probably have additional development endpoints
    // such as dev, qa, uat, sandbox, etc.
}

extension MyApiBasePath {
    // convenience property to point to the current environment
    static var current: MyApiBasePath = .prod
}

enum MyApiEndpoints: String, PathRepresentable {
    case users
}
```

You could then declare a new request protocol for each different api server that your app supports.

```swift
// You can declare a new protocol for each major endpoint your app supports
protocol MyApiRequest: NetworkRequest { }

extension MyApiRequest {
    // All requests sharing the same base path
    var basePath: PathRepresentable? { MyApiBasePath.current }
}
```

Then each request can derive from the protocol specific to their api server.

```swift
struct GetUsersRequest { }

extension GetUsersRequest: MyApiRequest {
    // which endpoint to hit
    var path: PathRepresentable { MyApiEndpoints.users }
}
```

### Using associated values in paths

Most api’s have some requests where the path contains a unique identifier. Adding associated values to your endpoints enum is a great way to handle these. It requires a slight reconfiguration in how our endpoint enum is declared.

```swift
enum MyApiEndpoints {
    case users
    case user(id: String)
}

extension MockApiEndpoints: PathRepresentable {
    var pathValue: String {
        switch self {
        case .users:
            return "users"
        case .user(let id):
            return "users/\(id)"
        }
    }
}
```

Then you could declare a request for a specific user like so:

```swift
struct GetUserRequest {
    /// Id of the user to fetch
    let userId: String
}

extension GetUserRequest: MyApiRequest {
    // which endpoint to hit
    var path: PathRepresentable { MyApiEndpoints.user(id: userId) }
}
```

Installation
----------

You can add Y-Network to an Xcode project by adding it as a package dependency.

1. From the **File** menu, select **Add Packages...**
2. Enter "[https://github.com/yml-org/ynetwork-ios](https://github.com/yml-org/ynetwork-ios)" into the package repository URL text field
3. Click **Add Package**

Contributing to Y-Network
----------

### Requirements

#### SwiftLint (linter)
```
brew install swiftlint
```

#### Jazzy (documentation)
```
sudo gem install jazzy
```

### Setup

Clone the repo and open `Package.swift` in Xcode.

### Versioning strategy

We utilize [semantic versioning](https://semver.org).

```
{major}.{minor}.{patch}
```

e.g.

```
1.0.5
```

### Branching strategy

We utilize a simplified branching strategy for our frameworks.

* main (and development) branch is `main`
* both feature (and bugfix) branches branch off of `main`
* feature (and bugfix) branches are merged back into `main` as they are completed and approved.
* `main` gets tagged with an updated version # for each release
 
### Branch naming conventions:

```
feature/{ticket-number}-{short-description}
bugfix/{ticket-number}-{short-description}
```
e.g.
```
feature/CM-44-button
bugfix/CM-236-textview-color
```

### Pull Requests

Prior to submitting a pull request you should:

1. Compile and ensure there are no warnings and no errors.
2. Run all unit tests and confirm that everything passes.
3. Check unit test coverage and confirm that all new / modified code is fully covered.
4. Run `swiftlint` from the command line and confirm that there are no violations.
5. Run `jazzy` from the command line and confirm that you have 100% documentation coverage.
6. Consider using `git rebase -i HEAD~{commit-count}` to squash your last {commit-count} commits together into functional chunks.
7. If HEAD of the parent branch (typically `main`) has been updated since you created your branch, use `git rebase main` to rebase your branch.
    * _Never_ merge the parent branch into your branch.
    * _Always_ rebase your branch off of the parent branch.

When submitting a pull request:

* Use the [provided pull request template](PULL_REQUEST_TEMPLATE.md) and populate the Introduction, Purpose, and Scope fields at a minimum.
* If you're submitting before and after screenshots, movies, or GIF's, enter them in a two-column table so that they can be viewed side-by-side.

When merging a pull request:

* Make sure the branch is rebased (not merged) off of the latest HEAD from the parent branch. This keeps our git history easy to read and understand.
* Make sure the branch is deleted upon merge (should be automatic).

### Releasing new versions
* Tag the corresponding commit with the new version (e.g. `1.0.5`)
* Push the local tag to remote

Generating Documentation (via Jazzy)
----------

You can generate your own local set of documentation directly from the source code using the following command from Terminal:
```
jazzy
```
This generates a set of documentation under `/docs`. The default configuration is set in the default config file `.jazzy.yaml` file.

To view additional documentation options type:
```
jazzy --help
```
A GitHub Action automatically runs each time a commit is pushed to `main` that runs Jazzy to generate the documentation for our GitHub page at: https://yml-org.github.io/ynetwork-ios/
