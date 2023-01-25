//
//  MyDailyDietRouter.swift
//  MyDailyDiet
//
//  Created by MacBook on 23/01/23.
//

import Foundation
import UIKit

class MyDailyDietRouter {
    
    lazy var navigationController: UINavigationController = {
        
        let navigationController = UINavigationController()
        
        return navigationController
        
    }()
    
    lazy var interactor: UserInteractor = {
        
        let interactor = UserInteractor()
        
        return interactor
        
    }()
    
    // Presentadores (1 por pantalla)
    //var homePresenter: SongsHomePresenter?
    //var songInfoPresenter: SongInfoPresenter?
    //var songPlayerPresenter: SongPlayerPresenter?
    
    
    // Funciones que nos llevaran a las vistas 
    func goToHome() {
        
        self.homePresenter = SongsHomePresenter()
        
        self.homePresenter?.start(router: self, interactor: self.interactor)
        
        if let viewController = self.homePresenter?.view as? HomeViewController {
            
            self.navigationController.pushViewController(viewController, animated: false)
            
        }
        
    }
}
