import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import Quickshell
import Quickshell.Services.Mpris

PanelWindow {
    id: win
    implicitWidth: 360
    implicitHeight: player ? 196 : 40
    color: bg
    exclusionMode: ExclusionMode.Normal

    anchors.right: true
    anchors.bottom: true
    margins.right: 8
    margins.bottom: 8

    readonly property color fg: "#e2daf0"
    readonly property color muted: "#73648a"
    readonly property color accent: "#cba6f7"
    readonly property color surface: "#2b2638"
    readonly property color hoverBg: "#3d3550"
    readonly property color bg: "#1a1826"

    property int playerIndex: 0
    property var players: Mpris.players.values
    property var player: players.length > 0 ? players[playerIndex % players.length] : null
    property string spotifyArt: ""

    property string artSource: {
        if (player?.trackArtUrl) return player.trackArtUrl
        if (player?.metadata?.["mpris:artUrl"]) return player.metadata["mpris:artUrl"]
        return spotifyArt
    }

    Timer {
        running: player?.playbackState === MprisPlaybackState.Playing
        interval: 1000
        repeat: true
        onTriggered: player?.positionChanged()
    }

    Connections {
        target: Mpris.players
        function onValuesChanged() {
            if (players.length === 0) playerIndex = 0
            else playerIndex = playerIndex % players.length
        }
    }

    Connections {
        target: player
        function onTrackChanged() { fetchSpotifyArt() }
    }

    function fetchSpotifyArt() {
        spotifyArt = ""
        if (!player?.metadata) return
        var url = player.metadata["xesam:url"]
        if (!url || !url.includes("open.spotify.com")) return
        var xhr = new XMLHttpRequest()
        xhr.open("GET", "https://open.spotify.com/oembed?url=" + encodeURIComponent(url))
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE && xhr.status === 200) {
                try {
                    var json = JSON.parse(xhr.responseText)
                    if (json.thumbnail_url) spotifyArt = json.thumbnail_url
                } catch (e) {}
            }
        }
        xhr.send()
    }

    Rectangle {
        anchors.fill: parent
        color: bg
        radius: 12

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 10
            spacing: 6

            Text {
                Layout.alignment: Qt.AlignCenter
                text: "No media playing"
                color: muted
                font.pixelSize: 13
                visible: !player
            }

            ColumnLayout {
                visible: player
                spacing: 6

                RowLayout {
                    Layout.alignment: Qt.AlignCenter
                    spacing: 4
                    visible: players.length > 1

                    Repeater {
                        model: players.length
                        delegate: Rectangle {
                            width: index === playerIndex ? 16 : 6
                            height: 6
                            radius: 3
                            color: index === playerIndex ? accent : surface
                            Behavior on width { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: { if (index !== playerIndex) playerIndex = index }
                            }
                        }
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10

                    Item {
                        width: 56
                        height: 56

                        Rectangle {
                            anchors.fill: parent
                            radius: 8
                            color: surface

                            Image {
                                id: artImg
                                anchors.fill: parent
                                source: artSource
                                fillMode: Image.PreserveAspectCrop
                                visible: status === Image.Ready
                                layer.enabled: true
                                layer.effect: MultiEffect {
                                    shadowEnabled: true
                                    shadowColor: "#80000000"
                                    shadowBlur: 0.8
                                    shadowVerticalOffset: 2
                                    autoPaddingEnabled: true
                                }
                                onStatusChanged: {
                                    if (status === Image.Error) {
                                        console.log("art load error:", source)
                                    }
                                }
                            }

                            Rectangle {
                                anchors.fill: parent
                                radius: 8
                                color: accent
                                visible: artImg.status !== Image.Ready
                                opacity: 0.15
                            }

                            Text {
                                anchors.centerIn: parent
                                text: "\uF025"
                                font.pixelSize: 16
                                color: accent
                                visible: artImg.status !== Image.Ready
                            }
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignVCenter
                        spacing: 1

                        Text {
                            Layout.fillWidth: true
                            text: player?.trackTitle || "No title"
                            color: fg
                            font.pixelSize: 13
                            font.bold: true
                            elide: Text.ElideRight
                        }

                        Text {
                            Layout.fillWidth: true
                            text: {
                                const a = player?.trackArtist
                                const al = player?.trackAlbum
                                if (a && al) return a + "  \u2022  " + al
                                if (a) return a
                                if (al) return al
                                return ""
                            }
                            color: muted
                            font.pixelSize: 11
                            elide: Text.ElideRight
                            visible: text !== ""
                        }

                        Text {
                            text: player?.identity ?? ""
                            color: accent
                            font.pixelSize: 9
                            visible: text !== ""

                            MouseArea {
                                anchors.fill: parent
                                enabled: player?.canRaise ?? false
                                cursorShape: Qt.PointingHandCursor
                                onClicked: player?.raise()
                            }
                        }
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 5

                    Text {
                        text: formatTime(player?.position ?? 0)
                        color: muted
                        font.pixelSize: 9
                    }

                    Item {
                        Layout.fillWidth: true
                        height: 6

                        Rectangle {
                            anchors.verticalCenter: parent.verticalCenter
                            width: parent.width
                            height: 4
                            radius: 2
                            color: surface
                        }

                        Rectangle {
                            anchors {
                                left: parent.left
                                verticalCenter: parent.verticalCenter
                            }
                            width: player?.length > 0
                                ? parent.width * Math.min(player.position / player.length, 1)
                                : 0
                            height: 4
                            radius: 2
                            color: accent
                            Behavior on width { NumberAnimation { duration: 200; easing.type: Easing.Linear } }
                        }

                        MouseArea {
                            anchors.fill: parent
                            enabled: player?.canSeek ?? false
                            cursorShape: Qt.PointingHandCursor
                            onClicked: mouse => {
                                if (player?.canSeek && player.length > 0)
                                    player.position = player.length * (mouse.x / width)
                            }
                        }
                    }

                    Text {
                        text: formatTime(player?.length ?? 0)
                        color: muted
                        font.pixelSize: 9
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignCenter
                    spacing: 2

                    CtrlBtn {
                        text: "\uF033"
                        active: player?.shuffle ?? false
                        enabled: player?.shuffleSupported ?? false
                        onClicked: player.shuffle = !player.shuffle
                    }

                    CtrlBtn {
                        text: "\uF04A"
                        enabled: player?.canGoPrevious ?? false
                        onClicked: player?.previous()
                    }

                    CtrlBtn {
                        text: player?.playbackState === MprisPlaybackState.Playing ? "\uF04C" : "\uF04B"
                        enabled: player?.canTogglePlaying ?? false
                        big: true
                        onClicked: player?.togglePlaying()
                    }

                    CtrlBtn {
                        text: "\uF04E"
                        enabled: player?.canGoNext ?? false
                        onClicked: player?.next()
                    }

                    CtrlBtn {
                        text: "\uF01E"
                        active: player?.loopState !== MprisLoopState.None
                        enabled: player?.loopSupported ?? false
                        onClicked: {
                            if (player.loopState === MprisLoopState.None)
                                player.loopState = MprisLoopState.Track
                            else if (player.loopState === MprisLoopState.Track)
                                player.loopState = MprisLoopState.Playlist
                            else
                                player.loopState = MprisLoopState.None
                        }
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 5
                    visible: player?.volumeSupported ?? false

                    Text {
                        text: (player?.volume ?? 1) > 0 ? "\uF028" : "\uF026"
                        color: fg
                        font.pixelSize: 12
                    }

                    Item {
                        Layout.fillWidth: true
                        height: 6

                        Rectangle {
                            anchors.verticalCenter: parent.verticalCenter
                            width: parent.width
                            height: 4
                            radius: 2
                            color: surface
                        }

                        Rectangle {
                            anchors {
                                left: parent.left
                                verticalCenter: parent.verticalCenter
                            }
                            width: parent.width * (player?.volume ?? 1)
                            height: 4
                            radius: 2
                            color: accent
                            Behavior on width { NumberAnimation { duration: 100 } }
                        }

                        MouseArea {
                            anchors.fill: parent
                            enabled: player?.volumeSupported ?? false
                            cursorShape: Qt.PointingHandCursor
                            onClicked: mouse => {
                                if (player?.volumeSupported)
                                    player.volume = Math.max(0, Math.min(1, mouse.x / width))
                            }
                        }
                    }

                    Text {
                        text: player?.volume !== undefined ? Math.round(player.volume * 100) + "%" : ""
                        color: muted
                        font.pixelSize: 9
                        visible: text !== ""
                    }
                }
            }
        }
    }

    component CtrlBtn: Rectangle {
        property string text
        property bool active: false
        property bool big: false

        signal clicked()

        implicitWidth: big ? 38 : 30
        implicitHeight: big ? 38 : 30
        radius: 8
        color: ma.containsMouse ? win.hoverBg : "transparent"
        border.color: active ? win.accent : "transparent"
        border.width: active ? 1 : 0

        Behavior on color { ColorAnimation { duration: 150 } }

        Text {
            anchors.centerIn: parent
            text: parent.text
            color: parent.enabled ? (parent.active ? win.accent : win.fg) : win.muted
            font.pixelSize: parent.big ? 18 : 13
        }

        MouseArea {
            id: ma
            anchors.fill: parent
            hoverEnabled: true
            enabled: parent.enabled
            cursorShape: Qt.PointingHandCursor
            onClicked: parent.clicked()
        }
    }

    function formatTime(seconds) {
        if (isNaN(seconds) || seconds < 0) return "0:00"
        const total = Math.floor(seconds)
        const m = Math.floor(total / 60)
        const s = total % 60
        const h = Math.floor(m / 60)
        if (h > 0) return h + ":" + String(m % 60).padStart(2, "0") + ":" + String(s).padStart(2, "0")
        return m + ":" + String(s).padStart(2, "0")
    }
}
