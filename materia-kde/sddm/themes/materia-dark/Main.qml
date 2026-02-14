import QtQuick 2.8
import QtQuick.Controls 2.1
import QtGraphicalEffects 1.0
import QtQuick.Controls.Material 2.1
import "components"

Rectangle {
    width: 640
    height: 480
    LayoutMirroring.enabled: Qt.locale().textDirection === Qt.RightToLeft
    LayoutMirroring.childrenInherit: true

    TextConstants { id: textConstants }

    Loader {
        id: inputPanel
        property bool keyboardActive: false
        source: "components/VirtualKeyboard.qml"
    }

    Connections {
        target: sddm
        onLoginSucceeded: {}
        onLoginFailed: {
            password.placeholderText = textConstants.loginFailed
            password.placeholderTextColor = "#f44336"
            password.text = ""
            password.focus = true
            errorMsgContainer.visible = true
        }
    }

    Image {
        anchors.fill: parent
        fillMode: Image.PreserveAspectCrop
        Binding on source {
            when: config.background !== undefined
            value: config.background
        }
    }

    Rectangle {
        id: panel
        color: "#243447"
        height: 32
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
    }

    DropShadow {
        anchors.fill: panel
        horizontalOffset: 0
        verticalOffset: 3
        radius: 8.0
        samples: 17
        color: "#50000000"
        source: panel
    }

    Row {
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.rightMargin: 30
        anchors.topMargin: 5
        Item {
            Image {
                id: shutdown
                height: 22
                width: 22
                source: "images/system-shutdown.svg"
                fillMode: Image.PreserveAspectFit
                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onEntered: shutdown.source = "images/system-shutdown-hover.svg"
                    onExited: shutdown.source = "images/system-shutdown.svg"
                    onClicked: {
                        shutdown.source = "images/system-shutdown-pressed.svg"
                        sddm.powerOff()
                    }
                }
            }
        }
    }

    Row {
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.rightMargin: 60
        anchors.topMargin: 5
        Item {
            Image {
                id: reboot
                height: 22
                width: 22
                source: "images/system-reboot.svg"
                fillMode: Image.PreserveAspectFit
                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onEntered: reboot.source = "images/system-reboot-hover.svg"
                    onExited: reboot.source = "images/system-reboot.svg"
                    onClicked: {
                        reboot.source = "images/system-reboot-pressed.svg"
                        sddm.reboot()
                    }
                }
            }
        }
    }

    Row {
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.rightMargin: 70
        anchors.topMargin: 5
        Text {
            id: timelb
            text: Qt.formatDateTime(new Date(), "HH:mm")
            color: "#f0e4d0"
            font.pointSize: 11
        }
    }

    Timer {
        id: timetr
        interval: 500
        repeat: true
        onTriggered: timelb.text = Qt.formatDateTime(new Date(), "HH:mm")
    }

    Row {
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.rightMargin: 120
        anchors.topMargin: 4
        Text {
            id: kb
            color: "#f0e4d0"
            text: keyboard.layouts[keyboard.currentLayout].shortName
            font.pointSize: 11
        }
    }

    Row {
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.leftMargin: 10
        anchors.topMargin: 5
        Text {
            id: welcome
            text: textConstants.welcomeText.arg(sddm.hostName)
            color: "#f0e4d0"
            font.pointSize: 11
        }
    }

    Item {
        anchors.centerIn: parent
        width: dialog.width
        height: dialog.height

        Dialog {
            id: dialog
            closePolicy: Popup.NoAutoClose
            focus: true
            visible: true
            Material.theme: Material.Dark
            Material.accent: "#61aaff"

            Grid {
                columns: 1
                spacing: 10
                verticalItemAlignment: Grid.AlignVCenter
                horizontalItemAlignment: Grid.AlignHCenter

                Column {
                    Rectangle {
                        id: mask
                        width: 144
                        height: 144
                        radius: 100
                        visible: false
                    }
                    DropShadow {
                        anchors.fill: mask
                        width: mask.width
                        height: mask.height
                        horizontalOffset: 0
                        verticalOffset: 3
                        radius: 9.0
                        samples: 15
                        color: "#50000000"
                        source: mask
                    }

                    Image {
                        id: ava
                        width: 144
                        height: 144
                        fillMode: Image.PreserveAspectCrop
                        layer.enabled: true
                        layer.effect: OpacityMask { maskSource: mask }
                        source: "/var/lib/AccountsService/icons/" + user.currentText
                        onStatusChanged: {
                            if (status == Image.Error)
                                source = "images/.face.icon"
                        }
                    }
                }

                ComboBox {
                    id: user
                    height: 50
                    width: height * 7
                    model: userModel
                    textRole: "name"
                    currentIndex: userModel.lastIndex
                    delegate: MenuItem {
                        Material.theme: Material.Dark
                        Material.accent: "#61aaff"
                        width: ulistview.width
                        text: user.textRole ? (Array.isArray(user.model) ? modelData[user.textRole] : model[user.textRole]) : modelData
                        Material.foreground: user.currentIndex === index ? ulistview.contentItem.Material.accent : ulistview.contentItem.Material.foreground
                        highlighted: user.highlightedIndex === index
                        hoverEnabled: user.hoverEnabled
                        onClicked: {
                            user.currentIndex = index
                            ulistview.currentIndex = index
                            user.popup.close()
                            ava.source = "/var/lib/AccountsService/icons/" + user.currentText
                        }
                    }
                    popup: Popup {
                        Material.theme: Material.Dark
                        Material.accent: "#61aaff"
                        width: parent.width
                        height: parent.height * parent.count
                        implicitHeight: ulistview.contentHeight
                        margins: 0
                        contentItem: ListView {
                            id: ulistview
                            clip: true
                            anchors.fill: parent
                            model: user.model
                            spacing: 0
                            highlightFollowsCurrentItem: true
                            currentIndex: user.highlightedIndex
                            delegate: user.delegate
                        }
                    }
                }

                TextField {
                    id: password
                    height: 50
                    width: height * 7
                    echoMode: TextInput.Password
                    focus: true
                    placeholderText: textConstants.password
                    onAccepted: sddm.login(user.currentText, password.text, session.currentIndex)
                }

                ComboBox {
                    id: session
                    height: 50
                    width: height * 7
                    model: sessionModel
                    textRole: "name"
                    currentIndex: sessionModel.lastIndex
                    delegate: MenuItem {
                        Material.theme: Material.Dark
                        Material.accent: "#61aaff"
                        width: slistview.width
                        text: session.textRole ? (Array.isArray(session.model) ? modelData[session.textRole] : model[session.textRole]) : modelData
                        Material.foreground: session.currentIndex === index ? slistview.contentItem.Material.accent : slistview.contentItem.Material.foreground
                        highlighted: session.highlightedIndex === index
                        hoverEnabled: session.hoverEnabled
                        onClicked: {
                            session.currentIndex = index
                            slistview.currentIndex = index
                            session.popup.close()
                        }
                    }
                    popup: Popup {
                        Material.theme: Material.Dark
                        Material.accent: "#61aaff"
                        width: parent.width
                        height: parent.height * parent.count
                        implicitHeight: slistview.contentHeight
                        margins: 0
                        contentItem: ListView {
                            id: slistview
                            clip: true
                            anchors.fill: parent
                            model: session.model
                            spacing: 0
                            highlightFollowsCurrentItem: true
                            currentIndex: session.highlightedIndex
                            delegate: session.delegate
                        }
                    }
                }

                Button {
                    id: login
                    height: 50
                    width: height * 7
                    icon.source: "images/login.svg"
                    icon.width: 24
                    icon.height: 24
                    text: textConstants.login
                    font.bold: true
                    highlighted: true
                    onClicked: sddm.login(user.currentText, password.text, session.currentIndex)
                }
            }
        }
    }
}
