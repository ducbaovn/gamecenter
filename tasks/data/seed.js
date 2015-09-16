module.exports = function (grunt) {
  grunt.registerTask('seed', 'A sample task that logs stuff.', function(arg1, arg2) {
    console.log(process.env);
  if (arguments.length === 0) {
    grunt.log.writeln(this.name + ", no args");
  } else {
    grunt.log.writeln(this.name + ", " + arg1 + " " + arg2);
  }
});
};
