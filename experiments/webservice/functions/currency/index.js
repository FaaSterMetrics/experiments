const lib = require('@faastermetrics/lib')

// Exchange rates never change in the real world, so this is ok.
const EUR_RATES = {
  EUR: 1.0,
  CAD: 1.5231,
  HKD: 8.3693,
  ISK: 157.5,
  PHP: 54.778,
  DKK: 7.4576,
  HUF: 354.7,
  CZK: 27.589,
  AUD: 1.6805,
  RON: 4.84,
  SEK: 10.6695,
  IDR: 16127.82,
  INR: 81.9885,
  BRL: 6.3172,
  RUB: 79.6208,
  HRK: 7.5693,
  JPY: 115.53,
  THB: 34.656,
  CHF: 1.0513,
  SGD: 1.5397,
  PLN: 4.565,
  BGN: 1.9558,
  TRY: 7.4689,
  CNY: 7.6759,
  NOK: 11.0568,
  NZD: 1.8145,
  ZAR: 20.0761,
  USD: 1.0798,
  MXN: 25.8966,
  ILS: 3.8178,
  GBP: 0.88738,
  KRW: 1332.6,
  MYR: 4.6982
}

function getRate (from, to) {
  return EUR_RATES[to] / EUR_RATES[from]
}

function applyRate (units, nanos, rate) {
  const rawUnits = units * rate
  const newUnits = Math.floor(rawUnits)

  const addedNanos = (rawUnits - newUnits) * 1e9
  const newNanos = Math.floor(nanos * rate + addedNanos)

  const addedUnits = Math.floor(newNanos / 999999999)

  const finalUnits = newUnits + addedUnits
  const finalNanos = Math.floor(newNanos % 999999999)

  return [finalUnits, finalNanos]
}

module.exports = lib.serverless.router(router => {
  /**
   * Exchange the given currency by calling a POST request against the currency
   * endpoint with a JSON payload. (Content-Type: application/json)
   *
   * Units are the whole units of the given currency. Nanos are 10^-9 units of
   * the given currency, eg 0.5 USD are 500,000,000 Nanos.
   *
   * Ex Payload Body: {
   *   "units": 100,
   *   "nanos": 500000000,
   *   "from": "PHP",
   *   "to": "RUB"
   * }
   *
   * Response: {
   *   "units": 146,
   *   "nanos": 78542481,
   *   "currency": "RUB"
   *
   * }
   */
  router.post('/', (ctx, next) => {
    const { units, nanos, from, to } = ctx.request.body
    const rate = getRate(from, to)
    const [convUnits, convNanos] = applyRate(units, nanos, rate)

    // carry over fractions from units
    ctx.body = { units: convUnits, nanos: convNanos, currency: to }
  })

  router.get('/call/:provider', async (ctx, next) => {
    ctx.body = await lib.call(ctx.params.provider, 'test2')
  })

  router.attachEventHandler(event => {
    lib.log({ event })
    return { ok: true, from: 'test' }
  })
})
