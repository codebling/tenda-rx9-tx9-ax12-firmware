//当浏览器的语言环境为当前不支持的语言时会出错，因此注释掉。
//且当前浏览器语言不支持时，b28_async.js已经在getLang中处理为默认语言,即defaultLang
/*var lang = B.getLang();
if (lang != B.options.defaultLang) {
    $.ajax({
        "type": "get",
        "url": "/lang/" + lang + "/translate.json" + "?" + Math.random(),
        "async": true,
        "cache": false,
        "dataType": "text",
        "success": function (data) {
            B.setMsg($.parseJSON(data));
            B.translatePage();
        }
    })
} else {
    document.documentElement.style.display = '';
}

document.documentElement.className += " lang-" + lang;*/