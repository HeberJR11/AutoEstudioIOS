//
//  UserService.swift
//  MyDailyDiet
//
//  Created by MacBook on 23/01/23.
//  Updates:
//  Joel Brayan Navor Jimenez - Container created

import Foundation
import Combine
import CoreData
import FirebaseAuth
import UIKit

class UserLoginService {
    
    lazy var containerUserInfo: NSPersistentContainer = {
        
        let container = NSPersistentContainer(name: "MyDailyDiet")
        
        container.loadPersistentStores {
            
            _, error in
            
            if let error = error {
                
                fatalError("Error al cargar el contenedor del CoreData: \(error)")
                
            }
            
        }
        
        return container
        
    }()
    
    //Enumerable para los distintos tipos de auteticación en firebase
    enum ProviderType: String {
        
        case email_password
        
    }
    
    //Enumerable para el manejo de errores
    
    private let provider: ProviderType = .email_password
    
    // STATES
    
    // Retiene al usuario que acaba de iniciar sesion
    var userLogged: UserInfoEntity?
    
    // NOTIFICATORS
    
    // Notifica que el usuario ha iniciado sesion, mandando ese usuario logueado
    let userSignInSubject = PassthroughSubject<UserInfoEntity, Never>()
    // Notifica que el usuario previamente logueado, ha cerrado sesion
    let userSignOutSubject = PassthroughSubject<UserInfoEntity, Never>()
    
    // TRANSACTIONS
    
    func registerUser(name: String, surName: String, lastName: String, birthDay: Date, phoneNumber: String, gender: String, password: String, email: String, height: Double, weight: Double) {
        
        //
        let context = containerUserInfo.viewContext
        
        let newUser = UserInfoEntity(context: context)
        
        newUser.name = name
        newUser.surName = surName
        newUser.lastName = lastName
        newUser.email = email
        newUser.password = password
        newUser.height = height
        newUser.weight = weight
        newUser.birthDate = birthDay
        newUser.phoneNumber = phoneNumber
        newUser.gender = gender
        
        do {
            
            try context.save()
            
        } catch {
            context.rollback()
        }
            
        Auth.auth().createUser(withEmail: email, password: password) {
            (result, error) in
            
            if let result = result, error == nil {
                //TODO: Avisar que se creo con exito
                
            } else {
                //TODO: Manejar el error
            }
            
        }
        
    }
    
    func requestUserLogged() {
        
        if let userLogged = self.userLogged {
            userSignInSubject.send(userLogged)
        }
        
    }
    
    func LogInUser(email: String, password: String) {
        
        Auth.auth().signIn(withEmail: email, password: password)
        
        if let userLogged = self.userLogged {
            
            self.userSignInSubject.send(userLogged)
    
            self.userLogged = nil
            
        } else {
            
            
            
        }
        
    }
    
    func LogOutUser() {
       
        switch provider {
            
        case .email_password:
            do {
                
                try Auth.auth().signOut()
        
            } catch {
                //TODO ALERTA
            }
        }
        if let userLogged = self.userLogged {
            
            self.userSignOutSubject.send(userLogged)
            self.userLogged = nil
            
        } else {
            
            
            
        }
        
    }
    
    
}
