//
//  DataObject.swift
//  HyperCard
//
//  Created by Pierre Lorenzi on 12/02/2016.
//  Copyright © 2016 Pierre Lorenzi. All rights reserved.
//

import Foundation


/// An object pointing to a section of a data
public struct DataRange {
    
    /// The data pointed by by the object
    public let sharedData: Data
    
    /// The start of the pointed section
    public let offset: Int
    
    /// The length of the pointed section
    public let length: Int
    
    /// Main constructor, declared to be public
    public init(sharedData: Data, offset: Int, length: Int) {
        self.sharedData = sharedData
        self.offset = offset
        self.length = length
    }
    
    /// Reads a unsigned byte in the pointed data
    public func readUInt8(at offset: Int) -> Int {
        return self.sharedData.readUInt8(at: self.offset + offset)
    }
    
    /// Reads a signed byte in the pointed data
    public func readSInt8(at offset: Int) -> Int {
        return self.sharedData.readSInt8(at: self.offset + offset)
    }
    
    /// Reads a big-endian unsigned 2-byte integer in the pointed data
    public func readUInt16(at offset: Int) -> Int {
        return self.sharedData.readUInt16(at: self.offset + offset)
    }
    
    /// Reads a big-endian signed 2-byte integer in the pointed data
    public func readSInt16(at offset: Int) -> Int {
        return self.sharedData.readSInt16(at: self.offset + offset)
    }
    
    /// Reads a big-endian unsigned 4-byte integer in the pointed data
    public func readUInt32(at offset: Int) -> Int {
        return self.sharedData.readUInt32(at: self.offset + offset)
    }
    
    /// Reads a big-endian signed 4-byte integer in the pointed data
    public func readSInt32(at offset: Int) -> Int {
        return self.sharedData.readSInt32(at: self.offset + offset)
    }
    
}


public extension DataRange {
    
    /// Reads a bit inside a big-endian 2-byte integer in the pointed data
    public func readFlag(at offset: Int, bitOffset: Int) -> Bool {
        
        let flags = readUInt16(at: offset)
        return (flags & (1 << bitOffset)) != 0
    }
    
    /// Reads a 2D rectangle in the pointed data
    public func readRectangle(at offset: Int) -> Rectangle {
        /* Sometimes a flag is added to top bit, so remove it */
        let top = self.readUInt16(at: offset) & 0x7FFF
        let left = self.readUInt16(at: offset + 2) & 0x7FFF
        let bottom = self.readUInt16(at: offset + 4) & 0x7FFF
        let right = self.readUInt16(at: offset + 6) & 0x7FFF
        return Rectangle(top: top, left: left, bottom: bottom, right: right)
    }
    
    /// Reads a null-terminated Mac OS Roman string in the pointed data
    public func readString(at offset: Int) -> HString {
        return HString(copyNullTerminatedFrom: sharedData, at: self.offset + offset)
    }
    
    /// Reads a Mac OS Roman string in the pointed data
    public func readString(at offset: Int, length: Int) -> HString {
        return HString(copyFrom: sharedData, at: self.offset + offset, length: length)
    }
    
}

public extension Data {
    
    /// Reads a unsigned byte
    public func readUInt8(at offset: Int) -> Int {
        return Int(self[offset])
    }
    
    /// Reads a signed byte
    public func readSInt8(at offset: Int) -> Int {
        let value = readUInt8(at: offset)
        if value > Int(Int8.max) {
            return value - Int(UInt8.max) - 1
        }
        return value
    }
    
    /// Reads a big-endian unsigned 2-byte integer
    public func readUInt16(at offset: Int) -> Int {
        return Int(self[offset]) << 8 | Int(self[offset+1])
    }
    
    /// Reads a big-endian signed 2-byte integer
    public func readSInt16(at offset: Int) -> Int {
        let value = readUInt16(at: offset)
        if value > Int(Int16.max) {
            return value - Int(UInt16.max) - 1
        }
        return value
    }
    
    /// Reads a big-endian unsigned 4-byte integer
    public func readUInt32(at offset: Int) -> Int {
        return Int(self[offset]) << 24 | Int(self[offset+1]) << 16 | Int(self[offset+2]) << 8 | Int(self[offset+3])
    }
    
    /// Reads a big-endian signed 4-byte integer
    public func readSInt32(at offset: Int) -> Int {
        let value = readUInt32(at: offset)
        if value > Int(Int32.max) {
            return value - Int(UInt32.max) - 1
        }
        return value
    }
    
}

public extension Image {
    
    /// Reads an uncompressed 1-bit image in a data
    public init(data: Data, offset: Int, width: Int, height: Int) {
        
        /* Create the image */
        self.init(width: width, height: height)
        
        /* Optimization if data can be read with 32-bit integers */
        if width & 31 == 0 {
            let count = width * height / 32
            for i in 0..<count {
                self.data[i] = UInt32(data.readUInt32(at: offset + i*4))
            }
            return
        }
        
        /* Fill the rows */
        let rowSize = width / 8
        var integerIndex = 0
        var shift: UInt32 = 24
        var i = offset
        for _ in 0..<height {
            for _ in 0..<rowSize {
                let byte = data[i]
                i += 1
                self.data[integerIndex] |= UInt32(byte) << shift
                if shift == 0 {
                    shift = 24
                    integerIndex += 1
                }
                else {
                    shift -= 8
                }
            }
            if shift != 24 {
                integerIndex += 1
                shift = 24
            }
        }
        
    }
    
}

public extension HString {
    
    /// Init with null-terminated data
    public init(copyNullTerminatedFrom data: Data, at offset: Int) {
        
        /* Find the null termination */
        let dataFromOffset = data.suffix(from: offset)
        let nullIndex = dataFromOffset.index(of: UInt8(0))!
        
        /* Extract the data for the string */
        let stringSlice = data[offset..<nullIndex]
        let stringData = Data(stringSlice)
        
        self.init(data: stringData)
    }
    
    /// Init with data
    public init(copyFrom data: Data, at offset: Int, length: Int) {
        
        /* Extract the data for the string */
        let stringSlice = data[offset..<offset + length]
        let stringData = Data(stringSlice)
        
        self.init(data: stringData)
    }
    
}