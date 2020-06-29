const lib = require('@faastermetrics/lib')

/*
bit order: 0b[red][yellow][green]
{
  lights: 0b000,
  blink: false
}
*/

module.exports = lib.serverless.rpcHandler(async (event, ctx) => {
  return {
    lights: 0b000,
    blink: false
  }
})
