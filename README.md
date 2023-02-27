# 📝 ClassToday Readme

__[2022년도 상명대학교 컴퓨터과학과 캡스톤디자인 프로젝트]__

__⭐️ 프로젝트 개요: 위치 정보 기반의 일회성 수업 중개 앱 개발__

📆 __프로젝트 기간: 2022.01. ~ 2022.09.__

__🙆‍♂️ 클래스투데이 팀 구성원:__ 

    1. 박태현 @yescoach - iOS Develop
    1. 김민상 @poohyhy - iOS Develop
    1. 이영찬 @prettyturtle - iOS Develop



## 🚀 프로젝트 개요

클래스투데이는 위치 정보를 기반으로, 동네 주민들이 가볍고 자유롭게 일회성 수업을 사고 팔 수 있도록 중개하는 플랫폼 앱 입니다.



## 📐 기술스택

|      iOS Target      |       iOS 14.0        |
| :------------------: | :-------------------: |
|  프로젝트 아키텍처   |      MVC / MVVM       |
| 개발 언어, 개발 환경 | Swift 5.4, Xcode 13.4 |
|     UI Framework     |   UIKit + Code-base   |
|   의존성 관리도구    |     CocoaPod, SPM     |
|       서버 DB        |  Firebase Firestore   |



## 📚 오픈소스

|
|

![스크린샷 2023-02-22 15.41.56](/Users/yescoach/Library/Application Support/typora-user-images/스크린샷 2023-02-22 15.41.56.png)

### 

## 📏 기능 명세서 및 프로젝트 설계

|
|

클래스투데이 팀은 노션을 통해 [기능 명세서](https://yescoach.notion.site/5d067b941e2c44498eceda7e15f48408)와 [프로젝스 설계](https://yescoach.notion.site/da72f49e546c4ce5a5f4bb82d584c420)를 작성했습니다.

## 🛹 기능 구현

### 1. 메인 화면

---

<img src="/Users/yescoach/Downloads/IMG_0026.PNG" alt="IMG_0026" style="zoom:25%;" /> 

(1) 카테고리 정렬 기능

(2) 수업 검색 기능

(3) 즐겨찾기 목록 정렬 기능

(4) 유저의 위치 설정 기능

(5) 수업 등록 기능

### 카테고리 정렬

<img src="/Users/yescoach/Downloads/IMG_0029.PNG" alt="IMG_0029" style="zoom:25%;" /><img src="/Users/yescoach/Downloads/IMG_0030.PNG" alt="IMG_0030" style="zoom:25%;" />

>  카테고리 별로 수업들을 보여줍니다.

### 수업 검색

<img src="/Users/yescoach/Downloads/IMG_0031.PNG" alt="IMG_0031" style="zoom:25%;" /><img src="/Users/yescoach/Downloads/IMG_0032.PNG" alt="IMG_0032" style="zoom:25%;" />

>  검색어에 해당하는 수업들을 보여줍니다.

### 즐겨찾기 정렬

<img src="/Users/yescoach/Downloads/IMG_0033.PNG" alt="IMG_0033" style="zoom:25%;" />

>  즐겨찾기로 등록한 수업들을 보여줍니다.

### 유저 위치 설정 기능

<img src="/Users/yescoach/Downloads/IMG_0034.PNG" alt="IMG_0034" style="zoom:25%;" /><img src="/Users/yescoach/Downloads/IMG_0035.PNG" alt="IMG_0035" style="zoom:25%;" /><img src="/Users/yescoach/Downloads/IMG_0036.PNG" alt="IMG_0036" style="zoom:25%;" />

### 수업 등록 기능

<img src="/Users/yescoach/Downloads/IMG_0037.PNG" alt="IMG_0037" style="zoom:25%;" /> 

>  중앙의 등록 버튼을 통해 구매글 / 판매글을 등록합니다.

### 2. 수업의 등록

---

<img src="/Users/yescoach/Downloads/IMG_0038.PNG" alt="IMG_0038" style="zoom:25%;" /><img src="/Users/yescoach/Downloads/IMG_0039.PNG" alt="IMG_0039" style="zoom:25%;" />

> 수업 구매글/판매글을 등록하려면, 수업에 대한 정보들을 입력해야 합니다.

- 이미지 등록

​        <img src="/Users/yescoach/Downloads/IMG_0040.PNG" alt="IMG_0040" style="zoom:25%;" /><img src="/Users/yescoach/Downloads/IMG_0041.PNG" alt="IMG_0041" style="zoom:25%;" />

- 장소 등록

    <img src="/Users/yescoach/Downloads/IMG_0042.PNG" alt="IMG_0042" style="zoom:25%;" /><img src="/Users/yescoach/Downloads/IMG_0043.PNG" alt="IMG_0043" style="zoom:25%;" />

    > 지도의 특정 위치를 탭하면, 핀이 추가되며 해당 주소의 도로명 주소가 추가됩니다.

    **필수 항목들을 모두 작성하여 등록하면, 해당 지역에 수업이 추가됩니다.**

<img src="/Users/yescoach/Downloads/IMG_0044.PNG" alt="IMG_0044" style="zoom:25%;" />

### 3. 수업 수정 및 삭제

<img src="/Users/yescoach/Downloads/IMG_0048.PNG" alt="IMG_0048" style="zoom:25%;" /><img src="/Users/yescoach/Downloads/IMG_0047.PNG" alt="IMG_0047" style="zoom:25%;" />

### 4. 수업 상세 화면

---

<img src="/Users/yescoach/Downloads/IMG_0045.PNG" alt="IMG_0045" style="zoom:25%;" /><img src="/Users/yescoach/Downloads/IMG_0046.PNG" alt="IMG_0046" style="zoom:25%;" />

### 5. 수업 매칭

---

<img src="/Users/yescoach/Downloads/IMG_0049.PNG" alt="IMG_0049" style="zoom:25%;" /><img src="/Users/yescoach/Downloads/IMG_0050.PNG" alt="IMG_0050" style="zoom:25%;" />

<img src="/Users/yescoach/Downloads/IMG_0051.PNG" alt="IMG_0051" style="zoom:25%;" /><img src="/Users/yescoach/Downloads/IMG_0052.PNG" alt="IMG_0052" style="zoom:25%;" />



### 6. 맵뷰

---

<img src="/Users/yescoach/Downloads/IMG_0053.PNG" alt="IMG_0053" style="zoom:25%;" /><img src="/Users/yescoach/Downloads/IMG_0055.PNG" alt="IMG_0055" style="zoom:25%;" /><img src="/Users/yescoach/Downloads/IMG_0056.PNG" alt="IMG_0056" style="zoom:25%;" />

### 7. 채팅

---

<img src="/Users/yescoach/Downloads/IMG_0058.PNG" alt="IMG_0058" style="zoom:25%;" /><img src="/Users/yescoach/Downloads/IMG_0057.PNG" alt="IMG_0057" style="zoom:25%;" />

### 8. 프로필

---

<img src="/Users/yescoach/Downloads/IMG_0059.PNG" alt="IMG_0059" style="zoom:25%;" />

### 9. 회원가입



## ⚒️ Clean Architecture 적용

**개요: 기존의 MVC 구조에서 Clean Architecture을 적용한 MVVM 구조로 리팩토링 진행**

**프로젝트 기간: 2023.01. ~ 2023.02.**

**주요 개념: MVVM, Clean Architecture, Dependency Container, Repository Pattern**

## ⛔️ 기존 프로젝트 구조

<img src="/Users/yescoach/Library/Application Support/typora-user-images/스크린샷 2023-02-23 18.15.33.png" alt="스크린샷 2023-02-23 18.15.33" style="zoom:80%;" />

## 🟢 Clean Architecture 적용

<img src="/Users/yescoach/Library/Application Support/typora-user-images/스크린샷 2023-02-23 17.28.21.png" alt="스크린샷 2023-02-23 17.27.09" style="zoom:80%;" />

>   참고한 프로젝트: https://github.com/kudoleh/iOS-Clean-Architecture-MVVM

 ### Layer 별 구성요소

-   **Domain Layer**
    -   Entities: Business Rules, Business Model
    -   UseCases: Application Business Rules
    -   Interfaces: Repositories Interfaces
-   **Presentation Layer**
    -   View: `ViewController`와 `ViewModel(Presenters)`, `SubView`
    -   Utilities: Delegates, Framework type extensions
-   **Data Layer**
    -   Repositories: Repositories Implementations
    -   PersistentStorages: Persistence DB
-   Infrastructure
    -   Network: Server Network Managers(Firebase, Naver API, Kakao API 등)
    -   Services: Core Location, Image Cache Manager 등 Framework 관련 매니저 객체

### Dependency Container

---

Clean Architecture를 적용하면서 `Repository`, `UseCase` 와 이를 가지고 데이터를 구성하는 Presenter인 `ViewModel`, UI로 보여주는 `ViewController`에서 모두 의존성 주입이 이루어집니다. 인스턴스를 생성할때 생성자를 통해 의존성을 주입하는데, 이 의존성 주입을 한 곳에서 전담해서 처리하기 위해서 `Dependency Container` 를 사용합니다.

**장점**

-   매번 인스턴스 생성시 중복되던 코드를 `Dependency Container` 를 통해 줄일 수 있습니다(`Repository`,` Usecase` 의 생성, 주입 등)
-   인스턴스의 생성과 의존성을 `Dependency Container`에서 관리하므로, 이외의 영역에서는 비즈니스 로직에만 집중할 수 있습니다.

### Repository Pattern

---

**데이터(DB, API)의 출처에 관계없이 동일한 인터페이스로 접근하게 하는 디자인 패턴 입니다.**

`ViewModel`은 추상화된 `Repository`의 인터페이스를 통해 데이터에 접근하여 비즈니스 로직을 수행하며,
`Repository`는 해당 인터페이스를 구현하여 실제 데이터를 받아오고 가공합니다.

**장점**

-   Presenter인 `ViewModel`은 비즈니스 로직에만 집중할 수 있게 됩니다.
-   `ViewModel`은 추상화된 `Repository`에 접근하므로 객체 간 결합도가 감소합니다.
-   `데이터(DB, API) 출처` 및 `데이터 로직`의 유연한 변경이 가능합니다. `ViewModel`은 아무 영향 없습니다.
-   일관된 인터페이스를 통해 데이터를 요청할 수 있습니다.

### Repository Pattern + Use Case

---

Clean Architecture에서는  `ViewModel` 와 `Repository` 사이에 `UseCase` 가 존재합니다.

`Use Case`는 앱의 비즈니스 규칙을 포함한 모든 유스케이스를 캡슐화하여 구현한 객체입니다.

`Use Case`는 `Repository`의 인터페이스에 접근하여 데이터를 받아와 비즈니스 로직을 수행합니다.(= 의존성 주입)
= `Use Case`의 변경이 `Entity` 에 영향을 주지 않으며, `DB, API`등 Data Layer의 변경으로부터 영향 받지 않습니다. 

**ex. 이미지 관련 UseCase**

```swift
protocol ImageUseCase {
    func uploadRx(image: UIImage) -> Observable<String>
    func downloadImageRx(urlString: String) -> Observable<UIImage>
    func deleteImageRx(urlString: String) -> Observable<Void>
}

final class DefaultImageUseCase: ImageUseCase {

    private let imageRepository: ImageRepository

    init(imageRepository: ImageRepository) {
        self.imageRepository = imageRepository
    }

    func uploadRx(image: UIImage) -> Observable<String> {
        return Observable.create { [weak self] emitter in
            self?.imageRepository.upload(image: image) { result in
                switch result {
                case .success(let url):
                    emitter.onNext(url)
                    emitter.onCompleted()
                case .failure(let error):
                    emitter.onError(error)
                }
            }
            return Disposables.create()
        }
    }

    func downloadImageRx(urlString: String) -> Observable<UIImage> {
        return Observable.create { [weak self] emitter in
            self?.imageRepository.downloadImage(urlString: urlString) { result in
                switch result {
                case .success(let image):
                    emitter.onNext(image)
                    emitter.onCompleted()
                case .failure(let error):
                    emitter.onError(error)
                }
            }
            return Disposables.create()
        }
    }

    func deleteImageRx(urlString: String) -> Observable<Void> {
        return Observable.create { [weak self] emitter in
            self?.imageRepository.deleteImage(urlString: urlString) {
                emitter.onCompleted()
            }
            return Disposables.create()
        }
    }
}
```





## ⚒️ RxSwift 적용

## ⚒️ RxSwift 적용

**개요: API Call을 비롯한 다양한 비동기 시퀀스를 RxSwift를 통해 더 직관적이고 효율적으로 처리할 수 있도록 리팩토링**

**프로젝트 기간: 2023.01. ~ 2023.02**

**주요 개념: RxSwift, RxCocoa, Observer, Observable, Disposable**

### 기존 비동기 방식 및 Data Binding 코드

---

-   Custom Type을 구현하여 Data Binding 진행

```swift
final class CustomObservable<T> {
    // 클로저
    typealias Listner = (T) -> Void
    var listener: Listner?

    var value: T {
        // 값이 변하면 클로저 실행
        didSet {
            listener?(value)
        }
    }

    init(_ value: T) {
        self.value = value
    }

    func bind(listener: Listner?) {
        self.listener = listener
        listener?(value)
    }
}


```

### RxSwift를 활용한 Data Binding

-   **UseCase**의 비동기 메서드(Observable을 통해 이벤트 생성) 

```swift
final class DefaultFetchClassItemUseCase: FetchClassItemUseCase {

    private let classItemRepository: ClassItemRepository

    init(classItemRepository: ClassItemRepository) {
        self.classItemRepository = classItemRepository
    }

    // MARK: - Refactoring for RxSwift
    func executeRx(param: ClassItemQuery.FetchItems) -> Observable<[ClassItem]> {
        return Observable.create() { [weak self] emitter in
            self?.classItemRepository.fetchItems(param: param) { classItems in
                emitter.onNext(classItems)
                emitter.onCompleted()
            }
            return Disposables.create()
        }
    }

    func executeRx(param: ClassItemQuery.FetchItem) -> Observable<ClassItem> {
        return Observable.create() { [weak self] emitter in
            self?.classItemRepository.fetchItem(param: param) { classItem in
                emitter.onNext(classItem)
                emitter.onCompleted()
            }
            return Disposables.create()
        }
    }
}
```

-   **ViewModel**에서의 데이터 바인딩(Observable의 이벤트를 구독하여 그 결과를 Observing)

```swift
public class DefaultSearchResultViewModel: SearchResultViewModel {
    
    private let fetchClassItemUseCase: FetchClassItemUseCase
    private let disposeBag = DisposeBag()
    
    // MARK: - OUTPUT
    let isNowLocationFetching: BehaviorRelay<Bool> = BehaviorRelay(value: false)
    let isNowDataFetching: BehaviorRelay<Bool> = BehaviorRelay(value: false)
    
    let currentUser: BehaviorSubject<User?> = BehaviorSubject(value: nil)
    let outPutData: BehaviorSubject<[ClassItem]> = BehaviorSubject(value: [])
    
    let classDetailViewController: BehaviorSubject<ClassDetailViewController?> = BehaviorSubject(value: nil)
    let searchKeyword: String
    
    private let viewModelData: BehaviorSubject<[ClassItem]> = BehaviorSubject(value: [])
    private var currentSegmentControlIndex: Int = 0
    
    // MARK: - Init
    init(fetchClassItemUseCase: FetchClassItemUseCase, searchKeyword: String) {
        self.fetchClassItemUseCase = fetchClassItemUseCase
        self.searchKeyword = searchKeyword
        configureLocation()
    }

    private func configureLocation() {
        isNowLocationFetching.accept(true)
        _ = User.getCurrentUserRx()
            .subscribe(
                onNext: { user in
                    self.currentUser.onNext(user)
                    self.isNowLocationFetching.accept(false)
                    guard let _ = user.detailLocation else {
                        // TODO: 위치 설정 얼럿 호출 해야됨
                        return
                    }
                    self.fetchData()
                },
                onError: { error in
                    self.isNowLocationFetching.accept(false)
                    print("ERROR \(error)🌔")
                }
            )
            .disposed(by: disposeBag)
    }
}

// MARK: - INPUT
extension DefaultSearchResultViewModel {
    func refreshClassItemList() {
        fetchData()
    }

    func didSelectItem(at index: Int) {
        if let classItem = try? outPutData.value()[index] {
            classDetailViewController.onNext(
                AppDIContainer()
                    .makeDIContainer()
                    .makeClassDetailViewController(classItem: classItem)
            )
            classDetailViewController.onNext(nil)
        }
    }

    func fetchData() {
        isNowDataFetching.accept(true)
        guard let currentUser = try? currentUser.value() else {
            debugPrint("유저 정보가 없거나 아직 받아오지 못했습니다😭")
            isNowDataFetching.accept(false)
            return
        }
        guard let keyword = currentUser.keywordLocation else {
            debugPrint("유저의 키워드 주소 설정 값이 없습니다. 주소 설정 먼저 해주세요😭")
            isNowDataFetching.accept(false)
            return
        }
        fetchClassItemUseCase.executeRx(
            param: .fetchByKeywordSearch(
                keyword: keyword,
                searchKeyword: searchKeyword
            )
        )
        .map { (classItems) -> [ClassItem] in
            classItems.sorted { $0 > $1 }
        }
        .subscribe( onNext: { [weak self] classItems in
            self?.isNowDataFetching.accept(false)
            self?.viewModelData.onNext(classItems)
            switch self?.currentSegmentControlIndex {
            case 1:
                self?.outPutData.onNext(classItems.filter { $0.itemType == ClassItemType.buy })
            case 2:
                self?.outPutData.onNext(classItems.filter { $0.itemType == ClassItemType.sell })
            default:
                self?.outPutData.onNext(classItems)
            }
        })
        .disposed(by: disposeBag)
    }
    
    func didSelectSegmentControl(segmentControlIndex: Int) {
        self.currentSegmentControlIndex = segmentControlIndex
        
        guard let datas = try? viewModelData.value() else {
            outPutData.onNext([])
            return
        }
        
        switch segmentControlIndex {
        case 1:
            outPutData.onNext(datas.filter { $0.itemType == .buy })
        case 2:
            outPutData.onNext(datas.filter { $0.itemType == .sell })
        default:
            outPutData.onNext(datas)
        }
    }
}

```

-   **ViewController**의 데이터 바인딩

```swift
class SearchResultViewController: UIViewController {
        // ...
    // MARK: Properties
    private var viewModel: SearchResultViewModel
    private let disposeBag = DisposeBag()
    
    init(viewModel: SearchResultViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - view lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationBar()
        setLayout()
        bindViewModel()
    }
    
    private func bindViewModel() {
        /// 수업아이템 바인딩
        viewModel.outPutData
            .bind { [weak self] classItems in
                self?.classItemTableView.reloadData()
                if classItems.isEmpty {
                    self?.nonDataAlertLabel.isHidden = false
                } else {
                    self?.nonDataAlertLabel.isHidden = true
                }
            }
            .disposed(by: disposeBag)

        /// 지역명 패칭 진행중인지 바인딩
        viewModel.isNowLocationFetching
            .asDriver()
            .drive { [weak self] isFetching in
                isFetching ?
                self?.classItemTableView.refreshControl?.beginRefreshing() :
                self?.classItemTableView.refreshControl?.endRefreshing()
            }
            .disposed(by: disposeBag)

        /// 수업 아이템 패칭중인지 바인딩
        viewModel.isNowDataFetching
            .asDriver()
            .drive { [weak self] isFetching in
                if isFetching {
                    self?.classItemTableView.refreshControl?.beginRefreshing()
                    self?.nonDataAlertLabel.isHidden = true
                } else {
                    self?.classItemTableView.refreshControl?.endRefreshing()
                }
            }
            .disposed(by: disposeBag)

        viewModel.classDetailViewController
            .bind { [weak self] viewController in
                if let viewController = viewController {
                    self?.navigationController?.pushViewController(viewController, animated: true)
                }
            }
            .disposed(by: disposeBag)
    }
    
        // ...
}
```


