
import Whitelist from "../../contracts/mu/Whitelist.cdc"

pub fun main(address: Address): Bool {
  return  Whitelist.whitelisted(address: address)
}