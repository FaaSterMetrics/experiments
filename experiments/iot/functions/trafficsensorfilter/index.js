const lib = require('@faastermetrics/lib')

/*
input:
{
 carDirection: {
  plate: string
  direction: 0-4
  speed: float
 }
}
*/

module.exports = lib.serverless.rpcHandler(async (event, ctx) => {
  const { carDirection } = event

  if (!carDirection.plate.startsWith('B')) return {}

  await ctx.call('movementplan', {
    carDirection
  })
  return {}
})
