const crypto = require("crypto");
const querystring = require("querystring");
const vnpayConfig = require("../config/vnpay.config");

class VNPayService {
  constructor() {
    this.vnp_TmnCode = vnpayConfig.vnp_TmnCode;
    this.vnp_HashSecret = vnpayConfig.vnp_HashSecret;
    this.vnp_Url = vnpayConfig.vnp_Url;
    this.vnp_ReturnUrl = vnpayConfig.vnp_ReturnUrl;
  }

  /**
   * Sắp xếp object theo key
   */
  sortObject(obj) {
    const sorted = {};
    const keys = Object.keys(obj).sort();
    keys.forEach((key) => {
      sorted[key] = obj[key];
    });
    return sorted;
  }

  /**
   * Tạo chữ ký HMAC SHA512
   */
  createSignature(data, secretKey) {
    const hmac = crypto.createHmac("sha512", secretKey);
    return hmac.update(Buffer.from(data, "utf-8")).digest("hex");
  }

  /**
   * Tạo URL thanh toán VNPay
   */
  createPaymentUrl(
    orderId,
    amount,
    orderInfo,
    ipAddr,
    locale = "vn",
    bankCode = ""
  ) {
    const date = new Date();
    const createDate = date.toISOString().slice(0, 19).replace(/[-:T]/g, "");

    let vnp_Params = {
      vnp_Version: "2.1.0",
      vnp_Command: "pay",
      vnp_TmnCode: this.vnp_TmnCode,
      vnp_Locale: locale,
      vnp_CurrCode: "VND",
      vnp_TxnRef: orderId,
      vnp_OrderInfo: orderInfo,
      vnp_OrderType: "other",
      vnp_Amount: amount * 100,
      vnp_ReturnUrl: this.vnp_ReturnUrl,
      vnp_IpAddr: ipAddr,
      vnp_CreateDate: createDate,
    };

    if (bankCode) {
      vnp_Params.vnp_BankCode = bankCode;
    }

    vnp_Params = this.sortObject(vnp_Params);

    // Build sign data WITHOUT encoding (VNPay requires raw values for signature)
    const signData = Object.keys(vnp_Params)
      .map((key) => `${key}=${vnp_Params[key]}`)
      .join("&");

    const secureHash = this.createSignature(signData, this.vnp_HashSecret);

    vnp_Params.vnp_SecureHash = secureHash;

    // Build final payment URL with encoding
    const paymentUrl =
      this.vnp_Url +
      "?" +
      Object.keys(vnp_Params)
        .map((key) => `${key}=${encodeURIComponent(vnp_Params[key])}`)
        .join("&");

    return paymentUrl;
  }

  /**
   * Xác thực phản hồi từ VNPay
   */
  verifyReturnUrl(query) {
    try {
      const secureHash = query.vnp_SecureHash;
      delete query.vnp_SecureHash;
      delete query.vnp_SecureHashType;

      const sortedParams = this.sortObject(query);
      const signData = querystring.stringify(sortedParams, { encode: false });
      const checkSum = this.createSignature(signData, this.vnp_HashSecret);

      const isVerified = secureHash === checkSum;
      const isSuccess = query.vnp_ResponseCode === "00";

      return {
        isSuccess,
        isVerified,
        vnp_TxnRef: query.vnp_TxnRef,
        vnp_Amount: query.vnp_Amount,
        vnp_ResponseCode: query.vnp_ResponseCode,
        vnp_TransactionNo: query.vnp_TransactionNo,
        vnp_BankCode: query.vnp_BankCode,
        vnp_PayDate: query.vnp_PayDate,
      };
    } catch (error) {
      console.error("Verify return URL error:", error);
      return {
        isSuccess: false,
        isVerified: false,
        error: error.message,
      };
    }
  }

  /**
   * Xác thực IPN (Instant Payment Notification)
   */
  verifyIpnCall(query) {
    try {
      const secureHash = query.vnp_SecureHash;
      delete query.vnp_SecureHash;
      delete query.vnp_SecureHashType;

      const sortedParams = this.sortObject(query);
      const signData = querystring.stringify(sortedParams, { encode: false });
      const checkSum = this.createSignature(signData, this.vnp_HashSecret);

      const isVerified = secureHash === checkSum;
      const isSuccess = query.vnp_ResponseCode === "00";

      return {
        isVerified,
        isSuccess,
        vnp_TxnRef: query.vnp_TxnRef,
        vnp_Amount: query.vnp_Amount,
        vnp_ResponseCode: query.vnp_ResponseCode,
      };
    } catch (error) {
      console.error("Verify IPN error:", error);
      return {
        isVerified: false,
        isSuccess: false,
        error: error.message,
      };
    }
  }

  /**
   * Query transaction status từ VNPay
   */
  async queryTransaction(orderId, transactionDate, ipAddr) {
    console.log("Query transaction not implemented for vnpay 0.3.0");
    throw new Error("Query transaction not supported");
  }

  /**
   * Hoàn tiền giao dịch
   */
  async refund(orderId, amount, transactionDate, user, ipAddr) {
    console.log("Refund not implemented for vnpay 0.3.0");
    throw new Error("Refund not supported");
  }
}

module.exports = new VNPayService();
