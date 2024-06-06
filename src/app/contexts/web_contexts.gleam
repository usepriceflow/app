import gleam/pgo.{type Connection}

pub type Context {
  Context(db: Connection)
}
