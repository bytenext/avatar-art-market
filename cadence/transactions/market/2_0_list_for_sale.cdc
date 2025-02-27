import FungibleToken from "../../contracts/FungibleToken.cdc"
import AvatarArtMarketplace from "../../contracts/AvatarArtMarketplace.cdc"
import AvatarArtNFT from "../../contracts/AvatarArtNFT.cdc";
import BNU from "../../contracts/BNU.cdc";

transaction(nftID: UInt64, price: UFix64) {

    prepare(signer: AuthAccount) {
        // check to see if sale collection already exists
        let collectionPrivatePath = /private/avatarArtNFTCollection
        if !signer.getCapability<&AvatarArtNFT.Collection>(collectionPrivatePath).check() {
            signer.link<&AvatarArtNFT.Collection>(collectionPrivatePath, target: AvatarArtNFT.CollectionPublicPath)
        }

        if signer.borrow<&AvatarArtMarketplace.SaleCollection>(from: AvatarArtMarketplace.SaleCollectionStoragePath) == nil {
            let collection <- AvatarArtMarketplace.createSaleCollection(
                ownerCollection: signer.getCapability<&AvatarArtNFT.Collection>(collectionPrivatePath)
            )

            signer.save(<-collection, to: AvatarArtMarketplace.SaleCollectionStoragePath)
            signer.link<&AvatarArtMarketplace.SaleCollection{AvatarArtMarketplace.SalePublic}>(AvatarArtMarketplace.SaleCollectionPublicPath, target: AvatarArtMarketplace.SaleCollectionStoragePath)
        }

        let ownerCapability = signer.getCapability<&{FungibleToken.Receiver}>(BNU.ReceiverPath);
        // borrow a reference to the sale
        let saleCollection = signer.borrow<&AvatarArtMarketplace.SaleCollection>(from: AvatarArtMarketplace.SaleCollectionStoragePath)
            ?? panic("Could not borrow from sale in storage")

    
        let nftCollection = signer.borrow<&AvatarArtNFT.Collection>(from: AvatarArtNFT.CollectionStoragePath)
            ?? panic("Could not borrow from owner NFT collection")

        // put the moment up for sale
        saleCollection.listForSale(nftID: nftID, price: price, paymentType: Type<@BNU.Vault>(), receiver: ownerCapability)
        
    }
}