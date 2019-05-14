//
//  EosioReferenceAuthenticatorSignatureProviderTests.swift
//  EosioReferenceAuthenticatorSignatureProviderTests
//
//  Created by Steve McCoole on 4/16/19.
//  Copyright (c) 2017-2019 block.one and its contributors. All rights reserved.
//

import XCTest
import EosioSwift

@testable import EosioSwiftReferenceAuthenticatorSignatureProvider

// swiftlint:disable line_length
class EosioReferenceAuthenticatorSignatureProviderTests: XCTestCase {

    func testResponseFromHex() {

        let response = try? EosioReferenceAuthenticatorSignatureProvider.ResponsePayload(hex: "7b226465766963654964223a22222c226964223a2239363342393935442d304445462d344232382d413835332d434337344234413233393433222c22726573706f6e7365223a7b227472616e73616374696f6e5369676e6174757265223a7b227369676e65645472616e73616374696f6e223a7b2273657269616c697a65645472616e73616374696f6e223a226f48584d584262633974314147514141414141436b4b5c2f43324144714d4655414141424158616574756742797939325662314b73325244447956675462584c3456673059527278383878565c2f58372b334c544142336b5758394b48397673326d315a79577044414a5c2f4635646534396a6d784a7078337a7363595267334d476373774541706f4930412b6f775651414141466374504d334e41554f47545672775c2f696c4e524e476359534132792b6a416d45464d53684b6c7037734c5c2f6e327856574a49414b61434e4150714d465541414142584c547a4e7a5145417271704b77567a39525141414141436f375449795a414375716b72425850314641414141594e49307a54326761415941414141414141524654314d41414141415131646f5a5734676557393149474e68626942305957746c4948526f5a5342775a574a69624755675a6e4a76625342746553426f5957356b4c434270644342336157787349474a6c49485270625755676447386762475668646d5541222c227369676e617475726573223a5b225349475f4b315f4b3464366a7068397071754e6846484c36504b356a346539327a46446f74575a66735a6f7253584832426b345a5471314145745246486a63364845553545623942707967755976566f50787876645376676248514b38635865794c514173225d7d7d7d7d")
        XCTAssertNotNil(response)
        XCTAssert(response?.id == "963B995D-0DEF-4B28-A853-CC74B4A23943")
        let payload = response?.response
        XCTAssertNotNil(payload)
        XCTAssertNotNil(payload?.transactionSignature)
        XCTAssertNotNil(payload?.transactionSignature?.signedTransaction)
        XCTAssertNil(payload?.transactionSignature?.error)
        XCTAssert(payload?.transactionSignature?.signedTransaction?.serializedTransaction.hex == "a075cc5c16dcf6dd4019000000000290afc2d800ea3055000000405da7adba0072cbdd956f52acd910c3c958136d72f8560d1846bc7cf3157f5fbfb72d3001de4597f4a1fdbecda6d59c96a43009fc5e5d7b8f639b1269c77cec718460dcc19cb30100a6823403ea3055000000572d3ccdcd0143864d5af0fe294d44d19c612036cbe8c098414c4a12a5a7bb0bfe7db155624800a6823403ea3055000000572d3ccdcd0100aeaa4ac15cfd4500000000a8ed32326400aeaa4ac15cfd4500000060d234cd3da06806000000000004454f5300000000435768656e20796f752063616e2074616b652074686520706562626c652066726f6d206d792068616e642c2069742077696c6c2062652074696d6520746f206c6561766500")
        XCTAssertNotNil(payload?.transactionSignature?.signedTransaction?.signatures)
        XCTAssert(payload?.transactionSignature?.signedTransaction?.signatures.count == 1)
        XCTAssert(payload?.transactionSignature?.signedTransaction?.signatures[0] == "SIG_K1_K4d6jph9pquNhFHL6PK5j4e92zFDotWZfsZorSXH2Bk4ZTq1AEtRFHjc6HEU5Eb9BpyguYvVoPxxvdSvgbHQK8cXeyLQAs")

    }

    func testRequestToHex() {
        var requestPayload = EosioReferenceAuthenticatorSignatureProvider.RequestPayload()
        requestPayload.id = "F85526EA-727D-4A96-B13A-89777E859063"
        requestPayload.declaredDomain = "my.example.com"
        requestPayload.returnUrl = "myexample://"
        requestPayload.requireBiometric = false
        requestPayload.callbackUrl = nil
        requestPayload.responseKey = nil
        requestPayload.securityExclusions = nil

        var transactionSignatureRequest = EosioTransactionSignatureRequest()
        do {
            transactionSignatureRequest.serializedTransaction = try Data(hex: "ca7ecc5c6aeec4212251000000000100a6823403ea3055000000572d3ccdcd0100aeaa4ac15cfd4500000000a8ed32326400aeaa4ac15cfd4500000060d234cd3da06806000000000004454f5300000000435768656e20796f752063616e2074616b652074686520706562626c652066726f6d206d792068616e642c2069742077696c6c2062652074696d6520746f206c6561766500")
        } catch {
            XCTFail("Can't create serialized transaction from hex.")
        }
        transactionSignatureRequest.chainId = "687fa513e18843ad3e820744f4ffcf93b1354036d80737db8dc444fe4b15ad17"
        transactionSignatureRequest.publicKeys = ["EOS5j67P1W2RyBXAL8sNzYcDLox3yLpxyrxgkYy1xsXzVCvzbYpba"]
        var abi = EosioTransactionSignatureRequest.BinaryAbi()
        abi.accountName = "eosio.token"
        abi.abi = "0e656f73696f3a3a6162692f312e30010c6163636f756e745f6e616d65046e616d6505087472616e7366657200040466726f6d0c6163636f756e745f6e616d6502746f0c6163636f756e745f6e616d65087175616e74697479056173736574046d656d6f06737472696e67066372656174650002066973737565720c6163636f756e745f6e616d650e6d6178696d756d5f737570706c79056173736574056973737565000302746f0c6163636f756e745f6e616d65087175616e74697479056173736574046d656d6f06737472696e67076163636f756e7400010762616c616e63650561737365740e63757272656e63795f7374617473000306737570706c790561737365740a6d61785f737570706c79056173736574066973737565720c6163636f756e745f6e616d6503000000572d3ccdcd087472616e73666572bc072d2d2d0a7469746c653a20546f6b656e205472616e736665720a73756d6d6172793a205472616e7366657220746f6b656e732066726f6d206f6e65206163636f756e7420746f20616e6f746865722e0a69636f6e3a2068747470733a2f2f63646e2e746573746e65742e6465762e62316f70732e6e65742f746f6b656e2d7472616e736665722e706e6723636535316566396639656563613334333465383535303765306564343965373666666631323635343232626465643032353566333139366561353963386230630a2d2d2d0a0a2323205472616e73666572205465726d73202620436f6e646974696f6e730a0a492c207b7b66726f6d7d7d2c20636572746966792074686520666f6c6c6f77696e6720746f206265207472756520746f207468652062657374206f66206d79206b6e6f776c656467653a0a0a312e204920636572746966792074686174207b7b7175616e746974797d7d206973206e6f74207468652070726f6365656473206f66206672617564756c656e74206f722076696f6c656e7420616374697669746965732e0a322e2049206365727469667920746861742c20746f207468652062657374206f66206d79206b6e6f776c656467652c207b7b746f7d7d206973206e6f7420737570706f7274696e6720696e6974696174696f6e206f662076696f6c656e636520616761696e7374206f74686572732e0a332e2049206861766520646973636c6f73656420616e7920636f6e747261637475616c207465726d73202620636f6e646974696f6e732077697468207265737065637420746f207b7b7175616e746974797d7d20746f207b7b746f7d7d2e0a0a4920756e6465727374616e6420746861742066756e6473207472616e736665727320617265206e6f742072657665727369626c6520616674657220746865207b7b247472616e73616374696f6e2e64656c61795f7365637d7d207365636f6e6473206f72206f746865722064656c617920617320636f6e66696775726564206279207b7b66726f6d7d7d2773207065726d697373696f6e732e0a0a4966207468697320616374696f6e206661696c7320746f20626520697272657665727369626c7920636f6e6669726d656420616674657220726563656976696e6720676f6f6473206f722073657276696365732066726f6d20277b7b746f7d7d272c204920616772656520746f206569746865722072657475726e2074686520676f6f6473206f72207365727669636573206f7220726573656e64207b7b7175616e746974797d7d20696e20612074696d656c79206d616e6e65722e0000000000a531760569737375650000000000a86cd445066372656174650002000000384f4d113203693634010863757272656e6379010675696e743634076163636f756e740000000000904dc603693634010863757272656e6379010675696e7436340e63757272656e63795f737461747300000000"
        transactionSignatureRequest.abis = []
        transactionSignatureRequest.isModificationAllowed = true
        var request = EosioReferenceAuthenticatorSignatureProvider.Request()
        request.transactionSignature = transactionSignatureRequest
        request.selectiveDisclosure = nil

        requestPayload.request = request

        // encode the payload
        let encoder = JSONEncoder()
        guard let encodedPayload = try? encoder.encode(requestPayload) else {
            XCTFail("Error encoding request payload.")
            return
        }

        XCTAssert(encodedPayload.hex == "7b226465636c61726564446f6d61696e223a226d792e6578616d706c652e636f6d222c226964223a2246383535323645412d373237442d344139362d423133412d383937373745383539303633222c227265717569726542696f6d6574726963223a66616c73652c2272657175657374223a7b227472616e73616374696f6e5369676e6174757265223a7b22636861696e4964223a2236383766613531336531383834336164336538323037343466346666636639336231333534303336643830373337646238646334343466653462313561643137222c2261626973223a5b5d2c2273657269616c697a65645472616e73616374696f6e223a22796e374d58477275784345695551414141414142414b61434e4150714d465541414142584c547a4e7a5145417271704b77567a39525141414141436f375449795a414375716b72425850314641414141594e49307a54326761415941414141414141524654314d41414141415131646f5a5734676557393149474e68626942305957746c4948526f5a5342775a574a69624755675a6e4a76625342746553426f5957356b4c434270644342336157787349474a6c49485270625755676447386762475668646d5541222c227075626c69634b657973223a5b22454f53356a36375031573252794258414c38734e7a5963444c6f7833794c7078797278676b5979317873587a5643767a6259706261225d2c2269734d6f64696669636174696f6e416c6c6f776564223a747275657d7d2c2272657475726e55726c223a226d796578616d706c653a5c2f5c2f227d")
    }

    // swiftlint:enable line_length
}