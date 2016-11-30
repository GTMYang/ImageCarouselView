//
//  ImageCarouselView.swift
//  Ollix
//
//  Created by luoyang on 2016/11/29.
//  Copyright © 2016年 syncsoft. All rights reserved.
//

import UIKit

public enum PageControlAliment {
    case bottomLeft
    case bottomCenter
    case bottomRight
    case topRight
}

public protocol ImageCarouselViewDelegate: class {
    func imageCarouselView(_ imageCarouselView: ImageCarouselView, didSelectItemAt index:Int)
    // 设置网络图的方法(这里将图片设置方法交给代理，避免本控件依赖网络库)
    func setImageForImageView(imageV: UIImageView, byUrlString: String?, placeholderImage:UIImage?)
    // 取出图片数据里面的文本字段值
    func titleForData(_ imageData:Any) -> String
    // 取出图片数据里面的图片Url字段值
    func imageUrlStringForData(_ imageData:Any) -> String
}

public class ImageCarouselView: UIView {
    //========================================================
    // MARK: - 暴露的属性
    //========================================================
    // 代理
    public weak var delegate: ImageCarouselViewDelegate?
    // 数据
    public var imageArray: [Any] = [] {
        didSet {
            self.virtualItemCount = imageArray.count * 100
            self.pageControl.numberOfPages = imageArray.count
            self.reloadData()
        }
    }
    // 是否自动播放(默认false)
    public var isAutoScroll: Bool = false {
        didSet {
            self.autoScrollTimer?.invalidate() //先取消先前定时器
            if isAutoScroll {
                self.setupTimer()   //重新设置定时器
            }
        }
    }
    public var scrollInterval: Double = 5.0 {
        didSet {
            if isAutoScroll {
                self.setupTimer()   //重新设置定时器
            }
        }
    }
    // MARK: // 样式属性
    public var placeholderImage: UIImage?
    public var pictureContentMode: UIViewContentMode?
    
    var isShowPageControl: Bool = true {
        didSet {
            self.pageControl.isHidden = !isShowPageControl
        }
    }
    
    public var pageControlAliment: PageControlAliment = .bottomCenter
    public var currentPageIndicatorTintColor = UIColor.white {
        didSet {
            self.pageControl.currentPageIndicatorTintColor = currentPageIndicatorTintColor
        }
    }
    public var pageIndicatorTintColor = UIColor.gray {
        didSet {
            self.pageControl.pageIndicatorTintColor = pageIndicatorTintColor
        }
    }
    
    public var isShowImageText: Bool = false {
        didSet {
            self.textBackgroundView.isHidden = !isShowImageText
            self.textLabel.isHidden = !isShowImageText
        }
    }
    
    public var descTextFont: UIFont = UIFont.systemFont(ofSize: 15) {
        didSet {
            self.textLabel.font = descTextFont
        }
    }
    public var descTextColor: UIColor = UIColor.white {
        didSet {
            self.textLabel.textColor = descTextColor
        }
    }
    public var descTextBackgroundColor: UIColor = UIColor.black {
        didSet {
            self.textBackgroundView.backgroundColor = descTextBackgroundColor
        }
    }
    public var descTextBackgroundAlpha: CGFloat = 0.5 {
        didSet {
            self.textBackgroundView.alpha = descTextBackgroundAlpha
        }
    }
    
    
    //========================================================
    // MARK: - 内部属性
    //========================================================
    fileprivate var virtualItemCount: Int = 0
    fileprivate weak var autoScrollTimer: Timer?
    fileprivate lazy var layout: UICollectionViewFlowLayout = {
        let flowLayout =  UICollectionViewFlowLayout()
        
        //        flowLayout.itemSize = self.frame.size
        flowLayout.minimumLineSpacing = 0
        flowLayout.scrollDirection = .horizontal
        
        return flowLayout
    }()
    fileprivate lazy var collectionView: UICollectionView = {
        let collectionV = UICollectionView(frame: self.bounds, collectionViewLayout: self.layout)
        collectionV.showsVerticalScrollIndicator = false
        collectionV.showsHorizontalScrollIndicator = false
        collectionV.bounces = false
        collectionV.isPagingEnabled = true
        
        collectionV.delegate = self
        collectionV.dataSource = self
        
        collectionV.register(ImageCarouselViewItem.self, forCellWithReuseIdentifier: "ImageCarouselViewItem")
        
        return collectionV
    }()
    fileprivate lazy var pageControl: UIPageControl = {
        let pageCtrl = UIPageControl()
        pageCtrl.numberOfPages = self.imageArray.count
        pageCtrl.currentPageIndicatorTintColor = self.currentPageIndicatorTintColor
        pageCtrl.pageIndicatorTintColor = self.pageIndicatorTintColor
        pageCtrl.isUserInteractionEnabled = false
        
        return pageCtrl
    }()
    private lazy var textBackgroundView: UIView = {
        let bgV = UIView()
        bgV.backgroundColor = self.descTextBackgroundColor
        bgV.alpha = self.descTextBackgroundAlpha
        
        return bgV
    }()
    fileprivate lazy var textLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = self.descTextFont
        label.textColor = self.descTextColor
        
        return label
    }()
    
    // MARK: // Life Cycle
    public init(frame: CGRect, imageArray: [Any]?) {
        super.init(frame: frame)
        
        self.addSubview(self.collectionView)
        self.addSubview(self.textBackgroundView)
        self.addSubview(self.textLabel)
        self.addSubview(self.pageControl)
        
        self.layout.itemSize = frame.size
        if let arr = imageArray {
            self.imageArray = arr
            self.virtualItemCount = arr.count * 100
            self.pageControl.numberOfPages = arr.count
            self.reloadData()
        }
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: // Layout
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        var frame = self.bounds
        self.collectionView.frame = frame
        frame.origin.y = frame.size.height - 60
        frame.size.height = 60
        self.textBackgroundView.frame = frame
        self.textLabel.frame = CGRect(x: 10, y: frame.origin.y+2, width: frame.size.width - 20, height: 40)
        
        self.layoutPageControl()
//        self.layout.itemSize = frame.size
//        self.reloadData()
    }
    
    
    private func layoutPageControl() {
        let frame = self.bounds
        let width: CGFloat = 100, height: CGFloat = 5,
        bottomY: CGFloat = frame.size.height - 15,
        leftX: CGFloat = 10,
        centerX: CGFloat = (frame.size.width - width)/2,
        rightX: CGFloat = frame.size.width - width - 10
        switch self.pageControlAliment {
        case .bottomCenter:
            self.pageControl.frame = CGRect(x: centerX, y: bottomY, width: width, height: height)
        case .bottomLeft:
            self.pageControl.frame = CGRect(x: leftX, y: bottomY, width: width, height: height)
        case .bottomRight:
            self.pageControl.frame = CGRect(x: rightX, y: bottomY, width: width, height: height)
        case .topRight:
            self.pageControl.frame = CGRect(x: rightX, y: 10, width: width, height: height)
            
        }
    }
    
    // MARK: // 内部方法
    private func reloadData() {
        guard !imageArray.isEmpty else {
            return
        }
        
        self.collectionView.reloadData()
        self.showFirstImage()// 显示第一张图(因为要无限循环，所以先要移动到中间位置)
        if isAutoScroll {
            self.setupTimer()
        }
    }
    
    fileprivate func setupTimer() {
        autoScrollTimer?.invalidate() //先取消先前定时器
        autoScrollTimer = Timer.scheduledTimer(timeInterval: scrollInterval, target: self, selector: #selector(showNextImage), userInfo: nil, repeats: true)
        if let timer = autoScrollTimer {
            RunLoop.main.add(timer, forMode: RunLoopMode.commonModes)
        }
    }
    
    private func showFirstImage() {
        guard virtualItemCount > 0 else {
            return
        }
        
        let row = virtualItemCount / 2
        collectionView.scrollToItem(at: IndexPath(row: row, section: 0), at: UICollectionViewScrollPosition.left, animated: true)
        pageControl.currentPage = 0
    }
    
    @objc private func showNextImage() {
        guard virtualItemCount > 0 else {
            return
        }
        
        let currentRow = Int(collectionView.contentOffset.x / layout.itemSize.width)
        let nextRow = currentRow + 1
        if nextRow >= virtualItemCount {
            showFirstImage()
        }else {
            collectionView.scrollToItem(at: IndexPath(row: nextRow, section: 0), at: UICollectionViewScrollPosition.left, animated: true)
        }
    }

}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegate
extension ImageCarouselView: UICollectionViewDelegate, UICollectionViewDataSource {
    // UICollectionViewDataSource
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return self.virtualItemCount
    }
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCarouselViewItem", for: indexPath) as! ImageCarouselViewItem
        
        let data = imageArray[indexPath.row % imageArray.count]
        
        self.textLabel.text = delegate?.titleForData(data)
        let urlString = delegate?.imageUrlStringForData(data)
        delegate?.setImageForImageView(imageV: cell.imageView, byUrlString: urlString, placeholderImage: placeholderImage)
        
        return cell
    }
    
    // UICollectionViewDelegate
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.imageCarouselView(self, didSelectItemAt: indexPath.row % imageArray.count)
    }

}

// MARK: - UIScrollViewDelegate
extension ImageCarouselView: UIScrollViewDelegate {
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if isAutoScroll {
            autoScrollTimer?.invalidate()
        }
    }
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if isAutoScroll {
            self.setupTimer()
        }
    }
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetIndex: Int = Int(collectionView.contentOffset.x / layout.itemSize.width)
        let currentIndex = Int(Double(offsetIndex % imageArray.count) + 0.5)
        pageControl.currentPage = currentIndex == imageArray.count ? 0 :currentIndex
    }
}

// MARK: - ImageCarouselViewItem View
class ImageCarouselViewItem: UICollectionViewCell {
    fileprivate var imageView: UIImageView = {
        let imgV = UIImageView()
        
        return imgV
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.contentView.addSubview(self.imageView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.imageView.frame = self.bounds
    }
}
