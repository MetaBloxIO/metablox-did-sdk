//
//  DataModel.swift
//  MetabloxDID
//
//  Created by TORA on 2022-05-26.
//

import Foundation
import MetabloxDID.DID

public struct VCCoreModel : Codable {
    public init(context: [String], id: String, type: [String], subType: String, issuer: String, issuanceDate: String, expirationDate: String, description: String, credentialSubject: [String], vcProof: CoreProofModel, revoked: Bool) {
        self.context = context
        self.id = id
        self.type = type
        self.subType = subType
        self.issuer = issuer
        self.issuanceDate = issuanceDate
        self.expirationDate = expirationDate
        self.description = description
        self.credentialSubject = credentialSubject
        self.vcProof = vcProof
        self.revoked = revoked
    }
    
    public var context: [String]
    public var id: String
    public var type: [String]
    public var subType: String
    public var issuer: String
    public var issuanceDate: String
    public var expirationDate: String
    public var description: String
    public var credentialSubject: [String]
    public var vcProof: CoreProofModel
    public var revoked: Bool
}

extension VCCoreModel {
    public init(vc: UnsafeMutablePointer<VC>) {
        context = toArray(ptr: vc.pointee.context, length: Int(vc.pointee.count_context))
        id = String(cString: &vc.pointee.id.0, encoding: .utf8) ?? ""
        type = toArray(ptr: vc.pointee.type, length: Int(vc.pointee.count_type))
        subType = String(cString: &vc.pointee.sub_type.0, encoding: .utf8) ?? ""
        issuer = String(cString: &vc.pointee.issuer.0, encoding: .utf8) ?? ""
        issuanceDate = String(cString: &vc.pointee.issuance_data.0, encoding: .utf8) ?? ""
        expirationDate = String(cString: &vc.pointee.expiration_data.0, encoding: .utf8) ?? ""
        description = String(cString: &vc.pointee.description.0, encoding: .utf8) ?? ""
        credentialSubject = toArray(ptr: vc.pointee.CredentialSubject, length: Int(vc.pointee.count_subject))
        vcProof = CoreProofModel(vcProof: &vc.pointee.vcProof)
        revoked = (vc.pointee.revoked != 0)
    }
    
    public func toCStruct() -> UnsafeMutablePointer<VC>? {
        let contextptr = UnsafePointer(toDoublePtr(strArr: context))
        let typeptr = UnsafePointer(toDoublePtr(strArr: type))
        let credentialSubjectPtr =  UnsafePointer(toDoublePtr(strArr: credentialSubject))
        let vc = new_vc(contextptr, Int32(context.count), id, typeptr, Int32(type.count), subType, issuer, issuanceDate, expirationDate, description, credentialSubjectPtr, Int32(credentialSubject.count), vcProof.toVCProof(), revoked ? 1 : 0)
        return vc
    }
}

public struct VPCoreModel: Codable{
    public init(context: [String], type: [String], vc: [VCCoreModel], holder: String, vpProof: CoreProofModel) {
        self.context = context
        self.type = type
        self.vc = vc
        self.holder = holder
        self.vpProof = vpProof
    }
    
    public var context: [String]
    public var type: [String]
    public var vc: [VCCoreModel]
    public var holder: String
    public var vpProof: CoreProofModel
}

extension VPCoreModel {
    public init(vp: UnsafeMutablePointer<VP>) {
        context = toArray(ptr: vp.pointee.context, length: Int(vp.pointee.count_context))
        type = toArray(ptr: vp.pointee.type, length: Int(vp.pointee.count_type))
        holder = String(cString: &vp.pointee.holder.0, encoding: .utf8) ?? ""
        vc = []
        let vcCount = Int(vp.pointee.count_vc)
        for i in 0..<vcCount {
            let vcPtr = vp.pointee.vc[i]
            let c = VCCoreModel(vc: vcPtr!)
            vc.append(c)
        }
        vpProof = CoreProofModel(vpProof: &vp.pointee.vpProof)
    }
    
    public func toCStruct() -> UnsafeMutablePointer<VP>? {
        let contextptr = UnsafePointer(toDoublePtr(strArr: context))
        let typeptr = UnsafePointer(toDoublePtr(strArr: type))
        
        let vcPtr = UnsafeMutablePointer<UnsafeMutablePointer<VC>?>.allocate(capacity: vc.count)
        var vcArr = vc.map {
            $0.toCStruct()
        }
        vcArr.append(nil)
        vcPtr.initialize(from: vcArr, count: vc.count)
        
        let vp = new_vp(contextptr, Int32(context.count), typeptr, Int32(type.count), UnsafePointer(vcPtr), Int32(vc.count), holder, vpProof.toVPProof())
        
        return vp
    }
}

let pubkeyLength = 65
public struct CoreProofModel : Codable {
    public init(type: String, created: String, verificationMethod: String, proofPurpose: String, publicKey: String, JWSSignature: String, nonce: String? = nil) {
        self.type = type
        self.created = created
        self.verificationMethod = verificationMethod
        self.proofPurpose = proofPurpose
        self.publicKey = publicKey
        self.JWSSignature = JWSSignature
        self.nonce = nonce
    }
    
    public var type: String
    public var created: String
    public var verificationMethod: String
    public var proofPurpose: String
    public var publicKey: String
    public var JWSSignature: String
    public var nonce: String?
    
    public init(vcProof: UnsafeMutablePointer<VCProof>) {
        type = String(cString: &vcProof.pointee.type.0, encoding: .utf8) ?? ""
        created = String(cString: &vcProof.pointee.created.0, encoding: .utf8) ?? ""
        verificationMethod = String(cString: &vcProof.pointee.verification_method.0, encoding: .utf8) ?? ""
        proofPurpose = String(cString: &vcProof.pointee.proof_purpose.0, encoding: .utf8) ?? ""
        publicKey = Data(bytes: &vcProof.pointee.public_key.0, count: pubkeyLength).base64EncodedString()
        JWSSignature = String(cString: &vcProof.pointee.JWSSignature.0, encoding: .utf8) ?? ""
        nonce = nil
    }
    
    public init(vpProof: UnsafeMutablePointer<VPProof>) {
        type = String(cString: &vpProof.pointee.type.0, encoding: .utf8) ?? ""
        created = String(cString: &vpProof.pointee.created.0, encoding: .utf8) ?? ""
        verificationMethod = String(cString: &vpProof.pointee.verification_method.0, encoding: .utf8) ?? ""
        proofPurpose = String(cString: &vpProof.pointee.proof_purpose.0, encoding: .utf8) ?? ""
        publicKey = Data(bytes: &vpProof.pointee.public_key.0, count: pubkeyLength).base64EncodedString()
        JWSSignature = String(cString: &vpProof.pointee.JWSSignature.0, encoding: .utf8) ?? ""
        nonce = String(cString: &vpProof.pointee.nonce.0, encoding: .utf8)
    }
    
    public func toVCProof()-> UnsafeMutablePointer<VCProof>? {
        let pubkey = Data(base64Encoded: publicKey)?.toBytesCopy()
        defer {
            pubkey?.deallocate()
        }
        let p = new_vc_proof(type, created, verificationMethod, proofPurpose, JWSSignature, pubkey)
        return p
    }

    public func toVPProof()-> UnsafeMutablePointer<VPProof>? {
        let pubkey = Data(base64Encoded: publicKey)?.toBytesCopy()
        defer {
            pubkey?.deallocate()
        }
        let p = new_vp_proof(type, created, verificationMethod, proofPurpose, JWSSignature, nonce ?? "", pubkey)
        return p
    }
}