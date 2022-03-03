'use strict'

module.exports = {

  newStats: () => {
    return new Map();
  },

  makeCollector: (txGasStats) => {
    return (context, tx) => {
      if (txGasStats.has(context)) {
        const samples = txGasStats.get(context);
        samples.push(tx.receipt.gasUsed);
      } else {
        const samples = [tx.receipt.gasUsed];
        txGasStats.set(context, samples);
      }
    }
  },

  toConsoleLog: (txGasStats) => {
    const min = (arr) => {
      return arr.reduce(( accumulator, currentValue ) => Math.min(accumulator, currentValue));
    };
    const max = (arr) => {
      return arr.reduce(( accumulator, currentValue ) => Math.max(accumulator, currentValue));
    };
    const sum = (arr) => {
      return arr.reduce(( accumulator, currentValue ) => accumulator + currentValue, 0);
    };
    const mean = (arr) => {
      return sum(arr) / arr.length;
    };
    const sample_stddev = (arr, m) => {
      if (arr.length < 2) return 0;
      const sum_of_sq_diffs = sum(arr.map(s => Math.pow(s - m, 2)));
      return Math.sqrt(sum_of_sq_diffs / (arr.length - 1));
    };

    for (var [context, samples] of txGasStats.entries()) {
      console.log('gasUsed ' + context + ' (samples = ' + samples.length + ')');
      console.log('  min. = ' + min(samples));
      console.log('  max. = ' + max(samples));
      const m = mean(samples);
      console.log('  avg. = ' + Math.round(m));
      console.log('  dev. = ' + Math.round(sample_stddev(samples, m)));
      console.log('  sum. = ' + samples.reduce((a, b) => a + b));
    }
  },
};