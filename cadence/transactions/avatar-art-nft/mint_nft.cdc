import NonFungibleToken from "../../contracts/NonFungibleToken.cdc"
import AvatarArtNFT from "../../contracts/AvatarArtNFT.cdc"

// This transction uses the NFTMinter resource to mint a new NFT.
//
// It must be run with the account that has the minter resource
// stored at path /storage/NFTMinter.

transaction(recipient: Address, metadata: String) {
    
    // local variable for storing the minter reference
    let minter: &AvatarArtNFT.NFTMinter

    prepare(signer: AuthAccount) {

        // borrow a reference to the NFTMinter resource in storage
        self.minter = signer.borrow<&AvatarArtNFT.NFTMinter>(from: AvatarArtNFT.MinterStoragePath)
            ?? panic("Could not borrow a reference to the NFT minter")
    }

    execute {
        // get the public account object for the recipient
        let recipient = getAccount(recipient)

        // borrow the recipient's public NFT collection reference
        let receiver = recipient
            .getCapability(AvatarArtNFT.CollectionPublicPath)!
            .borrow<&{AvatarArtNFT.CollectionPublic}>()
            ?? panic("Could not get receiver reference to the NFT Collection")

        // mint the NFT and deposit it to the recipient's collection
        self.minter.mintNFT(metadata: metadata, recipient: receiver)
    }
}