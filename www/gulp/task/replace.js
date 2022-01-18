
const { src, dest } = require('gulp');
const {dist} = require("../config");

const callback = require('gulp-custom-callback');

function replaceStr(str, reg, replaceText) {
	
	if(reg.test(str)) {
		str = str.replace(reg, function($0, $1, $2, $3, $4) {
			return $1 + replaceText + $4;
		});
	}

	return str;


}

/**
 * @description 文字替换
 * @param {*} str 传入的文件内容
 * @returns  返回替换后的文件字符串
 */
function replaceAll(str, config) {

	//配置文件属性替换为值
	for(let prop in config) {
		
		if(typeof config[prop] === "object") {
			let regStr;
			//匹配 /* OEM_XXX_XXX|Default Value */
			regStr = (`\\/\\*[ ]{0,}${escapeText(prop)}[ ]{0,}(\\|)?[ ]{0,}.*?[ ]{0,}\\*\\/`);
			
			//匹配 value /* OEMTAG */
			let reg = new RegExp('(' +  regStr + ')'+ '(.*?)(\\/\\*[ ]{0,}OEMTAG(.*?){0,}\\*\\/)', 'gi');
			let replaceText = config[prop].value != undefined ? config[prop].value : config[prop].default;
			str = replaceStr(str, reg, replaceText);
		} else {
			// let regStr = (`\\/\\*[ ]{0,}${escapeText(prop)}[ ]{0,}\\|[ ]{0,}${escapeText(config[prop])}[ ]{0,}\\*\\/`);
			// let reg = new RegExp('(' +  regStr + ')'+ '(.*?)(\\/\\*[ ]{0,}OEMTAG[ ]{0,}\\*\\/)', 'gi');
			// //替换带标签注释
			// str = replaceStr(str, reg, config[prop]);

			//文字直接替换，比如域名定义
			str = str.replace(new RegExp(escapeText(prop), 'gi'), config[prop]);
		}
	}

	return str;
}

function escapeText(str) {
	if(typeof str != "string") {
		return "";
	}
	return str.replace(/[\[\]\/\*\(\)\|\.]/g, function (s) {
        return "\\" + s;
    });
}

function replaceConfig() {
	 let {config} = require("../oem_config");
	
  	return src(['./**/*.{css,js,html,json}', '!./node_modules/**', '!./gulp/**','!./gulpfile.js', '!./img/**', '!./fonts/**'])
		.pipe(callback(function(file, enc, cb) {
			
			file.contents = new Buffer(replaceAll(String(file.contents), config));
			cb(null, file);
		}))
		.pipe(dest(dist));
}

exports.replaceConfig = replaceConfig;