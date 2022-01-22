const mocha = require('mocha');
const fs = require('fs');
const submitted_at = process.env.npm_config_submitted_at;

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
    let grade;

    // if complete failure and/or non-attempt, assign 0 to avoid NaN from division by zero
    if (!passes || !(passes + failures)) {
      grade = 0;
    } else {
      grade = ((passes / (passes + failures)) * 100).toFixed(1);
    }

    fs.writeFileSync(
      'grade.json',
      JSON.stringify({
        grade,
        submitted_at: new Date(+submitted_at * 1000).toLocaleString(),
      })
    );
  });
}
