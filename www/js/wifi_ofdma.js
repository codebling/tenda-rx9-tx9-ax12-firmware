var wrlBfInfo;
var pageview = R.pageView({ //页面初始化
    init: function () {
        top.loginOut();
        top.$(".main-dailog").removeClass("none");
        top.$(".save-msg").addClass("none");
    }
});
var pageModel = R.pageModel({
    getUrl: "goform/WifiOfdmaGet",
    setUrl: "goform/WifiOfdmaSet",
    translateData: function (data) {
        var newData = {};
        newData.wrlBf = data;
        return newData;
    },
    afterSubmit: callback
});

/************************/
var view = R.moduleView({
    initEvent: initEvent
});
var moduleModel = R.moduleModel({
    initData: initValue,
    getSubmitData: function () {
        return "ofdmaEn=" + $("#ofdmaEn").val();
    }
});

//模块注册
R.module("wrlBf", view, moduleModel);

function initEvent() {
    $("#ofdmaEn").on("click", function () {
        if ($(this).hasClass("btn-off")) {
            if (!confirm(_("Some OFDMA terminals have compatibility problems, which may cause unknown problems. It is recommended to open them carefully!"))) {
                return;
            }
        }
        if ($(this).hasClass("btn-on")) {
            $(this).attr("class", "btn-off");
            $(this).val(0);
            changeOfdma(0)
        } else {
            $(this).attr("class", "btn-on");
            $(this).val(1);
            changeOfdma(1)
        }
        wrlBfInfo.submit();
        if ($("#ofdmaEn").val() === "1") {
            $("#waitingTip").html(_("Enabling OFDMA")).removeClass("none");
        } else {
            $("#waitingTip").html(_("Shutting down OFDMA")).removeClass("none");
        }
    });
}

function callback(str) {
    if (!top.isTimeout(str)) {
        return;
    }
    var num = $.parseJSON(str).errCode;
    //top.showSaveMsg(num);
    if (num == 0) {
        top.wrlInfo.initValue();
        setTimeout(function () {
            pageModel.update();
            $("#waitingTip").html(" ").addClass("none");
        }, 2000);
    }
}

function initValue(obj) {
   $("#ofdmaEn").attr("class", (obj.ofdmaEn === "1") ? "btn-on" : "btn-off");
    changeOfdma(obj.ofdmaEn);
}

function changeOfdma(data){
    if (data === "0") {
        $(".container").addClass('none');
    } else {
        $(".container").removeClass('none');
    }
}

window.onload = function () {
    wrlBfInfo = R.page(pageview, pageModel);
};