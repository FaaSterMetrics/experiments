const lib = require('@faastermetrics/lib')

/**
 *
 * Responds with an appropriate list of product recommendations.
 *
 * Example Payload: {
 *   "userID": "USER12",
 *   "productIDs": ["QWERTY", "NOTAVAILABLE"]
 * }
 *
 * Example Response: {
 *   "productIDs": ["QWERTY"]
 * }
 *
 */

module.exports = lib.serverless.rpcHandler(async event => {
  const requestedIDs = event.productIDs
  if (requestedIDs === undefined) {
    return { error: 'Wrong payload.' }
  }
  const availableProducts = (await lib.call('listproducts', {})).products
  console.log(availableProducts)
  if (availableProducts === undefined) {
    return { error: 'Cannot receive product list.' }
  }
  const availableIDs = []
  for (const key in availableProducts) {
    availableIDs.push(availableProducts[key].id)
  }
  // console.log(availableIDs)

  const suitableIDs = requestedIDs.filter(id => !availableIDs.includes(id))
  // We always want to have at most 7 recommendations
  while (suitableIDs.length > 7) {
    const randomIndex = Math.floor(Math.random() * suitableIDs.length)
    suitableIDs.splice(randomIndex, 1)
  }
  return { productIDs: suitableIDs }
})
