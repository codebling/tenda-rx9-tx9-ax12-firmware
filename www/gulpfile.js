const {
	series,
	task,
	watch
} = require('gulp');

//替换文件
const {
	replaceConfig
} = require("./gulp/task/replace");

//拷贝文件
const {
	copyFile
} = require("./gulp/task/copy");

//拷贝图片
const {
	copyImg
} = require("./gulp/task/image");

//拷贝gulp文件
const {
	copyBuildFile
} = require("./gulp/task/build");

//生成配置文件
const {
	initConfig
} = require("./gulp/task/init");

//配置文件任务
task('init', series(initConfig));

//编译任务
task('default', series(replaceConfig, copyFile, copyImg, copyBuildFile));

//监听
// task('watch', function () {
// 	watch('./**/*.*', series(replaceConfig, copyFile, copyImg, copyBuildFile));
// });