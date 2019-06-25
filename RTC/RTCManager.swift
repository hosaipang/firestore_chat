//
//  RTCManager.swift
//  RTC
//
//  Created by king on 29/4/2019.
//  Copyright © 2019 Real. All rights reserved.
//

import Foundation
import WebRTC

class RTCManager: NSObject, RTCPeerConnectionDelegate {
    func setup() {
        let configuration = RTCConfiguration()
        let iceServer = RTCIceServer(urlStrings: ["stun:stun1.l.google.com:19302"])
        configuration.iceServers = [iceServer]
        let constraint = RTCMediaConstraints(mandatoryConstraints: nil, optionalConstraints: nil)
        let pcFactory = RTCPeerConnectionFactory()
        let _ = pcFactory.peerConnection(with: configuration, constraints: constraint, delegate: self)
    }
}

extension RTCManager {
    func peerConnection(_ peerConnection: RTCPeerConnection, didChange stateChanged: RTCSignalingState) {
        
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didAdd stream: RTCMediaStream) {
        
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didRemove stream: RTCMediaStream) {
        
    }
    
    func peerConnectionShouldNegotiate(_ peerConnection: RTCPeerConnection) {
        
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didChange newState: RTCIceConnectionState) {
        
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didChange newState: RTCIceGatheringState) {
        
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didGenerate candidate: RTCIceCandidate) {
        
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didRemove candidates: [RTCIceCandidate]) {
        
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didOpen dataChannel: RTCDataChannel) {
        
    }
    
}
