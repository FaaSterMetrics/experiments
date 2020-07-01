const lib = require('@faastermetrics/lib')

/*
bit order: 0b[red][yellow][green]
{
  lights: ["red","green", "yellow"],
  blink: false
}
*/

module.exports = lib.serverless.rpcHandler(
  { db: 'redis' },
  async (event, ctx) => {
    const light = await ctx.db.get('lightcalculation:light')
    const blink = (await ctx.db.set('lightcalculation:blink')) || true
    return {
      lights: light,
      blink
    }
  }
)
