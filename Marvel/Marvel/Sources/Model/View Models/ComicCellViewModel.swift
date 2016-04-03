import Foundation
import RxSwift

class ComicCellViewModel: BaseViewModel {
    
    var title     = PublishSubject<String>()
    var thumbnail = PublishSubject<UIImage?>()
    
    var model: Comic {
        didSet {
            modelWasUpdated()
        }
    }
    
    init(model: Comic) {
        self.model = model
        
        super.init()
    }
    
    override func didBecomeActive() {
        modelWasUpdated()
    }
    
    func modelWasUpdated() {
        guard let comicTitle = model.title where !comicTitle.isEmpty else { return }

        title.on(.Next(comicTitle))
        thumbnail.on(.Next(model.thumbnail))
    }
}
