import EVM from 0x8c5303eaa26202d6

access(all) contract EVMCaller {

    access(all) fun main(contractAddressHex: String, dataHex: String): [UInt8] {
        let contractAddress = EVM.addressFromString(contractAddressHex)
            let callData = dataHex.decodeHex()

            // EVM.call performs a read-only query (eth_call)
            let result = EVM.call(address: contractAddress, data: callData)

            return result
    }
}
