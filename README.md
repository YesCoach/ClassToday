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

![스크린샷 2022-10-05 00 47 12](https://user-images.githubusercontent.com/59643667/193865606-5c6cc0d7-0b95-4ea5-a58a-98bb3502c8ac.png)



## 📏 기능 명세서 및 프로젝트 설계

클래스투데이 팀은 노션을 통해 [기능 명세서](https://yescoach.notion.site/5d067b941e2c44498eceda7e15f48408)와 [프로젝스 설계](https://yescoach.notion.site/da72f49e546c4ce5a5f4bb82d584c420)를 작성했습니다.


## 🛹 기능 구현

### 1. 메인 화면

---
<img src="https://user-images.githubusercontent.com/59643667/221517079-c783a07f-5c8c-456a-b6f9-53eff02e5b92.PNG" alt="IMG_0026" width="25%"> 

(1) 카테고리 정렬 기능

(2) 수업 검색 기능

(3) 즐겨찾기 목록 정렬 기능

(4) 유저의 위치 설정 기능

(5) 수업 등록 기능


### 카테고리 정렬 

<p alien="left">
<img src="https://user-images.githubusercontent.com/59643667/221518143-47878fe6-3564-484d-bccd-3a22cbadc620.PNG" alt="IMG_0029" align="center" width="25%"> 
<img src="https://user-images.githubusercontent.com/59643667/221518153-f59d9698-c8e9-40fe-bd51-8c0c208273d6.PNG" alt="IMG_0030" align="center" width="25%"> 
</p>

> 카테고리 별로 수업들을 보여줍니다.


### 수업 검색

<p alien="left">
<img src="https://user-images.githubusercontent.com/59643667/221520735-a94cd36b-1efb-4b41-8d6e-2373d4a98fea.PNG" alt="IMG_0031" align="center" width="25%"> 
<img src="https://user-images.githubusercontent.com/59643667/221520984-20c576e7-b37f-4826-b050-9657d8acf691.PNG" alt="IMG_0032" align="center" width="25%"> 
</p>

> 검색어에 해당하는 수업들을 보여줍니다.


### 즐겨찾기 정렬

<img src="https://user-images.githubusercontent.com/59643667/221521224-a839f427-5f77-4bfa-8af7-0be84034e001.PNG" alt="IMG_0033" width="25%">

>  즐겨찾기로 등록한 수업들을 보여줍니다.


### 유저 위치 설정 기능

<p align="left">
<img src="https://user-images.githubusercontent.com/59643667/221521508-bd824e69-4558-47f1-8376-7cd224fa8f69.PNG" alt="IMG_0034" align="center" width="25%">
<img src="https://user-images.githubusercontent.com/59643667/221521502-4d775944-dfa4-40c9-9cb8-d1150d68bec2.PNG" alt="IMG_0035" align="center" width="25%">
<img src="https://user-images.githubusercontent.com/59643667/221521727-99182422-f97a-40e8-8144-b56e1bef4451.PNG" alt="IMG_0036" align="center" width="25%">
</p>

> 유저의 위치를 설정합니다.


### 수업 등록 기능

<img src="https://user-images.githubusercontent.com/59643667/221524084-65e2d1ea-cb20-48b6-843b-8794ee48ec7c.PNG" alt="IMG_0037" width="25%"> 

>  중앙의 등록 버튼을 통해 구매글 / 판매글을 등록합니다.


### 2. 수업의 등록

---

<p alien="left">
<img src="https://user-images.githubusercontent.com/59643667/221524335-5eb39ca6-7542-4361-891c-6fac70c40d13.PNG" alt="IMG_0038" align="center" width="25%">
<img src="https://user-images.githubusercontent.com/59643667/221524353-8a57b4c2-dbc6-4222-b84e-e5295df4a76e.PNG" alt="IMG_0039" align="center" width="25%">
</p>

> 수업 구매글/판매글을 등록하려면, 수업에 대한 정보들을 입력해야 합니다.


- 이미지 등록

<p alien="left">
<img src="https://user-images.githubusercontent.com/59643667/221524791-86d0dc01-c5d5-445d-adbd-b52d42f6c4c0.PNG" alt="IMG_0040" align="center" width="25%">
<img src="https://user-images.githubusercontent.com/59643667/221524819-6f040742-cec1-4202-b9e1-f580f1867adb.PNG" alt="IMG_0041" align="center" width="25%">
</p>

- 장소 등록

<p alien="left">
<img src="https://user-images.githubusercontent.com/59643667/221525261-c2664ab8-46d3-4a8b-82b3-dc62f927f5ee.PNG" alt="IMG_0042" align="center" width="25%">
<img src="https://user-images.githubusercontent.com/59643667/221525275-82418544-1b89-446f-8aa8-c5a1313ce1fa.PNG" alt="IMG_0043" align="center" width="25%">
</p>

> 지도의 특정 위치를 탭하면, 핀이 추가되며 해당 주소의 도로명 주소가 추가됩니다. &nbsp;
> **필수 항목들을 모두 작성하여 등록하면, 해당 지역에 수업이 추가됩니다.**

<img src="https://user-images.githubusercontent.com/59643667/221526058-e1e724c4-0086-4ef4-bb54-a471919f50bb.PNG" alt="IMG_0044" width="25%">


### 3. 수업 수정 및 삭제

<p alien="left">
<img src="https://user-images.githubusercontent.com/59643667/221526369-1f5023af-f137-4791-900c-2ff69bfa8f71.PNG" alt="IMG_0048" align="center" width="25%">
<img src="https://user-images.githubusercontent.com/59643667/221526382-14471593-c1ac-42f2-80d3-fcfd709baaff.PNG" alt="IMG_0047" align="center" width="25%">
</p>

### 4. 수업 상세 화면

---

<p alien="left">
<img src="https://user-images.githubusercontent.com/59643667/221526783-bcbac39d-8566-4190-b465-a8ff1fa6f268.PNG" alt="IMG_0045" align="center" width="25%">
<img src="https://user-images.githubusercontent.com/59643667/221526794-c1fee175-6c08-4605-977d-e6164bae98a7.PNG" alt="IMG_0046" align="center" width="25%">
</p>


### 5. 수업 매칭

---

<p alien="left">
<img src="https://user-images.githubusercontent.com/59643667/221527086-a2f1d341-d227-42c9-9f79-4ae1466fdf2a.PNG" alt="IMG_0049" align="center" width="25%">
<img src="https://user-images.githubusercontent.com/59643667/221527105-f73194e1-e0f9-4f80-809b-e4ac309e6915.PNG" alt="IMG_0050" align="center" width="25%">
 </p>
<p alien="left">
<img src="https://user-images.githubusercontent.com/59643667/221527320-92fb702b-9321-4d88-8922-1b540bfe4b2d.PNG" alt="IMG_0051" align="center" width="25%">
<img src="https://user-images.githubusercontent.com/59643667/221527330-2659da9e-5f32-4f96-b7c4-10fc77d5f1dc.PNG" alt="IMG_0052" align="center" width="25%">
</p>

### 6. 맵뷰

---

<p align="left">
<img src="https://user-images.githubusercontent.com/59643667/221527496-25ed8007-47d1-48bd-b661-0f3bcdae9cc2.PNG" alt="IMG_0053" align="center" width="25%">
<img src="https://user-images.githubusercontent.com/59643667/221527546-8df0f827-14f9-465e-8031-5546623caec6.PNG" alt="IMG_0055" align="center" width="25%">
<img src="https://user-images.githubusercontent.com/59643667/221527568-bc1863ae-e5a3-43c7-bf84-02d4692db8bd.PNG" alt="IMG_0056" align="center" width="25%">
</p>


### 7. 채팅

---

<p alien="left">
<img src="https://user-images.githubusercontent.com/59643667/221528051-f6e12196-99bd-4166-b5a7-c80a26bc45a1.PNG" alt="IMG_0058" align="center" width="25%">
<img src="https://user-images.githubusercontent.com/59643667/221528057-609af306-486e-4f43-b02e-505d52f45cd8.PNG" alt="IMG_0057" align="center" width="25%">
</p>


### 8. 프로필

---

<img src="https://user-images.githubusercontent.com/59643667/221528069-482a690f-8b09-4f33-b6dd-367a3da2b6c3.PNG" alt="IMG_0059" width="25%">


### 9. 회원가입



## ⚒️ Clean Architecture 적용

**개요: 기존의 MVC 구조에서 Clean Architecture을 적용한 MVVM 구조로 리팩토링 진행**

**프로젝트 기간: 2023.01. ~ 2023.02.**

**주요 개념: MVVM, Clean Architecture, Dependency Container, Repository Pattern**

**브랜치: https://github.com/YesCoach/ClassToday/tree/cleanArchitecture**

## ⛔️ 기존 프로젝트 구조

<img src="https://user-images.githubusercontent.com/59643667/221531328-31ee9b37-4c75-4710-a101-721433ecedff.png" alt="스크린샷 2023-02-23 18.15.33" width="50%" />

## 🟢 Clean Architecture 적용

<img src="https://user-images.githubusercontent.com/59643667/221531556-cd17aeeb-01af-4e25-8d44-6e297cb6e3c7.png" alt="스크린샷 2023-02-23 17.27.09" width="50%" />

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

**개요: API Call을 비롯한 다양한 비동기 시퀀스를 RxSwift를 통해 더 직관적이고 효율적으로 처리할 수 있도록 리팩토링**

**프로젝트 기간: 2023.01. ~ 2023.02**

**주요 개념: RxSwift, RxCocoa, Observer, Observable, Disposable**

**브랜치: https://github.com/YesCoach/ClassToday/tree/rxSwift**

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


