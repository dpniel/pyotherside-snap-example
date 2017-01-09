import QtQuick 2.4
import QtQuick.Window 2.1
import Ubuntu.Components 1.3
import PreMailer 1.0

Window {
    id: window
    width: units.gu(50)
    height: units.gu(50)
    visible: true

    MainView {
        anchors.fill: window.contentItem
        Page {
            id: page
            header: PageHeader {
                title: "PreMailer example"
            }

            PreMailer {
                id: premailer
                onTransformed: {
                    console.log(text)
                    resultLabel.text = text
                }
            }

            Item {
                id: contentArea
                anchors {
                    left: parent.left
                    top: page.header.bottom
                    right: parent.right
                    bottom: parent.bottom
                }
                Column {
                    anchors {
                        left: parent.left
                        top: parent.top
                        right: parent.right
                    }
                    Label {
                        text: "HTML Input with <style> tags in the header"
                    }

                    TextArea {
                        height: contentArea.height / 2 - units.gu(4)
                        width: parent.width
                        onTextChanged: premailer.transform(text)
                    }
                    Label {
                        text: "Result should have style attributes inline."
                    }

                    TextArea {
                        id: resultLabel
                        height: contentArea.height / 2 - units.gu(4)
                        width: parent.width
                        readOnly: true
                    }
                }
            }
        }
    }
}
