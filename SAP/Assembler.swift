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
    let commandListing = [
    "halt":0,
    "clrr":1,
    "clrx":2,
    "clrm":3,
    "clrb":4,
    "movir":5,
    "movrr":6,
    "movrm":7,
    "movmr":8,
    "movxr":9,
    "movar":10,
    "movb":11,
    "addir":12,
    "addrr":13,
    "addmr":14,
    "addxr":15,
    "subir":16,
    "subrr":17,
    "submr":18,
    "subxr":19,
    "mulir":20,
    "mulrr":21,
    "mulmr":22,
    "mulxr":23,
    "divir":24,
    "divrr":25,
    "divmr":26,
    "divxr":27,
    "jmp":28,
    "sojr":29,
    "sojnz":30,
    "aojz":31,
    "aojnz":32,
    "cmpir":33,
    "cmprr":34,
    "cmpmr":35,
    "jmpn":36,
    "jmpz":37,
    "jmpp":38,
    "jsr":39,
    "ret":40,
    "push":41,
    "pop":42,
    "stackc":43,
    "outci":44,
    "outcr":45,
    "outcx":46,
    "outcb":47,
    "readi":48,
    "printi":49,
    "readc":50,
    "readln":51,
    "brk":52,
    "movrx":53,
    "movxx":54,
    "outs":55,
    "nop":56,
    "jmpne":57]
    
    private(set) var pointers:[String:Int] = [:];
    private(set) var program:String? = "";
    
    func load(Program:String){
        self.program = Program;
    }
    
    func Assemble()->[Int]{
        var Data = [Int]();
        
        guard let PGRM = self.program else{
            print("FATAL ASSEMBLY ERROR : No Program Loaded.")
            return [Int]();
        }
        
        let Lines = PGRM.characters.split(separator: "\n").map{String($0)};
        
        for Line in Lines{
            let ColonBreaker = Line.characters.split(separator: ":")
            let CInd = 0 + ColonBreaker.count - 1;
            guard ColonBreaker.count <= 2 else{
                print("Assebler error. Too many colons.");
                return [Int]()
            }
            
            let Options = String(ColonBreaker[CInd]).characters.split(separator: " ")
                                                    .filter({!$0.isEmpty})
                                                    .map{String($0)};
            
            
            let Command = Options[0];
            
            if let cmdInt = commandListing[Command]{
                print(cmdInt)
            }else{
                print(Command);
                switch(Command){
                    case ".Integer":
                        guard Options.count > 1 else{
                            print("Error : .Integer takes at least 1 option.");
                            break;
                        }
                        print(Options)
                        Data.append(Int(String(Options[1].characters.dropFirst()))!)
                        
                        break;
                    case ".String":
                        guard Options.count > 1 else{
                            print("Error : .String takes at least 1 option.");
                            break;
                        }
                        let Collision = Options[1...Options.count - 1].reduce("",{$0 + " \($1)"});
                        let STR = String(Collision.characters.dropFirst(2).dropLast());
                        Data.append(Int(STR.characters.count));
                        STR.characters.map{let S = String($0).unicodeScalars; return Int(S[S.startIndex].value)}
                            .forEach({Data.append($0)});
                        
                        
                        break;
                    default:
                        break;
                }
            }
            print(Data);
            
            
        }
        
        return [Int]();
    }
}










