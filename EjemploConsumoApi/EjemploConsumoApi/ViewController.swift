//
//  ViewController.swift
//  EjemploConsumoApi
//
//  Created by Heber  on 23/01/23.
//

import UIKit

struct RecipeResponse: Decodable {
    
    var hits: [RecipeDetails] = []
    
}

struct RecipeDetails: Decodable {
    
    let label: String
    let images: [ImageRecipeSize]
    let ingredientLines: [String]
    let calories: Double
    let mealType: [String]
    let totalNutrients: [IngredientNutrients]
    
}

struct ImageRecipeSize: Decodable {
    
    let THUMBNAIL: ImageSource
    let SMALL: ImageSource
    let REGULAR: ImageSource
    
}

struct ImageSource: Decodable {
    
    let url: String
    
}

struct IngredientNutrients: Decodable {
    
    let ENERC_KCAL: [IngredientMeasure]
    let FAT: [IngredientMeasure]
    let FASAT: [IngredientMeasure]
    let FATRN: [IngredientMeasure]
    let FAMS: [IngredientMeasure]
    let FAPU: [IngredientMeasure]
    let CHOCDF: [IngredientMeasure]
    let CHOCDF.net: [IngredientMeasure]
    let FIBTG: [IngredientMeasure]
    let SUGAR: [IngredientMeasure]
    let SUGAR.added: [IngredientMeasure]
    let PROCNT: [IngredientMeasure]
    let CHOLE: [IngredientMeasure]
    let NA: [IngredientMeasure]
    let CA: [IngredientMeasure]
    let MG: [IngredientMeasure]
    let K: [IngredientMeasure]
    let FE: [IngredientMeasure]
    let ZN: [IngredientMeasure]
    let P: [IngredientMeasure]
    let VITA_RAE: [IngredientMeasure]
    let VITC: [IngredientMeasure]
    let THIA: [IngredientMeasure]
    let RIBF: [IngredientMeasure]
    let NIA: [IngredientMeasure]
    let VITB6A: [IngredientMeasure]
    let FOLDFE: [IngredientMeasure]
    let FOLFD: [IngredientMeasure]
    let FOLAC: [IngredientMeasure]
    let VITB12: [IngredientMeasure]
    let VITD: [IngredientMeasure]
    let TOCPHA: [IngredientMeasure]
    let VITK1: [IngredientMeasure]
    let Sugar.alcohol: [IngredientMeasure]
    let WATER: [IngredientMeasure]
    
}

struct IngredientMeasure: Decodable {
    
    let label: String
    let quantity: Double
    let unit: String
    
}

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }


}

// https://developer.edamam.com/edamam-docs-recipe-api
// https://api.edamam.com/api/recipes/v2?type=public&q=pollo&app_id=f96df2b8&app_key=0f6b3a0641795cfa4289ba79dbb98572

