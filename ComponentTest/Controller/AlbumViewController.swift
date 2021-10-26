//
//  AlbumViewController.swift
//  ComponentTest
//
//  Created by zou jingbo on 2021/10/22.
//

import UIKit
import SnapKit
import Photos

class AlbumViewController: UIViewController {
    var navBar:NavBar!
    var navigationBar:UIView!
    
    var dropDownListView:UIView!
    var dropDownSafeView:UIView!
    var tableView:UITableView!
    var tableCellId:String = "TableViewCellId"
    
    var collectionView:UICollectionView!
    var collectionLayout:UICollectionViewFlowLayout!
    var collectionCellId:String = "CollectionCellId"
    
    var oldOrientation:UIDeviceOrientation = .unknown
    var isChoosing: Bool = false{
        didSet{
            if isChoosing != oldValue{
                collectionView.reloadData()
            }
        }
    }
    
    var chosenItems:Set<Int> = []
    
    var collections:[PHAssetCollection]!
    
    var assets:[PHAsset]?{
        didSet{
            collectionView.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        installUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateUI()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension AlbumViewController: NavBarDelegate{
    func openDropDownList() {
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {[self] in
            dropDownListView.transform = CGAffineTransform(translationX: 0, y: -(height - 44 - self.view.safeAreaInsets.top))
        }, completion: nil)
    }
    
    func closeDropDownList() {
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {[self] in
            dropDownListView.transform = CGAffineTransform.identity
        }, completion: nil)
    }
}

extension AlbumViewController: UITableViewDelegate, UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return collections.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCell(withIdentifier: tableCellId)
        if cell == nil{
            cell = UITableViewCell(style: .value1, reuseIdentifier: tableCellId)
        }
        
        cell?.backgroundColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1)
        cell!.contentView.backgroundColor = UIColor.clear
        //设置选中时的背景颜色
        let backView = UIView(frame: CGRect(x: 0, y: 0, width: cell!.frame.width, height: cell!.frame.height))
        backView.backgroundColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)
        cell?.selectedBackgroundView = backView
        
        cell!.textLabel?.textAlignment = .left
        cell!.textLabel?.textColor = UIColor.white
        cell!.textLabel?.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        
        cell!.detailTextLabel?.textAlignment = .right
        cell!.detailTextLabel?.textColor = UIColor.white
        cell!.detailTextLabel?.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        
        let collection = collections[indexPath.row]
        cell!.textLabel?.text = collection.localizedTitle
        cell!.detailTextLabel?.text = "\(PhotoUtils.shared.getAssetNumberOfCollection(albumName: collection.localizedTitle!))"
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        //根据相册名字获取相册中的所有图片的缩略图
        let collection = collections[indexPath.row]
        assets = PhotoUtils.shared.getAssetOfCollection(collection: collection, asceding: true)
    
        self.navBar.isOpen = false
    }
}

extension AlbumViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return assets?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let num: CGFloat = floor((self.view.frame.width + 3) / (cellLength + 3))
        let right: CGFloat = self.view.frame.width - num * (cellLength + 3) + 3
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: right)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: collectionCellId, for: indexPath) as! GSCollectionViewCell
        cell.contentMode = .scaleAspectFill
        cell.clipsToBounds = true
        cell.tag = indexPath.row
        cell.delegate = self
        cell.isChoosing = self.isChoosing
        
        if let assets = assets{
            let asset = assets[indexPath.row]
            cell.image = PhotoUtils.shared.getThumbnail(asset: asset, targetSize: CGSize(width: cellLength, height: cellLength))
            if chosenItems.contains(indexPath.row){
                cell.isChosen = true
            }else{
                cell.isChosen = false
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if chosenItems.contains(indexPath.row){
            chosenItems.remove(indexPath.row)
        }else{
            chosenItems.insert(indexPath.row)
        }
        
        collectionView.reloadItems(at: [indexPath])
    }
}

extension AlbumViewController: GSCollectionViewCellDelegate{
    func beginLongPress(_ sender: UILongPressGestureRecognizer) {
        
    }
    
    func endLongPress(_ sender: UILongPressGestureRecognizer) {
        let cell = sender.view
        self.isChoosing = true
        if let cell = cell{
            chosenItems.insert(cell.tag)
        }
    }
}

extension AlbumViewController{
    
    private func updateUI(){
        navBar.snp.updateConstraints { make in
            make.top.equalTo(self.view.safeAreaInsets.top)
            make.left.equalTo(0)
            make.width.equalToSuperview()
            make.height.equalTo(44)
            make.bottom.equalTo(0)
        }
        
        dropDownListView.snp.updateConstraints { make in
            make.top.equalTo(height)
            make.left.equalTo(0)
            make.width.equalToSuperview()
            make.height.equalTo(height - 44 - self.view.safeAreaInsets.top)
        }
        
        collectionView.snp.updateConstraints { make in
            make.top.equalTo(navigationBar.snp.bottom)
            make.left.equalTo(0)
            make.width.equalToSuperview()
            make.bottom.equalTo(-self.view.safeAreaInsets.bottom)
        }
        
        tableView.snp.updateConstraints { make in
            make.top.equalTo(0)
            make.left.equalTo(0)
            make.width.equalToSuperview()
            make.bottom.equalTo(-self.view.safeAreaInsets.bottom)
        }
    }
    
    private func installUI(){
        self.view.backgroundColor = UIColor.white
        
        navigationBar = UIView()
        navigationBar.backgroundColor = UIColor.white
        self.view.addSubview(navigationBar)
        navigationBar.snp.makeConstraints { make in
            make.top.left.equalTo(0)
            make.width.equalToSuperview()
        }
        
        navBar = NavBar()
        navBar.heading = "Photo Library"
        navBar.delegate = self
        navigationBar.addSubview(navBar)
        navBar.snp.makeConstraints { make in
            make.top.equalTo(self.view.safeAreaInsets.top)
            make.left.equalTo(0)
            make.width.equalToSuperview()
            make.height.equalTo(44)
            make.bottom.equalTo(0)
        }
        
        collectionLayout = UICollectionViewFlowLayout()
        collectionLayout.scrollDirection = .vertical
        collectionLayout.itemSize = CGSize(width: cellLength, height: cellLength)
        collectionLayout.minimumLineSpacing = 3
        collectionLayout.minimumInteritemSpacing = 3
        collectionView = UICollectionView(frame: CGRect(x: 0, y: 44 + self.view.safeAreaInsets.top, width: width, height: height - (44 + self.view.safeAreaInsets.top)), collectionViewLayout: collectionLayout)
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = UIColor(red: 0.97, green: 0.97, blue: 0.97, alpha: 1)
        collectionView.register(GSCollectionViewCell.self, forCellWithReuseIdentifier: collectionCellId)
        self.view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(navigationBar.snp.bottom)
            make.left.equalTo(0)
            make.width.equalToSuperview()
            make.bottom.equalTo(-self.view.safeAreaInsets.bottom)
        }
        
        dropDownListView = UIView()
        dropDownListView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.4)
        self.view.addSubview(dropDownListView)
        dropDownListView.snp.makeConstraints { make in
            make.top.equalTo(height)
            make.left.equalTo(0)
            make.width.equalToSuperview()
            make.height.equalTo(height - 44 - self.view.safeAreaInsets.top)
        }
        
        dropDownSafeView = UIView()
        dropDownSafeView.backgroundColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1)
        dropDownListView.addSubview(dropDownSafeView)
        dropDownSafeView.snp.makeConstraints { make in
            make.top.equalTo(0)
            make.left.equalTo(0)
            make.width.equalToSuperview()
            make.bottom.equalTo(0)
        }
        
        tableView = UITableView()
        tableView.backgroundColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1)
        tableView.dataSource = self
        tableView.delegate = self
        dropDownListView.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.top.equalTo(0)
            make.left.equalTo(0)
            make.width.equalToSuperview()
            make.bottom.equalTo(-self.view.safeAreaInsets.bottom)
        }
        
        //获取系统相册
        collections = PhotoUtils.shared.getAllAlbums()
        
        //监听横竖屏切换
        NotificationCenter.default.addObserver(self, selector: #selector(orientationChanged), name: UIDevice.orientationDidChangeNotification, object: nil)
    }
    
    @objc private func orientationChanged(_ sender: Notification){
        let orientation = UIDevice.current.orientation
        
        if oldOrientation != orientation{
            switch orientation {
            case .portrait, .landscapeLeft, .landscapeRight:
                collectionView.reloadData()
                oldOrientation = orientation
            default:
                break
            }
        }
    }
}
