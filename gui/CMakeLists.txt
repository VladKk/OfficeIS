find_package(Qt6 6.2 COMPONENTS Qml Core Quick Widgets REQUIRED)

set_source_files_properties(Style.qml PROPERTIES QT_QML_SINGLETON_TYPE TRUE)
set_source_files_properties(Global.qml PROPERTIES QT_QML_SINGLETON_TYPE TRUE)

qt_add_qml_module(gui
    URI gui
    VERSION 1.0
    STATIC
    QML_FILES
        main.qml
        Global.qml
        Style.qml
        pages/AppAbout.qml
        pages/StartPage.qml
        pages/MyDocs.qml
        pages/MyEquipment.qml
        pages/MyProjects.qml
        pages/MyTeam.qml
        pages/account/ForgetPass.qml
        pages/account/LoginUser.qml
        pages/account/RegisterUser.qml
        pages/account/SetNewPass.qml
        page_models/AppElements.qml
        widgets/BaseButton.qml
        widgets/BaseCheckBox.qml
        widgets/BaseComboBox.qml
        widgets/BaseDateField.qml
        widgets/BaseMenu.qml
        widgets/BaseScrollIndicator.qml
        widgets/BaseTask.qml
        widgets/EquipmentDialog.qml
        widgets/ClearSymbol.qml
        widgets/ContextMenu.qml
        widgets/EchoModeSymbol.qml
        widgets/EditFieldSymbol.qml
        widgets/FormField.qml
        widgets/MenuTile.qml
        widgets/Notification.qml
        widgets/PersonalSettingsPopUp.qml
        widgets/ProjectDialog.qml
        widgets/TaskDialog.qml
        widgets/TitleBarButton.qml
        widgets/WarningSymbol.qml
    RESOURCES
        images/windowControls/window-close.png
        images/windowControls/window-maximize.png
        images/windowControls/window-minimize.png
        images/windowControls/window-restore.png
        images/windowControls/window-settings.png
        images/appControls/logout.png
        images/appControls/home.png
        images/appControls/apps-grid.png
        images/appControls/search.png
        images/symbols/info.png
        images/symbols/edit.png
        images/symbols/database.png
        images/symbols/wrench.png
        images/symbols/magic_wand.png
        images/symbols/agent.png
        images/symbols/peace_palm.png
        images/symbols/merge.png
        images/symbols/refresh.png
        images/symbols/close.png
        images/symbols/forbidden.png
        images/symbols/eye.png
        images/symbols/eye-slash.png
        images/symbols/lock.png
        images/symbols/lock-open.png
        images/symbols/user.png
        images/symbols/plus.png
        images/symbols/pencil.png
        images/symbols/cogs.png
        images/symbols/settings.png
        images/symbols/answer.png
        images/symbols/checkmark.png
        images/symbols/spok.png
        images/symbols/misc.png
        images/symbols/close_round.png
        images/appIcon.png
        images/close_icon.jpeg
        images/progress_bars-dark.gif
        images/progress_bars-light.gif
        images/progress_blocks-dark.gif
        images/progress_blocks-light.gif
        fonts/fontawesome-webfont.ttf
    PLUGIN_TARGET gui
)

target_link_libraries(gui PUBLIC Qt6::Qml Qt6::Core Qt6::Quick Qt6::Widgets)
