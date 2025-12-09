import {ErrorResponse} from "./errorModel";
import {AuthenticationError} from "../authentication/authentication.service";
import {constants} from "http2";
import e from "express";
const {MessageCode} = require('./messageCode');
const {HttpStatusCode} = require('./httpStatusCode');

function handleError(err: any, req: any, res: any, next: any) {
    console.log('-- Going to handle exception --')
    console.log(err)

    if (err instanceof AuthenticationError) {
        res.status(401).json(err);
    }
    else {
        const errorBody: ErrorResponse = {error: true, code: MessageCode.INTERNAL_ERROR.name, message: MessageCode.INTERNAL_ERROR.content};
        res.status(HttpStatusCode.INTERNAL).json(errorBody);
    }
}

module.exports = {
    handleError
}
