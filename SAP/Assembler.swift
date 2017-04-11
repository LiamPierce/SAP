//
//  Assembler.swift
//  SAP
//
//  Created by Liam Pierce on 4/4/17.
//  Copyright © 2017 Liam Pierce. All rights reserved.
//

import Foundation

//Crude attempt at an assembler.

extension Character
{
    func unicodeScalarCodePoint() -> UInt32
    {
        let characterString = String(self)
        let scalars = characterString.unicodeScalars
        
        return scalars[scalars.startIndex].value
    }
}


class Assembler{
    let commandListing = VirtualMachine.commandListing;
    
    private(set) var pointers:[String:Int] = [:];
    private(set) var pointerReplicate:[String:[Int]] = [:];
    private(set) var program:String? = "";
    
    func getASCI(Char:Character)->Int{
        let S = String(Char).unicodeScalars;
        return Int(S[S.startIndex].value);
    }
    
    func load(Program:String){
        self.program = Program;
    }
    
    func Assemble()->[Int]{
        var Data = [Int]();
        var startPointer:String = "";
        
        guard let PGRM = self.program else{
            print("FATAL ASSEMBLY ERROR : No Program Loaded.")
            return [Int]();
        }
        
        let Lines = PGRM.characters.split(separator: "\n").map{String($0)};
        
        for Line in Lines{
            let ColonBreaker = Line.characters.split(separator: ":")
            let CInd = ColonBreaker.count - 1;
            let MemoryLocation = Data.count;
            guard ColonBreaker.count <= 2 else{
                print("Assebler error. Too many colons.");
                return [Int]()
            }
            
            let Options = String(ColonBreaker[CInd]).characters.split(separator: " ")
                                                    .filter({!$0.isEmpty})
                                                    .map{String($0)};
            
            let Command = (Options.count > 0) ? Options[0] : "";
            
            if let cmdInt = commandListing[Command]{
                Data.append(cmdInt);
                if Options.count > 1{
                    for i in 1...Options.count - 1{ //For each option.
                    
                        if let asInt = Int(Options[i]){
                            Data.append(asInt)
                        }else if Options[i].characters.first == "r" && Options[i].characters.count == 2{
                            Data.append(Int(String(Options[i].characters.dropFirst()))!);
                            print(Data[Data.count - 1]);
                        }else if Options[i].characters.first == "#" && i >= 1{
                            Data.append(Int(String(Options[i].characters.dropFirst()))!);
                        }else if Options[i].characters.first == ";"{
                            break;
                        }else{
                            let LOW = Options[i].lowercased()
                            if pointerReplicate[LOW] != nil{
                                pointerReplicate[LOW]!.append(Data.count);
                            }else{
                                pointerReplicate[LOW] = [Data.count];
                            }
                            Data.append(0); //Append a placeholder to be replaced by the pointer on 2nd pass.
                        }
                    }
                }
            
                if CInd > 0{
                    pointers[String(ColonBreaker[0]).lowercased()] = MemoryLocation;
                }
            }else{
                switch(Command){
                    case ".Integer":
                        guard Options.count > 1 else{
                            print("Error : .Integer takes at least 1 option.");
                            break;
                        }
                        Data.append(Int(String(Options[1].characters.dropFirst()))!)
                        break;
                    case ".String":
                        guard Options.count > 1 else{
                            print("Error : .String takes at least 1 option.");
                            return [Int]();
                        }
                        
                        let QSplit = Line.characters.split(separator: "\"");
                        
                        guard QSplit.count >= 2 else{
                            print("Syntax error: .String call without quotations.");
                            return [Int]();
                        }
                        
                        let STR = QSplit[1]; //"first of string" "part of quote" "end quote, blank."
                        Data.append(Int(STR.count));
                        STR.map(getASCI)
                            .forEach({Data.append($0)});
                        break;
                    case ".Character":
                        let QSplit = Line.characters.split(separator: "\'");
                        guard QSplit.count >= 2 else{
                            print("Syntax error: .String call without quotations.");
                            return [Int]();
                        }
                        Data.append(getASCI(Char:QSplit[1].first!));
                    
                    case ".Tuple":
                        print(Options)
                        guard Options.count >= 5 else{
                            print("Tuple length invalid.");
                            return [Int]();
                        }
                        guard let InState = Int(String(Options[1])) else{
                            print("InState is not a valid number.");
                            return [Int]();
                        }
                        
                        let InChar = getASCI(Char:Options[2].characters.first!)
                        
                        guard let OutState = Int(String(Options[3])) else{
                            print("OutState is not a valid number.")
                            return [Int]();
                        }
                        
                        let OutChar = getASCI(Char:Options[4].characters.first!)
                        let Dir = (String(Options[5]) == "l") ? 0 : 1; //If not l, it will be r.
                        
                        Data.append(InState); //Input State
                        Data.append(InChar); //InChar
                        Data.append(OutState); //OutState
                        Data.append(OutChar); //OutChar
                        Data.append(Dir) //OutDir;
                        
                        break;
                    case ".Start":
                        print("Start established at location: \(Options[1].lowercased()).")
                        startPointer = Options[1].lowercased();
                        break;
                    case ".end":
                        print("Program assembled.")
                        break;
                    case "": //Empty line.
                        break;
                    default:
                        if (Command.characters.first != ";"){
                            print("This command did not exist.")
                        }
                        break;
                }
                
                if CInd > 0{
                    pointers[String(ColonBreaker[0]).lowercased()] = MemoryLocation;
                }
            }
            
            
        }
        
        for (k,v) in pointers{
            if let local = pointerReplicate[k]{
                for location in local {
                    Data[location] = v;
                }
            }else if startPointer != k{
                print("Pointer not used : \(k)");
            }
        }
        
        Data.insert(Data.count, at: 0);
        Data.insert(pointers[startPointer] ?? 0,at:1);
        
        return Data;
    }
}










