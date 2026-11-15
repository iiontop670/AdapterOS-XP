import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtMultimedia

Item {
    id: game

    signal exitRequested()

    property int columns: 20
    property int rows: 15
    property var snake: [{ x: 7, y: 7 }, { x: 6, y: 7 }, { x: 5, y: 7 }]
    property int foodX: 13
    property int foodY: 7
    property int score: 0
    property int bestScore: 0
    property string direction: "right"
    property string nextDirection: "right"
    property bool gameOver: false
    property bool paused: false

    SoundEffect {
        id: eatSound
        source: "qrc:/sounds/ui-click.wav"
        volume: 0.22
    }
    SoundEffect {
        id: crashSound
        source: "qrc:/sounds/ui-error.wav"
        volume: 0.28
    }

    function placeFood() {
        var valid = false
        var attempts = 0
        while (!valid && attempts < 500) {
            foodX = Math.floor(Math.random() * columns)
            foodY = Math.floor(Math.random() * rows)
            valid = true
            for (var i = 0; i < snake.length; ++i) {
                if (snake[i].x === foodX && snake[i].y === foodY) {
                    valid = false
                    break
                }
            }
            attempts++
        }
    }

    function resetGame() {
        snake = [{ x: 7, y: 7 }, { x: 6, y: 7 }, { x: 5, y: 7 }]
        direction = "right"
        nextDirection = "right"
        score = 0
        gameOver = false
        paused = false
        placeFood()
        board.requestPaint()
        game.forceActiveFocus()
    }

    function setDirection(value) {
        if (value === "up" && direction !== "down") nextDirection = value
        else if (value === "down" && direction !== "up") nextDirection = value
        else if (value === "left" && direction !== "right") nextDirection = value
        else if (value === "right" && direction !== "left") nextDirection = value
    }

    function tick() {
        if (gameOver || paused)
            return

        direction = nextDirection
        var head = snake[0]
        var nx = head.x
        var ny = head.y

        if (direction === "up") ny--
        else if (direction === "down") ny++
        else if (direction === "left") nx--
        else nx++

        if (nx < 0 || nx >= columns || ny < 0 || ny >= rows) {
            gameOver = true
            crashSound.play()
            return
        }

        var ateFood = nx === foodX && ny === foodY
        var bodyLimit = ateFood ? snake.length : snake.length - 1
        for (var i = 0; i < bodyLimit; ++i) {
            if (snake[i].x === nx && snake[i].y === ny) {
                gameOver = true
                crashSound.play()
                return
            }
        }

        var nextSnake = [{ x: nx, y: ny }].concat(snake)
        if (!ateFood)
            nextSnake.pop()
        else {
            score += 10
            if (score > bestScore) bestScore = score
            eatSound.play()
            placeFood()
        }

        snake = nextSnake
        board.requestPaint()
    }

    Component.onCompleted: {
        placeFood()
        game.forceActiveFocus()
    }

    Keys.onPressed: function(event) {
        if (event.key === Qt.Key_Up || event.key === Qt.Key_W) setDirection("up")
        else if (event.key === Qt.Key_Down || event.key === Qt.Key_S) setDirection("down")
        else if (event.key === Qt.Key_Left || event.key === Qt.Key_A) setDirection("left")
        else if (event.key === Qt.Key_Right || event.key === Qt.Key_D) setDirection("right")
        else if (event.key === Qt.Key_Space) paused = !paused
        else return
        event.accepted = true
    }

    Timer {
        interval: 135
        repeat: true
        running: !game.gameOver && !game.paused
        onTriggered: game.tick()
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 12
        spacing: 9

        RowLayout {
            Layout.fillWidth: true
            Label { text: "SCORE  " + game.score; font.bold: true; color: "#174a7e" }
            Item { Layout.fillWidth: true }
            Label { text: "BEST  " + game.bestScore; color: "#526d86" }
            Button {
                text: game.paused ? "Resume" : "Pause"
                onClicked: { game.paused = !game.paused; game.forceActiveFocus() }
            }
            Button { text: "New game"; onClicked: game.resetGame() }
        }

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Rectangle {
                anchors.centerIn: parent
                width: Math.min(parent.width, parent.height * (game.columns / game.rows))
                height: width * (game.rows / game.columns)
                color: "#102d24"
                border.color: "#6c9e7b"
                border.width: 2
                radius: 5

                Canvas {
                    id: board
                    anchors.fill: parent
                    anchors.margins: 4
                    onPaint: {
                        var ctx = getContext("2d")
                        var cellW = width / game.columns
                        var cellH = height / game.rows
                        ctx.clearRect(0, 0, width, height)
                        ctx.fillStyle = "#173d30"
                        ctx.fillRect(0, 0, width, height)

                        ctx.strokeStyle = "#28523f"
                        ctx.lineWidth = 0.6
                        for (var gx = 1; gx < game.columns; ++gx) {
                            ctx.beginPath(); ctx.moveTo(gx * cellW, 0); ctx.lineTo(gx * cellW, height); ctx.stroke()
                        }
                        for (var gy = 1; gy < game.rows; ++gy) {
                            ctx.beginPath(); ctx.moveTo(0, gy * cellH); ctx.lineTo(width, gy * cellH); ctx.stroke()
                        }

                        ctx.fillStyle = "#ffcf43"
                        ctx.beginPath()
                        ctx.arc((game.foodX + 0.5) * cellW, (game.foodY + 0.5) * cellH, Math.min(cellW, cellH) * 0.34, 0, Math.PI * 2)
                        ctx.fill()

                        for (var i = game.snake.length - 1; i >= 0; --i) {
                            var part = game.snake[i]
                            ctx.fillStyle = i === 0 ? "#a7f06b" : "#59c75b"
                            ctx.fillRect(part.x * cellW + 1.5, part.y * cellH + 1.5, cellW - 3, cellH - 3)
                        }
                    }
                }

                Rectangle {
                    anchors.fill: parent
                    color: "#c8000000"
                    visible: game.gameOver
                    radius: 4
                    Column {
                        anchors.centerIn: parent
                        spacing: 9
                        Text { anchors.horizontalCenter: parent.horizontalCenter; text: "GAME OVER"; color: "white"; font.pixelSize: 26; font.bold: true }
                        Text { anchors.horizontalCenter: parent.horizontalCenter; text: "Final score: " + game.score; color: "#e9f5e9"; font.pixelSize: 15 }
                        Button { anchors.horizontalCenter: parent.horizontalCenter; text: "Play again"; onClicked: game.resetGame() }
                    }
                }

                Rectangle {
                    anchors.fill: parent
                    color: "#99000000"
                    visible: game.paused && !game.gameOver
                    Text { anchors.centerIn: parent; text: "PAUSED"; color: "white"; font.pixelSize: 27; font.bold: true }
                }
            }
        }

        Label {
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
            text: "Move with the arrow keys or WASD  •  Space to pause"
            color: "#536b80"
            font.pixelSize: 11
        }
    }
}
