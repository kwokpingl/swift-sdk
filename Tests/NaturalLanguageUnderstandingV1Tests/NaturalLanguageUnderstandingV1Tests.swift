/**
 * Copyright IBM Corporation 2017
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 **/

import XCTest
import Foundation
import NaturalLanguageUnderstandingV1

class NaturalLanguageUnderstandingTests: XCTestCase {
    
    private var naturalLanguageUnderstanding: NaturalLanguageUnderstanding!
    private let timeout: TimeInterval = 5.0
    private let text = "In 2009, Elliot Turner launched AlchemyAPI to process the written word, with all of its quirks and nuances, and got immediate traction."
    private let url = "http://www.politico.com/story/2016/07/dnc-2016-obama-prepared-remarks-226345"
    private let testHtmlFileName = "testArticle"
    
    override func setUp() {
        super.setUp()
        instantiateNaturalLanguageUnderstanding()
    }
    
    static var allTests : [(String, (NaturalLanguageUnderstandingTests) -> () throws -> Void)] {
        return [
            ("testAnalyzeHTML", testAnalyzeHTML),
            ("testAnalyzeText", testAnalyzeText),
            ("testAnalyzeURL", testAnalyzeURL),
            ("testAnalyzeTextForConcepts", testAnalyzeTextForConcepts),
            ("testAnalyzeHTMLForConcepts", testAnalyzeHTMLForConcepts),
            ("testAnalyzeTextForEmotions", testAnalyzeTextForEmotions),
            ("testAnalyzeTextForEmotionsWithoutTargets", testAnalyzeTextForEmotionsWithoutTargets),
            ("testAnalyzeTextForEntities", testAnalyzeTextForEntities),
            ("testAnalyzeTextForKeywords", testAnalyzeTextForKeywords),
            ("testAnalyzeHTMLForMetadata", testAnalyzeHTMLForMetadata),
            ("testAnalyzeTextForRelations", testAnalyzeTextForRelations),
            ("testAnalyzeTextForSemanticRoles", testAnalyzeTextForSemanticRoles),
            ("testAnalyzeTextForSentiment", testAnalyzeTextForSentiment),
            ("testAnalyzeTextForSentimentWithoutTargets", testAnalyzeTextForSentimentWithoutTargets),
            ("testAnalyzeTextForCategories", testAnalyzeTextForCategories)
        ]
    }
    
    /** Instantiate Natural Language Understanding instance. */
    func instantiateNaturalLanguageUnderstanding() {
        let username = Credentials.NaturalLanguageUnderstandingUsername
        let password = Credentials.NaturalLanguageUnderstandingPassword
        naturalLanguageUnderstanding = NaturalLanguageUnderstanding(username: username, password: password, version: "2016-05-17")
    }
    
    /** Fail false negatives. */
    func failWithError(error: Error) {
        XCTFail("Positive test failed with error: \(error)")
    }
    
    /** Fail false positives. */
    func failWithResult<T>(result: T) {
        XCTFail("Negative test returned a result.")
    }
    
    /** Wait for expectations. */
    func waitForExpectations() {
        waitForExpectations(timeout: timeout) { error in
            XCTAssertNil(error, "Timeout")
        }
    }
    
    // MARK: - Helper Functions
    
    /** Load a file. */
    func loadFile(name: String, withExtension: String) -> URL? {
        
        #if os(iOS)
            let bundle = Bundle(for: type(of: self))
            guard let url:URL = bundle.url(forResource: name, withExtension: withExtension) else {
                return nil
            }
        #else
            let url = URL(fileURLWithPath: "Tests/NaturalLanguageUnderstandingV1Tests/"+name+"."+withExtension)
        #endif
        
        return url
    }
    
    // MARK: - Positive tests
    
    /** Default test for HTML input. */
    func testAnalyzeHTML() {
        let description = "Analyze HTML."
        let expectation = self.expectation(description: description)
        
        guard let fileURL = loadFile(name: testHtmlFileName, withExtension: "html") else {
            XCTFail("Failed to load file.")
            return
        }
        let concepts = ConceptsOptions(limit: 5)
        let features = Features(concepts: concepts)
        let parameters = Parameters(features: features, html: fileURL)
        
        naturalLanguageUnderstanding.analyzeContent(withParameters: parameters, failure: failWithError) {
            results in
            expectation.fulfill()
        }
        waitForExpectations()
    }
    
    /** Default test for text input. */
    func testAnalyzeText() {
        let description = "Analyze text with no features."
        let expectation = self.expectation(description: description)
        
        let concepts = ConceptsOptions(limit: 5)
        let features = Features(concepts: concepts)
        let parameters = Parameters(features: features, text: text)
        
        naturalLanguageUnderstanding.analyzeContent(withParameters: parameters, failure: failWithError) {
            results in
            expectation.fulfill()
        }
        waitForExpectations()
    }

    /** Default test for URL. */
    func testAnalyzeURL() {
        let description = "Analyze URL with no features."
        let expectation = self.expectation(description: description)
        
        let concepts = ConceptsOptions(limit: 5)
        let features = Features(concepts: concepts)
        let parameters = Parameters(features: features, url: url, returnAnalyzedText: true)
        
        naturalLanguageUnderstanding.analyzeContent(withParameters: parameters, failure: failWithError) {
            results in
            expectation.fulfill()
        }
        waitForExpectations()
    }
    
    /** Analyze given test input text for concepts. */
    func testAnalyzeTextForConcepts() {
        let description = "Analyze text with features."
        let expectation = self.expectation(description: description)
        
        let text = "In remote corners of the world, citizens are demanding respect for the dignity of all people no matter their gender, or race, or religion, or disability, or sexual orientation, and those who deny others dignity are subject to public reproach. An explosion of social media has given ordinary people more ways to express themselves, and has raised people's expectations for those of us in power. Indeed, our international order has been so successful that we take it as a given that great powers no longer fight world wars; that the end of the Cold War lifted the shadow of nuclear Armageddon; that the battlefields of Europe have been replaced by peaceful union; that China and India remain on a path of remarkable growth."
        let concepts = ConceptsOptions(limit: 5)
        let features = Features(concepts: concepts)
        let parameters = Parameters(features: features, text: text, returnAnalyzedText: true)
        
        naturalLanguageUnderstanding.analyzeContent(withParameters: parameters, failure: failWithError) {
            results in
            
            XCTAssertEqual(results.analyzedText, text)
            guard let concepts = results.concepts else {
                XCTAssertNil(results.concepts)
                return
            }
            for concept in concepts {
                XCTAssertNotNil(concept.name)
                XCTAssertNotNil(concept.dbpediaResource)
                XCTAssertNotNil(concept.relevance)
            }
            expectation.fulfill()
        }
        waitForExpectations()
    }
    
    /** Analyze test HTML for concepts. */
    func testAnalyzeHTMLForConcepts() {
        let description = "Analyze HTML for concepts."
        let expectation = self.expectation(description: description)
        
        guard let fileURL = loadFile(name: testHtmlFileName, withExtension: "html") else {
            XCTFail("Failed to load file.")
            return
        }
        let features = Features(concepts: ConceptsOptions())
        let parameters = Parameters(features: features, html: fileURL, returnAnalyzedText: true)
        
        naturalLanguageUnderstanding.analyzeContent(withParameters: parameters, failure: failWithError) {
            results in
            
            XCTAssertNotNil(results.analyzedText)
            XCTAssertNotNil(results.concepts)
            guard let concepts = results.concepts else {
                XCTAssertNil(results.concepts)
                return
            }
            for concept in concepts {
                XCTAssertNotNil(concept.name)
                XCTAssertNotNil(concept.dbpediaResource)
                XCTAssertNotNil(concept.relevance)
            }
            expectation.fulfill()
        }
        waitForExpectations()
    }
    
    /** Analyze input text for emotions. */
    func testAnalyzeTextForEmotions() {
        let description = "Analyze text for emotions."
        let expectation = self.expectation(description: description)
        
        let text = "But I believe this thinking is wrong. I believe the road of true democracy remains the better path. I believe that in the 21st century, economies can only grow to a certain point until they need to open up -- because entrepreneurs need to access information in order to invent; young people need a global education in order to thrive; independent media needs to check the abuses of power."
        let emotion = EmotionOptions(targets: ["democracy", "entrepreneurs", "media", "economies"])
        let features = Features(emotion: emotion)
        let parameters = Parameters(features: features, text: text, returnAnalyzedText: true)
        naturalLanguageUnderstanding.analyzeContent(withParameters: parameters, failure: failWithError) {
            results in
            
            XCTAssertEqual(results.analyzedText, text)
            guard let emotion = results.emotion else {
                XCTAssertNil(results.emotion)
                return
            }

            XCTAssertNotNil(emotion.document)
            guard let targets = emotion.targets else {
                XCTAssertNil(emotion.targets)
                return
            }
            for target in targets {
                XCTAssertNotNil(target.text)
                guard let emotion = target.emotion else {
                    XCTAssertNil(target.emotion)
                    return
                }
                XCTAssertNotNil(emotion.anger)
                XCTAssertNotNil(emotion.disgust)
                XCTAssertNotNil(emotion.fear)
                XCTAssertNotNil(emotion.joy)
                XCTAssertNotNil(emotion.sadness)
                break
            }
            expectation.fulfill()
        }
        waitForExpectations()
    }
    
    /** Analyze input text for emotions. */
    func testAnalyzeTextForEmotionsWithoutTargets() {
        let description = "Analyze text for emotions without targets."
        let expectation = self.expectation(description: description)
        
        let text = "But I believe this thinking is wrong. I believe the road of true democracy remains the better path. I believe that in the 21st century, economies can only grow to a certain point until they need to open up -- because entrepreneurs need to access information in order to invent; young people need a global education in order to thrive; independent media needs to check the abuses of power."
        let features = Features(emotion: EmotionOptions())
        let parameters = Parameters(features: features, text: text, returnAnalyzedText: true)
        naturalLanguageUnderstanding.analyzeContent(withParameters: parameters, failure: failWithError) {
            results in
            
            XCTAssertEqual(results.analyzedText, text)
            guard let emotionResults = results.emotion else {
                XCTAssertNil(results.emotion)
                return
            }
            XCTAssertNotNil(emotionResults.document)
            guard let documentEmotion = emotionResults.document?.emotion else {
                XCTAssertNil(emotionResults.document?.emotion)
                return
            }
            XCTAssertNotNil(documentEmotion.anger)
            XCTAssertNotNil(documentEmotion.disgust)
            XCTAssertNotNil(documentEmotion.fear)
            XCTAssertNotNil(documentEmotion.joy)
            XCTAssertNotNil(documentEmotion.sadness)
            
            XCTAssertNil(emotionResults.targets)

            expectation.fulfill()
        }
        waitForExpectations()
    }
    
    /** Analyze input text for entities. */
    func testAnalyzeTextForEntities() {
        let description = "Analyze text for entities and its corresponding sentiment values."
        let expectation = self.expectation(description: description)

        let features = Features(entities: EntitiesOptions(limit: 2, sentiment: true))
        let parameters = Parameters(features: features, text: self.text, returnAnalyzedText: true)
        naturalLanguageUnderstanding.analyzeContent(withParameters: parameters, failure: failWithError) {
            results in
            
            XCTAssertEqual(results.analyzedText, self.text)
            guard let entityResults = results.entities else {
                XCTAssertNil(results.entities)
                return
            }
            XCTAssertEqual(2, entityResults.count)
            for result in entityResults {
                XCTAssertNotNil(result.count)
                XCTAssertNotNil(result.relevance)
                XCTAssertNotNil(result.text)
                XCTAssertNotNil(result.type)
                XCTAssertNotNil(result.sentiment)
            }
            expectation.fulfill()
        }
        waitForExpectations()
    }
    
    /** Analyze input text for keywords. */
    func testAnalyzeTextForKeywords() {
        let description = "Analyze text for keywords and its corresponding sentiment values."
        let expectation = self.expectation(description: description)
        
        let features = Features(keywords: KeywordsOptions(sentiment: true))
        let parameters = Parameters(features: features, text: self.text, returnAnalyzedText: true)
        naturalLanguageUnderstanding.analyzeContent(withParameters: parameters, failure: failWithError) {
            results in
            
            XCTAssertEqual(results.analyzedText, self.text)
            guard let keywords = results.keywords else {
                XCTAssertNil(results.keywords)
                return
            }
            for keyword in keywords {
                XCTAssertNotNil(keyword.relevance)
                XCTAssertNotNil(keyword.text)
                XCTAssertNotNil(keyword.sentiment)
            }
            expectation.fulfill()
        }
        waitForExpectations()
    }
    
    /** Analyze html input for metadata. */
    func testAnalyzeHTMLForMetadata() {
        let description = "Analyze html for metadata."
        let expectation = self.expectation(description: description)
        
        let features = Features(metadata: MetadataOptions())
        guard let fileURL = loadFile(name: testHtmlFileName, withExtension: "html") else {
            XCTFail("Failed to load file.")
            return
        }
        let fileTitle = "This 5,000-year-old recipe for beer actually sounds pretty tasty"
        let fileDate = "2016-05-23T20:13:00"
        let fileAuthor = "Annalee Newitz"
        
        let parameters = Parameters(features: features, html: fileURL, returnAnalyzedText: true)
        naturalLanguageUnderstanding.analyzeContent(withParameters: parameters, failure: failWithError) {
            results in
            
            XCTAssertEqual(results.language, "en")
            XCTAssertEqual(results.metadata?.title, fileTitle)
            XCTAssertEqual(results.metadata?.publicationDate, fileDate)
            XCTAssertEqual(results.metadata?.authors?.count, 1)
            XCTAssertEqual(results.metadata?.authors?.first?.name, fileAuthor)
            
            expectation.fulfill()
        }
        waitForExpectations()
    }
    
    /** Analyze input text for relations. */
    func testAnalyzeTextForRelations() {
        let description = "Analyze text for relations."
        let expectation = self.expectation(description: description)
        
        let features = Features(relations: RelationsOptions())
        
        let parameters = Parameters(features: features, text: self.text, returnAnalyzedText: true)
        naturalLanguageUnderstanding.analyzeContent(withParameters: parameters, failure: failWithError) {
            results in
            
            XCTAssertEqual(results.analyzedText, self.text)
            XCTAssertEqual(results.language, "en")
            XCTAssertNotNil(results.relations)
            
            expectation.fulfill()
        }
        waitForExpectations()
    }
    
    /** Analyze input text for semantic roles. */
    func testAnalyzeTextForSemanticRoles() {
        let description = "Analyze text and verify semantic roles returned."
        let expectation = self.expectation(description: description)
        
        let features = Features(semanticRoles: SemanticRolesOptions(limit: 7, keywords: true, entities: true, requireEntities: false))
        
        let param = Parameters(features: features, text: text, returnAnalyzedText: true)
        naturalLanguageUnderstanding.analyzeContent(withParameters: param, failure: failWithError) {
            results in
            
            XCTAssertEqual(results.analyzedText, self.text)
            XCTAssertEqual(results.language, "en")
            XCTAssertNotNil(results.semanticRoles)
            for semanticRole in results.semanticRoles! {
                XCTAssertEqual(semanticRole.sentence, self.text)
                if let subject = semanticRole.subject {
                    XCTAssertNotNil(subject.text)
                }
                if let action = semanticRole.action {
                    XCTAssertNotNil(action.text)
                }
                if let object = semanticRole.object {
                    XCTAssertNotNil(object.text)
                }
            }
            expectation.fulfill()
        }
        waitForExpectations()
    }
    
    /** Analyze input text for sentiment with targets. */
    func testAnalyzeTextForSentiment() {
        let description = "Analyze text and verify sentiment returned."
        let expectation = self.expectation(description: description)
        
        let features = Features(sentiment: SentimentOptions(document: true, targets: ["Elliot Turner", "traction"]))
        
        let param = Parameters(features: features, text: text, returnAnalyzedText: true)
        naturalLanguageUnderstanding.analyzeContent(withParameters: param, failure: failWithError) {
            results in
            
            XCTAssertEqual(results.analyzedText, self.text)
            XCTAssertEqual(results.language, "en")
            XCTAssertNotNil(results.sentiment)
            XCTAssertNotNil(results.sentiment?.document)
            XCTAssertNotNil(results.sentiment?.document?.score)
            XCTAssertNotNil(results.sentiment?.targets)
            for target in (results.sentiment?.targets)! {
                XCTAssertNotNil(target.text)
                XCTAssertNotNil(target.score)
            }
            expectation.fulfill()
        }
        waitForExpectations()
    }
    
    func testAnalyzeTextCCForSentiment() {
        
        let description = "Analyze text and verify sentiment returned."
        let expectation = self.expectation(description: description)
        
        
        let features = Features(keywords: KeywordsOptions(limit: 100, sentiment: true))
        let textCC = "DON'T EAT HERE! Waiter was Pompas a**, recommend a bottle of wine that was terrible.. I was very specific about what we like. It seems that they were more interest in selling what they need to get rid of. Steak was tough, nothing was worth the price.  The worst was for a 330$ tab, we handed over 400! The waiter didn't even come back to the table! Apparently you automatically give 20% tip, even if food is mediocre and service sub par! Go to Capitol Grill, or old town Steakhouse... You'll be WAY happier.. Me and my Wife were in Vegas for a day layover and before we went home we wanted a nice steak dinner to cap off a great day and christmas weekend...unfortunately that was not the case.  The service and food up to the main course was great, we were having a great time.  Once the entree came out we started eating and chatting away.  As my wife was about to take her next bite she found a piece of metal shard in her bite of mushrooms and steak.  This could have come from a cleaning sponge or from a wire brush.  We let the staff know and they came over and were nice about it.  They gave us a new batch of mushrooms, which were over cooked, and again apologized.  After that moment we continued but were guarded in eating the rest of the meal.  After finding the shard kinda killed the meal and experience.  Due to our short stay we had to leave back to N.Y.  Also talked with the GM and never heard back. From someone who is in the hospitality industry... all in all it was a disappointing experience. I guess if you haven't eaten at any top of the lie steak houses this would be an above avg experience. The service was 5 stars all the way. Apps- Bacon-4 stars. Shrimp cocktail -1 star. Absolutely some of the smallest shrimp I have seen and at $5 a shrimp it's a must skip. Steak- Bone-in ribeye-3 stars. I have had much better, but I have also had much worse. Dessert- Warm brownie with ice cream covered in hot fudge 3 stars. OK service. We sat at the bar this time. I wouldn't suggest it. Table service is much more professional. Food just average this time. My go to Las Vegas Steakhouse!  Food and service is always amazing.  Typically we'll sit out on the patio so we can smoke cigars, which is nice, since most places don't allow it.  Prices for food, wine and liquor are typical for high-end Vegas steakhouses but worth it."
        
        let param = Parameters(features: features, text: textCC, returnAnalyzedText: true)
        
        naturalLanguageUnderstanding.analyzeContent(withParameters: param, failure: failWithError) {
            results in
            XCTAssertEqual(results.analyzedText, self.text)
            XCTAssertEqual(results.language, "en")
            XCTAssertNotNil(results.sentiment)
            XCTAssertNotNil(results.sentiment?.document)
            XCTAssertNotNil(results.sentiment?.document?.score)
            XCTAssertNotNil(results.sentiment?.targets)
            expectation.fulfill()
        }
        waitForExpectations()
    }
    
    /** Analyze input text for sentiment without targets. */
    func testAnalyzeTextForSentimentWithoutTargets() {
        let description = "Analyze text and verify sentiment returned."
        let expectation = self.expectation(description: description)
        
        let features = Features(sentiment: SentimentOptions(document: true))
        
        let param = Parameters(features: features, text: text, returnAnalyzedText: true)
        naturalLanguageUnderstanding.analyzeContent(withParameters: param, failure: failWithError) {
            results in
            
            XCTAssertEqual(results.analyzedText, self.text)
            XCTAssertEqual(results.language, "en")
            XCTAssertNotNil(results.sentiment)
            XCTAssertNotNil(results.sentiment?.document)
            XCTAssertNotNil(results.sentiment?.document?.score)
            XCTAssertNil(results.sentiment?.targets)
            expectation.fulfill()
        }
        waitForExpectations()
    }
    
    /** Analyze input text for categories. */
    func testAnalyzeTextForCategories() {
        let description = "Analyze text and verify categories returned."
        let expectation = self.expectation(description: description)
        
        let features = Features(categories: CategoriesOptions())
        
        let param = Parameters(features: features, text: text, returnAnalyzedText: true)
        naturalLanguageUnderstanding.analyzeContent(withParameters: param, failure: failWithError) {
            results in
            
            XCTAssertEqual(results.analyzedText, self.text)
            XCTAssertEqual(results.language, "en")
            XCTAssertNotNil(results.categories)
            for category in results.categories! {
                XCTAssertNotNil(category.label)
                XCTAssertNotNil(category.score)
            }
            expectation.fulfill()
        }
        waitForExpectations()
    }

    // MARK: - Negative tests
    
}
