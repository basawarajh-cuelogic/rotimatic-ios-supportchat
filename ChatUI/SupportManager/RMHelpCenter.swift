//
//  RMHelpCenter.swift
//  ZendeskiOS
//
//  Created by Basawaraj on 23/02/16.
//  Copyright © 2016 Cuelogic. All rights reserved.
//

import UIKit

class Categories: NSObject {
    
    var id: String =  String()
    var name: String =  String()
    var categoryDescription: String =  String()
    
}

class Sections: NSObject {
    
    var id: String =  String()
    var categoryId: String =  String()
    var name: String =  String()
    var sectionDescription: String = String()
    
}

class Articles: NSObject {
    
    var id: String =  String()
    var title: String =  String()
    var body: String =  String()
    var articleDetails: String = String()
    
}

class ArticlesVote: NSObject {
    
    var id: String =  String()
    var title: String =  String()
    var body: String =  String()
    var articleDetails: String = String()
    
}


class RMHelpCenter: NSObject {

    static var sharedInstance = RMHelpCenter()
    
    let helpCenterProvider: ZDKHelpCenterProvider = ZDKHelpCenterProvider()

//MARK: Help Center API'S
    
    //MARK: Categories API
    func getHelpCentreCategories(completionBlock: (categoriesArr: NSArray?, error: NSError?) -> Void) {
        
        helpCenterProvider.getCategoriesWithCallback { (response, error) -> Void in
            
            if error == nil {
                let categories = response as! Array<ZDKHelpCenterCategory>
                completionBlock(categoriesArr: self.parseCategories(categories), error: error)
            }
            else{
                completionBlock(categoriesArr: nil, error: error)
            }
            
        }
        
    }
    
    
    //MARK: Sections API
    func getHelpCenterFAQSections(categoryID: String, completionBlock: (sections: AnyObject?, error: NSError?) -> Void) {
        
        helpCenterProvider.getCategoryById(categoryID) { (categories, error) -> Void in
            
            if categories != nil {
                
                let allcategories: Array = categories
                
                for (var i=0; i<allcategories.count; i++) {
                    
                    let article: ZDKHelpCenterCategory = allcategories[i] as! ZDKHelpCenterCategory
                    
                    self.helpCenterProvider.getSectionsForCategoryId(article.sid, withCallback: { (sections, error) -> Void in
                        
                        if error == nil {
                            completionBlock(sections: sections, error: error)
                        }
                        else{
                            completionBlock(sections: nil, error: error)
                        }
                        
                    })
                    
                }
                
            }
            
        }
        
    }
    
    func getHelpCenterSectionsByCategoryId(categoryID: String, completionBlock: (sectionsArr: NSArray?, error: NSError?) -> Void) {
        
        self.helpCenterProvider.getSectionsForCategoryId(categoryID, withCallback: { (response, error) -> Void in           
            
            if error == nil {
                let sections = response as! Array<ZDKHelpCenterSection>
                completionBlock(sectionsArr: self.parseSections(sections), error: error)
            }
            else{
                completionBlock(sectionsArr: nil, error: error)
            }
            
        })

        
    }
    
    
    //MARK: Articles API
    func getHelpCenterArticleByLabels(completionBlock: (articleArr: NSArray?, error: NSError?) -> Void) {
        
        let labels: [AnyObject]! = ["top_10_questions"]
        
        helpCenterProvider.getArticlesByLabels(labels) { (response, error) -> Void in
            
            if error == nil {
                let articles = response as! Array<ZDKHelpCenterArticle>
                completionBlock(articleArr: self.parseArticles(articles), error: error)
            }
            else{
                completionBlock(articleArr: nil, error: error)
            }
            
        }
        
    }

    
    func getHelpCenterArticleBySectionId(sectionID: String, completionBlock: (articlesArr: NSArray?, error: NSError?) -> Void) {
        
        helpCenterProvider.getArticlesForSectionId(sectionID) { (response , error) -> Void in
        
            if error == nil {
                let articles = response as! Array<ZDKHelpCenterArticle>
                completionBlock(articlesArr: self.parseArticles(articles), error: error)
            }
            else{
                completionBlock(articlesArr: nil, error: error)
            }
            
        }
        
    }
    
    func searchArticlesByQuery(query: String, completionBlock: (articlesArr: NSArray?, error: NSError?) -> Void) {
        
        helpCenterProvider.searchForArticlesUsingQuery(query) { (response , error) -> Void in
            
            if error == nil {
                let articles = response as! Array<ZDKHelpCenterArticle>
                completionBlock(articlesArr: self.parseArticles(articles), error: error)
            }
            else{
                completionBlock(articlesArr: nil, error: error)
            }
            
        }
        
    }
    
    //MARK: Articles UpVote or DownVote API
    func isArticleHelpful(isHelpful: Bool, articleId: String?, completionBlock: (error: NSError?) -> Void) {
        
        if isHelpful {
            
            helpCenterProvider.upvoteArticleWithId(articleId, withCallback: { (response, error) -> Void in
                if error == nil {
                    completionBlock(error: nil)
                }
                else {
                    print(error.description)
                }
            })
            
        }
        else {
            
            helpCenterProvider.downvoteArticleWithId(articleId, withCallback: { (response, error) -> Void in
                if error == nil {
                    completionBlock(error: nil)
                }
                else {
                    print(error.description)
                }
            })
            
        }
        
    }
    
//MARK: Parse Values
    
    //MARK: Parse Categories
    func parseCategories(categories: Array<ZDKHelpCenterCategory>) -> NSArray {
        
        let categoriesArr: NSMutableArray = NSMutableArray()
        
        for category in categories {
            
            let categoryObj: Categories = Categories()
            
            categoryObj.id = category.sid
            categoryObj.name = category.name
            categoryObj.categoryDescription = category.categoryDescription
            
            categoriesArr.addObject(categoryObj)
            
        }
        
        return categoriesArr as NSArray
        
    }
    
    //MARK: Parse Sections
    func parseSections(sections: Array<ZDKHelpCenterSection>) -> NSArray {
        
        let sectionsArr: NSMutableArray = NSMutableArray()
        
        for section in sections {
            
            let sectionObj: Sections = Sections()
            
            sectionObj.id = section.sid
            sectionObj.categoryId = section.category_id
            sectionObj.name = section.name
            sectionObj.sectionDescription = section.sectionDescription
            
            sectionsArr.addObject(sectionObj)
            
        }
        
        return sectionsArr as NSArray
        
    }

    
    //MARK: Parse Articles
    func parseArticles(articles: Array<ZDKHelpCenterArticle>) -> NSArray {
        
        let articlesArr: NSMutableArray = NSMutableArray()
        
        for article in articles {
            
            let articleObj: Articles = Articles()

            articleObj.id = article.sid
            articleObj.title = article.title
            articleObj.body = article.body
            articleObj.articleDetails = article.article_details
            
            articlesArr.addObject(articleObj)
            
        }
        
        return articlesArr as NSArray
    }

    
    

}
