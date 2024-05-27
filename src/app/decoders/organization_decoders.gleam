import app/types/organization_types.{
  type NewOrganization, type Organization, NewOrganization, Organization,
}
import gleam/dynamic.{type DecodeError, type Dynamic}
import gleam/result

// Decodes the return from the db insert
pub fn organization_decoder(
  tuple: Dynamic,
) -> Result(Organization, List(DecodeError)) {
  let decoder =
    dynamic.decode2(
      Organization,
      dynamic.element(0, dynamic.int),
      dynamic.element(1, dynamic.string),
    )

  decoder(tuple)
}

// Decodes the JSON blob from the POST to /organizations
pub fn new_organization_decoder(json: Dynamic) -> Result(NewOrganization, Nil) {
  let decoder =
    dynamic.decode1(NewOrganization, dynamic.field("name", dynamic.string))

  json
  |> decoder()
  |> result.nil_error()
}
