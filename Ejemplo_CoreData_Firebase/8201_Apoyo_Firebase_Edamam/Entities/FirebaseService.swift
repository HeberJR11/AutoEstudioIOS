//
//  FirebaseService.swift
//  8201_Apoyo_Firebase_Edamam
//
//  Created by MacBook  on 24/01/23.
//
// UserCredentialsEntity = Usuario de firebase
// UserInfoEntity = Usuario de CoreData

import Foundation
import FirebaseAuth
import Combine
import CoreData


// Enum de errores
enum FirebaseServiceError: Error {
    
    case createUser(Error)
    case getContext
    case saveContext(Error)
    case getUserByUid
    case signIn(Error)
    case getUserSigned
    case signOut(Error)
    case getUserRememberNotExists
    case invalidUser
    case invalidEmail
    case invalidPassword
    
}


class FirebaseService {
    
    // Creacion del contenedor de CoreData
    lazy var container: NSPersistentContainer = {
        
        // Se crea el contenedor persistente
        let container = NSPersistentContainer(name: "AppModel")
        
        // Carga toda la informacion de nuestro contenedor
        container.loadPersistentStores {
            
            _, error in
            
            // Si arroja error imprimimos un fatal error
            if let error = error {
                
                fatalError("Error al cargar el contenedor del CoreData: \(error)")
                
            }
            
        }
        
        // Si todo sale bien, devolvemos el contendor persistente
        return container
        
    }()
    
    // Retiene el usuario que acaba de inicar sesion
    var userSigned: UserCredentialsEntity?
    var userWithVerifiedEmail: UserCredentialsEntity?
    var userWithVerifiedEmailAndPassword: UserCredentialsEntity?
    
    // Notifica si el email proporcionado por el usuario es valido
    let isValidEmailSubject = PassthroughSubject<(UserCredentialsEntity?, FirebaseServiceError?), Never>()
    
    // Notifica si el password proporcionado por el usuario es valido
    let isValidPasswordSubject = PassthroughSubject<(UserCredentialsEntity?, FirebaseServiceError?), Never>()
    
    // Notifica que se ha creado el usuario con correo y contraseña desde firebase
    let createUserCredentialSubject = PassthroughSubject<(UserCredentialsEntity?, FirebaseServiceError?), Never>()
    
    // Notifica que se ha creado, o complementado el registro del usuario, con datos del CoreData
    let createUserInfoSubject = PassthroughSubject<(UserInfoEntity?, FirebaseServiceError?), Never>()
    
    // Notifica que un usuario ha iniciado sesion, y le pasa el usuario que se ha logueado, o si ocurrio algun error, le pasa ese error
    let signInSubject = PassthroughSubject<(UserCredentialsEntity?, FirebaseServiceError?), Never>()
    
    // Notifica que un usuario ha sido recordado y puede inicar sesion de manera automatica, si ocurre un error tambien le pasa ese error
    let autoSignInSubject = PassthroughSubject<(UserCredentialsEntity?, FirebaseServiceError?), Never>()
    
    // Notifica que el usuario ha cerrado sesion, si ocurre un error le pasas el error
    let signOutSubject = PassthroughSubject<(UserCredentialsEntity?, FirebaseServiceError?), Never>()
    
    // Notifica el usuario recordado, es decir el ultimo usuario que inicio sesion y la app lo recuerda
    let userRememberedSubject = PassthroughSubject<(UserCredentialsEntity?, FirebaseServiceError?), Never>()
    
    // Registro de un usuario en firebase, usando correo y contraseña
    func createUserCredential(email: String, password: String) {
        
        // LINEAL (Síncrono)
        // CLAUSURAS (Callbacks)
        // LINEAL (Asíncrono)
        
        // 1
        print("Hola")
        
        // 2
        // Se crea un usuario, implemntado el  metodo de firebase
        Auth.auth().createUser(withEmail: email, password: password) {
            
            // Firebase nos brindara un error o un resultado satisfactorio
            [weak self] result, error in
            
            // OTRO HILO: 1
            // Aquí completó el registro del usuario
            print("Se completó el registro")
            
            // Se comprueba que exista un error
            if let error = error {
                
                // Si ocurrio algun error, el notificador se encarga de propagar dicho error
                self?.createUserCredentialSubject.send((nil, .createUser(error)))
                return
                
            }
            
            // Se comprueba que exista un resultado (usuario creado)
            if let result = result {
                
                // Creamos un contexto
                guard let context = self?.container.viewContext else {
                    
                    // Si se genero un error al generar el contexto, el notificador se encarga de propagra dicho error
                    self?.createUserCredentialSubject.send((nil, .getContext))
                    return
                    
                }
                
                // Se comprueba si existe un usuario creado
                let userCredential = UserCredentialsEntity(context: context)
                
                // Se le pasan los demas datos de informacoin del usuario
                userCredential.email = email
                userCredential.password = password
                userCredential.uid = result.user.uid
                userCredential.token = result.user.refreshToken
                
                do {
                    
                    try context.save()
                    
                    // Dice quien es el usuario logueado
                    self?.userSigned = userCredential
                    
                    // El notificador envia el usuario que se ha creado
                    self?.createUserCredentialSubject.send((userCredential, nil))
                    
                } catch {
                    
                    context.rollback()
                    
                    self?.createUserCredentialSubject.send((nil, .saveContext(error)))
                    
                }
                
            }
            
        }
        
        // 3
        print("mundo")
        
        // ¿El usuario ya está creado?
        
    }
    
    func createUserInfo(name: String?, picture: Data?) {
        
        guard let userCredential = self.userSigned else {
            
            self.createUserInfoSubject.send((nil, .invalidUser))
            return
            
        }
        
        let context = self.container.viewContext
        
        let userInfo = UserInfoEntity(context: context)
        
        userInfo.name = name
        userInfo.picture = picture
        // Inverse (Asigna todo el objeto de CoreData)
        userInfo.userCredential = userCredential
        
        do {
            
            try context.save()
            
            self.createUserInfoSubject.send((userInfo, nil))
            
        } catch {
            
            context.rollback()
            
            self.createUserInfoSubject.send((nil, .saveContext(error)))
            
        }
        
    }
    
    func signIn(withEmail email: String, password: String, remember: Bool) {
        
        Auth.auth().signIn(withEmail: email, password: password) {
            
            [weak self] result, error in
            
            if let error = error {
                
                self?.signInSubject.send((nil, .signIn(error)))
                return
                
            }
            
            if let result = result {
                
                guard let context = self?.container.viewContext else {
                    
                    self?.createUserCredentialSubject.send((nil, .getContext))
                    return
                    
                }
                
                let uid = result.user.uid
                
                guard let userCredential = try? context.fetch(UserCredentialsEntity.fetchRequest()).filter({ $0.uid == uid }).first else {
                    
                    self?.signInSubject.send((nil, .getUserByUid))
                    return
                    
                }
                
                userCredential.token = result.user.refreshToken
                userCredential.signedAt = Date.now
                userCredential.isActiveRemember = remember
                
                do {
                    
                    // Guardamos el contexto porque el token para la credencial fue actualizado
                    try context.save()
                    
                    self?.userSigned = userCredential
                    
                    self?.signInSubject.send((userCredential, nil))
                    
                } catch {
                    
                    context.rollback()
                    
                    self?.signInSubject.send((nil, .saveContext(error)))
                    
                }
                
            }
            
        }
        
    }
    
    func signOut() {
        
        guard let userSigned = self.userSigned else {
            
            self.signOutSubject.send((nil, .getUserSigned))
            return
            
        }
        
        do {
            
            try Auth.auth().signOut()
            
            userSigned.isActiveRemember = false
            
            let context = self.container.viewContext
            
            do {
                
                try context.save()
                
                self.signOutSubject.send((userSigned, nil))
                
                self.userSigned = nil
                
            } catch {
                
                context.rollback()
                
                self.signOutSubject.send((nil, .saveContext(error)))
                
            }
            
        } catch {
            
            self.signOutSubject.send((nil, .signOut(error)))
            
        }
        
    }
    
    func getLastSignedUserRemember() {
        
        let context = self.container.viewContext
        
        guard let userCredential = try? context.fetch(UserCredentialsEntity.fetchRequest()).filter({ $0.isActiveRemember }).sorted(by: { $0.signedAt?.timeIntervalSince1970 ?? 0 > $1.signedAt?.timeIntervalSince1970 ?? 0 }).first else {
            
            self.userRememberedSubject.send((nil, .getUserRememberNotExists))
            return
            
        }
        
        
        
        self.userRememberedSubject.send((userCredential, nil))
        
    }
    
    func autoSignIn(uid: String) {
        
        guard let userCredential = try? self.container.viewContext.fetch(UserCredentialsEntity.fetchRequest()).filter({ $0.uid == uid }).first else {
            
            self.autoSignInSubject.send((nil, .getUserByUid))
            return
            
        }
        
        guard userCredential.isActiveRemember else {
            
            self.autoSignInSubject.send((nil, .invalidUser))
            return
            
        }
        
        guard let email = userCredential.email else {
            
            self.autoSignInSubject.send((nil, .invalidUser))
            return
            
        }
        
        guard let password = userCredential.password else {
            
            self.autoSignInSubject.send((nil, .invalidUser))
            return
            
        }
        
        self.signIn(withEmail: email, password: password, remember: true)
        
    }
    
    func verifyUserByEmail(email: String) {
        
        self.userWithVerifiedEmail = nil
        
        let context = self.container.viewContext
        
        guard let userCredential = try? context.fetch(UserCredentialsEntity.fetchRequest()).filter({ $0.email == email }).first else {
            
            self.isValidEmailSubject.send((nil, .invalidEmail))
            return
            
        }
        
        self.userWithVerifiedEmail = userCredential
        
        isValidEmailSubject.send((userCredential, nil))
        
    }
    
    func verifyUserByPassword(password: String) {
        
        self.userWithVerifiedEmailAndPassword = nil
        
        guard let userWithVerifiedEmail = self.userWithVerifiedEmail else {
            
            self.isValidPasswordSubject.send((nil, .invalidUser))
            return
            
        }
        
        if userWithVerifiedEmail.password == password {
            
            self.userWithVerifiedEmailAndPassword = userWithVerifiedEmail
            
            self.isValidPasswordSubject.send((userWithVerifiedEmail, nil))
            
        } else {
            
            self.isValidPasswordSubject.send((nil, .invalidPassword))
            
        }
        
    }
    
    func requestUserSigned() {
        
        guard let userSigned = self.userSigned else {
            
            self.signInSubject.send((nil, .invalidUser))
            return
            
        }
        
        self.signInSubject.send((userSigned, nil))
        
    }
    
}
