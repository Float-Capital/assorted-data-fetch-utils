module BigInt = {
  type t = BN.t
  let parse = json =>
    switch json->Js.Json.decodeString {
    | Some(str) => BN.new_(str)
    | None =>
      // In theory graphql should never allow this to not be a correct string
      Js.log("CRITICAL - should never happen!")
      BN.newInt_(0)
    }
  let serialize = bn => bn->BN.toString->Js.Json.string
}

module Bytes = {
  type t = string
  let parse = json =>
    switch json->Js.Json.decodeString {
    | Some(str) => str
    | None =>
      // In theory graphql should never allow this to not be a correct string
      Js.log("CRITICAL - should never happen!")
      "couldn't decode bytes"
    }
  let serialize = bytesString => bytesString->Js.Json.string
}
