//
//  Icon.swift
//  HyperCard
//
//  Created by Pierre Lorenzi on 13/02/2016.
//  Copyright © 2016 Pierre Lorenzi. All rights reserved.
//


/// Parsed icon resource
public class IconResourceBlock: ResourceBlock {
    
    public override class var Name: NumericName {
        return NumericName(string: "ICON")!
    }
    
    /// Image of the icon
    public func readImage() -> Image {
    
        /* Build an image with the data of the row */
        return Image(data: self.data.sharedData, offset: self.data.offset, width: IconSize, height: IconSize)
    }
    
    
}
