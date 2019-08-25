//
//  Resource.swift
//  HyperCard
//
//  Created by Pierre Lorenzi on 28/02/2017.
//  Copyright © 2017 Pierre Lorenzi. All rights reserved.
//


/// A resource in a resource fork.
public class Resource {
    
    /// The identifier
    public let identifier: Int
    
    /// The name
    public let name: HString
    
    /// The type identifier, read in the content
    public let typeIdentifier: Int
    
    /// The data contained in the resource
    private var content: Content
    
    private enum Content {
        
        case value(Any)
        case notDecoded(DataRange)
        case notLoaded(() -> Any)
    }
    
    public init(identifier: Int, name: HString, typeIdentifier: Int, data: DataRange) {
        self.identifier = identifier
        self.name = name
        self.typeIdentifier = typeIdentifier
        self.content = Content.notDecoded(data)
    }
    
    public init(identifier: Int, name: HString, typeIdentifier: Int, value: Any) {
        self.identifier = identifier
        self.name = name
        self.typeIdentifier = typeIdentifier
        self.content = Content.value(value)
    }
    
    public init<T>(identifier: Int, name: HString, typeIdentifier: Int, lazyLoad: @escaping () -> T) {
        self.identifier = identifier
        self.name = name
        self.typeIdentifier = typeIdentifier
        self.content = Content.notLoaded(lazyLoad)
    }
    
    public func isDecoded() -> Bool {
        
        switch self.content {
            
        case .value:
            return true
            
        case .notLoaded:
            return true
            
        case .notDecoded:
            return false
        }
    }
    
    public func getData() -> DataRange {
        
        guard case Content.notDecoded(let data) = self.content else {
            fatalError()
        }
        
        return data
    }
    
    public func getContent<T: ResourceContent>() -> T {
        
        switch self.content {
            
        case .value(let value):
            return value as! T
            
        case .notDecoded(let data):
            let value = T(loadFromData: data)
            self.content = Content.value(value)
            return value
            
        case .notLoaded(let loadAction):
            let value = loadAction()
            self.content = Content.value(value)
            return value as! T
        }
        
    }
}

public protocol ResourceContent {
    
    init(loadFromData: DataRange)
}

public enum ResourceTypes {
    
    public static let icon = 0x49434F4E // ICON
    public static let fontFamily = 0x464F4E44 // FOND
    public static let bitmapFont = 0x4E464E54 // NFNT
    public static let bitmapFontOld = 0x464F4E54 // FONT
    public static let vectorFont = 0x73666E74 // sfnt
    public static let cardColor = 0x48436364 // HCcd
    public static let backgroundColor = 0x48436267 // HCbg
    public static let picture = 0x50494354 // PICT
}

/* The shortcut functions */
public extension Resource {
    
    func getIcon() -> Icon {
        
        return getContent()
    }
    
    func getFontFamily() -> FontFamily {
        
        return getContent()
    }
    
    func getBitmapFont() -> BitmapFont {
        
        return getContent()
    }
    
    func getVectorFont() -> VectorFont {
        
        return getContent()
    }
    
    func getColor() -> LayerColor {
        
        return getContent()
    }
    
    func getPicture() -> Picture {
        
        return getContent()
    }
    
}
