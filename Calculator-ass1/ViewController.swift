//
//  ViewController.swift
//  Calculator-ass1
//
//  Created by Jay Mukul on 3/4/20.
//  Copyright © 2020 Jay Mukul. All rights reserved.
//

import UIKit

extension Double {
// Rounds the double to decimal places value
func rounded(toPlaces places:Int) -> Double {
    let divisor = pow(10.0, Double(places))
    return (self * divisor).rounded() / divisor
    
 }
}

class ViewController: UIViewController {

   //Result or Operation Display Label
    @IBOutlet weak var displayNum: UILabel!
    @IBOutlet weak var inputTextView: UITextView!
    
    
    /*----------------------Operator Enumartion for Case Starts Here----------------------*/
    enum Operators : String {
        case plus = "+"
        case minus = "-"
        case divide = "/"
        case multiply = "X"
    }
    /*----------------------Operator Enumartion for Case Ends Here----------------------*/
    
    
    /*---------------------- All Variables Declaration Starts Here----------------------*/
    var numbersArray : [(num : Double, sign : Bool)] = [(0,true)]
    var numbersStringArray : [String] = ["0"]
    var operatorsArray : [Operators] = []
    var inputText : String = "0"
    var numberExist : Bool = false
    var dotExist : Bool = false
    var operatorExist : Bool = false
    var currentSign : Bool = true
    var percentExist : Bool = false
    /*---------------------- All Variables Declaration Ends Here----------------------*/
    
    
     /*----------------------Loading Function Starts Here----------------------*/
    
     override func viewDidLoad() {
         super.viewDidLoad()
        displayNum.text = "0"
        inputTextView.text = "Input Display"
         // Do any additional setup after loading the view.
            inputTextView.textContainer.maximumNumberOfLines = 1
            inputTextView.invalidateIntrinsicContentSize()
            inputTextView.textContainer.lineBreakMode = .byTruncatingHead
            inputTextView.isScrollEnabled = true
              
     }
    
     /*----------------------Loading Function Ends Here----------------------*/
    
    /*----------------------User Click Number or Decimal Starts Here ----------------------*/
    
    @IBAction func numButtonsPressed(_ sender: UIButton) {
        
        if percentExist {return}
        //it gets the number which is clickget number that clicked
        guard let inputString : String = sender.titleLabel?.text else {return}
        
        //check if it is a point
        if inputString == "." {
            if dotExist {
                return
            } else {
                dotExist = true
            }
        }
        
        //pop last number to modify it
        let numberString : String = numbersStringArray.removeLast()
        if numberExist {
            numbersArray.removeLast()
        }
        
        //modify number based on input
        let newNumberString : String
        if inputText == "0" && inputString != "." {
            newNumberString = inputString
            numbersArray.removeFirst()
        } else {
            newNumberString = numberString + inputString
        }
        
        //push back new value
        numbersStringArray.append(newNumberString)
        numbersArray.append((Double(String(newNumberString))! , currentSign))
        
        //change input based on new number
        inputText = inputText.prefix(inputText.count - numberString.count) + newNumberString
        
        //re calculate whole input
        operatorExist = false
        numberExist = true
        mainCalculation()
       
    }
     /*----------------------User Click Number or Decimal Ends Here ----------------------*/
    
    /*----------------------Operators (+,-,x,/), Sign Change(+/-), Percentage (%) Starts Here---------------------*/
    @IBAction func performOperation(_ sender: UIButton) {
        
        //It doesn't put operator after negetive sign without number
               if !numberExist && !currentSign {
                   return
               }
               
               //It puts ")" when number is negetive
               if !currentSign {
                   inputText += ")"
               }
               
               //check if op exist
               if operatorExist {
                   //Here we are going to replace last 3 chars
                   inputText = String(inputText.dropLast(3))
                   operatorsArray.removeLast()
               } else {
                   operatorExist = true
                   numbersStringArray.append("")
               }
               
               //reset variables
               numberExist = false
               dotExist = false
               currentSign = true
               percentExist = false
               
               //get number that clicked
               guard let inputString : String = sender.titleLabel?.text else {return}
               
               //modify input
               inputText += " " + inputString + " "
               
               //set lable with new input
               inputTextView.text = inputText
               
               //Find the Case for the operator press from enum and add it to array
               guard let ops : Operators = Operators.init(rawValue: inputString) else {return}
               operatorsArray.append(ops)
       }
    
    @IBAction func invertnum(_ sender: Any) {
           //if number didn't exist we should add "(-" to label
           if !numberExist {
               if currentSign {
                   if inputText == "0" {
                       inputText = ""
                   }
                   inputText += "(-"
               } else {
                   inputText = String(inputText.prefix(inputText.count - 2))
               }
           } else {
               guard let numberString = numbersStringArray.last else {return}
               let numberTemp = numbersArray.removeLast()
               
               //delete and fix
              if numberTemp.sign {
                   inputText = inputText.prefix(inputText.count - numberString.count) + "(-" + numberString
                   numbersArray.append((numberTemp.num,false))
               } else {
                   inputText = inputText.prefix(inputText.count - numberString.count - 2) + numberString
                   numbersArray.append((numberTemp.num,true))
               }
           }
           
           mainCalculation()
           currentSign = !currentSign
           
           //set label
           inputTextView.text = inputText
       }
    
    @IBAction func percentBtn(_ sender: UIButton) {
        //don't enter number after persent (just op)
        if !numberExist {return}
        
        //lets get the last number to modify it
        var number = numbersArray.removeLast()
        number.num /= 100
        
        //fix input text
        var numberString : String = numbersStringArray.removeLast()
        inputText = String(inputText.prefix(inputText.count - numberString.count))
        
        //find if it has "." but no 0!
        if numberString.last == "." {
            numberString += "0"
        }
        inputText += numberString + "%"
        
        //push back number and it's string
        var fixedNumber : Double = number.num
        if numberString != String(fixedNumber){
            fixedNumber = Double(String(number.num))!
        }
        numbersArray.append((fixedNumber , number.sign))
        numbersStringArray.append(numberString)
        
        //set text and recalculate
        percentExist = true
        inputTextView.text = inputText
        mainCalculation()
        
    }
    /*--------------------------Operators (+,-,x,/), Sign Change(+/-), Percentage (%) Ends Here-------------------------*/
    
    /*----------------------Final Result on Click on Equals Starts Here!----------------------*/
       
       @IBAction func calculateBtn(_ sender: UIButton) {
           //if the last entered was operator and there wasn't any number after that
           if (operatorExist && !numberExist){
               operatorsArray.removeLast()
               mainCalculation()
           }
           
           // if we have only one number
           if (numbersArray.count < 2){
               return
           }
           
           //show the last calculated result a the last result :D
           let result : String = displayNum.text ?? "0"
           
           //remove and clear
           displayNum.text?.removeAll()
           numbersArray = []
           operatorsArray = []
           numbersStringArray = []
           
           //Set input View String with result
           inputText = result
           inputTextView.text = result
           
           //add result as input to elements
           let number : Double = Double(result)!
           currentSign = number >= 0
           numberExist = true
           numbersArray.append((num: abs(number), sign: currentSign))
           let numbersString : String = currentSign ? result : "(-" + result.dropFirst()
           dotExist = numbersString.contains(".")
           numbersStringArray.append(numbersString)
       }
    /*----------------------Final Result on Click on Equals Ends Here!----------------------*/
    
    
    /*----------------------Clear Screen Operation Starts Here!----------------------*/
    
    @IBAction func clearScreen(_ sender: UIButton) {
        displayNum.text = "0"
        inputTextView.text = "0"
        inputTextView.text?.removeAll()
        displayNum.text?.removeAll()
        numbersArray = [(0,true)]
        operatorsArray = []
        numbersStringArray = ["0"]
        inputText = "0"
        numberExist = false
        dotExist = false
        operatorExist = false
        currentSign = true
        percentExist = false
    }
   /*----------------------Clear Screen Operation Ends Here!----------------------*/
     
    
    /*---------------------Actual Calculation is Performed, With for Higher and Lower Percendance check Starts Here----------------------*/
    func mainCalculation(){
        //set lable with new input
        inputTextView.text = inputText
        
        //if we have 2 number in our list and we are sure that next number is entered then calculate result
        if (numbersArray.count > 1 && numberExist) || (percentExist && numberExist) {
            
            //clone arrays to calculate
            var numbersArrayTemp : [(num : Double, sign : Bool)] = numbersArray
            var operatorsArrayTemp : [Operators] = operatorsArray
            
            //Find * and / from left in the String
            var index : Int = 0
            while (!operatorsArrayTemp.isEmpty && index < operatorsArrayTemp.count){
                if operatorsArrayTemp[index] == .multiply || operatorsArrayTemp[index] == .divide {
                    
                    //get number and operators from left
                    let currentOP : Operators = operatorsArrayTemp.remove(at: index)
                    let num1Temp = numbersArrayTemp.remove(at: index)
                    let num2Temp = numbersArrayTemp.remove(at: index)
                    let result : Double
                    
                    //fix number sign
                    let num1 : Double = num1Temp.sign ? num1Temp.num : -num1Temp.num
                    let num2 : Double = num2Temp.sign ? num2Temp.num : -num2Temp.num
                    
                    //lets calculate result
                    switch currentOP {
                    case .multiply : result = num1 * num2
                    case .divide : result = num1 / num2
                    default: return
                    }
                    
                    //fix double point
                    let resultString = String(result)
                    if let fixedResult = Double(resultString){
                        //push back result
                        numbersArrayTemp.insert((abs(result.rounded(toPlaces: 8)), fixedResult < 0 ? false : true) , at: index)
                        index -= 1
                    }
                }
                index += 1
            }
            
           //Find + and - from left in the String
            index = 0
            while (!operatorsArrayTemp.isEmpty && index < operatorsArrayTemp.count){
                if operatorsArrayTemp[index] == .plus || operatorsArrayTemp[index] == .minus {

                    //get number and operators from left
                    let currentOP : Operators = operatorsArrayTemp.remove(at: index)
                    let num1Temp = numbersArrayTemp.remove(at: index)
                    let num2Temp = numbersArrayTemp.remove(at: index)
                    let result : Double
                    
                    //fix number sign
                    let num1 : Double = num1Temp.sign ? num1Temp.num : -num1Temp.num
                    let num2 : Double = num2Temp.sign ? num2Temp.num : -num2Temp.num

                    //lets calculate result
                    switch currentOP {
                    case .minus : result = num1 - num2
                    case .plus : result = num1 + num2
                    default: return
                    }

                    //push back result
                    numbersArrayTemp.insert((abs(result.rounded(toPlaces: 8)), result < 0 ? false : true ), at: index)
                    index -= 1
                }
                index += 1
            }
            
            //Set Final result to Display
            let resultTemp = numbersArrayTemp.removeFirst()
            let result = resultTemp.sign ? resultTemp.num : -resultTemp.num
            var resultString = String(result)
            if resultString.contains(".") {
                resultString = String(resultString.split(separator: ".")[1]) == "0" ? String(resultString.dropLast(2)) : resultString
            }
            displayNum.text = resultString
        }
        
    }
    /*---------------------Actual Calculation is Performed, With Higher and Lower Percendance check Ends Here----------------------*/
      
}
