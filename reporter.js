const mocha = require('mocha');
const fs = require('fs');

module.exports = MyReporter;

function MyReporter(runner) {
  mocha.reporters.Base.call(this, runner);

  let passes = 0;
  let failures = 0;

  runner.on('pass', () => {
    passes++;
  });

  runner.on('fail', () => {
    failures++;
  });

  runner.on('end', () => {
    const grade = passes / (passes + failures);
    fs.writeFileSync('grade.json', JSON.stringify({ grade }));
  });
}
