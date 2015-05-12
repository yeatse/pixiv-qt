import QtQuick 1.1

QtObject {
    id: psettings;

    property string username: utility.getValue("username", "");
    onUsernameChanged: utility.setValue("username", username);

    property string password: Qt.atob(utility.getValue("password", ""));
    onPasswordChanged: utility.setValue("password", Qt.btoa(password));

    property variant userData: utility.getValue("userData", {})||{};
    onUserDataChanged: utility.setValue("userData", userData);

    property string imageFolder: utility.getValue("imageFolder", "/home/user/MyDocs/Pictures/pixiv");
    onImageFolderChanged: utility.setValue("imageFolder", imageFolder);
}
