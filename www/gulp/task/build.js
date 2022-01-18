const {
  src,
  dest,
  series
} = require('gulp');
const {
  dist
} = require("../config");

function copyGulpFile() {
  return src(['./gulp/**'])
    .pipe(dest(dist + '/gulp'));
}

function copyBuildFile() {
  return src(['./gulpfile.js', './package.json'])
    .pipe(dest(dist));
}


exports.copyBuildFile = series(copyBuildFile, copyGulpFile);