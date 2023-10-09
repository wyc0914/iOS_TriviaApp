//
//  TriviaQuestionService.swift
//  Trivia
//
//  Created by YiC Wang on 10/9/23.
//

import Foundation

class TriviaQuestionService {
    let baseURL = "https://opentdb.com/api.php?amount=5&category=18"

    func fetchQuestions(completion: @escaping ([TriviaQuestion]?, Error?) -> Void) {
        guard let url = URL(string: baseURL) else {
            completion(nil, NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"]))
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(nil, error)
                return
            }

            guard let data = data else {
                completion(nil, NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "No data received"]))
                return
            }

            do {
                let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as! [String: AnyObject]
                var questions = [TriviaQuestion]()
                for item in json["results"] as! [[String: Any]] {
                    let question = item["question"] as! String
                    let correctAnswer = item["correct_answer"] as! String
                    let incorrectAnswers = item["incorrect_answers"] as! [String]
                    questions.append(TriviaQuestion(category: item["category"] as! String, question: question.htmlDecoded, correctAnswer: correctAnswer.htmlDecoded, incorrectAnswers: incorrectAnswers.map { $0.htmlDecoded }))
                }
                completion(questions, nil)
            } catch {
                completion(nil, error)
            }
        }.resume()
    }
}

extension String {
    var htmlDecoded: String {
        guard let data = self.data(using: .utf8) else { return self }
        let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue
        ]
        if let attributedString = try? NSAttributedString(data: data, options: options, documentAttributes: nil) {
            return attributedString.string
        }
        return self
    }
}
