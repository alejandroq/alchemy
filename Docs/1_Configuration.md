# Configuration

- [Run Commands](#run-commands)
  * [`serve`](#serve)
  * [`migrate`](#migrate)
  * [`queue`](#queue)
- [Environment](#environment)
  * [Dynamic Member Lookup](#dynamic-member-lookup)
  * [.env File](#env-file)
  * [Custom Environments](#custom-environments)
- [Working with Xcode](#working-with-xcode)
  * [Setting a Custom Working Directory](#setting-a-custom-working-directory)

## Run Commands

When Alchemy is run, it takes an argument that determines how it behaves on launch. When no argument is passed, the default command is `serve` which boots the app and serves it on the machine.

Additionally, there are `migrate` and `queue` commands which help run migrations and queue workers/schedulers respectively.

You can run these like so.

```shell
swift run Server migrate
```

Each command has options for customizing how it runs. If you're running your server from Xcode, you can configure flags passed on launch by editing the current scheme and navigating to `Run` -> `Arguments`.

### Serve

> `swift run` or `swift run Server serve`

|Option|Default|Description|
|-|-|-|
|--host|127.0.0.1|The host to listen on|
|--port|3000|The port to listen on|
|--unixSocket|nil|The unix socket to listen on. Mutally exclusive with `host` & `port`|
|--workers|0|The number of workers to run|
|--schedule|false|Whether scheduled tasks should also be run|
|--migrate|false|Whether any outstanding migrations should be run before serving|
|--env|env|The environment to load|

### Migrate

> `swift run Server migrate`

|Option|Default|Description|
|-|-|-|
|--rollback|false|Should migrations be rolled back instead of applied|
|--env|env|The environment to load|

### Queue

> `swift run Server queue`

|Option|Default|Description|
|-|-|-|
|--name|`nil`|The queue to monitor. Leave empty to monitor `Queue.default`|
|--channels|`default`|The channels to monitor, separated by comma|
|--workers|1|The number of workers to run|
|--schedule|false|Whether scheduled tasks should also be run|
|--env|env|The environment to load|

## Environment

Often you'll need to access environment variables of the running program. To do so, use the `Env` type.

```swift
// The type is inferred
let envBool: Bool? = Env.current.get("some_bool")
let envInt: Int? = Env.current.get("some_int")
let envString: String? = Env.current.get("some_string")
```

### Dynamic member lookup

If you're feeling fancy, `Env` supports dynamic member lookup.

```swift
let db: String? = Env.DB_DATABASE
let dbUsername: String? = Env.DB_USER
let dbPass: String? = Env.DB_PASS
```

### .env file

By default, environment variables are loaded from the process as well as the file `.env` if it exists in the working directory of your project.

Inside your `.env` file, keys & values are separated with an `=`.

```bash
# A sample .env file (a file literally titled ".env" in the working directory)

APP_NAME=Alchemy
APP_ENV=local
APP_KEY=
APP_DEBUG=true
APP_URL=http://localhost

DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=5432
DB_DATABASE=alchemy
DB_USER=josh
DB_PASS=password

REDIS_HOST=127.0.0.1
REDIS_PASSWORD=null
REDIS_PORT=6379

AWS_ACCESS_KEY_ID=
AWS_SECRET_ACCESS_KEY=
AWS_DEFAULT_REGION=us-east-1
AWS_BUCKET=
```

### Custom Environments

You can load your environment from another location by passing your app the `--env` option.

If you have separate environment variables for different server configurations (i.e. local dev, staging, production), you can pass your program a separate `--env` for each configuration so the right environment is loaded.

## Working with Xcode

You can use Xcode to run your project to take advantage of all the great tools built into it; debugging, breakpoints, memory graphs, testing, etc.

When working with Xcode be sure to set a custom working directory.

### Setting a Custom Working Directory

By default, Xcode builds and runs your project in a **DerivedData** folder, separate from the root directory of your project. Unfortunately this means that files your running server may need to access, such as a `.env` file or a `Public` directory, will not be available.

To solve this, edit your server target's scheme & change the working directory to your package's root folder. `Edit Scheme` -> `Run` -> `Options` -> `WorkingDirectory`.

_Up next: [Services & Fusion](2_Fusion.md)_

_[Table of Contents](/Docs#docs)_