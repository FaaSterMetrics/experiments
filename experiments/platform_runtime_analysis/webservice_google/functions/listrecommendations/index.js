const lib = require('@faastermetrics/lib')

/**
 *
 * Responds with an appropriate list of product recommendations.
 *
 * Example Payload: {
 *   "userId": "USER12",
 *   "productIds": ["QWERTY", "NOTAVAILABLE"]
 * }
 *
 * Example Response: {
 *   "productIds": ["QWERTY"]
 * }
 *
 */

module.exports = lib.serverless.rpcHandler(async (event, ctx) => {
  const requestedIDs = event.productIds
  if (!requestedIDs) {
    return { error: 'Wrong payload.' }
  }
  const availableProducts = (await ctx.call('listproducts', {})).products
  if (availableProducts === undefined) {
    return { error: 'Cannot receive product list.' }
  }
  const availableIDs = []
  for (const key in availableProducts) {
    availableIDs.push(availableProducts[key].id)
  }

  const suitableIDs = requestedIDs.filter(id => availableIDs.includes(id))
  // We always want to have at most 7 recommendations
  while (suitableIDs.length > 7) {
    const randomIndex = Math.floor(Math.random() * suitableIDs.length)
    suitableIDs.splice(randomIndex, 1)
  }
  return { productIds: suitableIDs }
})
