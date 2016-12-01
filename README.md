
ImageCarouselView 是一个用Swift3实现的图片轮播控件
<<<<<<< HEAD
=======
- 不依赖任何第三方类库
- 代码简介，使用简单
>>>>>>> develop


## Requirements

- iOS 8.0+ 
- Xcode 8.0+
- Swift 3.0+


## Installation

### CocoaPods

[CocoaPods](http://cocoapods.org) is a dependency manager for Cocoa projects. You can install it with the following command:

```bash
$ gem install cocoapods
```

> CocoaPods 1.1.0+ is required to build ImageCarouselView.

To integrate SnapKit into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '8.0'
use_frameworks!

target '<Your Target Name>' do
    pod 'ImageCarouselView'
end
```

Then, run the following command:

```bash
$ pod install
```

### Manually

If you prefer not to use either of the aforementioned dependency managers, you can integrate ImageCarouselView into your project manually.

---

## Usage

### Quick Start

```swift
import ImageCarouselView

class MyViewController: UIViewController {

    lazy var imageCarouselView: ImageCarouselView = {
        let screenWidth = UIScreen.main.bounds.size.width
        let frame = CGRect(x: 0, y: 0, width: screenWidth, height: screenWidth*320/568)

        let images = [["url": "http://pic1.zhimg.com/05a55004e42ef9d778d502c96bc198a4.jpg", "tit": "Whatever is worth doing is worth doing well."],
        ["url": "http://pic3.zhimg.com/cd1240013a1c68392c81ba2df54ebb52.jpg", "tit": "You may be out of my sight, but never out of my mind."],
        ["url": "http://pic1.zhimg.com/163af5e8c239e24654d26f3059cdccb4.jpg", "tit": "When the whole world is about to rain, let’s make it clear in our heart together."],
        ["url": "http://pic4.zhimg.com/fe48f0349c20a50a5ad1491e569920d3.jpg", "tit": "I’ll think of you every step of the way."],
        ["url": "http://pic2.zhimg.com/325aa7289be798e36518bdc6d18e3581.jpg", "tit": "Love is not a maybe thing. You know when you love someone."]]
        let carouselView = ImageCarouselView(frame: frame, imageArray: images)
        carouselView.delegate = self
        carouselView.isAutoScroll = true
        //carouselView.scrollInterval = 2
        //carouselView.isShowImageText = false

        return carouselView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.addSubview(self.imageCarouselView)
    }

}

extension ViewController: ImageCarouselViewDelegate {
        func imageCarouselView(_ imageCarouselView: ImageCarouselView, didSelectItemAt index:Int) {
            //self.toast(message: "touched the \(index) index image")
        }
        // 设置网络图的方法(这里将图片设置方法交给代理，避免本控件依赖网络库)
        func setImageForImageView(imageV: UIImageView, byUrlString: String?, placeholderImage:UIImage?){
            imageV.contentMode = UIViewContentMode.scaleAspectFill
            imageV.setImageWith(URL(string: byUrlString!)!, placeholderImage: placeholderImage)
        }
        // 取出图片数据里面的文本字段值
        func titleForData(_ imageData:Any) -> String {
            let data = imageData as? Dictionary<String, String>
            return data!["tit"]!
        }
        // 取出图片数据里面的图片Url字段值
        func imageUrlStringForData(_ imageData:Any) -> String {
            let data = imageData as? Dictionary<String, String>
            return data!["url"]!
        }
}

```

## License

SnapKit is released under the MIT license. See LICENSE for details.
