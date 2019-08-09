//
//  main.swift
//  1hegame
//
//  Created by Egor Tereshonok on 8/8/19.
//  Copyright © 2019 Egor Tereshonok. All rights reserved.
//
import Foundation

let SCENE_WIDTH = 15
let SCENE_HEIGHT = 12
let BOX_COUNT = 10
let BARRIERS_COUNT = 5
let BARRIERS = ["🌳","🌋","🏫","🏢"]

var stepsCount: Int = 0
var currentBoxCount: Int = 0
var bestResult: Int = 0
class SceneObject {
    var symbol: String
    init(symbol: String) {
        self.symbol = symbol
    }
}

class MovingObject: SceneObject {
    var x: Int = 0
    var y: Int = 0
}

enum Direction {
    case Left
    case Right
    case Up
    case Down
}

class Player: MovingObject {
    var currentRoom: Room? = nil
    init() {
        super.init(symbol: "👮🏿‍♀️")
    }
    
    func moveTo(direction : Direction) -> Bool {
        
        var isMoving = false
        switch direction {
        case .Left:
            if let room = currentRoom {
                isMoving = room.moveObject(object: self, x: -1, y: 0)
            }
        case .Right:
            if let room = currentRoom {
                isMoving = room.moveObject(object: self, x: 1, y: 0)
            }
        case .Up:
            if let room = currentRoom {
                isMoving = room.moveObject(object: self, x: 0, y: -1)
            }
        case .Down:
            if let room = currentRoom {
                isMoving = room.moveObject(object: self, x: 0, y: 1)
            }
        }
        
        if (isMoving){
            stepsCount = stepsCount + 1
        }
        return isMoving
    }
}

class Box: MovingObject {
    init() {
        super.init(symbol: "📦")
    }
}

class Wall: SceneObject {
    init() {
        super.init(symbol: "🔲")
    }
}

class Home: MovingObject {
    init() {
        super.init(symbol: "🚔")
    }
}

class barrier: MovingObject {
    var barrier: String
    init() {
        self.barrier = BARRIERS[Int.random(in: 0..<BARRIERS.count)]
        super.init(symbol: barrier)
    }
}

class Ground: SceneObject {
    init() {
        super.init(symbol: "⬜️")
    }
}

class Room {
    
    let width: Int
    let height: Int
    let boxesCount: Int
    
    let player: Player
    
    var map: [[SceneObject]]!
    
    init(width: Int, height: Int, boxesCount: Int) {
        self.width = width
        self.height = height
        self.boxesCount = boxesCount
        
        currentBoxCount = boxesCount
        stepsCount = 0
        
        self.map = Array.init(repeating: Array.init(repeating: Ground(), count: self.height), count: self.width)
        
        for i in 0..<self.width {
            self.map[i][0] = Wall()
            self.map[i][self.height-1] = Wall()
        }
        
        for i in 1..<self.height - 1 {
            self.map[0][i] = Wall()
            self.map[self.width-1][i] = Wall()
        }
        
        player = Player()
        player.currentRoom = self
        insertObject(object: player)
        
        for _ in 0..<boxesCount {
            insertObject(object: Box(), borderOffset: 2)
        }
        for _ in 0..<BARRIERS_COUNT {
            insertObject(object: barrier())
        }
        
        insertObject(object: Home())
    }
    
    func insertObject(object: MovingObject, borderOffset: Int = 0) {
        let x = Int(arc4random())%(self.width - borderOffset*2) + borderOffset
        let y = Int(arc4random())%(self.height - borderOffset*2) + borderOffset
        if map[x][y] is Ground {
            map[x][y] = object
            object.x = x
            object.y = y
        } else {
            insertObject(object: object, borderOffset: borderOffset)
        }
    }
    
    func moveObject(object:MovingObject, x: Int, y: Int) -> Bool {
        
        let _x = object.x + x
        let _y = object.y + y
        
        if _x < 0 || _y < 0 || _x >= self.width || _y >= self.height {
            return false
        }
        
        let obj = map[_x][_y]
        
        switch obj {
            
        case _ where obj is Ground:
            let tempPos =  (x: object.x, y: object.y)
            map[tempPos.x][tempPos.y] = obj
            object.x = _x
            object.y = _y
            map[_x][_y] = object
            return true
        case _ where obj is Box:
            if (moveObject(object: map[_x][_y] as! MovingObject, x: x, y: y)){
                return moveObject(object:object, x:x, y:y)
            }
            return true
        case _ where obj is Home && object is Box :
            map[object.x][object.y] = Ground()
            
            //check victory
            currentBoxCount = currentBoxCount - 1
            if currentBoxCount == 0 {
                if (stepsCount <= bestResult || bestResult == 0) {bestResult = stepsCount}
                print("VICTORY! ENTER r TO RESTART")
            }
            
            return true
            
        default:
            break
        }
        
        return false
    }
    
    func draw() {
        for i in 0..<self.height {
            var str = ""
            for j in 0..<self.width {
                str += map[j][i].symbol
            }
            print(str)
        }
    }
}
var room: Room!
func startGame() {
    room = Room(width: SCENE_WIDTH, height: SCENE_HEIGHT, boxesCount: BOX_COUNT)
    
}

func goTo(direction: Direction, steps: Int){
    for _ in 0..<steps {
        if !room.player.moveTo(direction: direction) {
            break
        }
    }
    room.draw()
}




func updateUI() {
    room.draw()
    printHintCommands()
}

func printHintCommands() {
    print("Put boxes in the car")
    print("[r] - restart")
    print("STEP: \(stepsCount)  BOXES: \(currentBoxCount)  BEST: \(bestResult)")
    print("   [w]    - up")
    print("[a][s][d] - left, down, right")
    
    print("Enter: ")
    let s = readLine()
    
    switch s?.prefix(1).lowercased() {
    case "r":
        startGame()
    case "w":
        _ = room.player.moveTo(direction: .Up)
    case "s":
        _ = room.player.moveTo(direction: .Down)
    case "a":
        _ = room.player.moveTo(direction: .Left)
    case "d":
        _ = room.player.moveTo(direction: .Right)
    default:
        break
    }
    
    updateUI()
}

startGame()
updateUI()


