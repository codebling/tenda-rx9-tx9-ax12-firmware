
//!标签注释格式，支持注释内部有空格 但不能换行
//!标记信息仅用于js、css内，html文件不能使用
//!可自定义字段替换，key/value键值对，如 "tendawifi.com": "router.com"
//以 /*OEM_XXX_XXX|Default Value*/开头, XXX为A-Z_- 的字符
//以 /* OEMTAG */结束，且源码可读
//otherStyle存放ico和Logo信息，定制化时需要替换

//[]表示可填，其他选项为必填项
//  格式 /* OEM_XXX_XXX [|Default] */ Value /* OEMTAG [描述信息] */

//示例1：
// /*OEM_XXX_XXX|Default value*/Default value /* OEMTAG */

//示例2：
// /*OEM_XXX_XXX*/Default value /* OEMTAG 描述信息*/

exports.config = {
    "tendawifi.com": "tendawifi.com",
    "OEM_MAIN_ACTIVE_COLOR": {
        "value": "#ed7020",
        "remark": "风格主颜色"
    },
    "OEM_MAIN_SHADOW_COLOR": {
        "value": "rgba(237, 109, 0, .6)",
        "default": "rgba(237, 109, 0, .6)",
        "remark": "输入框阴影颜色"
    },
    "OEM_LANG_HOVER_COLOR": {
        "value": "#FFBA79",
        "default": "#FFBA79",
        "remark": "导航栏hover文字颜色"
    },
    "OEM_MAIN_NAV_COLOR": {
        "value": "#ffc46a",
        "default": "#ffc46a",
        "remark": "导航栏文字颜色"
    },
    "OEM_STATUS_DISABLED_COLOR": {
        "value": "#f29622",
        "default": "#f29622"
    },
    "OEM_CONFIG_HAS_APP": {
        "value": true,
        "default": true,
        "remark": "是否支持APP管理"
    },
    "OEM_CONFIG_HAS_EXTENDER": {
        "value": true,
        "default": true,
        "remark": "是否支持显示扩展器购买"
    }
};
    