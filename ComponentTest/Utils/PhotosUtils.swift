//
//  PhotosUtils.swift
//  gs cool
//
//  Created by zou jingbo on 2021/9/13.
//  Copyright © 2021 Greysh Co., Ltd. All rights reserved.
//

import Foundation
import UIKit
import Photos

class PhotoUtils:NSObject{
    static let shared = PhotoUtils()
    
    //验证权限
    func verifyAuthority(){
        let library = PHPhotoLibrary.authorizationStatus()
        
        if library == .authorized{  //有权限，进行接下来的操作
            print("有权限")
        }else if library == .denied || library == .restricted{  //没有权限，提醒用户去设置中打开
            print("没有权限")
        }else{ //library == .notDetermined，第一次使用系统让用户选择开放权限时，用户选择了否，可以重新选择调出一次，这样做不用去设置中打开
            PHPhotoLibrary.requestAuthorization { status in
                if status == .authorized{ //如果用户这次授予了权限，执行接下来的操作
        
                }else{ //否则，提示操作执行失败
                    
                }
            }
        }
    }
    
    //枚举保存图片到相册的结果
    enum PhotoAlbumUtilResult {
        case success
        case error
        case denied
    }
    
    //保存图片到指定相册相册
    func saveImgToAlbum(img:UIImage, albumName: String? = nil ,completion: ((_ result: PhotoAlbumUtilResult) -> ())?) -> String?{
        //前提是经过了权限验证
        
        var assetAlbum: PHAssetCollection?
        var localId:String? // 用于保存图片的标识
        
        //如果没有传相册的名字，则保存到相机胶卷。（否则保存到指定相册）
        if albumName == nil || albumName!.isEmpty{
            print("没有传相册的名字")
        }else{
            //看保存的指定相册是否存在
            let albumList = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: nil)
            albumList.enumerateObjects { (album, index, stop) in
                let assetCollection = album
                if albumName == assetCollection.localizedTitle {
                    assetAlbum = assetCollection
                    stop.initialize(to: true)
                }
            }
            
            //不存在的话则创建该相册
            if  assetAlbum == nil{
                PHPhotoLibrary.shared().performChanges {
                    PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: albumName!)
                } completionHandler: { [self] (isSuccess, error) in
                    localId = saveImgToAlbum(img: img,albumName: albumName, completion: completion)
                }
                
                return localId
            }
        }
        
        
        //保存图片到系统相册或者特定相册，保存后返回该图片资源的标识符
        //所以到底是两个地方都有？还是从系统相册逻辑上移到了特定相册？
        PHPhotoLibrary.shared().performChanges {
            //添加到系统相机胶卷
            let result = PHAssetChangeRequest.creationRequestForAsset(from: img)
            let assetPlaceholder = result.placeholderForCreatedAsset
            //是否要添加到相簿
            if !albumName!.isEmpty{
                let albumChangeRequest = PHAssetCollectionChangeRequest(for: assetAlbum!)
                albumChangeRequest!.addAssets([assetPlaceholder!] as NSArray)
            }
            //保存资源标志符
            localId = assetPlaceholder?.localIdentifier
        } completionHandler: { (isSuccess, error) in
            if isSuccess{
                print("保存成功")
                completion?(.success)
            }else{
                print("保存失败")
                print(error!.localizedDescription)
                completion?(.error)
            }
        }
        
        return localId
    }
    
    //通过标识符获取对应的资源
    func getAssetByLocalId(localId:String?) -> PHAsset?{
        var asset:PHAsset?
        if let localId = localId{
            let assetResult = PHAsset.fetchAssets(withLocalIdentifiers: [localId], options: nil)
            asset = assetResult[0]
        }else{
            print("不存在该资源")
        }
        
        return asset
    }
    
    //通过标识符获取照片的路径
    func getImgPath(localId:String?) -> URL?{
        //通过标识符获取对应的资源
        let asset = getAssetByLocalId(localId: localId)
        
        let options = PHContentEditingInputRequestOptions()
        options.canHandleAdjustmentData = { (adjustMeta:PHAdjustmentData) -> Bool in
            return true
        }
        
        //获取保存图片的路径
        var imgURL:URL?
        if let asset = asset{
            asset.requestContentEditingInput(with: options) { (contentEditingInput:PHContentEditingInput?, info: [AnyHashable : Any]) in
//                print("地址: ",contentEditingInput!.fullSizeImageURL!)
                imgURL =  contentEditingInput?.fullSizeImageURL
            }
        }
        
        return imgURL
    }
    
    func getOriginImg(asset:PHAsset) -> UIImage?{
        let options = PHContentEditingInputRequestOptions()
        options.canHandleAdjustmentData = { (adjustMeta:PHAdjustmentData) -> Bool in
            return true
        }
        
        //获取保存的原图
        //如果targetSize大于原图尺寸，则只返回原图
        //PHImageManagerMaximumSize，表示可选范围内最大的尺寸，即原图尺寸，如果设置该值为targetSize，则contentMode无论怎么设置都是default
        //options：一个PHImageRequestOptions的实例，可以控制的内容相当丰富，包括图像的质量、版本，也会有参数控制图像的裁剪
        //requestHandler 请求结束后被调用block，返回一个包含资源对于图形的UIImage和包含图像信息的一个NSDictionary
        //默认情况下requestImage是异步执行的
        var originImage:UIImage?
        PHImageManager.default().requestImage(for: asset, targetSize: PHImageManagerMaximumSize, contentMode: .aspectFit, options: nil) { (image, _: [AnyHashable : Any]?) in
//            print("获取原图成功")
            originImage = image
        }
        
        return originImage
    }
    
    //获取照片的原图
    func getOriginImgById(localId:String?) -> UIImage?{
        //通过标识符获取对应的资源
        let asset = getAssetByLocalId(localId: localId)
        
        let options = PHContentEditingInputRequestOptions()
        options.canHandleAdjustmentData = { (adjustMeta:PHAdjustmentData) -> Bool in
            return true
        }
        
        //获取保存的原图
        //如果targetSize大于原图尺寸，则只返回原图
        //PHImageManagerMaximumSize，表示可选范围内最大的尺寸，即原图尺寸，如果设置该值为targetSize，则contentMode无论怎么设置都是default
        //options：一个PHImageRequestOptions的实力，可以控制的内容相当丰富，包括图像的质量、版本，也会有参数控制图像的裁剪
        //requestHandler 请求结束后被调用block，返回一个包含资源对于图形的UIImage和包含图像信息的一个NSDictionary
        //默认情况下requestImage是异步执行的
        var originImage:UIImage?
        if let asset = asset{
            PHImageManager.default().requestImage(for: asset, targetSize: PHImageManagerMaximumSize, contentMode: .aspectFit, options: nil) { (image, _: [AnyHashable : Any]?) in
//                print("获取原图成功")
                originImage = image
            }
        }
        return originImage
    }
    
    //根据asset获取照片的缩略图
    func getThumbnail(asset:PHAsset,targetSize:CGSize) -> UIImage?{
        
        let size = CGSize(width: targetSize.width * UIScreen.main.scale, height: targetSize.height * UIScreen.main.scale)
        
        let options = PHImageRequestOptions()
        options.deliveryMode = .highQualityFormat
        //返回一个单一结果，返回前会堵塞线程，默认是false
        options.isSynchronous = true
        options.isNetworkAccessAllowed = true
        
        //获取保存的缩略图
        var thumbnail:UIImage?
        PHImageManager.default().requestImage(for: asset, targetSize: size, contentMode: .aspectFit, options: options) { (image, _:[AnyHashable : Any]?) in
//            print("获取缩略图成功")
            thumbnail = image
        }
        
        return thumbnail
    }
    
    //根据ID获取照片的缩略图
    func getThumbnailById(localId:String?,targetSize:CGSize) -> UIImage?{
        //通过标识符获取对应的资源
        let asset = getAssetByLocalId(localId: localId)
        
        let size = CGSize(width: targetSize.width * UIScreen.main.scale, height: targetSize.height * UIScreen.main.scale)
        
        let options = PHImageRequestOptions()
        options.deliveryMode = .highQualityFormat
        //返回一个单一结果，返回前会堵塞线程，默认是false
        options.isSynchronous = true
        options.isNetworkAccessAllowed = true
        
        //获取保存的缩略图
        var thumbnail:UIImage?
        if let asset = asset{
            PHImageManager.default().requestImage(for: asset, targetSize: size, contentMode: .aspectFit, options: options) { (image, _:[AnyHashable : Any]?) in
//                print("获取缩略图成功")
                thumbnail = image
            }
        }
        
        return thumbnail
    }
    
    //获取相册
    func getAlbums(type:PHAssetCollectionType, subtype:PHAssetCollectionSubtype) -> [PHAssetCollection]{
        var assetCollectionArr = Array<PHAssetCollection>()
        let smartAlbums = PHAssetCollection.fetchAssetCollections(with: type, subtype: subtype, options: nil)
        smartAlbums.enumerateObjects { assetCollection, id, stop in
            assetCollectionArr.append(assetCollection)
        }
        
        return assetCollectionArr
    }
    
    //获取所有相册
    func getAllAlbums() -> [PHAssetCollection]{
        var assetCollectionArr = Array<PHAssetCollection>()
        
        let smartAlbums = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumUserLibrary, options: nil)
        smartAlbums.enumerateObjects { assetCollection, id, stop in
            assetCollectionArr.append(assetCollection)
        }
        
        let album = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .albumRegular, options: nil)
        album.enumerateObjects { assetCollection, id, stop in
            assetCollectionArr.append(assetCollection)
        }
        
        return assetCollectionArr
    }
    
    //获取某特定相册
    func getAlbumByName(albumName:String) -> PHAssetCollection?{
        var assetCollection:PHAssetCollection?
        
        //遍历相机相册
        let albums = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumUserLibrary, options: nil)
        albums.enumerateObjects {collection, id, stop in
            if collection.localizedTitle == albumName{
                assetCollection = collection
                stop.initialize(to: true)
            }
        }
        
        if assetCollection != nil{
            return assetCollection
        }

        //遍历用户自定义的相册
        let smartAlbums = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .albumRegular, options: nil)
        smartAlbums.enumerateObjects { collection, id, stop in
            if collection.localizedTitle == albumName{
                assetCollection = collection
                stop.initialize(to: true)
            }
        }
        
        return assetCollection
    }
    
    //获取某相册的照片数量
    func getAssetNumberOfCollection(albumName:String) -> Int{
        
        //获取该albumName对应的相册
        let collection = getAlbumByName(albumName: albumName)
        
        //获取该相册中所有的PHAsset
        if let collection = collection{
            let result = PHAsset.fetchAssets(in: collection, options: nil)
            
            return result.count
        }
        
        return 0
    }
    
    //获取所有照片资源
    func getAllAssetInAlbumWithAscending(ascending:Bool) -> [PHAsset]{
        var assetArr = Array<PHAsset>()
        
        let options = PHFetchOptions()
        //ascending为true是，照片按照创建事件升序排列，为false时为降序排列
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        let result = PHAsset.fetchAssets(with: .image, options: options)
        result.enumerateObjects { assetObj, id, stop in
            assetArr.append(assetObj)
        }
        
        return assetArr
    }
    
    //获取某个相册下的所有照片对象
    func getAssetOfCollection(collection:PHAssetCollection, asceding:Bool) -> [PHAsset]{
        var assetArr = Array<PHAsset>()
        
        let options = PHFetchOptions()
        //ascending为true是，照片按照创建事件升序排列，为false时为降序排列
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: asceding)]
        
        //获取该相册中所有的PHAsset
        let result = PHAsset.fetchAssets(in: collection, options: options)
        result.enumerateObjects { (asset, id, stop) in
            assetArr.append(asset)
        }
        
        return assetArr
    }
    
    //获取某个相册下的的所有照片对象
    func getAssetFromAlbumByAlbumName(albumName:String, asceding:Bool) -> [PHAsset]{
        var assetArr = Array<PHAsset>()
        
        //获取该albumName对应的相册
        let collection = getAlbumByName(albumName: albumName)
        
        let options = PHFetchOptions()
        //ascending为true是，照片按照创建事件升序排列，为false时为降序排列
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: asceding)]
        
        //获取该相册中所有的PHAsset
        if let collection = collection{
            let result = PHAsset.fetchAssets(in: collection, options: options)
            result.enumerateObjects { (asset, id, stop) in
                assetArr.append(asset)
            }
        }
        
        return assetArr
    }
    
    //验证该图片是否在本地（若开启了iCloud照片存储，则照片会定时上传到网上，本地不存在）
    func isInLocalAlbum(asset:PHAsset) -> Bool{
        var isInLocalAlbum:Bool = true
        
        let options = PHImageRequestOptions()
        options.isNetworkAccessAllowed = false
        options.isSynchronous = true
        
        PHCachingImageManager.default().requestImageDataAndOrientation(for: asset, options: options) { (imageData, dataUTI, orientation, info) in
            isInLocalAlbum = imageData != nil ? true : false
        }
    
        return isInLocalAlbum
    }
    
    //删除
    func deleteAsset(localIds:[String]){
        let result = PHAsset.fetchAssets(withLocalIdentifiers: localIds, options: nil)
        PHPhotoLibrary.shared().performChanges {
            PHAssetChangeRequest.deleteAssets(result)
        } completionHandler: { (isSuccess, error) in
            if isSuccess{
                print("删除成功")
            }else{
                print("删除失败")
                print(error!.localizedDescription)
            }
        }
    }
    
    //编辑
//    func editAsset(asset:PHAsset){
//        PHPhotoLibrary.shared().performChanges {
//            let request = PHAssetChangeRequest()
//            let output:PHContentEditingOutput? = request.contentEditingOutput
//        } completionHandler: { (isSuccess, error) in
//            if isSuccess{
//                print("删除成功")
//            }else{
//                print("删除失败")
//                print(error!.localizedDescription)
//            }
//        }
//    }
}
