qt_add_library(QuickStudioLogicHelper STATIC)
qt6_add_qml_module(QuickStudioLogicHelper
    URI "QtQuick.Studio.LogicHelper"
    VERSION "1.0"
    RESOURCE_PREFIX "/qt-project.org/imports"
    DESIGNER_SUPPORTED
    ${qds_qml_extra_args}
    QML_FILES
        BidirectionalBinding.qml
        RangeMapper.qml
        MinMaxMapper.qml
        StringMapper.qml
        OrOperator.qml
        AndOperator.qml
        NotOperator.qml
)

register_plugin(QuickStudioLogicHelper)
