const { src, dest, series } = require('gulp');
const callback = require('gulp-custom-callback');
const fs = require('fs');
const {config} = require("../config");
let configObj = Object.assign({}, config);

function setConfig(str) {

    let regStr = `\\/\\*[ ]{0,}(OEM_[A-Z-_]+)[ ]{0,}(.*?)\\*\\/(.*?)(\\/\\*[ ]{0,}OEMTAG(.*?)\\*\\/)`;
    let reg = new RegExp(regStr, 'g');
    
    if(reg.test(str)) {
        
        str.replace(reg, function($0, $1, $2, $3, $4) {
            let defaultVal;
            if(configObj[$1] == undefined) {
                configObj[$1] = {};
                defaultVal = $2.slice(1);
                if(defaultVal == "true" ) {
                    defaultVal = true;
                    configObj[$1].value = true;
                } else if(defaultVal == "false") {
                    defaultVal = false;
                    configObj[$1].value = false;
                } else {
                    defaultVal = $2.slice(1);
                    configObj[$1].value = $3;
                }  
            }

            let regContent = /\/\*[ ]{0,}OEMTAG((.*?){0,})\*\//g; 
            let matchArr = regContent.exec($4);
            if($2 && configObj[$1].default == undefined) {
                configObj[$1].default = defaultVal;
            }
            if(matchArr && matchArr[1].trim()) {
                configObj[$1].remark = matchArr[1].trim();
            }
            return $0;
        });
    }
}

function initConfig() {
    return src(['./**/*.{css,js,html}', '!./node_modules/**', '!./gulp/**','!./gulpfile.js', '!./img/**', '!./fonts/**'])
        .pipe(callback(function(file, enc, cb) {
            setConfig(String(file.contents));
            file.contents = new Buffer(JSON.stringify(configObj));
            cb(null, file);
    }));
}

function writeFile(cb) {

    let str = `
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

exports.config = ${JSON.stringify(configObj, null, 4)};
    `;

    fs.writeFile('./gulp/oem_config.js', str, function(err) {
        if (err) {
            cb();
            throw (err);
        }
        cb();
     });
}

function getConfig(cb) {
    
    //写文件
    writeFile(cb);
   
}
  
exports.initConfig = series(initConfig, getConfig);