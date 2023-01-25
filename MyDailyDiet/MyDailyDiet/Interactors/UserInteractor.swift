//
//  UserInteractor.swift
//  MyDailyDiet
//
//  Created by MacBook on 23/01/23.
//

import Foundation

class UserInteractor {
    
    // Servicio 
    private lazy var service: UserLoginService = {
        
        let service = UserLoginService()
        
        return service
        
    }()
    
    // Notificadores (replicadores)
    
    // Notifica que se ha creado el usuario con correo y contraseña desde firebase
    lazy var createUserCredentialSubject: PassthroughSubject<(UserCredentialsEntity?, FirebaseServiceError?), Never> = {
        
        self.service.createUserCredentialSubject
    }
    
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
    
    // Funciones
    
    func selectSong(song: SongEntity) {
        
        self.service.selectSong(byId: song.id)
        
    }
    
}
