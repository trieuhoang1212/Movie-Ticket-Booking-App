const NodeCache = require("node-cache");

export class CacheService {
    routeCache: any


    constructor() {
        // standard ttl for 300s
        this.routeCache = new NodeCache({stdTTL: 300, checkperiod: 120});
    }

    addRouteCache(url, method, value) {
        // set this cache 5s for test
        this.routeCache.set(`${url}_${method}`, value, 5)
    }

    getCache(url, method) {

        return this.routeCache.get(`${url}_${method}`)
    }


}
